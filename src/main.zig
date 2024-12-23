const std = @import("std");
const assert = std.debug.assert;
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const builtin = @import("builtin");

const alloc = @import("alloc");

const platform = @import("platform");
const Window = platform.Window;

const Renderer = @import("vulkan").Renderer;

const options = @import("options");
const flags = @import("flags");
pub var cmd_line_options: CmdLineOptions = undefined;

const CmdLineOptions = struct {
    pub const description = "Testing vulkan api";

    glfw_window_api: platform.WindowApi = .default,

    pub const descriptions = .{ .glfw_window_api = "Specify the underlying api glfw should use" };
};

const debug_log: bool = true;
const log_level = if (builtin.mode == .Debug and debug_log) .debug else .info;

pub const std_options = std.Options{
    .log_level = log_level,
    .log_scope_levels = &.{
        .{ .scope = .default, .level = log_level },
        .{ .scope = .window, .level = if (options.window_verbose) log_level else .info },
        .{ .scope = .vulkan, .level = if (options.vulkan_verbose) log_level else .info },
        .{ .scope = .VK_EXT_Debug_utils, .level = if (options.vulkan_verbose) log_level else .info },
    },
};

var renderer: Renderer = undefined;

pub fn vMain() !u8 {
    var args = try std.process.argsWithAllocator(alloc.gpa);
    defer args.deinit();

    cmd_line_options = flags.parseOrExit(&args, "vulkan-test", CmdLineOptions, .{});

    try Window.initSystem();
    defer Window.deinitSystem();

    var window: Window = undefined;
    try window.create("Vulkan Test");
    defer window.close();

    renderer = try Renderer.init(&window);
    defer renderer.deinit();

    window.framebuffer_resize_callback = framebufferResizeCallback;

    while (!window.shouldClose()) {
        if (window.input.escape_pressed) {
            window.requestClose();
        }

        renderer.drawFrame();

        window.pollEvents();
    }

    return 0;
}

fn framebufferResizeCallback(_: *const Window, width: c_int, height: c_int) void {
    renderer.handleFramebufferResize(width, height);
}

pub fn main() !u8 {
    const result = try vMain();
    alloc.deinit();
    return result;
}
