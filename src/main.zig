const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const Window = @import("window.zig").Window;

pub fn main() !u8 {
    try Window.init();
    var window = try Window.create("Vulkan Test");

    while (!window.should_close()) {
        window.update();
    }

    window.close();

    return 0;
}
