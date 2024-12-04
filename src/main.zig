const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

// const vk = @import("vulkan.zig");

const Window = @import("window.zig").Window;

pub fn main() !u8 {
    try Window.init_system();
    defer Window.deinit_system();

    var window: Window = undefined;
    try window.create("Vulkan Test");
    defer window.close();

    // var extension_count: u32 = undefined;
    // _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, null);
    // dlog("{} Vulkan extensions supported", .{extension_count});

    while (!window.should_close()) {
        window.update();
    }

    return 0;
}
