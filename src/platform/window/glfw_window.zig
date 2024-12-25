const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const f = @import("externFn").externFn;
const platform = @import("platform");
const Window = platform.Window;
const x = platform.x;
const glfw = platform.glfw;
const vk = @import("vulkan");

const root = @import("root");

const log = std.log.scoped(.window);
const dlog = log.debug;
const elog = log.err;
const ilog = log.info;

pub fn initSystem() Window.InitSystemError!void {
    const wayland_support = glfw.glfwPlatformSupported(.WAYLAND) == glfw.TRUE;
    const x11_support = glfw.glfwPlatformSupported(.X11) == glfw.TRUE;

    dlog("glfw wayland support: {}", .{wayland_support});
    dlog("glfw x11 support: {}", .{x11_support});

    var glfw_api = root.cmd_line_options.glfw_window_api;
    switch (glfw_api) {
        .default => {
            if (wayland_support) {
                glfw_api = .wayland;
            } else glfw_api = .x11;
        },
        .win32 => {
            elog("Invalid glfw window api: {s}", .{@tagName(glfw_api)});
            return error.InvalidGLFWWindowApi;
        },
        .wayland => assert(wayland_support),
        .x11 => assert(x11_support),
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

pub fn open(ptr: *anyopaque, title: [:0]const u8) Window.OpenError!void {
    const impl: *@This() = @ptrCast(@alignCast(ptr));
    const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", impl);
    assert(@as(*@This(), @ptrCast(impl_ptr)) == impl);
    const this: *Window = @fieldParentPtr("impl", impl_ptr);

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

    dlog("created glfw window", .{});

    const glfw_platform = glfw.glfwGetPlatform();
    dlog("glfw platform: {}", .{glfw_platform});

    _ = glfw.glfwSetKeyCallback(handle, keyCallback);
    _ = glfw.glfwSetFramebufferSizeCallback(handle, framebufferResizeCallback);

    glfw.glfwSetWindowUserPointer(handle, this);

    impl.* = .{
        .handle = handle,
        .new_fb_size = null,
    };
}

pub fn close(ptr: *const anyopaque) void {
    const impl: *const @This() = @ptrCast(@alignCast(ptr));

    glfw.glfwDestroyWindow(impl.handle);
}

pub fn shouldClose(ptr: *const anyopaque) bool {
    const impl: *const @This() = @ptrCast(@alignCast(ptr));

    const res = glfw.glfwWindowShouldClose(impl.handle);
    return res != 0;
}

pub fn requestClose(ptr: *anyopaque) void {
    const impl: *const @This() = @ptrCast(@alignCast(ptr));
    glfw.glfwSetWindowShouldClose(impl.handle, 1);
}

pub fn pollEvents(ptr: *anyopaque) void {
    const impl: *@This() = @ptrCast(@alignCast(ptr));

    glfw.glfwPollEvents();
    impl.handleEvents();
}

pub fn waitEvents(ptr: *anyopaque) void {
    const impl: *@This() = @ptrCast(@alignCast(ptr));
    glfw.glfwWaitEvents();
    impl.handleEvents();
}

fn handleEvents(impl: *@This()) void {
    if (impl.new_fb_size) |s| {
        const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", impl);
        assert(@as(*@This(), @ptrCast(impl_ptr)) == impl);
        const this: *Window = @fieldParentPtr("impl", impl_ptr);

        if (this.framebuffer_resize_callback) |cb| {
            cb.fun(this, s[0], s[1], cb.user_data);
        }
        impl.new_fb_size = null;
    }
}

pub fn framebufferSize(ptr: *const anyopaque, width: *i32, height: *i32) void {
    const impl: *const @This() = @ptrCast(@alignCast(ptr));
    glfw.glfwGetFramebufferSize(impl.handle, width, height);
}

pub fn requiredVulkanInstanceExtensions() error{VulkanApiUnavailable}![]const [*:0]const u8 {
    assert(glfw.glfwVulkanSupported() == 1);
    var count: u32 = undefined;
    const ext = glfw.glfwGetRequiredInstanceExtensions(&count) orelse return error.VulkanApiUnavailable;
    return @as([]const [*:0]const u8, @ptrCast(ext[0..count]));
}

pub fn createVulkanSurface(ptr: *const anyopaque, instance: vk.Instance) Window.CreateVulkanSurfaceError!vk.SurfaceKHR {
    const impl: *const @This() = @ptrCast(@alignCast(ptr));

    var surface: vk.SurfaceKHR = undefined;
    if (glfw.glfwCreateWindowSurface(instance, impl.handle, null, &surface) != .SUCCESS) {
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

fn keyCallback(gwindow: ?*glfw.GLFWwindow, gkey: glfw.Key, scancode: c_int, gaction: glfw.Action, mods: c_int) callconv(.C) void {
    _ = mods;

    const action: platform.KeyAction = switch (gaction) {
        .release => .release,
        .press => .press,
        .repeat => .repeat,
    };

    const impl: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(gwindow)));
    assert(gwindow == impl.handle);
    const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", impl);
    assert(@as(*@This(), @ptrCast(impl_ptr)) == impl);
    const this: *Window = @fieldParentPtr("impl", impl_ptr);

    if (this.key_callback) |cb| cb.fun(this, gkey, action, scancode, cb.user_data);
}

fn framebufferResizeCallback(gwindow: ?*glfw.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    const this: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(gwindow)));
    assert(gwindow == this.handle);

    this.new_fb_size = .{ width, height };
}
