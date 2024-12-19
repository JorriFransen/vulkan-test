const std = @import("std");
const c = @import("platform").c;

const s = @import("vulkan.zig");

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
    deviceType: s.PhysicalDeviceType = std.mem.zeroes(s.PhysicalDeviceType),
    deviceName: [256]u8 = std.mem.zeroes([256]u8),
    pipelineCacheUUID: [16]u8 = std.mem.zeroes([16]u8),
    limits: c.VkPhysicalDeviceLimits = std.mem.zeroes(c.VkPhysicalDeviceLimits),
    sparseProperties: c.VkPhysicalDeviceSparseProperties = std.mem.zeroes(c.VkPhysicalDeviceSparseProperties),
};

pub const PhysicalDeviceFeatures = c.VkPhysicalDeviceFeatures;

pub const QueueFamilyProperties = extern struct {
    queueFlags: s.QueueFlags = std.mem.zeroes(s.QueueFlags),
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
    format: s.Format = std.mem.zeroes(s.Format),
    colorSpace: s.ColorSpaceKHR = std.mem.zeroes(s.ColorSpaceKHR),
};

pub const Extent2D = c.VkExtent2D;

pub const SwapchainCreateInfoKHR = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkSwapchainCreateFlagsKHR = std.mem.zeroes(c.VkSwapchainCreateFlagsKHR),
    surface: s.SurfaceKHR = null,
    minImageCount: u32 = 0,
    imageFormat: s.Format = std.mem.zeroes(s.Format),
    imageColorSpace: s.ColorSpaceKHR = std.mem.zeroes(s.ColorSpaceKHR),
    imageExtent: c.VkExtent2D = std.mem.zeroes(c.VkExtent2D),
    imageArrayLayers: u32 = 0,
    imageUsage: c.VkImageUsageFlags = std.mem.zeroes(c.VkImageUsageFlags),
    imageSharingMode: c.VkSharingMode = std.mem.zeroes(c.VkSharingMode),
    queueFamilyIndexCount: u32 = 0,
    pQueueFamilyIndices: [*c]const u32 = null,
    preTransform: c.VkSurfaceTransformFlagBitsKHR = std.mem.zeroes(c.VkSurfaceTransformFlagBitsKHR),
    compositeAlpha: c.VkCompositeAlphaFlagBitsKHR = std.mem.zeroes(c.VkCompositeAlphaFlagBitsKHR),
    presentMode: s.PresentModeKHR = std.mem.zeroes(s.PresentModeKHR),
    clipped: c.VkBool32 = std.mem.zeroes(c.VkBool32),
    oldSwapchain: c.VkSwapchainKHR = null,
};

pub const ImageViewCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkImageViewCreateFlags = std.mem.zeroes(c.VkImageViewCreateFlags),
    image: s.Image = null,
    viewType: c.VkImageViewType = std.mem.zeroes(c.VkImageViewType),
    format: s.Format = std.mem.zeroes(s.Format),
    components: c.VkComponentMapping = std.mem.zeroes(c.VkComponentMapping),
    subresourceRange: c.VkImageSubresourceRange = std.mem.zeroes(c.VkImageSubresourceRange),
};

pub const ShaderModuleCreateInfo = c.VkShaderModuleCreateInfo;

pub const PipelineShaderStageCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineShaderStageCreateFlags = std.mem.zeroes(c.VkPipelineShaderStageCreateFlags),
    stage: c.VkShaderStageFlagBits = std.mem.zeroes(c.VkShaderStageFlagBits),
    module: s.ShaderModule = null,
    pName: [*c]const u8 = null,
    pSpecializationInfo: [*c]const c.VkSpecializationInfo = null,
};

pub const PipelineDynamicStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineDynamicStateCreateFlags = std.mem.zeroes(c.VkPipelineDynamicStateCreateFlags),
    dynamicStateCount: u32 = 0,
    pDynamicStates: [*c]const s.DynamicState = null,
};

pub const PipelineVertexInputStateCreateInfo = c.VkPipelineVertexInputStateCreateInfo;

pub const PipelineInputAssemblyStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineInputAssemblyStateCreateFlags = std.mem.zeroes(c.VkPipelineInputAssemblyStateCreateFlags),
    topology: s.PrimitiveTopology = std.mem.zeroes(s.PrimitiveTopology),
    primitiveRestartEnable: c.VkBool32 = std.mem.zeroes(c.VkBool32),
};

