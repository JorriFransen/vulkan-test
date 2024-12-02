const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const glfw = @import("glfw");

pub fn init() !void {
    if (glfw.glfwInit() == 0) {
        elog("glfwInit() failed...", .{});

        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });

        return error.glfwInitFailed;
    }
}

pub fn deinit() void {
    glfw.glfwTerminate();
}

handle: *glfw.GLFWwindow,

pub fn create(title: []const u8) !@This() {
    glfw.glfwWindowHint(glfw.CLIENT_API, glfw.NO_API);

    var handle: *glfw.GLFWwindow = undefined;

    _ = title;
    if (glfw.glfwCreateWindow(500, 500, "test", null, null)) |h| {
        handle = h;
    } else {
        var cstr: [*:0]const u8 = undefined;
        const code = glfw.glfwGetError(&cstr);
        elog("glfw err: {}: {s}", .{ code, cstr });
        return error.Glfw_Create_Window_Failed;
    }

    const result = @This(){
        .handle = handle,
    };

    return result;
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
