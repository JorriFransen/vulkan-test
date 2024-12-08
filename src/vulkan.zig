const std = @import("std");
const dlog = std.log.debug;
const assert = std.debug.assert;

const c = @import("vulkan/c.zig");

pub const helper = @import("vulkan/helper.zig");

pub const loader = struct {
    pub const debug_utils = @import("vulkan/ext_debug_utils.zig");

    pub fn load(instance: Instance, req_extensions: []const [*:0]const u8) void {
        for (req_extensions) |ext_name| {
            var found = false;
            const name = std.mem.span(ext_name);

            inline for (@typeInfo(@This()).@"struct".decls) |decl| {
                const ext_struct_type = @field(@This(), decl.name);
                if (@TypeOf(ext_struct_type) != type) continue;

                if (@typeInfo(ext_struct_type) == .@"struct") {
                    assert(@hasDecl(ext_struct_type, "extension_name"));
                    assert(@hasDecl(ext_struct_type, "extension_loaded"));
                } else {
                    continue;
                }

                if (std.mem.eql(u8, name, @field(ext_struct_type, "extension_name"))) {
                    found = true;
                    assert(!@field(ext_struct_type, "extension_loaded"));
                    ext_struct_type.load(instance);
                    break;
                }
            }
        }
    }
};

pub const extensions = struct {
    pub usingnamespace loader.debug_utils;

    // Extension names
    pub const KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME = c.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME;
    pub const EXT_DEBUG_UTILS_EXTENSION_NAME = c.VK_EXT_DEBUG_UTILS_EXTENSION_NAME;
};

// Types
pub const Bool32 = u32;
pub const Result = c_int;

// Structs
pub const ApplicationInfo = c.VkApplicationInfo;
pub const ExtensionProperties = c.VkExtensionProperties;
pub const LayerProperties = c.VkLayerProperties;
pub const InstanceCreateInfo = c.VkInstanceCreateInfo;
pub const AllocationCallbacks = c.VkAllocationCallbacks;

pub const Instance_T = opaque {};
pub const PhysicalDevice_T = opaque {};
pub const Instance = ?*Instance_T;
pub const PhysicalDevice = ?*PhysicalDevice_T;

// Functions
pub const createInstance = f("vkCreateInstance", fn (create_info: *const InstanceCreateInfo, allocator: ?*const AllocationCallbacks, instance: *Instance) callconv(.C) Result);
pub const destroyInstance = f("vkDestroyInstance", fn (instance: Instance, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getInstanceProcAddr = f("vkGetInstanceProcAddr", fn (instance: Instance, name: [*:0]const u8) callconv(.C) c.PFN_vkVoidFunction);
pub const enumerateInstanceExtensionProperties = f("vkEnumerateInstanceExtensionProperties", fn (layer_name: ?[*:0]const u8, ext_count: *u32, extensions: ?[*]ExtensionProperties) callconv(.C) Result);
pub const enumerateInstanceLayerProperties = f("vkEnumerateInstanceLayerProperties", fn (count: *u32, layers: ?[*]LayerProperties) callconv(.C) Result);
pub const enumeratePhysicalDevices = f("vkEnumeratePhysicalDevices", fn (instance: Instance, count: *u32, devices: ?[*]PhysicalDevice) callconv(.C) Result);

fn f(comptime name: []const u8, comptime T: type) *const T {
    return @extern(*const T, .{ .name = name });
}

// Macros
pub const MAKE_VERSION = c.VK_MAKE_VERSION;

// Constants
pub const API_VERSION_1_0 = c.VK_API_VERSION_1_0;
pub const API_VERSION_1_1 = c.VK_API_VERSION_1_1;
pub const API_VERSION_1_2 = c.VK_API_VERSION_1_2;
pub const API_VERSION_1_3 = c.VK_API_VERSION_1_3;

pub const TRUE = 1;
pub const FALSE = 0;
pub const SUCCESS = 0;

// Create Instance flags
pub const INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR = c.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;

pub const Structure_Type = struct {
    pub const APPLICATION_INFO = c.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pub const INSTANCE_CREATE_INFO = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
};
