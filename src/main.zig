const std = @import("std");
const assert = std.debug.assert;
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const builtin = @import("builtin");

const alloc = @import("alloc.zig");

const platform = @import("platform.zig");
pub const Window = platform.Window;

const Renderer = @import("vulkan/vulkan.zig").Renderer;

const options = @import("options");
const cla = @import("command_line_args.zig");

inline fn ll(t: options.@"log.Level") std.log.Level {
    assert(@typeInfo(std.log.Level).@"enum".fields.len == @typeInfo(options.@"log.Level").@"enum".fields.len);
    return @enumFromInt(@intFromEnum(t));
}
pub const std_options = std.Options{
    .log_level = if (builtin.mode == .Debug) .debug else ll(options.log_level),
    .log_scope_levels = &.{
        .{ .scope = .window, .level = ll(options.window_log_level) },
        .{ .scope = .vulkan, .level = ll(options.vulkan_log_level) },
        .{ .scope = .VK_EXT_Debug_utils, .level = ll(options.vulkan_log_level) },
    },
};

pub fn vMain() !u8 {
    const cl_opts = cla.parse() catch |err| {
        std.debug.assert(err == error.InvalidCommandLine);
        std.process.exit(0);
    };
    const init_options = cl_opts.initOptions();

    var window = try Window.init(init_options.window_api);
    try window.initSystem(init_options);
    defer window.deinitSystem();

    try window.open("Vulkan Test");
    defer window.close();

    var renderer: Renderer = undefined;
    try renderer.init(&window);
    defer renderer.deinit();

    window.setFramebufferResizeCallback(.{ .fun = framebufferResizeCallback, .user_data = &renderer });
    window.setKeyCallback(.{ .fun = keyCallback, .user_data = null });

    while (!window.shouldClose()) {
        renderer.drawFrame();
        window.pollEvents();
    }

    return 0;
}

pub fn framebufferResizeCallback(_: *const Window, width: c_int, height: c_int, user_data: ?*anyopaque) void {
    const renderer: ?*Renderer = @alignCast(@ptrCast(user_data));
    renderer.?.handleFramebufferResize(width, height);
}

pub fn keyCallback(window: *Window, key: platform.Key, action: platform.KeyAction, _: c_int, _: ?*anyopaque) void {
    if (key == .escape and action == .press) {
        window.requestClose();
    }
}

pub fn main() !u8 {
    const result = try vMain();
    try alloc.deinit();
    return result;
}
