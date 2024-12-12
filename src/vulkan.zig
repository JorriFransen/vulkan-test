const std = @import("std");
const dlog = std.log.debug;
const assert = std.debug.assert;

const f = @import("util").extern_f;

const c = @import("platform").c;
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
pub const SwapchainKHR_T = opaque {};
pub const Image_T = opaque {};
pub const Instance = ?*Instance_T;
pub const SurfaceKHR = ?*SurfaceKHR_T;
pub const PhysicalDevice = ?*PhysicalDevice_T;
pub const Device = ?*Device_T;
pub const Queue = ?*Queue_T;
pub const SwapchainKHR = ?*SwapchainKHR_T;
pub const Image = ?*Image_T;

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
pub const SurfaceCapabilitiesKHR = c.VkSurfaceCapabilitiesKHR;
pub const SurfaceFormatKHR = extern struct {
    format: Format = std.mem.zeroes(Format),
    colorSpace: ColorSpaceKHR = std.mem.zeroes(ColorSpaceKHR),
};
pub const Extent2D = c.VkExtent2D;
pub const SwapchainCreateInfoKHR = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkSwapchainCreateFlagsKHR = std.mem.zeroes(c.VkSwapchainCreateFlagsKHR),
    surface: SurfaceKHR = std.mem.zeroes(SurfaceKHR),
    minImageCount: u32 = std.mem.zeroes(u32),
    imageFormat: Format = std.mem.zeroes(Format),
    imageColorSpace: ColorSpaceKHR = std.mem.zeroes(ColorSpaceKHR),
    imageExtent: c.VkExtent2D = std.mem.zeroes(c.VkExtent2D),
    imageArrayLayers: u32 = std.mem.zeroes(u32),
    imageUsage: c.VkImageUsageFlags = std.mem.zeroes(c.VkImageUsageFlags),
    imageSharingMode: c.VkSharingMode = std.mem.zeroes(c.VkSharingMode),
    queueFamilyIndexCount: u32 = std.mem.zeroes(u32),
    pQueueFamilyIndices: [*c]const u32 = std.mem.zeroes([*c]const u32),
    preTransform: c.VkSurfaceTransformFlagBitsKHR = std.mem.zeroes(c.VkSurfaceTransformFlagBitsKHR),
    compositeAlpha: c.VkCompositeAlphaFlagBitsKHR = std.mem.zeroes(c.VkCompositeAlphaFlagBitsKHR),
    presentMode: PresentModeKHR = std.mem.zeroes(PresentModeKHR),
    clipped: c.VkBool32 = std.mem.zeroes(c.VkBool32),
    oldSwapchain: c.VkSwapchainKHR = std.mem.zeroes(c.VkSwapchainKHR),
};

// Functions
pub const createInstance = f("vkCreateInstance", fn (create_info: *const InstanceCreateInfo, allocator: ?*const AllocationCallbacks, instance: *Instance) callconv(.C) Result);
pub const destroyInstance = f("vkDestroyInstance", fn (instance: Instance, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getInstanceProcAddr = f("vkGetInstanceProcAddr", fn (instance: Instance, name: [*:0]const u8) callconv(.C) c.PFN_vkVoidFunction);
pub const enumerateInstanceExtensionProperties = f("vkEnumerateInstanceExtensionProperties", fn (layer_name: ?[*:0]const u8, ext_count: *u32, extensions: ?[*]ExtensionProperties) callconv(.C) Result);
pub const enumerateInstanceLayerProperties = f("vkEnumerateInstanceLayerProperties", fn (count: *u32, layers: ?[*]LayerProperties) callconv(.C) Result);
pub const enumeratePhysicalDevices = f("vkEnumeratePhysicalDevices", fn (instance: Instance, count: *u32, devices: ?[*]PhysicalDevice) callconv(.C) Result);
pub const enumerateDeviceExtensionProperties = f("vkEnumerateDeviceExtensionProperties", fn (device: PhysicalDevice, layer_name: ?[*:0]const u8, count: *u32, properties: ?[*]ExtensionProperties) callconv(.c) Result);
pub const getPhysicalDeviceProperties = f("vkGetPhysicalDeviceProperties", fn (device: PhysicalDevice, properties: *PhysicalDeviceProperties) callconv(.C) void);
pub const getPhysicalDeviceFeatures = f("vkGetPhysicalDeviceFeatures", fn (device: PhysicalDevice, properties: *PhysicalDeviceFeatures) callconv(.C) void);
pub const getPhysicalDeviceQueueFamilyProperties = f("vkGetPhysicalDeviceQueueFamilyProperties", fn (device: PhysicalDevice, count: *u32, properties: ?[*]QueueFamilyProperties) callconv(.C) void);
pub const createDevice = f("vkCreateDevice", fn (pdev: PhysicalDevice, create_info: *const DeviceCreateInfo, allocator: ?*AllocationCallbacks, device: *Device) callconv(.C) Result);
pub const destroyDevice = f("vkDestroyDevice", fn (device: Device, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const getDeviceQueue = f("vkGetDeviceQueue", fn (device: Device, family_index: u32, queue_index: u32, queue: *Queue) callconv(.C) void);
pub const createXcbSurfaceKHR = f("vkCreateXcbSurfaceKHR", fn (instance: Instance, create_info: *const XcbSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createXlibSurfaceKHR = f("vkCreateXlibSurfaceKHR", fn (instance: Instance, create_info: *const XlibSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createWin32SurfaceKHR = f("vkCreateWin32SurfaceKHR", fn (instance: Instance, create_info: *const Win32SurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const destroySurfaceKHR = f("vkDestroySurfaceKHR", fn (instance: Instance, surface: SurfaceKHR, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const getPhysicalDeviceSurfaceSupportKHR = f("vkGetPhysicalDeviceSurfaceSupportKHR", fn (device: PhysicalDevice, qf_index: u32, surface: SurfaceKHR, supported: *Bool32) callconv(.C) Result);
pub const getPhysicalDeviceSurfaceCapabilitiesKHR = f("vkGetPhysicalDeviceSurfaceCapabilitiesKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, capabailities: *SurfaceCapabilitiesKHR) callconv(.C) Result);
pub const getPhysicalDeviceSurfaceFormatsKHR = f("vkGetPhysicalDeviceSurfaceFormatsKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, count: *u32, formats: ?*SurfaceFormatKHR) callconv(.C) Result);
pub const getPhysicalDeviceSurfacePresentModesKHR = f("vkGetPhysicalDeviceSurfacePresentModesKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, count: *u32, modes: ?*PresentModeKHR) callconv(.C) Result);
pub const createSwapchainKHR = f("vkCreateSwapchainKHR", fn (device: Device, create_info: *const SwapchainCreateInfoKHR, allocator: ?*AllocationCallbacks, swapchain: *SwapchainKHR) callconv(.C) Result);
pub const destroySwapchainKHR = f("vkDestroySwapchainKHR", fn (device: Device, swapchain: SwapchainKHR, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const getSwapchainImagesKHR = f("vkGetSwapchainImagesKHR", fn (device: Device, swapchain: SwapchainKHR, count: *u32, images: ?[*]Image) callconv(.C) Result);

// Macros
pub const MAKE_VERSION = c.VK_MAKE_VERSION;

// Constants
pub usingnamespace @import("vulkan/constants.zig");
const self = @This();
const PhysicalDeviceType = self.PhysicalDeviceType;
const QueueFlags = self.QueueFlags;
const PresentModeKHR = self.PresentModeKHR;
const Format = self.Format;
const ColorSpaceKHR = self.ColorSpaceKHR;
