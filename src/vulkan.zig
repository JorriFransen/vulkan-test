const std = @import("std");
const dlog = std.log.debug;
const assert = std.debug.assert;

const f = @import("externFn").externFn;

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
pub const ImageView_T = opaque {};
pub const ShaderModule_T = opaque {};
pub const PipelineLayout_T = opaque {};
pub const RenderPass_T = opaque {};
pub const Pipeline_T = opaque {};
pub const Framebuffer_T = opaque {};
pub const Instance = ?*Instance_T;
pub const SurfaceKHR = ?*SurfaceKHR_T;
pub const PhysicalDevice = ?*PhysicalDevice_T;
pub const Device = ?*Device_T;
pub const Queue = ?*Queue_T;
pub const SwapchainKHR = ?*SwapchainKHR_T;
pub const Image = ?*Image_T;
pub const ImageView = ?*ImageView_T;
pub const ShaderModule = ?*ShaderModule_T;
pub const PipelineLayout = ?*PipelineLayout_T;
pub const RenderPass = ?*RenderPass_T;
pub const Pipeline = ?*Pipeline_T;
pub const Framebuffer = ?*Framebuffer_T;

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
pub const ImageViewCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkImageViewCreateFlags = std.mem.zeroes(c.VkImageViewCreateFlags),
    image: Image = std.mem.zeroes(Image),
    viewType: c.VkImageViewType = std.mem.zeroes(c.VkImageViewType),
    format: Format = std.mem.zeroes(Format),
    components: c.VkComponentMapping = std.mem.zeroes(c.VkComponentMapping),
    subresourceRange: c.VkImageSubresourceRange = std.mem.zeroes(c.VkImageSubresourceRange),
};
pub const ShaderModuleCreateInfo = c.VkShaderModuleCreateInfo;
pub const PipelineShaderStageCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkPipelineShaderStageCreateFlags = std.mem.zeroes(c.VkPipelineShaderStageCreateFlags),
    stage: c.VkShaderStageFlagBits = std.mem.zeroes(c.VkShaderStageFlagBits),
    module: ShaderModule = std.mem.zeroes(ShaderModule),
    pName: [*c]const u8 = std.mem.zeroes([*c]const u8),
    pSpecializationInfo: [*c]const c.VkSpecializationInfo = std.mem.zeroes([*c]const c.VkSpecializationInfo),
};
pub const PipelineDynamicStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkPipelineDynamicStateCreateFlags = std.mem.zeroes(c.VkPipelineDynamicStateCreateFlags),
    dynamicStateCount: u32 = std.mem.zeroes(u32),
    pDynamicStates: [*c]const DynamicState = std.mem.zeroes([*c]const DynamicState),
};
pub const PipelineVertexInputStateCreateInfo = c.VkPipelineVertexInputStateCreateInfo;
pub const PipelineInputAssemblyStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkPipelineInputAssemblyStateCreateFlags = std.mem.zeroes(c.VkPipelineInputAssemblyStateCreateFlags),
    topology: PrimitiveTopology = std.mem.zeroes(PrimitiveTopology),
    primitiveRestartEnable: c.VkBool32 = std.mem.zeroes(c.VkBool32),
};
pub const Viewport = c.VkViewport;
pub const Rect2D = c.VkRect2D;
pub const PipelineViewportStateCreateInfo = c.VkPipelineViewportStateCreateInfo;
pub const PipelineRasterizationStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkPipelineRasterizationStateCreateFlags = std.mem.zeroes(c.VkPipelineRasterizationStateCreateFlags),
    depthClampEnable: Bool32 = std.mem.zeroes(Bool32),
    rasterizerDiscardEnable: Bool32 = std.mem.zeroes(Bool32),
    polygonMode: PolygonMode = std.mem.zeroes(PolygonMode),
    cullMode: CullModeFlags = std.mem.zeroes(CullModeFlags),
    frontFace: FrontFace = std.mem.zeroes(FrontFace),
    depthBiasEnable: Bool32 = std.mem.zeroes(Bool32),
    depthBiasConstantFactor: f32 = std.mem.zeroes(f32),
    depthBiasClamp: f32 = std.mem.zeroes(f32),
    depthBiasSlopeFactor: f32 = std.mem.zeroes(f32),
    lineWidth: f32 = std.mem.zeroes(f32),
};
pub const PipelineMultisampleStateCreateInfo = c.VkPipelineMultisampleStateCreateInfo;
pub const PipelineDepthStencilStateCreateInfo = c.VkPipelineDepthStencilStateCreateInfo;
pub const PipelineColorBlendAttachmentState = extern struct {
    blendEnable: Bool32 = std.mem.zeroes(Bool32),
    srcColorBlendFactor: BlendFactor = std.mem.zeroes(BlendFactor),
    dstColorBlendFactor: BlendFactor = std.mem.zeroes(BlendFactor),
    colorBlendOp: BlendOp = std.mem.zeroes(BlendOp),
    srcAlphaBlendFactor: BlendFactor = std.mem.zeroes(BlendFactor),
    dstAlphaBlendFactor: BlendFactor = std.mem.zeroes(BlendFactor),
    alphaBlendOp: BlendOp = std.mem.zeroes(BlendOp),
    colorWriteMask: ColorComponentFlags = std.mem.zeroes(ColorComponentFlags),
};
pub const PipelineColorBlendStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkPipelineColorBlendStateCreateFlags = std.mem.zeroes(c.VkPipelineColorBlendStateCreateFlags),
    logicOpEnable: Bool32 = std.mem.zeroes(Bool32),
    logicOp: LogicOp = std.mem.zeroes(LogicOp),
    attachmentCount: u32 = std.mem.zeroes(u32),
    pAttachments: [*c]const PipelineColorBlendAttachmentState = std.mem.zeroes([*c]const PipelineColorBlendAttachmentState),
    blendConstants: [4]f32 = std.mem.zeroes([4]f32),
};
pub const PipelineLayoutCreateInfo = c.VkPipelineLayoutCreateInfo;
pub const AttachmentDescription = extern struct {
    flags: c.VkAttachmentDescriptionFlags = std.mem.zeroes(c.VkAttachmentDescriptionFlags),
    format: Format = std.mem.zeroes(Format),
    samples: c.VkSampleCountFlagBits = std.mem.zeroes(c.VkSampleCountFlagBits),
    loadOp: AttachmentLoadOp = std.mem.zeroes(AttachmentLoadOp),
    storeOp: AttachmentStoreOp = std.mem.zeroes(AttachmentStoreOp),
    stencilLoadOp: AttachmentLoadOp = std.mem.zeroes(AttachmentLoadOp),
    stencilStoreOp: AttachmentStoreOp = std.mem.zeroes(AttachmentStoreOp),
    initialLayout: ImageLayout = std.mem.zeroes(ImageLayout),
    finalLayout: ImageLayout = std.mem.zeroes(ImageLayout),
};
pub const AttachmentReference = extern struct {
    attachment: u32 = std.mem.zeroes(u32),
    layout: ImageLayout = std.mem.zeroes(ImageLayout),
};
pub const SubpassDescription = extern struct {
    flags: c.VkSubpassDescriptionFlags = std.mem.zeroes(c.VkSubpassDescriptionFlags),
    pipelineBindPoint: PipelineBindPoint = std.mem.zeroes(PipelineBindPoint),
    inputAttachmentCount: u32 = std.mem.zeroes(u32),
    pInputAttachments: [*c]const c.VkAttachmentReference = std.mem.zeroes([*c]const c.VkAttachmentReference),
    colorAttachmentCount: u32 = std.mem.zeroes(u32),
    pColorAttachments: [*c]const AttachmentReference = std.mem.zeroes([*c]const AttachmentReference),
    pResolveAttachments: [*c]const c.VkAttachmentReference = std.mem.zeroes([*c]const c.VkAttachmentReference),
    pDepthStencilAttachment: [*c]const c.VkAttachmentReference = std.mem.zeroes([*c]const c.VkAttachmentReference),
    preserveAttachmentCount: u32 = std.mem.zeroes(u32),
    pPreserveAttachments: [*c]const u32 = std.mem.zeroes([*c]const u32),
};
pub const RenderPassCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkRenderPassCreateFlags = std.mem.zeroes(c.VkRenderPassCreateFlags),
    attachmentCount: u32 = std.mem.zeroes(u32),
    pAttachments: [*c]const AttachmentDescription = std.mem.zeroes([*c]const AttachmentDescription),
    subpassCount: u32 = std.mem.zeroes(u32),
    pSubpasses: [*c]const SubpassDescription = std.mem.zeroes([*c]const SubpassDescription),
    dependencyCount: u32 = std.mem.zeroes(u32),
    pDependencies: [*c]const c.VkSubpassDependency = std.mem.zeroes([*c]const c.VkSubpassDependency),
};
pub const GraphicsPiplineCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkPipelineCreateFlags = std.mem.zeroes(c.VkPipelineCreateFlags),
    stageCount: u32 = std.mem.zeroes(u32),
    pStages: [*c]const PipelineShaderStageCreateInfo = std.mem.zeroes([*c]const PipelineShaderStageCreateInfo),
    pVertexInputState: [*c]const c.VkPipelineVertexInputStateCreateInfo = std.mem.zeroes([*c]const c.VkPipelineVertexInputStateCreateInfo),
    pInputAssemblyState: [*c]const PipelineInputAssemblyStateCreateInfo = std.mem.zeroes([*c]const PipelineInputAssemblyStateCreateInfo),
    pTessellationState: [*c]const c.VkPipelineTessellationStateCreateInfo = std.mem.zeroes([*c]const c.VkPipelineTessellationStateCreateInfo),
    pViewportState: [*c]const c.VkPipelineViewportStateCreateInfo = std.mem.zeroes([*c]const c.VkPipelineViewportStateCreateInfo),
    pRasterizationState: [*c]const PipelineRasterizationStateCreateInfo = std.mem.zeroes([*c]const PipelineRasterizationStateCreateInfo),
    pMultisampleState: [*c]const c.VkPipelineMultisampleStateCreateInfo = std.mem.zeroes([*c]const c.VkPipelineMultisampleStateCreateInfo),
    pDepthStencilState: [*c]const c.VkPipelineDepthStencilStateCreateInfo = std.mem.zeroes([*c]const c.VkPipelineDepthStencilStateCreateInfo),
    pColorBlendState: [*c]const PipelineColorBlendStateCreateInfo = std.mem.zeroes([*c]const PipelineColorBlendStateCreateInfo),
    pDynamicState: [*c]const PipelineDynamicStateCreateInfo = std.mem.zeroes([*c]const PipelineDynamicStateCreateInfo),
    layout: PipelineLayout = std.mem.zeroes(PipelineLayout),
    renderPass: RenderPass = std.mem.zeroes(RenderPass),
    subpass: u32 = std.mem.zeroes(u32),
    basePipelineHandle: c.VkPipeline = std.mem.zeroes(c.VkPipeline),
    basePipelineIndex: i32 = std.mem.zeroes(i32),
};
pub const FramebufferCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkFramebufferCreateFlags = std.mem.zeroes(c.VkFramebufferCreateFlags),
    renderPass: RenderPass = std.mem.zeroes(RenderPass),
    attachmentCount: u32 = std.mem.zeroes(u32),
    pAttachments: [*c]const ImageView = std.mem.zeroes([*c]const ImageView),
    width: u32 = std.mem.zeroes(u32),
    height: u32 = std.mem.zeroes(u32),
    layers: u32 = std.mem.zeroes(u32),
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
pub const createImageView = f("vkCreateImageView", fn (device: Device, create_info: *const ImageViewCreateInfo, allocator: ?*AllocationCallbacks, view: *ImageView) callconv(.C) Result);
pub const destroyImageView = f("vkDestroyImageView", fn (device: Device, view: ImageView, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const createShaderModule = f("vkCreateShaderModule", fn (device: Device, create_info: *const ShaderModuleCreateInfo, allocator: ?*AllocationCallbacks, shader_module: *ShaderModule) callconv(.C) Result);
pub const destroyShaderModule = f("vkDestroyShaderModule", fn (device: Device, shader_module: ShaderModule, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const createPipelineLayout = f("vkCreatePipelineLayout", fn (device: Device, create_info: *const PipelineLayoutCreateInfo, allocator: ?*AllocationCallbacks, pipeline_layout: *PipelineLayout) callconv(.C) Result);
pub const destroyPipelineLayout = f("vkDestroyPipelineLayout", fn (device: Device, pipeline_layout: PipelineLayout, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const createRenderPass = f("vkCreateRenderPass", fn (device: Device, create_info: *const RenderPassCreateInfo, allocator: ?*AllocationCallbacks, render_pass: *RenderPass) callconv(.C) Result);
pub const destroyRenderPass = f("vkDestroyRenderPass", fn (device: Device, render_pass: RenderPass, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const createGraphicsPipelines = f("vkCreateGraphicsPipelines", fn (device: Device, cache: c.VkPipelineCache, create_info_count: u32, create_infos: [*]const GraphicsPiplineCreateInfo, allocator: ?*AllocationCallbacks, pipelines: *Pipeline) callconv(.C) Result);
pub const destroyPipeline = f("vkDestroyPipeline", fn (device: Device, pipeline: Pipeline, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const createFramebuffer = f("vkCreateFramebuffer", fn (device: Device, create_info: *const FramebufferCreateInfo, allocator: ?*AllocationCallbacks, framebuffer: *Framebuffer) callconv(.C) Result);
pub const destroyFramebuffer = f("vkDestroyFramebuffer", fn (device: Device, framebuffer: Framebuffer, allocator: ?*AllocationCallbacks) callconv(.C) void);

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
const PrimitiveTopology = self.PrimitiveTopology;
const PolygonMode = self.PolygonMode;
const CullModeFlags = self.CullModeFlags;
const FrontFace = self.FrontFace;
const ColorComponentFlags = self.ColorComponentFlags;
const BlendFactor = self.BlendFactor;
const BlendOp = self.BlendOp;
const LogicOp = self.LogicOp;
const AttachmentLoadOp = self.AttachmentLoadOp;
const AttachmentStoreOp = self.AttachmentStoreOp;
const ImageLayout = self.ImageLayout;
const PipelineBindPoint = self.PipelineBindPoint;
const DynamicState = self.DynamicState;
