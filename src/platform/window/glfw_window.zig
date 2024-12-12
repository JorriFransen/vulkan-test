const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const f = @import("util").extern_f;
const platform = @import("platform");
const c = platform.c;
const glfw = platform.glfw;
const vk = @import("vulkan");

const root = @import("root");

const log = std.log.scoped(.window);
const dlog = log.debug;
const elog = log.err;
const ilog = log.info;

pub const X = if (builtin.os.tag == .linux) struct {
    pub const getXCBConnection = f("XGetXCBConnection", fn (display: *c.Display) callconv(.C) *c.xcb_connection_t);
};

pub fn init_system() !void {
    const wayland_support = glfw.glfwPlatformSupported(.WAYLAND) == 1;
    const x11_support = glfw.glfwPlatformSupported(.X11) == 1;

    dlog("glfw wayland support: {}", .{wayland_support});
    dlog("glfw x11 support: {}", .{x11_support});

    var api = root.cmd_line_options.glfw_window_api;
    switch (api) {
        .default => {
            if (wayland_support) {
                api = .wayland;
            } else api = .x11;
        },
        .wayland => assert(wayland_support),
        .x11 => assert(x11_support),
    }

    const window_platform = switch (api) {
        else => {
            @panic("Expected .wayland or .x11 at this point!");
        },
        .wayland => glfw.Platform.WAYLAND,
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

pub fn deinit_system() void {
    glfw.glfwTerminate();
}

handle: *glfw.GLFWwindow,
input: platform.Input_State = .{},
last_input: platform.Input_State = .{},

pub fn create(this: *@This(), title: [:0]const u8) !void {
    glfw.glfwWindowHint(glfw.CLIENT_API, glfw.NO_API);

    glfw.glfwWindowHintString(glfw.WAYLAND_APP_ID, "my_app_id");

    var handle: *glfw.GLFWwindow = undefined;

    if (glfw.glfwCreateWindow(500, 500, title, null, null)) |h| {
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

    _ = glfw.glfwSetKeyCallback(handle, key_callback);

    glfw.glfwSetWindowUserPointer(handle, this);

    this.* = .{
        .handle = handle,
    };
}

pub fn should_close(this: *const @This()) bool {
    const res = glfw.glfwWindowShouldClose(this.handle);
    return res != 0;
}

pub fn request_close(this: *@This()) void {
    glfw.glfwSetWindowShouldClose(this.handle, 1);
}

pub fn update(this: *@This()) void {
    this.last_input = this.input;
    this.input = .{};

    glfw.glfwPollEvents();
}

pub fn close(this: *@This()) void {
    glfw.glfwDestroyWindow(this.handle);
}

pub fn frame_buffer_size(this: *const @This(), width: *i32, height: *i32) void {
    glfw.glfwGetFramebufferSize(this.handle, width, height);
}

pub fn required_vulkan_instance_extensions(_: *const @This()) ![]const [*:0]const u8 {
    assert(glfw.glfwVulkanSupported() == 1);
    var count: u32 = undefined;
    const ext = glfw.glfwGetRequiredInstanceExtensions(&count) orelse return error.API_UNAVAILABLE;
    return @as([]const [*:0]const u8, @ptrCast(ext[0..count]));
}

pub fn create_vulkan_surface(this: *const @This(), instance: vk.Instance) !vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;
    if (glfw.glfwCreateWindowSurface(instance, this.handle, null, &surface) != vk.SUCCESS) {
        elog("glfwCreateWindowSurface failed!", .{});
        return error.Vulkan_Surface_Creation_Failed;
    }
    return surface;

    // var surface: vk.SurfaceKHR = undefined;
    //
    // const display = glfw.glfwGetX11Display();
    // const connection = X.getXCBConnection(display);
    //
    // const create_info = vk.XcbSurfaceCreateInfoKHR{
    //     .sType = vk.Structure_Type.XCB_SURFACE_CREATE_INFO_KHR,
    //     .connection = connection,
    //     .window = @intCast(glfw.glfwGetX11Window(this.handle)),
    // };
    //
    // if (vk.createXcbSurfaceKHR(instance, &create_info, null, &surface) != vk.SUCCESS) {
    //     elog("glfwCreateWindowSurface failed!", .{});
    //     return error.Vulkan_Surface_Creation_Failed;
    // }
    //
    // return surface;

    // var surface: vk.SurfaceKHR = undefined;
    // const create_info = vk.XlibSurfaceCreateInfoKHR{
    //     .sType = vk.Structure_Type.XLIB_SURFACE_CREATE_INFO_KHR,
    //     .dpy = glfw.glfwGetX11Display(),
    //     .window = glfw.glfwGetX11Window(this.handle),
    // };
    //
    // if (vk.createXlibSurfaceKHR(instance, &create_info, null, &surface) != vk.SUCCESS) {
    //     elog("glfwCreateWindowSurface failed!", .{});
    //     return error.Vulkan_Surface_Creation_Failed;
    // }
    //
    // return surface;
}

fn key_callback(window: *glfw.GLFWwindow, key: glfw.Key, scancode: c_int, action: glfw.Action, mods: c_int) callconv(.C) void {
    _ = scancode;
    _ = mods;

    const this: *@This() = @alignCast(@ptrCast(glfw.glfwGetWindowUserPointer(window)));
    assert(window == this.handle);

    if (key == .escape) {
        this.input.escape_pressed = action == .press;
    }
}
