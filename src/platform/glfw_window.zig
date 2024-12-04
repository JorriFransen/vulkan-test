const std = @import("std");
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
    if (this.handle) |h| {
        const res = glfw.glfwWindowShouldClose(h);
        return res != 0;
    } else {
        elog("should_close(): Invalid handle", .{});
        return true;
    }
}

pub fn update(this: *@This()) void {
    _ = this;
    glfw.glfwPollEvents();
}

pub fn close(this: *@This()) void {
    if (this.handle) |h| {
        glfw.glfwDestroyWindow(h);
    } else {
        elog("close(): Invalid handle", .{});
    }
}
