const std = @import("std");
const assert = std.debug.assert;
const log = std.log.scoped(.VK_EXT_Debug_utils);

const vk = @import("vulkan");

pub const name = "VK_EXT_debug_utils";
pub var loaded = false;

pub fn load(instance: vk.Instance) void {
    assert(!loaded);
    log.debug("loading extension functions", .{});

    createDebugUtilsMessenger = @ptrCast(vk.getInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT"));
    destroyDebugUtilsMessenger = @ptrCast(vk.getInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT"));

    loaded = true;
}

pub var createDebugUtilsMessenger: *const fn (instance: vk.Instance, create_info: *const vk.DebugUtilsMessengerCreateInfoEXT, allocator: ?*const vk.AllocationCallbacks, debug_messenger: *vk.DebugUtilsMessengerEXT) callconv(.C) vk.Result = undefined;
pub var destroyDebugUtilsMessenger: *const fn (instance: vk.Instance, messenger: vk.DebugUtilsMessengerEXT, allocator: ?*vk.AllocationCallbacks) callconv(.C) void = undefined;
