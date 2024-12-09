const std = @import("std");

const assert = std.debug.assert;
const log = std.log.scoped(.window);
const dlog = log.debug;
const elog = log.err;
const ilog = log.info;

const vk = @import("vulkan");
const w = @import("window");
const glfw = @import("glfw");

pub fn init_system() !void {
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

pub fn required_instance_extensions() ![]const [*:0]const u8 {
    assert(glfw.glfwVulkanSupported() == 1);
    var count: u32 = undefined;
    const ext = glfw.glfwGetRequiredInstanceExtensions(&count) orelse return error.API_UNAVAILABLE;
    return @as([]const [*:0]const u8, @ptrCast(ext[0..count]));
}

handle: *glfw.GLFWwindow,
input: w.Input_State = .{},
last_input: w.Input_State = .{},

pub fn create(this: *@This(), title: [:0]const u8) !void {
    glfw.glfwWindowHint(glfw.CLIENT_API, glfw.NO_API);

    var handle: *glfw.GLFWwindow = undefined;

    if (glfw.glfwCreateWindow(500, 500, title, null, null)) |h| {
        handle = h;
    } else {
        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });
        return error.Glfw_Create_Window_Failed;
    }

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

pub fn create_vulkan_surface(this: *const @This(), instance: vk.Instance) vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;

    const display = glfw.glfwGetX11Display();
    const connection = vk.c.XGetXCBConnection(display);
    const create_info = vk.XcbSurfaceCreateInfoKHR{
        .sType = vk.Structure_Type.XCB_SURFACE_CREATE_INFO_KHR,
        .connection = connection,
        .window = @intCast(glfw.glfwGetX11Window(this.handle)),
    };

    const err = vk.createXcbSurfaceKHR(instance, &create_info, null, &surface);
    assert(err == 0);

    return surface;
    // const create_info = vk.XlibSurfaceCreateInfoKHR{
    //     .sType = vk.Structure_Type.XLIB_SURFACE_CREATE_INFO_KHR,
    //     .dpy = glfw.glfwGetX11Display(),
    //     .window = glfw.glfwGetX11Window(this.handle),
    // };
    //
    //
    // const err = vk.createXlibSurfaceKHR(instance, &create_info, null, &surface);
    // assert(err == 0);
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
