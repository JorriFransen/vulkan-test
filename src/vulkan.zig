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
pub const Instance = ?*opaque {};
pub const SurfaceKHR = ?*opaque {};
pub const PhysicalDevice = ?*opaque {};
pub const Device = ?*opaque {};
pub const Queue = ?*opaque {};
pub const SwapchainKHR = ?*opaque {};
pub const Image = ?*opaque {};
pub const ImageView = ?*opaque {};
pub const ShaderModule = ?*opaque {};
pub const PipelineLayout = ?*opaque {};
pub const RenderPass = ?*opaque {};
pub const Pipeline = ?*opaque {};
pub const Framebuffer = ?*opaque {};
pub const CommandPool = ?*opaque {};
pub const CommandBuffer = ?*opaque {};
pub const Semaphore = ?*opaque {};
pub const Fence = ?*opaque {};

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
    queueCount: u32 = 0,
    timestampValidBits: u32 = 0,
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
    pNext: ?*const anyopaque = null,
    flags: c.VkSwapchainCreateFlagsKHR = std.mem.zeroes(c.VkSwapchainCreateFlagsKHR),
    surface: SurfaceKHR = null,
    minImageCount: u32 = 0,
    imageFormat: Format = std.mem.zeroes(Format),
    imageColorSpace: ColorSpaceKHR = std.mem.zeroes(ColorSpaceKHR),
    imageExtent: c.VkExtent2D = std.mem.zeroes(c.VkExtent2D),
    imageArrayLayers: u32 = 0,
    imageUsage: c.VkImageUsageFlags = std.mem.zeroes(c.VkImageUsageFlags),
    imageSharingMode: c.VkSharingMode = std.mem.zeroes(c.VkSharingMode),
    queueFamilyIndexCount: u32 = 0,
    pQueueFamilyIndices: [*c]const u32 = null,
    preTransform: c.VkSurfaceTransformFlagBitsKHR = std.mem.zeroes(c.VkSurfaceTransformFlagBitsKHR),
    compositeAlpha: c.VkCompositeAlphaFlagBitsKHR = std.mem.zeroes(c.VkCompositeAlphaFlagBitsKHR),
    presentMode: PresentModeKHR = std.mem.zeroes(PresentModeKHR),
    clipped: c.VkBool32 = std.mem.zeroes(c.VkBool32),
    oldSwapchain: c.VkSwapchainKHR = null,
};
pub const ImageViewCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkImageViewCreateFlags = std.mem.zeroes(c.VkImageViewCreateFlags),
    image: Image = null,
    viewType: c.VkImageViewType = std.mem.zeroes(c.VkImageViewType),
    format: Format = std.mem.zeroes(Format),
    components: c.VkComponentMapping = std.mem.zeroes(c.VkComponentMapping),
    subresourceRange: c.VkImageSubresourceRange = std.mem.zeroes(c.VkImageSubresourceRange),
};
pub const ShaderModuleCreateInfo = c.VkShaderModuleCreateInfo;
pub const PipelineShaderStageCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineShaderStageCreateFlags = std.mem.zeroes(c.VkPipelineShaderStageCreateFlags),
    stage: c.VkShaderStageFlagBits = std.mem.zeroes(c.VkShaderStageFlagBits),
    module: ShaderModule = null,
    pName: [*c]const u8 = null,
    pSpecializationInfo: [*c]const c.VkSpecializationInfo = null,
};
pub const PipelineDynamicStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineDynamicStateCreateFlags = std.mem.zeroes(c.VkPipelineDynamicStateCreateFlags),
    dynamicStateCount: u32 = 0,
    pDynamicStates: [*c]const DynamicState = null,
};
pub const PipelineVertexInputStateCreateInfo = c.VkPipelineVertexInputStateCreateInfo;
pub const PipelineInputAssemblyStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineInputAssemblyStateCreateFlags = std.mem.zeroes(c.VkPipelineInputAssemblyStateCreateFlags),
    topology: PrimitiveTopology = std.mem.zeroes(PrimitiveTopology),
    primitiveRestartEnable: c.VkBool32 = std.mem.zeroes(c.VkBool32),
};
pub const Viewport = c.VkViewport;
pub const Rect2D = c.VkRect2D;
pub const PipelineViewportStateCreateInfo = c.VkPipelineViewportStateCreateInfo;
pub const PipelineRasterizationStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineRasterizationStateCreateFlags = std.mem.zeroes(c.VkPipelineRasterizationStateCreateFlags),
    depthClampEnable: Bool32 = std.mem.zeroes(Bool32),
    rasterizerDiscardEnable: Bool32 = std.mem.zeroes(Bool32),
    polygonMode: PolygonMode = std.mem.zeroes(PolygonMode),
    cullMode: CullModeFlags = std.mem.zeroes(CullModeFlags),
    frontFace: FrontFace = std.mem.zeroes(FrontFace),
    depthBiasEnable: Bool32 = std.mem.zeroes(Bool32),
    depthBiasConstantFactor: f32 = 0.0,
    depthBiasClamp: f32 = 0.0,
    depthBiasSlopeFactor: f32 = 0.0,
    lineWidth: f32 = 0.0,
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
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineColorBlendStateCreateFlags = std.mem.zeroes(c.VkPipelineColorBlendStateCreateFlags),
    logicOpEnable: Bool32 = std.mem.zeroes(Bool32),
    logicOp: LogicOp = std.mem.zeroes(LogicOp),
    attachmentCount: u32 = 0,
    pAttachments: [*c]const PipelineColorBlendAttachmentState = null,
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
    attachment: u32 = 0,
    layout: ImageLayout = std.mem.zeroes(ImageLayout),
};
pub const SubpassDescription = extern struct {
    flags: c.VkSubpassDescriptionFlags = std.mem.zeroes(c.VkSubpassDescriptionFlags),
    pipelineBindPoint: PipelineBindPoint = std.mem.zeroes(PipelineBindPoint),
    inputAttachmentCount: u32 = 0,
    pInputAttachments: [*c]const c.VkAttachmentReference = null,
    colorAttachmentCount: u32 = 0,
    pColorAttachments: [*c]const AttachmentReference = null,
    pResolveAttachments: [*c]const c.VkAttachmentReference = null,
    pDepthStencilAttachment: [*c]const c.VkAttachmentReference = null,
    preserveAttachmentCount: u32 = 0,
    pPreserveAttachments: [*c]const u32 = null,
};
pub const RenderPassCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkRenderPassCreateFlags = std.mem.zeroes(c.VkRenderPassCreateFlags),
    attachmentCount: u32 = 0,
    pAttachments: [*]const AttachmentDescription,
    subpassCount: u32 = 0,
    pSubpasses: [*]const SubpassDescription,
    dependencyCount: u32 = 0,
    pDependencies: ?[*]const SubpassDependency = null,
};
pub const GraphicsPipelineCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineCreateFlags = std.mem.zeroes(c.VkPipelineCreateFlags),
    stageCount: u32 = 0,
    pStages: [*c]const PipelineShaderStageCreateInfo = null,
    pVertexInputState: [*c]const c.VkPipelineVertexInputStateCreateInfo = null,
    pInputAssemblyState: [*c]const PipelineInputAssemblyStateCreateInfo = null,
    pTessellationState: [*c]const c.VkPipelineTessellationStateCreateInfo = null,
    pViewportState: [*c]const c.VkPipelineViewportStateCreateInfo = null,
    pRasterizationState: [*c]const PipelineRasterizationStateCreateInfo = null,
    pMultisampleState: [*c]const c.VkPipelineMultisampleStateCreateInfo = null,
    pDepthStencilState: [*c]const c.VkPipelineDepthStencilStateCreateInfo = null,
    pColorBlendState: [*c]const PipelineColorBlendStateCreateInfo = null,
    pDynamicState: [*c]const PipelineDynamicStateCreateInfo = null,
    layout: PipelineLayout = std.mem.zeroes(PipelineLayout),
    renderPass: RenderPass = null,
    subpass: u32 = 0,
    basePipelineHandle: c.VkPipeline = null,
    basePipelineIndex: i32 = 0,
};
pub const FramebufferCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkFramebufferCreateFlags = std.mem.zeroes(c.VkFramebufferCreateFlags),
    renderPass: RenderPass = null,
    attachmentCount: u32 = 0,
    pAttachments: [*c]const ImageView = null,
    width: u32 = 0,
    height: u32 = 0,
    layers: u32 = 0,
};
pub const CommandPoolCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: CommandPoolCreateFlags = std.mem.zeroes(CommandPoolCreateFlags),
    queueFamilyIndex: u32 = 0,
};
pub const CommandBufferAllocateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    commandPool: CommandPool = null,
    level: CommandBufferLevel = std.mem.zeroes(CommandBufferLevel),
    commandBufferCount: u32 = 0,
};
pub const CommandBufferBeginInfo = c.VkCommandBufferBeginInfo;
pub const RenderPassBeginInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    renderPass: RenderPass = null,
    framebuffer: Framebuffer = null,
    renderArea: Rect2D = std.mem.zeroes(Rect2D),
    clearValueCount: u32 = 0,
    pClearValues: ?[*]const ClearValue = null,
};
pub const SemaphoreCreateInfo = c.VkSemaphoreCreateInfo;
pub const FenceCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: FenceCreateFlags = std.mem.zeroes(FenceCreateFlags),
};
pub const SubmitInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32 = 0,
    pWaitSemaphores: [*]const Semaphore,
    pWaitDstStageMask: [*]const PipelineStageFlags,
    commandBufferCount: u32 = 0,
    pCommandBuffers: [*]const CommandBuffer,
    signalSemaphoreCount: u32 = 0,
    pSignalSemaphores: [*]const Semaphore,
};
pub const SubpassDependency = extern struct {
    srcSubpass: u32 = 0,
    dstSubpass: u32 = 0,
    srcStageMask: PipelineStageFlags = std.mem.zeroes(PipelineStageFlags),
    dstStageMask: PipelineStageFlags = std.mem.zeroes(PipelineStageFlags),
    srcAccessMask: c.VkAccessFlags = std.mem.zeroes(c.VkAccessFlags),
    dstAccessMask: c.VkAccessFlags = std.mem.zeroes(c.VkAccessFlags),
    dependencyFlags: c.VkDependencyFlags = std.mem.zeroes(c.VkDependencyFlags),
};
pub const PresentInfoKHR = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32 = 0,
    pWaitSemaphores: [*]const Semaphore,
    swapchainCount: u32 = 0,
    pSwapchains: [*]const SwapchainKHR,
    pImageIndices: [*]const u32,
    pResults: ?[*]Result,
};
pub const ClearValue = extern union {
    color: c.VkClearColorValue,
    depthStencil: c.VkClearDepthStencilValue,
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
pub const createDevice = f("vkCreateDevice", fn (pdev: PhysicalDevice, create_info: *const DeviceCreateInfo, allocator: ?*const AllocationCallbacks, device: *Device) callconv(.C) Result);
pub const destroyDevice = f("vkDestroyDevice", fn (device: Device, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const deviceWaitIdle = f("vkDeviceWaitIdle", fn (device: Device) callconv(.C) Result);
pub const getDeviceQueue = f("vkGetDeviceQueue", fn (device: Device, family_index: u32, queue_index: u32, queue: *Queue) callconv(.C) void);
pub const queueSubmit = f("vkQueueSubmit", fn (queue: Queue, submit_count: u32, submits: [*]const SubmitInfo, fence: Fence) callconv(.C) Result);
pub const queuePresentKHR = f("vkQueuePresentKHR", fn (queue: Queue, present_info: *const PresentInfoKHR) callconv(.C) Result);
pub const createXcbSurfaceKHR = f("vkCreateXcbSurfaceKHR", fn (instance: Instance, create_info: *const XcbSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createXlibSurfaceKHR = f("vkCreateXlibSurfaceKHR", fn (instance: Instance, create_info: *const XlibSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createWin32SurfaceKHR = f("vkCreateWin32SurfaceKHR", fn (instance: Instance, create_info: *const Win32SurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const destroySurfaceKHR = f("vkDestroySurfaceKHR", fn (instance: Instance, surface: SurfaceKHR, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getPhysicalDeviceSurfaceSupportKHR = f("vkGetPhysicalDeviceSurfaceSupportKHR", fn (device: PhysicalDevice, qf_index: u32, surface: SurfaceKHR, supported: *Bool32) callconv(.C) Result);
pub const getPhysicalDeviceSurfaceCapabilitiesKHR = f("vkGetPhysicalDeviceSurfaceCapabilitiesKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, capabailities: *SurfaceCapabilitiesKHR) callconv(.C) Result);
pub const getPhysicalDeviceSurfaceFormatsKHR = f("vkGetPhysicalDeviceSurfaceFormatsKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, count: *u32, formats: ?*SurfaceFormatKHR) callconv(.C) Result);
pub const getPhysicalDeviceSurfacePresentModesKHR = f("vkGetPhysicalDeviceSurfacePresentModesKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, count: *u32, modes: ?*PresentModeKHR) callconv(.C) Result);
pub const createSwapchainKHR = f("vkCreateSwapchainKHR", fn (device: Device, create_info: *const SwapchainCreateInfoKHR, allocator: ?*const AllocationCallbacks, swapchain: *SwapchainKHR) callconv(.C) Result);
pub const destroySwapchainKHR = f("vkDestroySwapchainKHR", fn (device: Device, swapchain: SwapchainKHR, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getSwapchainImagesKHR = f("vkGetSwapchainImagesKHR", fn (device: Device, swapchain: SwapchainKHR, count: *u32, images: ?[*]Image) callconv(.C) Result);
pub const createImageView = f("vkCreateImageView", fn (device: Device, create_info: *const ImageViewCreateInfo, allocator: ?*const AllocationCallbacks, view: *ImageView) callconv(.C) Result);
pub const destroyImageView = f("vkDestroyImageView", fn (device: Device, view: ImageView, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createShaderModule = f("vkCreateShaderModule", fn (device: Device, create_info: *const ShaderModuleCreateInfo, allocator: ?*const AllocationCallbacks, shader_module: *ShaderModule) callconv(.C) Result);
pub const destroyShaderModule = f("vkDestroyShaderModule", fn (device: Device, shader_module: ShaderModule, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createPipelineLayout = f("vkCreatePipelineLayout", fn (device: Device, create_info: *const PipelineLayoutCreateInfo, allocator: ?*const AllocationCallbacks, pipeline_layout: *PipelineLayout) callconv(.C) Result);
pub const destroyPipelineLayout = f("vkDestroyPipelineLayout", fn (device: Device, pipeline_layout: PipelineLayout, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createRenderPass = f("vkCreateRenderPass", fn (device: Device, create_info: *const RenderPassCreateInfo, allocator: ?*const AllocationCallbacks, render_pass: *RenderPass) callconv(.C) Result);
pub const destroyRenderPass = f("vkDestroyRenderPass", fn (device: Device, render_pass: RenderPass, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createGraphicsPipelines = f("vkCreateGraphicsPipelines", fn (device: Device, cache: c.VkPipelineCache, create_info_count: u32, create_infos: [*]const GraphicsPipelineCreateInfo, allocator: ?*const AllocationCallbacks, pipelines: *Pipeline) callconv(.C) Result);
pub const destroyPipeline = f("vkDestroyPipeline", fn (device: Device, pipeline: Pipeline, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createFramebuffer = f("vkCreateFramebuffer", fn (device: Device, create_info: *const FramebufferCreateInfo, allocator: ?*const AllocationCallbacks, framebuffer: *Framebuffer) callconv(.C) Result);
pub const destroyFramebuffer = f("vkDestroyFramebuffer", fn (device: Device, framebuffer: Framebuffer, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createCommandPool = f("vkCreateCommandPool", fn (device: Device, create_info: *const CommandPoolCreateInfo, allocator: ?*const AllocationCallbacks, command_pool: *CommandPool) callconv(.c) Result);
pub const destroyCommandPool = f("vkDestroyCommandPool", fn (device: Device, command_pool: CommandPool, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const allocateCommandBuffers = f("vkAllocateCommandBuffers", fn (device: Device, alloc_info: *const CommandBufferAllocateInfo, command_buffer: *CommandBuffer) callconv(.C) Result);
pub const beginCommandBuffer = f("vkBeginCommandBuffer", fn (command_buffer: CommandBuffer, begin_info: *const CommandBufferBeginInfo) callconv(.C) Result);
pub const endCommandBuffer = f("vkEndCommandBuffer", fn (command_buffer: CommandBuffer) callconv(.C) Result);
pub const resetCommandBuffer = f("vkResetCommandBuffer", fn (command_buffer: CommandBuffer, flags: CommandBufferResetFlags) callconv(.C) Result);
pub const cmdBeginRenderPass = f("vkCmdBeginRenderPass", fn (cmd_buf: CommandBuffer, begin_info: *const RenderPassBeginInfo, contents: SubpassContents) callconv(.C) void);
pub const cmdEndRenderPass = f("vkCmdEndRenderPass", fn (cmd_buf: CommandBuffer) callconv(.C) void);
pub const cmdBindPipeline = f("vkCmdBindPipeline", fn (cmd_buf: CommandBuffer, bind_point: PipelineBindPoint, pipeline: Pipeline) callconv(.C) void);
pub const cmdSetViewport = f("vkCmdSetViewport", fn (cmd_buf: CommandBuffer, first_viewport: u32, viewport_count: u32, viewports: *const Viewport) callconv(.C) void);
pub const cmdSetScissor = f("vkCmdSetScissor", fn (cmd_buf: CommandBuffer, first_scissor: u32, scissor_count: u32, scissors: *const Rect2D) callconv(.C) void);
pub const cmdDraw = f("vkCmdDraw", fn (cmd_buf: CommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) callconv(.C) void);
pub const createSemaphore = f("vkCreateSemaphore", fn (device: Device, create_info: *const SemaphoreCreateInfo, allocator: ?*const AllocationCallbacks, semaphore: *Semaphore) callconv(.C) Result);
pub const destroySemaphore = f("vkDestroySemaphore", fn (device: Device, semaphore: Semaphore, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createFence = f("vkCreateFence", fn (device: Device, create_info: *const FenceCreateInfo, allocator: ?*const AllocationCallbacks, fence: *Fence) callconv(.C) Result);
pub const destroyFence = f("vkDestroyFence", fn (device: Device, fence: Fence, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const waitForFences = f("vkWaitForFences", fn (device: Device, count: u32, fences: [*]const Fence, wait_all: Bool32, timeout: u64) callconv(.C) Result);
pub const resetFences = f("vkResetFences", fn (device: Device, count: u32, fences: [*]const Fence) callconv(.C) Result);
pub const acquireNextImageKHR = f("vkAcquireNextImageKHR", fn (device: Device, swapchain: SwapchainKHR, timeout: u64, semaphore: Semaphore, fence: Fence, image_index: *u32) callconv(.C) Result);

// Macros
pub const MAKE_VERSION = c.VK_MAKE_VERSION;

// Constants
const constants = @import("vulkan/constants.zig");
pub usingnamespace constants;
const PhysicalDeviceType = constants.PhysicalDeviceType;
const QueueFlags = constants.QueueFlags;
const PresentModeKHR = constants.PresentModeKHR;
const Format = constants.Format;
const ColorSpaceKHR = constants.ColorSpaceKHR;
const PrimitiveTopology = constants.PrimitiveTopology;
const PolygonMode = constants.PolygonMode;
const CullModeFlags = constants.CullModeFlags;
const FrontFace = constants.FrontFace;
const ColorComponentFlags = constants.ColorComponentFlags;
const BlendFactor = constants.BlendFactor;
const BlendOp = constants.BlendOp;
const LogicOp = constants.LogicOp;
const AttachmentLoadOp = constants.AttachmentLoadOp;
const AttachmentStoreOp = constants.AttachmentStoreOp;
const ImageLayout = constants.ImageLayout;
const PipelineBindPoint = constants.PipelineBindPoint;
const DynamicState = constants.DynamicState;
const CommandPoolCreateFlags = constants.CommandPoolCreateFlags;
const CommandBufferLevel = constants.CommandBufferLevel;
const SubpassContents = constants.SubpassContents;
const FenceCreateFlags = constants.FenceCreateFlags;
const CommandBufferResetFlags = constants.CommandBufferResetFlags;
const PipelineStageFlags = constants.PipelineStageFlags;
