const std = @import("std");
const assert = std.debug.assert;
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const Window = @import("window").Window;
const vkh = @import("vulkan").helper;

pub fn main() !u8 {
    try Window.init_system();
    defer Window.deinit_system();

    var window: Window = undefined;
    try window.create("Vulkan Test");
    defer window.close();

    try vkh.init_system();
    defer vkh.deinit_system();

    while (!window.should_close()) {
        window.update();

        if (window.input.escape_pressed) {
            window.request_close();
        }
    }

    return 0;
}
