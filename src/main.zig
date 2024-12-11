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

const debug_log: bool = true;
const log_level = if (builtin.mode == .Debug and debug_log) .debug else .info;

pub const std_options = std.Options{
    .log_level = log_level,
};

pub fn main() !u8 {
    try Window.init_system();
    defer Window.deinit_system();

    var window: Window = undefined;
    try window.create("Vulkan Test");
    defer window.close();

    try vkh.init_system(&window);
    defer vkh.deinit_system();

    while (!window.should_close()) {
        window.update();

        if (window.input.escape_pressed) {
            window.request_close();
        }
    }

    if (builtin.mode == .Debug and alloc.detectLeaks()) {
        return 1;
    }

    return 0;
}
