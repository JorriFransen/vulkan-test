const std = @import("std");
const builtin = @import("builtin");
const platform = @import("platform");
const vk = @import("vulkan");
const root = @import("root");
const f = @import("externFn").externFn;

const assert = std.debug.assert;

const Window = platform.Window;
const x = platform.x;
const glfw = platform.glfw;

const dlog = Window.dlog;
const elog = Window.elog;

pub fn initSystem(options: Window.InitSystemOptions) Window.InitSystemError!void {
    const wayland_support = glfw.glfwPlatformSupported(.WAYLAND) == glfw.TRUE;
    const x11_support = glfw.glfwPlatformSupported(.X11) == glfw.TRUE;
    const win32_support = glfw.glfwPlatformSupported(.WIN32) == glfw.TRUE;

    var glfw_api = options.glfw_api;
    if (glfw_api == .default) {
        if (builtin.os.tag == .windows) {
            glfw_api = .win32;
        } else if (wayland_support) {
            glfw_api = .wayland;
        } else glfw_api = .x11;
    }
    const supported = switch (glfw_api) {
        .default => unreachable,
        .win32 => win32_support,
        .wayland => wayland_support,
        .x11 => x11_support,
    };

    if (!supported) {
        elog("Invalid glfw window api: {s}", .{@tagName(glfw_api)});
        return error.InvalidGLFWWindowApi;
    }

    const glfw_platform = switch (glfw_api) {
        else => {
            @panic("Expected .wayland or .x11 at this point!");
        },
        .win32 => glfw.Platform.WIN32,
        .wayland => glfw.Platform.WAYLAND,
        // .wayland => glfw.Platform.X11,
        .x11 => glfw.Platform.X11,
    };

    glfw.glfwInitHint(glfw.PLATFORM, @intFromEnum(glfw_platform));
    dlog("using glfw platform: {s}", .{@tagName(glfw_platform)});

    if (glfw.glfwInit() == 0) {
        elog("glfwInit() failed...", .{});

        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });

        return error.nativeInitFailed;
    }
}

pub fn deinitSystem() void {
    glfw.glfwTerminate();
}

handle: ?*glfw.GLFWwindow = null,
new_fb_size: ?struct { c_int, c_int } = null,

framebuffer_resize_callback: ?Window.FrameBufferResizeCallback = null,
key_callback: ?Window.KeyCallback = null,

pub fn open(this: *@This(), title: [:0]const u8) Window.OpenError!void {
    glfw.glfwWindowHint(glfw.CLIENT_API, glfw.NO_API);

    glfw.glfwWindowHintString(glfw.WAYLAND_APP_ID, "my_app_id");

    var handle: *glfw.GLFWwindow = undefined;

    if (glfw.glfwCreateWindow(800, 600, title, null, null)) |h| {
        handle = h;
    } else {
        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });
        return error.NativeCreateFailed;
    }

    const glfw_platform = glfw.glfwGetPlatform();
    dlog("glfw platform: {}", .{glfw_platform});

    _ = glfw.glfwSetKeyCallback(handle, keyCallback);
    _ = glfw.glfwSetFramebufferSizeCallback(handle, framebufferResizeCallback);

    glfw.glfwSetWindowUserPointer(handle, this);

    this.* = .{
        .handle = handle,
        .new_fb_size = null,
    };
}

pub fn close(this: *const @This()) void {
    glfw.glfwDestroyWindow(this.handle);
}

pub fn shouldClose(this: *const @This()) bool {
    const res = glfw.glfwWindowShouldClose(this.handle);
    return res != 0;
}

pub fn requestClose(this: *@This()) void {
    glfw.glfwSetWindowShouldClose(this.handle, 1);
}

pub fn pollEvents(this: *@This()) void {
    glfw.glfwPollEvents();
    this.handleEvents();
}

pub fn waitEvents(this: *@This()) void {
    glfw.glfwWaitEvents();
    this.handleEvents();
}

