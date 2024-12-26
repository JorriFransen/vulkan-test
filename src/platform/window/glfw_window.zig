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

pub fn initSystem() Window.InitSystemError!void {
    const wayland_support = glfw.platformSupported(.wayland);
    const x11_support = glfw.platformSupported(.x11);

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

    const glfw_platform: glfw.PlatformType = switch (glfw_api) {
        else => {
            @panic("Expected .wayland or .x11 at this point!");
        },
        .win32 => .win32,
        .wayland => .wayland,
        // .wayland => glfw.Platform.X11,
        .x11 => .x11,
    };

    if (!glfw.init(.{ .platform = glfw_platform })) {
        elog("glfwInit() failed...", .{});

        if (glfw.getError()) |err| {
            elog("glfw err: {}: {s}", .{ err.error_code, err.description });
        }

        return error.nativeInitFailed;
    }
}

pub fn deinitSystem() void {
    glfw.terminate();
}

handle: glfw.Window = undefined,
new_fb_size: ?struct { i32, i32 } = null,

pub fn open(this: *@This(), title: [:0]const u8) Window.OpenError!void {
    var w: glfw.Window = undefined;
    if (glfw.Window.create(800, 600, title, null, null, .{
        .client_api = .no_api,
        .wayland_app_id = "my_app_id",
    })) |window| {
        w = window;
    } else {
        if (glfw.getError()) |err| {
            elog("glfw err: {}: {s}", .{ err.error_code, err.description });
        }
        return error.NativeCreateFailed;
    }

    w.setKeyCallback(keyCallback);
    w.setFramebufferSizeCallback(framebufferResizeCallback);

    w.setUserPointer(this);

    this.* = .{
        .handle = w,
        .new_fb_size = null,
    };
}

pub fn close(this: *const @This()) void {
    this.handle.destroy();
}

pub fn shouldClose(this: *const @This()) bool {
    return this.handle.shouldClose();
}

pub fn requestClose(this: *@This()) void {
    this.handle.setShouldClose(true);
}

pub fn pollEvents(this: *@This()) void {
    glfw.pollEvents();
    this.handleEvents();
}

pub fn waitEvents(this: *@This()) void {
    glfw.waitEvents();
    this.handleEvents();
}

fn handleEvents(this: *@This()) void {
    if (this.new_fb_size) |s| {
        const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", this);
        assert(@as(*@This(), @ptrCast(impl_ptr)) == this);
        const window: *Window = @fieldParentPtr("impl", impl_ptr);

        if (window.framebuffer_resize_callback) |cb| {
            cb.fun(window, s[0], s[1], cb.user_data);
        }
        this.new_fb_size = null;
    }
}

pub fn framebufferSize(this: *const @This(), width: *i32, height: *i32) void {
    const size = this.handle.getFramebufferSize();
    width.* = @intCast(size.width);
    height.* = @intCast(size.height);
}

pub fn requiredVulkanInstanceExtensions() error{VulkanApiUnavailable}![]const [*:0]const u8 {
    assert(glfw.vulkanSupported());
    if (glfw.getRequiredInstanceExtensions()) |ext| return ext;
    return error.VulkanApiUnavailable;
    // const ext = glfw.getRequiredInstanceExtensions(&count) orelse return error.VulkanApiUnavailable;
    // return @as([]const [*:0]const u8, @ptrCast(ext[0..count]));
}

pub fn createVulkanSurface(this: *const @This(), instance: vk.Instance) Window.CreateVulkanSurfaceError!vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;
    if (glfw.createWindowSurface(instance, this.handle, null, &surface) != @intFromEnum(vk.Result.SUCCESS)) {
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

fn keyCallback(gwindow: glfw.Window, gkey: glfw.Key, scancode: i32, gaction: glfw.Action, mods: glfw.Mods) void {
    _ = mods;

    const action: platform.KeyAction = switch (gaction) {
        .release => .release,
        .press => .press,
        .repeat => .repeat,
    };

    const impl = gwindow.getUserPointer(@This()).?;
    assert(gwindow.handle == impl.handle.handle);
    const impl_ptr: *Window.Impl = @fieldParentPtr("glfw_window", impl);
    assert(@as(*@This(), @ptrCast(impl_ptr)) == impl);
    const this: *Window = @fieldParentPtr("impl", impl_ptr);

    if (this.key_callback) |cb| cb.fun(this, @enumFromInt(@intFromEnum(gkey)), action, scancode, cb.user_data);
}

fn framebufferResizeCallback(gwindow: glfw.Window, width: u32, height: u32) void {
    const this = gwindow.getUserPointer(@This()).?;
    assert(gwindow.handle == this.handle.handle);

    this.new_fb_size = .{ @intCast(width), @intCast(height) };
}
