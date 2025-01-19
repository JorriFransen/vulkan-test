const flags = @import("flags");
const platform = @import("platform.zig");
const Window = platform.Window;
const std = @import("std");
const alloc = @import("alloc.zig");

pub const Options = struct {
    pub const description = "Testing vulkan api";

    window_api: platform.WindowApi = .default,
    glfw_api: platform.GlfwWindowApi = .default,

    pub const descriptions = .{ .glfw_api = "Specify the underlying api glfw should use" };

    pub fn initOptions(this: *const @This()) Window.InitSystemOptions {
        return .{ .window_api = this.window_api, .glfw_api = this.glfw_api };
    }
};

pub const CommandLineParseError = error{InvalidCommandLine};

pub fn parse() CommandLineParseError!Options {
    var args = try std.process.argsWithAllocator(alloc.gpa);
    defer args.deinit();

    const name = "vulkan-test";

    return flags.parse(&args, name, Options, .{}) catch return error.InvalidCommandLine;
}