pub const Viewport = c.VkViewport;
pub const Rect2D = c.VkRect2D;
pub const PipelineViewportStateCreateInfo = c.VkPipelineViewportStateCreateInfo;

pub const PipelineRasterizationStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineRasterizationStateCreateFlags = std.mem.zeroes(c.VkPipelineRasterizationStateCreateFlags),
    depthClampEnable: s.Bool32 = std.mem.zeroes(s.Bool32),
    rasterizerDiscardEnable: s.Bool32 = std.mem.zeroes(s.Bool32),
    polygonMode: s.PolygonMode = std.mem.zeroes(s.PolygonMode),
    cullMode: s.CullModeFlags = std.mem.zeroes(s.CullModeFlags),
    frontFace: s.FrontFace = std.mem.zeroes(s.FrontFace),
    depthBiasEnable: s.Bool32 = std.mem.zeroes(s.Bool32),
    depthBiasConstantFactor: f32 = 0.0,
    depthBiasClamp: f32 = 0.0,
    depthBiasSlopeFactor: f32 = 0.0,
    lineWidth: f32 = 0.0,
};

pub const PipelineMultisampleStateCreateInfo = c.VkPipelineMultisampleStateCreateInfo;
pub const PipelineDepthStencilStateCreateInfo = c.VkPipelineDepthStencilStateCreateInfo;

pub const PipelineColorBlendAttachmentState = extern struct {
    blendEnable: s.Bool32 = std.mem.zeroes(s.Bool32),
    srcColorBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    dstColorBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    colorBlendOp: s.BlendOp = std.mem.zeroes(s.BlendOp),
    srcAlphaBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    dstAlphaBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    alphaBlendOp: s.BlendOp = std.mem.zeroes(s.BlendOp),
    colorWriteMask: s.ColorComponentFlags = std.mem.zeroes(s.ColorComponentFlags),
};

pub const PipelineColorBlendStateCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineColorBlendStateCreateFlags = std.mem.zeroes(c.VkPipelineColorBlendStateCreateFlags),
    logicOpEnable: s.Bool32 = std.mem.zeroes(s.Bool32),
    logicOp: s.LogicOp = std.mem.zeroes(s.LogicOp),
    attachmentCount: u32 = 0,
    pAttachments: [*c]const PipelineColorBlendAttachmentState = null,
    blendConstants: [4]f32 = std.mem.zeroes([4]f32),
};

pub const PipelineLayoutCreateInfo = c.VkPipelineLayoutCreateInfo;

pub const AttachmentDescription = extern struct {
    flags: c.VkAttachmentDescriptionFlags = std.mem.zeroes(c.VkAttachmentDescriptionFlags),
    format: s.Format = std.mem.zeroes(s.Format),
    samples: c.VkSampleCountFlagBits = std.mem.zeroes(c.VkSampleCountFlagBits),
    loadOp: s.AttachmentLoadOp = std.mem.zeroes(s.AttachmentLoadOp),
    storeOp: s.AttachmentStoreOp = std.mem.zeroes(s.AttachmentStoreOp),
    stencilLoadOp: s.AttachmentLoadOp = std.mem.zeroes(s.AttachmentLoadOp),
    stencilStoreOp: s.AttachmentStoreOp = std.mem.zeroes(s.AttachmentStoreOp),
    initialLayout: s.ImageLayout = std.mem.zeroes(s.ImageLayout),
    finalLayout: s.ImageLayout = std.mem.zeroes(s.ImageLayout),
};

pub const AttachmentReference = extern struct {
    attachment: u32 = 0,
    layout: s.ImageLayout = std.mem.zeroes(s.ImageLayout),
};

pub const SubpassDescription = extern struct {
    flags: c.VkSubpassDescriptionFlags = std.mem.zeroes(c.VkSubpassDescriptionFlags),
    pipelineBindPoint: s.PipelineBindPoint = std.mem.zeroes(s.PipelineBindPoint),
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
    layout: s.PipelineLayout = std.mem.zeroes(s.PipelineLayout),
    renderPass: s.RenderPass = null,
    subpass: u32 = 0,
    basePipelineHandle: c.VkPipeline = null,
    basePipelineIndex: i32 = 0,
};

pub const FramebufferCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkFramebufferCreateFlags = std.mem.zeroes(c.VkFramebufferCreateFlags),
    renderPass: s.RenderPass = null,
    attachmentCount: u32 = 0,
    pAttachments: [*c]const s.ImageView = null,
    width: u32 = 0,
    height: u32 = 0,
    layers: u32 = 0,
};