fn handleEvents(this: *@This()) void {
    if (this.new_fb_size) |s| {
        if (this.framebuffer_resize_callback) |cb| {
            const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", this);
            assert(@as(*@This(), @ptrCast(impl_ptr)) == this);
            const window: *Window = @fieldParentPtr("impl", impl_ptr);
            cb.fun(window, s[0], s[1], cb.user_data);
        }
        this.new_fb_size = null;
    }
}

pub fn requiredVulkanInstanceExtensions() error{VulkanApiUnavailable}![]const [*:0]const u8 {
    assert(glfw.glfwVulkanSupported() == 1);
    var count: u32 = undefined;
    const ext = glfw.glfwGetRequiredInstanceExtensions(&count) orelse return error.VulkanApiUnavailable;
    return @as([]const [*:0]const u8, @ptrCast(ext[0..count]));
}

pub fn createVulkanSurface(this: *const @This(), instance: vk.Instance) Window.CreateVulkanSurfaceError!vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;
    if (glfw.glfwCreateWindowSurface(instance, this.handle, null, &surface) != .SUCCESS) {
        elog("glfwCreateWindowSurface failed!", .{});
        return error.NativeCreateSurfaceFailed;
    }
    return surface;

    // var surface: vk.SurfaceKHR = undefined;
    // dlog("createVulkanSurface()", .{});
    //
    // const display = glfw.glfwGetX11Display();
    // dlog("Got x11 display!", .{});
    // const connection = x.getXCBConnection(display);
    // dlog("Got xcb connection!", .{});
    //
    // const create_info = vk.XcbSurfaceCreateInfoKHR{
    //     .sType = .XCB_SURFACE_CREATE_INFO_KHR,
    //     .connection = connection,
    //     .window = @intCast(glfw.glfwGetX11Window(this.handle)),
    // };
    //
    // if (vk.createXcbSurfaceKHR(instance, &create_info, null, &surface) != .SUCCESS) {
    //     elog("glfwCreateWindowSurface failed!", .{});
    //     return error.Vulkan_Surface_Creation_Failed;
    // }
    //
    // return surface;

    // var surface: vk.SurfaceKHR = undefined;
    // const create_info = vk.XlibSurfaceCreateInfoKHR{
    //     .sType = .XLIB_SURFACE_CREATE_INFO_KHR,
    //     .dpy = glfw.glfwGetX11Display(),
    //     .window = glfw.glfwGetX11Window(this.handle),
    // };
    //
    // if (vk.createXlibSurfaceKHR(instance, &create_info, null, &surface) != .SUCCESS) {
    //     elog("glfwCreateWindowSurface failed!", .{});
    //     return error.Vulkan_Surface_Creation_Failed;
    // }
    //
    // return surface;
}

pub fn framebufferSize(this: *const @This()) Window.Size {
    var width: c_int = undefined;
    var height: c_int = undefined;
    glfw.glfwGetFramebufferSize(this.handle, &width, &height);
    return .{ .width = width, .height = height };
}

pub fn setFramebufferResizeCallback(this: *@This(), callback: Window.FrameBufferResizeCallback) void {
    this.framebuffer_resize_callback = callback;
}

pub fn setKeyCallback(this: *@This(), callback: Window.KeyCallback) void {
    this.key_callback = callback;
}

fn keyCallback(gwindow: ?*glfw.GLFWwindow, gkey: glfw.Key, scancode: c_int, gaction: glfw.Action, mods: c_int) callconv(.C) void {
    _ = mods;

    const action: platform.KeyAction = switch (gaction) {
        .release => .release,
        .press => .press,
        .repeat => .repeat,
    };

    const impl: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(gwindow)));
    assert(gwindow == impl.handle);

    if (impl.key_callback) |cb| {
        const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", impl);
        assert(@as(*@This(), @ptrCast(impl_ptr)) == impl);
        const this: *Window = @fieldParentPtr("impl", impl_ptr);
        cb.fun(this, gkey, action, scancode, cb.user_data);
    }
}

fn framebufferResizeCallback(gwindow: ?*glfw.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    const this: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(gwindow)));
    assert(gwindow == this.handle);

    this.new_fb_size = .{ width, height };
}
