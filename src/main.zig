const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

const builtin = @import("builtin");

const alloc = @import("alloc");
const vk = @import("vulkan.zig");

const Window = @import("window.zig").Window;

pub fn main() !u8 {
    try Window.init_system();
    defer Window.deinit_system();

    var window: Window = undefined;
    try window.create("Vulkan Test");
    defer window.close();

    var extension_count: u32 = undefined;
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, null);
    dlog("{} Vulkan extensions supported", .{extension_count});

    const extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, extension_count);
    defer alloc.gpa.free(extension_props);
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, extension_props.ptr);
    // for (extension_props) |p| dlog("supported extension: '{s}'", .{@as([*:0]const u8, @ptrCast(&p.extensionName))});

    const app_info = vk.ApplicationInfo{
        .sType = vk.Structure_Type.APPLICATION_INFO,

        .pApplicationName = "Vulkan app",
        .applicationVersion = vk.MAKE_VERSION(1, 0, 0),
        .pEngineName = "Vulkan engine",
        .engineVersion = vk.MAKE_VERSION(1, 0, 0),
        .apiVersion = vk.API_VERSION_1_0,
    };

    const window_required_extensions = try Window.required_instance_extensions();

    const mac_extensions: []const [*:0]const u8 = if (builtin.target.os.tag == .macos) &.{
        vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
    } else &.{};

    const instance_ext_count = window_required_extensions.len + mac_extensions.len;

    var required_instance_extensions = try std.ArrayList([*:0]const u8).initCapacity(alloc.gpa, instance_ext_count);
    defer required_instance_extensions.deinit();
    required_instance_extensions.appendSliceAssumeCapacity(window_required_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(mac_extensions);

    for (required_instance_extensions.items) |required| {
        var found = false;
        const r: []const u8 = std.mem.span(required);

        dlog("window required instance extension: '{s}'", .{r});

        for (extension_props) |*available| {
            const a: @TypeOf(r) = std.mem.span(@as([*:0]const u8, @ptrCast(&available.extensionName)));
            if (std.mem.eql(u8, r, a)) {
                found = true;
                break;
            }
        }

        if (!found) {
            elog("missing required extension: '{s}'", .{required});
            return error.Missing_Required_Extension;
        }
    }

    const create_info = vk.InstanceCreateInfo{
        .sType = vk.Structure_Type.INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
        .flags = vk.INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR,
        .enabledExtensionCount = @intCast(required_instance_extensions.items.len),
        .ppEnabledExtensionNames = required_instance_extensions.items.ptr,
        .enabledLayerCount = 0,
    };

    var instance: vk.Instance = undefined;
    switch (vk.createInstance(&create_info, null, &instance)) {
        vk.SUCCESS => {}, //ok
        else => |v| {
            elog("vkCreateInstance returned '{}'", .{v});
            return error.vkCreateInstance_Failed;
        },
    }
    defer vk.destroyInstance(instance, null);

    while (!window.should_close()) {
        window.update();
    }

    return 0;
}
