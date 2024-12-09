const std = @import("std");
const dlog = std.log.debug;
const assert = std.debug.assert;

pub const c = @import("vulkan/c.zig");

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

// Handles
pub const Instance_T = opaque {};
pub const SurfaceKHR_T = opaque {};
pub const PhysicalDevice_T = opaque {};
pub const Device_T = opaque {};
pub const Queue_T = opaque {};
pub const Instance = ?*Instance_T;
pub const SurfaceKHR = ?*SurfaceKHR_T;
pub const PhysicalDevice = ?*PhysicalDevice_T;
pub const Device = ?*Device_T;
pub const Queue = ?*Queue_T;

// Structs
pub const ApplicationInfo = c.VkApplicationInfo;
pub const ExtensionProperties = c.VkExtensionProperties;
pub const LayerProperties = c.VkLayerProperties;
pub const InstanceCreateInfo = c.VkInstanceCreateInfo;
pub const AllocationCallbacks = c.VkAllocationCallbacks;
pub const PhysicalDeviceProperties = extern struct {
    apiVersion: u32 = 0,
    driverVersion: u32 = 0,
    vendorID: u32 = 0,
    deviceID: u32 = 0,
    deviceType: PhysicalDeviceType = std.mem.zeroes(PhysicalDeviceType),
    deviceName: [256]u8 = std.mem.zeroes([256]u8),
    pipelineCacheUUID: [16]u8 = std.mem.zeroes([16]u8),
    limits: c.VkPhysicalDeviceLimits = std.mem.zeroes(c.VkPhysicalDeviceLimits),
    sparseProperties: c.VkPhysicalDeviceSparseProperties = std.mem.zeroes(c.VkPhysicalDeviceSparseProperties),
};
pub const PhysicalDeviceFeatures = c.VkPhysicalDeviceFeatures;
pub const QueueFamilyProperties = extern struct {
    queueFlags: QueueFlags = std.mem.zeroes(QueueFlags),
    queueCount: u32 = std.mem.zeroes(u32),
    timestampValidBits: u32 = std.mem.zeroes(u32),
    minImageTransferGranularity: c.VkExtent3D = std.mem.zeroes(c.VkExtent3D),
};
pub const DeviceQueueCreateInfo = c.VkDeviceQueueCreateInfo;
pub const DeviceCreateInfo = c.VkDeviceCreateInfo;
pub const XcbSurfaceCreateInfoKHR = c.VkXcbSurfaceCreateInfoKHR;
pub const XlibSurfaceCreateInfoKHR = c.VkXlibSurfaceCreateInfoKHR;
pub const Win32SurfaceCreateInfoKHR = c.VkWin32SurfaceCreateInfoKHR;

// Functions
pub const createInstance = f("vkCreateInstance", fn (create_info: *const InstanceCreateInfo, allocator: ?*const AllocationCallbacks, instance: *Instance) callconv(.C) Result);
pub const destroyInstance = f("vkDestroyInstance", fn (instance: Instance, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getInstanceProcAddr = f("vkGetInstanceProcAddr", fn (instance: Instance, name: [*:0]const u8) callconv(.C) c.PFN_vkVoidFunction);
pub const enumerateInstanceExtensionProperties = f("vkEnumerateInstanceExtensionProperties", fn (layer_name: ?[*:0]const u8, ext_count: *u32, extensions: ?[*]ExtensionProperties) callconv(.C) Result);
pub const enumerateInstanceLayerProperties = f("vkEnumerateInstanceLayerProperties", fn (count: *u32, layers: ?[*]LayerProperties) callconv(.C) Result);
pub const enumeratePhysicalDevices = f("vkEnumeratePhysicalDevices", fn (instance: Instance, count: *u32, devices: ?[*]PhysicalDevice) callconv(.C) Result);
pub const getPhysicalDeviceProperties = f("vkGetPhysicalDeviceProperties", fn (device: PhysicalDevice, properties: *PhysicalDeviceProperties) callconv(.C) void);
pub const getPhysicalDeviceFeatures = f("vkGetPhysicalDeviceFeatures", fn (device: PhysicalDevice, properties: *PhysicalDeviceFeatures) callconv(.C) void);
pub const getPhysicalDeviceQueueFamilyProperties = f("vkGetPhysicalDeviceQueueFamilyProperties", fn (device: PhysicalDevice, count: *u32, properties: ?[*]QueueFamilyProperties) callconv(.C) void);
pub const createDevice = f("vkCreateDevice", fn (pdev: PhysicalDevice, create_info: *const DeviceCreateInfo, allocator: ?*AllocationCallbacks, device: *Device) callconv(.C) Result);
pub const destroyDevice = f("vkDestroyDevice", fn (device: Device, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const getDeviceQueue = f("vkGetDeviceQueue", fn (device: Device, family_index: u32, queue_index: u32, queue: *Queue) callconv(.C) void);
pub const createXcbSurfaceKHR = f("vkCreateXcbSurfaceKHR", fn (instance: Instance, create_info: *const XcbSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createXlibSurfaceKHR = f("vkCreateXlibSurfaceKHR", fn (instance: Instance, create_info: *const XlibSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createWin32SurfaceKHR = f("vkCreateWin32SurfaceKHR", fn (instance: Instance, create_info: *const Win32SurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);

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
    pub const DEVICE_QUEUE_CREATE_INFO = c.VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
    pub const DEVICE_CREATE_INFO = c.VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;
    pub const XLIB_SURFACE_CREATE_INFO_KHR = c.VK_STRUCTURE_TYPE_XLIB_SURFACE_CREATE_INFO_KHR;
    pub const XCB_SURFACE_CREATE_INFO_KHR = c.VK_STRUCTURE_TYPE_XCB_SURFACE_CREATE_INFO_KHR;
    pub const WIN32_SURFACE_CREATE_INFO_KHR = c.VK_STRUCTURE_TYPE_WIN32_SURFACE_CREATE_INFO_KHR;
};

// Enums/Flags
pub const PhysicalDeviceType = enum(c_uint) {
    OTHER = 0,
    INTEGRATED_GPU = 1,
    DISCRETE_GPU = 2,
    VIRTUAL_GPU = 3,
    CPU = 4,
    MAX_ENUM = 2147483647,
};

pub const QueueFlags = packed struct(u32) {
    GRAPHICS_BIT: u1 = 0,
    COMPUTE_BIT: u1 = 0,
    TRANSFER_BIT: u1 = 0,
    SPARSE_BINDING_BIT: u1 = 0,
    PROTECTED_BIT: u1 = 0,
    VIDEO_DECODE_BIT_KHR: u1 = 0,
    VIDEO_ENCODE_BIT_KHR: u1 = 0,
    OPTICAL_FLOW_BIT_NV: u1 = 0,
    __reserved__: u24 = 0,
};
