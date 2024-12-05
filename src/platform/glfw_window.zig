const std = @import("std");

const assert = std.debug.assert;
const log = std.log.scoped(.window);
const dlog = log.debug;
const elog = log.err;
const ilog = log.info;

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

    this.* = .{
        .handle = handle,
    };
}

pub fn should_close(this: *const @This()) bool {
    const res = glfw.glfwWindowShouldClose(this.handle);
    return res != 0;
}

pub fn update(this: *@This()) void {
    _ = this;
    glfw.glfwPollEvents();
}

pub fn close(this: *@This()) void {
    glfw.glfwDestroyWindow(this.handle);
}
