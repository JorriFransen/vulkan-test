const std = @import("std");
const assert = std.debug.assert;
const log = std.log.scoped(.VK_EXT_Debug_utils);

const vk = @import("vulkan");
const c = @import("platform").c;

pub const extension_name = "VK_EXT_debug_utils";
pub var extension_loaded = false;

// Types
const Instance = vk.Instance;
const Result = vk.Result;
const AllocationCallbacks = vk.AllocationCallbacks;

// Structs
pub const DebugUtilsMessenger = c.VkDebugUtilsMessengerEXT;
pub const DebugUtilsMessengerCallbackData = c.VkDebugUtilsMessengerCallbackDataEXT;
pub const DebugUtilsMessengerCreateInfo = c.VkDebugUtilsMessengerCreateInfoEXT;
pub const DebugUtilsMessageSeverityFlagBits = c.VkDebugUtilsMessageSeverityFlagBitsEXT;
pub const DebugUtilsMessageTypeFlags = c.VkDebugUtilsMessageTypeFlagsEXT;

// Message severity flags
pub const DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT = c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT_EXT;
pub const DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT = c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT_EXT;
pub const DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT = c.VK_DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT_EXT;

// Message type flags
pub const DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT = c.VK_DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT_EXT;
pub const DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT = c.VK_DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT_EXT;
pub const DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT = c.VK_DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT_EXT;

// Constants
pub const Structure_Type = struct {
    pub const DEBUG_UTILS_MESSENGER_CREATE_INFO = c.VK_STRUCTURE_TYPE_DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT;
};

pub fn load(instance: vk.Instance) void {
    assert(!extension_loaded);
    log.debug("loading extension functions", .{});

    createDebugUtilsMessenger = @ptrCast(vk.getInstanceProcAddr(instance, "vkCreateDebugUtilsMessengerEXT"));
    destroyDebugUtilsMessenger = @ptrCast(vk.getInstanceProcAddr(instance, "vkDestroyDebugUtilsMessengerEXT"));

    extension_loaded = true;
}

pub var createDebugUtilsMessenger: *const fn (instance: Instance, create_info: *const DebugUtilsMessengerCreateInfo, allocator: ?*const AllocationCallbacks, debug_messenger: *DebugUtilsMessenger) callconv(.C) Result = undefined;
pub var destroyDebugUtilsMessenger: *const fn (instance: Instance, messenger: DebugUtilsMessenger, allocator: ?*AllocationCallbacks) callconv(.C) void = undefined;
