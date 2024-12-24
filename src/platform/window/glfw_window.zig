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

pub fn initSystem() !void {
    const wayland_support = glfw.glfwPlatformSupported(.WAYLAND) == glfw.TRUE;
    const x11_support = glfw.glfwPlatformSupported(.X11) == glfw.TRUE;

    dlog("glfw wayland support: {}", .{wayland_support});
    dlog("glfw x11 support: {}", .{x11_support});

    var api = root.cmd_line_options.glfw_window_api;
    switch (api) {
        .default => {
            if (wayland_support) {
                api = .wayland;
            } else api = .x11;
        },
        .win32 => {
            elog("Invalid glfw window api: {s}", .{@tagName(api)});
            return error.InvalidGLFWWindowApi;
        },
        .wayland => assert(wayland_support),
        .x11 => assert(x11_support),
    }

    const window_platform = switch (api) {
        else => {
            @panic("Expected .wayland or .x11 at this point!");
        },
        .win32 => glfw.Platform.WIN32,
        .wayland => glfw.Platform.WAYLAND,
        // .wayland => glfw.Platform.X11,
        .x11 => glfw.Platform.X11,
    };

    glfw.glfwInitHint(glfw.PLATFORM, @intFromEnum(window_platform));

    if (glfw.glfwInit() == 0) {
        elog("glfwInit() failed...", .{});

        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });

        return error.glfwInitFailed;
    }
}

pub fn deinitSystem() void {
    glfw.glfwTerminate();
}

handle: *glfw.GLFWwindow,
new_fb_size: ?struct { c_int, c_int } = null,

pub fn init(this: *@This(), title: [:0]const u8) !void {
    glfw.glfwWindowHint(glfw.CLIENT_API, glfw.NO_API);

    glfw.glfwWindowHintString(glfw.WAYLAND_APP_ID, "my_app_id");

    var handle: *glfw.GLFWwindow = undefined;

    if (glfw.glfwCreateWindow(800, 600, title, null, null)) |h| {
        handle = h;
    } else {
        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });
        return error.Glfw_Create_Window_Failed;
    }

    dlog("created glfw window", .{});

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

pub fn deinit(this: *@This()) void {
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
        const window: *Window = @fieldParentPtr("impl", this);

        if (window.framebuffer_resize_callback) |cb| {
            cb.fun(window, s[0], s[1], cb.user_data);
        }
        this.new_fb_size = null;
    }
}

pub fn frameBufferSize(this: *const @This(), width: *i32, height: *i32) void {
    glfw.glfwGetFramebufferSize(this.handle, width, height);
}

pub fn requiredVulkanInstanceExtensions(_: *const @This()) ![]const [*:0]const u8 {
    assert(glfw.glfwVulkanSupported() == 1);
    var count: u32 = undefined;
    const ext = glfw.glfwGetRequiredInstanceExtensions(&count) orelse return error.API_UNAVAILABLE;
    return @as([]const [*:0]const u8, @ptrCast(ext[0..count]));
}

pub fn createVulkanSurface(this: *const @This(), instance: vk.Instance) !vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;
    if (glfw.glfwCreateWindowSurface(instance, this.handle, null, &surface) != .SUCCESS) {
        elog("glfwCreateWindowSurface failed!", .{});
        return error.Vulkan_Surface_Creation_Failed;
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

fn keyCallback(gwindow: *glfw.GLFWwindow, gkey: glfw.Key, scancode: c_int, gaction: glfw.Action, mods: c_int) callconv(.C) void {
    _ = mods;

    const action: platform.KeyAction = switch (gaction) {
        .release => .release,
        .press => .press,
        .repeat => .repeat,
    };

    const impl: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(gwindow)));
    assert(gwindow == impl.handle);
    const window: *Window = @fieldParentPtr("impl", impl);

    if (window.key_callback) |cb| cb.fun(window, gkey, action, scancode, cb.user_data);
}

fn framebufferResizeCallback(gwindow: *glfw.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    const this: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(gwindow)));
    assert(gwindow == this.handle);

    this.new_fb_size = .{ width, height };
}