pub const CommandPoolCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: s.CommandPoolCreateFlags = std.mem.zeroes(s.CommandPoolCreateFlags),
    queueFamilyIndex: u32 = 0,
};

pub const CommandBufferAllocateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    commandPool: s.CommandPool = null,
    level: s.CommandBufferLevel = std.mem.zeroes(s.CommandBufferLevel),
    commandBufferCount: u32 = 0,
};

pub const CommandBufferBeginInfo = c.VkCommandBufferBeginInfo;

pub const RenderPassBeginInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    renderPass: s.RenderPass = null,
    framebuffer: s.Framebuffer = null,
    renderArea: Rect2D = std.mem.zeroes(Rect2D),
    clearValueCount: u32 = 0,
    pClearValues: ?[*]const ClearValue = null,
};

pub const SemaphoreCreateInfo = c.VkSemaphoreCreateInfo;

pub const FenceCreateInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: s.FenceCreateFlags = std.mem.zeroes(s.FenceCreateFlags),
};

pub const SubmitInfo = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32 = 0,
    pWaitSemaphores: [*]const s.Semaphore,
    pWaitDstStageMask: [*]const s.PipelineStageFlags,
    commandBufferCount: u32 = 0,
    pCommandBuffers: [*]const s.CommandBuffer,
    signalSemaphoreCount: u32 = 0,
    pSignalSemaphores: [*]const s.Semaphore,
};

pub const SubpassDependency = extern struct {
    srcSubpass: u32 = 0,
    dstSubpass: u32 = 0,
    srcStageMask: s.PipelineStageFlags = std.mem.zeroes(s.PipelineStageFlags),
    dstStageMask: s.PipelineStageFlags = std.mem.zeroes(s.PipelineStageFlags),
    srcAccessMask: c.VkAccessFlags = std.mem.zeroes(c.VkAccessFlags),
    dstAccessMask: c.VkAccessFlags = std.mem.zeroes(c.VkAccessFlags),
    dependencyFlags: c.VkDependencyFlags = std.mem.zeroes(c.VkDependencyFlags),
};

pub const PresentInfoKHR = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32 = 0,
    pWaitSemaphores: [*]const s.Semaphore,
    swapchainCount: u32 = 0,
    pSwapchains: [*]const s.SwapchainKHR,
    pImageIndices: [*]const u32,
    pResults: ?[*]s.Result,
};

pub const ClearValue = extern union {
    color: c.VkClearColorValue,
    depthStencil: c.VkClearDepthStencilValue,
};

pub const DebugUtilsMessengerCallbackData = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    flags: c.VkDebugUtilsMessengerCallbackDataFlagsEXT = std.mem.zeroes(c.VkDebugUtilsMessengerCallbackDataFlagsEXT),
    pMessageIdName: [*c]const u8 = std.mem.zeroes([*c]const u8),
    messageIdNumber: i32 = std.mem.zeroes(i32),
    pMessage: [*c]const u8 = std.mem.zeroes([*c]const u8),
    queueLabelCount: u32 = std.mem.zeroes(u32),
    pQueueLabels: [*c]const c.VkDebugUtilsLabelEXT = std.mem.zeroes([*c]const c.VkDebugUtilsLabelEXT),
    cmdBufLabelCount: u32 = std.mem.zeroes(u32),
    pCmdBufLabels: [*c]const c.VkDebugUtilsLabelEXT = std.mem.zeroes([*c]const c.VkDebugUtilsLabelEXT),
    objectCount: u32 = std.mem.zeroes(u32),
    pObjects: [*c]const c.VkDebugUtilsObjectNameInfoEXT = std.mem.zeroes([*c]const c.VkDebugUtilsObjectNameInfoEXT),
};

pub const DebugUtilsMessengerCreateInfoEXT = extern struct {
    sType: c.VkStructureType = std.mem.zeroes(c.VkStructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkDebugUtilsMessengerCreateFlagsEXT = std.mem.zeroes(c.VkDebugUtilsMessengerCreateFlagsEXT),
    messageSeverity: s.DebugUtilsMessageSeverityFlagsEXT = std.mem.zeroes(s.DebugUtilsMessageSeverityFlagsEXT),
    messageType: s.DebugUtilsMessageTypeFlagsEXT = std.mem.zeroes(s.DebugUtilsMessageTypeFlagsEXT),
    pfnUserCallback: s.DebugUtilsMessengerCallback = null,
    pUserData: ?*anyopaque = null,
};
