const std = @import("std");
const assert = std.debug.assert;
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const builtin = @import("builtin");

const alloc = @import("alloc");

const platform = @import("platform");
const Window = platform.Window;

const vkh = @import("vulkan").helper;

const options = @import("options");
const flags = @import("flags");
pub var cmd_line_options: Cmd_Line_Options = undefined;

const Cmd_Line_Options = struct {
    pub const description = "Testing vulkan api";

    glfw_window_api: enum {
        default,
        wayland,
        x11,
        pub const descriptions = .{
            .default = "Use wayland if available, fallback to x11",
        };
    } = .default,

    pub const descriptions = .{ .glfw_window_api = "Specify the underlying api glfw should use" };
};

const debug_log: bool = true;
const log_level = if (builtin.mode == .Debug and debug_log) .debug else .info;

pub const std_options = std.Options{
    .log_level = log_level,
    .log_scope_levels = &.{
        .{ .scope = .default, .level = log_level },
        .{ .scope = .vulkan, .level = if (options.vulkan_verbose) log_level else .info },
    },
};

pub fn vmain() !u8 {
    var args = try std.process.argsWithAllocator(alloc.gpa);
    defer args.deinit();

    cmd_line_options = flags.parseOrExit(&args, "vulkan-test", Cmd_Line_Options, .{});

    try Window.init_system();
    defer Window.deinit_system();

    var window: Window = undefined;
    try window.create("Vulkan Test");
    defer window.close();

    try vkh.init_system(&window);
    defer vkh.deinit_system();

    // var width: i32 = undefined;
    // var height: i32 = undefined;
    // window.frame_buffer_size(&width, &height);
    // dlog("window size: {}, {}", .{ width, height });

    while (!window.should_close()) {
        window.update();

        if (window.input.escape_pressed) {
            window.request_close();
        }
    }

    return 0;
}

pub fn main() !u8 {
    const result = try vmain();
    alloc.deinit();
    return result;
}
