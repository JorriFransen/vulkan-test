const std = @import("std");

const c = @import("platform").c;

const s = @import("vulkan.zig");

pub const ApplicationInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    pApplicationName: [*:0]const u8,
    applicationVersion: u32 = 0,
    pEngineName: [*:0]const u8,
    engineVersion: u32 = 0,
    apiVersion: u32 = 0,
};

pub const ExtensionProperties = extern struct {
    extensionName: [256]u8 = std.mem.zeroes([256]u8),
    specVersion: u32 = 0,
};

pub const LayerProperties = extern struct {
    layerName: [256]u8 = std.mem.zeroes([256]u8),
    specVersion: u32 = 0,
    implementationVersion: u32 = 0,
    description: [256]u8 = std.mem.zeroes([256]u8),
};

pub const InstanceCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.InstanceCreateFlags = std.mem.zeroes(s.InstanceCreateFlags),
    pApplicationInfo: *const ApplicationInfo,
    enabledLayerCount: u32 = 0,
    ppEnabledLayerNames: ?[*]const [*:0]const u8 = null,
    enabledExtensionCount: u32 = 0,
    ppEnabledExtensionNames: ?[*]const [*:0]const u8 = null,
};

pub const AllocationCallbacks = extern struct {
    pUserData: ?*anyopaque = null,
    pfnAllocation: s.PFN_AllocationFunction = std.mem.zeroes(s.PFN_AllocationFunction),
    pfnReallocation: s.PFN_ReallocationFunction = std.mem.zeroes(s.PFN_ReallocationFunction),
    pfnFree: s.PFN_FreeFunction = std.mem.zeroes(s.PFN_FreeFunction),
    pfnInternalAllocation: s.PFN_InternalAllocationNotification = std.mem.zeroes(s.PFN_InternalAllocationNotification),
    pfnInternalFree: s.PFN_InternalFreeNotification = std.mem.zeroes(s.PFN_InternalFreeNotification),
};

pub const PhysicalDeviceProperties = extern struct {
    apiVersion: u32 = 0,
    driverVersion: u32 = 0,
    vendorID: u32 = 0,
    deviceID: u32 = 0,
    deviceType: s.PhysicalDeviceType,
    deviceName: [256]u8 = std.mem.zeroes([256]u8),
    pipelineCacheUUID: [16]u8 = std.mem.zeroes([16]u8),
    limits: PhysicalDeviceLimits,
    sparseProperties: PhysicalDeviceSparseProperties,
};

pub const PhysicalDeviceLimits = extern struct {
    maxImageDimension1D: u32 = 0,
    maxImageDimension2D: u32 = 0,
    maxImageDimension3D: u32 = 0,
    maxImageDimensionCube: u32 = 0,
    maxImageArrayLayers: u32 = 0,
    maxTexelBufferElements: u32 = 0,
    maxUniformBufferRange: u32 = 0,
    maxStorageBufferRange: u32 = 0,
    maxPushConstantsSize: u32 = 0,
    maxMemoryAllocationCount: u32 = 0,
    maxSamplerAllocationCount: u32 = 0,
    bufferImageGranularity: s.DeviceSize = 0,
    sparseAddressSpaceSize: s.DeviceSize = 0,
    maxBoundDescriptorSets: u32 = 0,
    maxPerStageDescriptorSamplers: u32 = 0,
    maxPerStageDescriptorUniformBuffers: u32 = 0,
    maxPerStageDescriptorStorageBuffers: u32 = 0,
    maxPerStageDescriptorSampledImages: u32 = 0,
    maxPerStageDescriptorStorageImages: u32 = 0,
    maxPerStageDescriptorInputAttachments: u32 = 0,
    maxPerStageResources: u32 = 0,
    maxDescriptorSetSamplers: u32 = 0,
    maxDescriptorSetUniformBuffers: u32 = 0,
    maxDescriptorSetUniformBuffersDynamic: u32 = 0,
    maxDescriptorSetStorageBuffers: u32 = 0,
    maxDescriptorSetStorageBuffersDynamic: u32 = 0,
    maxDescriptorSetSampledImages: u32 = 0,
    maxDescriptorSetStorageImages: u32 = 0,
    maxDescriptorSetInputAttachments: u32 = 0,
    maxVertexInputAttributes: u32 = 0,
    maxVertexInputBindings: u32 = 0,
    maxVertexInputAttributeOffset: u32 = 0,
    maxVertexInputBindingStride: u32 = 0,
    maxVertexOutputComponents: u32 = 0,
    maxTessellationGenerationLevel: u32 = 0,
    maxTessellationPatchSize: u32 = 0,
    maxTessellationControlPerVertexInputComponents: u32 = 0,
    maxTessellationControlPerVertexOutputComponents: u32 = 0,
    maxTessellationControlPerPatchOutputComponents: u32 = 0,
    maxTessellationControlTotalOutputComponents: u32 = 0,
    maxTessellationEvaluationInputComponents: u32 = 0,
    maxTessellationEvaluationOutputComponents: u32 = 0,
    maxGeometryShaderInvocations: u32 = 0,
    maxGeometryInputComponents: u32 = 0,
    maxGeometryOutputComponents: u32 = 0,
    maxGeometryOutputVertices: u32 = 0,
    maxGeometryTotalOutputComponents: u32 = 0,
    maxFragmentInputComponents: u32 = 0,
    maxFragmentOutputAttachments: u32 = 0,
    maxFragmentDualSrcAttachments: u32 = 0,
    maxFragmentCombinedOutputResources: u32 = 0,
    maxComputeSharedMemorySize: u32 = 0,
    maxComputeWorkGroupCount: [3]u32 = std.mem.zeroes([3]u32),
    maxComputeWorkGroupInvocations: u32 = 0,
    maxComputeWorkGroupSize: [3]u32 = std.mem.zeroes([3]u32),
    subPixelPrecisionBits: u32 = 0,
    subTexelPrecisionBits: u32 = 0,
    mipmapPrecisionBits: u32 = 0,
    maxDrawIndexedIndexValue: u32 = 0,
    maxDrawIndirectCount: u32 = 0,
    maxSamplerLodBias: f32 = 0,
    maxSamplerAnisotropy: f32 = 0,
    maxViewports: u32 = 0,
    maxViewportDimensions: [2]u32 = std.mem.zeroes([2]u32),
    viewportBoundsRange: [2]f32 = std.mem.zeroes([2]f32),
    viewportSubPixelBits: u32 = 0,
    minMemoryMapAlignment: usize = 0,
    minTexelBufferOffsetAlignment: s.DeviceSize = 0,
    minUniformBufferOffsetAlignment: s.DeviceSize = 0,
    minStorageBufferOffsetAlignment: s.DeviceSize = 0,
    minTexelOffset: i32 = 0,
    maxTexelOffset: u32 = 0,
    minTexelGatherOffset: i32 = 0,
    maxTexelGatherOffset: u32 = 0,
    minInterpolationOffset: f32 = 0,
    maxInterpolationOffset: f32 = 0,
    subPixelInterpolationOffsetBits: u32 = 0,
    maxFramebufferWidth: u32 = 0,
    maxFramebufferHeight: u32 = 0,
    maxFramebufferLayers: u32 = 0,
    framebufferColorSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    framebufferDepthSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    framebufferStencilSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    framebufferNoAttachmentsSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    maxColorAttachments: u32 = 0,
    sampledImageColorSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    sampledImageIntegerSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    sampledImageDepthSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    sampledImageStencilSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    storageImageSampleCounts: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    maxSampleMaskWords: u32 = 0,
    timestampComputeAndGraphics: s.Bool32 = s.FALSE,
    timestampPeriod: f32 = 0,
    maxClipDistances: u32 = 0,
    maxCullDistances: u32 = 0,
    maxCombinedClipAndCullDistances: u32 = 0,
    discreteQueuePriorities: u32 = 0,
    pointSizeRange: [2]f32 = std.mem.zeroes([2]f32),
    lineWidthRange: [2]f32 = std.mem.zeroes([2]f32),
    pointSizeGranularity: f32 = 0,
    lineWidthGranularity: f32 = 0,
    strictLines: s.Bool32 = s.FALSE,
    standardSampleLocations: s.Bool32 = s.FALSE,
    optimalBufferCopyOffsetAlignment: s.DeviceSize = 0,
    optimalBufferCopyRowPitchAlignment: s.DeviceSize = 0,
    nonCoherentAtomSize: s.DeviceSize = 0,
};

pub const PhysicalDeviceSparseProperties = extern struct {
    residencyStandard2DBlockShape: s.Bool32 = s.FALSE,
    residencyStandard2DMultisampleBlockShape: s.Bool32 = s.FALSE,
    residencyStandard3DBlockShape: s.Bool32 = s.FALSE,
    residencyAlignedMipSize: s.Bool32 = s.FALSE,
    residencyNonResidentStrict: s.Bool32 = s.FALSE,
};

pub const PhysicalDeviceFeatures = extern struct {
    robustBufferAccess: s.Bool32 = s.FALSE,
    fullDrawIndexUint32: s.Bool32 = s.FALSE,
    imageCubeArray: s.Bool32 = s.FALSE,
    independentBlend: s.Bool32 = s.FALSE,
    geometryShader: s.Bool32 = s.FALSE,
    tessellationShader: s.Bool32 = s.FALSE,
    sampleRateShading: s.Bool32 = s.FALSE,
    dualSrcBlend: s.Bool32 = s.FALSE,
    logicOp: s.Bool32 = s.FALSE,
    multiDrawIndirect: s.Bool32 = s.FALSE,
    drawIndirectFirstInstance: s.Bool32 = s.FALSE,
    depthClamp: s.Bool32 = s.FALSE,
    depthBiasClamp: s.Bool32 = s.FALSE,
    fillModeNonSolid: s.Bool32 = s.FALSE,
    depthBounds: s.Bool32 = s.FALSE,
    wideLines: s.Bool32 = s.FALSE,
    largePoints: s.Bool32 = s.FALSE,
    alphaToOne: s.Bool32 = s.FALSE,
    multiViewport: s.Bool32 = s.FALSE,
    samplerAnisotropy: s.Bool32 = s.FALSE,
    textureCompressionETC2: s.Bool32 = s.FALSE,
    textureCompressionASTC_LDR: s.Bool32 = s.FALSE,
    textureCompressionBC: s.Bool32 = s.FALSE,
    occlusionQueryPrecise: s.Bool32 = s.FALSE,
    pipelineStatisticsQuery: s.Bool32 = s.FALSE,
    vertexPipelineStoresAndAtomics: s.Bool32 = s.FALSE,
    fragmentStoresAndAtomics: s.Bool32 = s.FALSE,
    shaderTessellationAndGeometryPointSize: s.Bool32 = s.FALSE,
    shaderImageGatherExtended: s.Bool32 = s.FALSE,
    shaderStorageImageExtendedFormats: s.Bool32 = s.FALSE,
    shaderStorageImageMultisample: s.Bool32 = s.FALSE,
    shaderStorageImageReadWithoutFormat: s.Bool32 = s.FALSE,
    shaderStorageImageWriteWithoutFormat: s.Bool32 = s.FALSE,
    shaderUniformBufferArrayDynamicIndexing: s.Bool32 = s.FALSE,
    shaderSampledImageArrayDynamicIndexing: s.Bool32 = s.FALSE,
    shaderStorageBufferArrayDynamicIndexing: s.Bool32 = s.FALSE,
    shaderStorageImageArrayDynamicIndexing: s.Bool32 = s.FALSE,
    shaderClipDistance: s.Bool32 = s.FALSE,
    shaderCullDistance: s.Bool32 = s.FALSE,
    shaderFloat64: s.Bool32 = s.FALSE,
    shaderInt64: s.Bool32 = s.FALSE,
    shaderInt16: s.Bool32 = s.FALSE,
    shaderResourceResidency: s.Bool32 = s.FALSE,
    shaderResourceMinLod: s.Bool32 = s.FALSE,
    sparseBinding: s.Bool32 = s.FALSE,
    sparseResidencyBuffer: s.Bool32 = s.FALSE,
    sparseResidencyImage2D: s.Bool32 = s.FALSE,
    sparseResidencyImage3D: s.Bool32 = s.FALSE,
    sparseResidency2Samples: s.Bool32 = s.FALSE,
    sparseResidency4Samples: s.Bool32 = s.FALSE,
    sparseResidency8Samples: s.Bool32 = s.FALSE,
    sparseResidency16Samples: s.Bool32 = s.FALSE,
    sparseResidencyAliased: s.Bool32 = s.FALSE,
    variableMultisampleRate: s.Bool32 = s.FALSE,
    inheritedQueries: s.Bool32 = s.FALSE,
};

pub const QueueFamilyProperties = extern struct {
    queueFlags: s.QueueFlags = std.mem.zeroes(s.QueueFlags),
    queueCount: u32 = 0,
    timestampValidBits: u32 = 0,
    minImageTransferGranularity: Extent3D,
};

pub const DeviceQueueCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.DeviceQueueCreateFlags = std.mem.zeroes(s.DeviceQueueCreateFlags),
    queueFamilyIndex: u32 = 0,
    queueCount: u32 = 0,
    pQueuePriorities: [*]const f32,
};

pub const DeviceCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.DeviceCreateFlags = std.mem.zeroes(s.DeviceCreateFlags),
    queueCreateInfoCount: u32 = 0,
    pQueueCreateInfos: [*]const DeviceQueueCreateInfo,
    enabledLayerCount: u32 = 0,
    ppEnabledLayerNames: [*]const [*:0]const u8,
    enabledExtensionCount: u32 = 0,
    ppEnabledExtensionNames: [*]const [*:0]const u8,
    pEnabledFeatures: ?*const PhysicalDeviceFeatures = null,
};

pub const XcbSurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.XcbSurfaceCreateFlagsKHR = std.mem.zeroes(s.XcbSurfaceCreateFlagsKHR),
    connection: *s.xcb_connection_t,
    window: s.xcb_window_t = 0,
};

pub const XlibSurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.XlibSurfaceCreateFlagsKHR = std.mem.zeroes(s.XlibSurfaceCreateFlagsKHR),
    dpy: *s.Display,
    window: s.Window,
};

pub const Win32SurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.Win32SurfaceCreateFlagsKHR = std.mem.zeroes(s.Win32SurfaceCreateFlagsKHR),
    hinstance: s.HINSTANCE,
    hwnd: s.HWND,
};

pub const SurfaceCapabilitiesKHR = extern struct {
    minImageCount: u32 = 0,
    maxImageCount: u32 = 0,
    currentExtent: Extent2D,
    minImageExtent: Extent2D,
    maxImageExtent: Extent2D,
    maxImageArrayLayers: u32 = 0,
    supportedTransforms: s.SurfaceTransformFlagsKHR = std.mem.zeroes(s.SurfaceTransformFlagsKHR),
    currentTransform: s.SurfaceTransformFlagsKHR = std.mem.zeroes(s.SurfaceTransformFlagsKHR),
    supportedCompositeAlpha: s.CompositeAlphaFlagsKHR = std.mem.zeroes(s.CompositeAlphaFlagsKHR),
    supportedUsageFlags: s.ImageUsageFlags = std.mem.zeroes(s.ImageUsageFlags),
};

pub const SurfaceFormatKHR = extern struct {
    format: s.Format = std.mem.zeroes(s.Format),
    colorSpace: s.ColorSpaceKHR = std.mem.zeroes(s.ColorSpaceKHR),
};

pub const Extent3D = extern struct {
    width: u32 = 0,
    height: u32 = 0,
    depth: u32 = 0,
};

pub const Extent2D = extern struct {
    width: u32 = 0,
    height: u32 = 0,
};

pub const SwapchainCreateInfoKHR = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.SwapchainCreateFlagsKHR = std.mem.zeroes(s.SwapchainCreateFlagsKHR),
    surface: s.SurfaceKHR = null,
    minImageCount: u32 = 0,
    imageFormat: s.Format = std.mem.zeroes(s.Format),
    imageColorSpace: s.ColorSpaceKHR = std.mem.zeroes(s.ColorSpaceKHR),
    imageExtent: Extent2D,
    imageArrayLayers: u32 = 0,
    imageUsage: s.ImageUsageFlags,
    imageSharingMode: s.SharingMode,
    queueFamilyIndexCount: u32 = 0,
    pQueueFamilyIndices: ?[*]const u32,
    preTransform: s.SurfaceTransformFlagsKHR = std.mem.zeroes(s.SurfaceTransformFlagsKHR),
    compositeAlpha: s.CompositeAlphaFlagsKHR = std.mem.zeroes(s.CompositeAlphaFlagsKHR),
    presentMode: s.PresentModeKHR = std.mem.zeroes(s.PresentModeKHR),
    clipped: s.Bool32 = s.FALSE,
    oldSwapchain: s.SwapchainKHR = null,
};

pub const ImageViewCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.ImageViewCreateFlags = std.mem.zeroes(s.ImageViewCreateFlags),
    image: s.Image = null,
    viewType: s.ImageViewType = std.mem.zeroes(s.ImageViewType),
    format: s.Format = std.mem.zeroes(s.Format),
    components: ComponentMapping = std.mem.zeroes(ComponentMapping),
    subresourceRange: ImageSubresourceRange = std.mem.zeroes(ImageSubresourceRange),
};

pub const ComponentMapping = extern struct {
    r: s.ComponentSwizzle,
    g: s.ComponentSwizzle,
    b: s.ComponentSwizzle,
    a: s.ComponentSwizzle,
};

pub const ImageSubresourceRange = extern struct {
    aspectMask: s.ImageAspectFlags = std.mem.zeroes(s.ImageAspectFlags),
    baseMipLevel: u32 = 0,
    levelCount: u32 = 0,
    baseArrayLayer: u32 = 0,
    layerCount: u32 = 0,
};

pub const ShaderModuleCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.ShaderModuleCreateFlags = std.mem.zeroes(s.ShaderModuleCreateFlags),
    codeSize: usize,
    pCode: [*]const u32,
};

pub const PipelineShaderStageCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.PipelineShaderStageCreateFlags = std.mem.zeroes(s.PipelineShaderStageCreateFlags),
    stage: s.ShaderStageFlags,
    module: s.ShaderModule,
    pName: [*:0]const u8,
    pSpecializationInfo: ?*const SpecializationInfo = null,
};

pub const SpecializationInfo = extern struct {
    mapEntryCount: u32,
    pMapEntries: [*]const SpecializationMapEntry,
    dataSize: usize = 0,
    pData: ?*const anyopaque = null,
};

pub const SpecializationMapEntry = extern struct {
    constantID: u32 = 0,
    offset: u32 = 0,
    size: usize = 0,
};

pub const PipelineDynamicStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.PipelineDynamicStateCreateFlags = std.mem.zeroes(s.PipelineDynamicStateCreateFlags),
    dynamicStateCount: u32,
    pDynamicStates: [*]const s.DynamicState,
};

pub const PipelineVertexInputStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.PipelineVertexInputStateCreateFlags = 0,
    vertexBindingDescriptionCount: u32,
    pVertexBindingDescriptions: ?[*]const c.VkVertexInputBindingDescription,
    vertexAttributeDescriptionCount: u32,
    pVertexAttributeDescriptions: ?[*]const c.VkVertexInputAttributeDescription,
};

pub const PipelineInputAssemblyStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.PipelineInputAssemblyStateCreateFlags = std.mem.zeroes(s.PipelineInputAssemblyStateCreateFlags),
    topology: s.PrimitiveTopology = std.mem.zeroes(s.PrimitiveTopology),
    primitiveRestartEnable: s.Bool32 = s.FALSE,
};

pub const PipelineTessellationStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineTessellationStateCreateFlags = std.mem.zeroes(c.VkPipelineTessellationStateCreateFlags),
    patchControlPoints: u32 = 0,
};

pub const Viewport = extern struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    width: f32 = 0.0,
    height: f32 = 0.0,
    minDepth: f32 = 0.0,
    maxDepth: f32 = 0.0,
};

pub const Rect2D = extern struct {
    offset: c.VkOffset2D = std.mem.zeroes(c.VkOffset2D),
    extent: Extent2D = std.mem.zeroes(Extent2D),
};

pub const PipelineViewportStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineViewportStateCreateFlags = std.mem.zeroes(c.VkPipelineViewportStateCreateFlags),
    viewportCount: u32 = 0,
    pViewports: [*c]const s.Viewport = std.mem.zeroes([*c]const s.Viewport),
    scissorCount: u32 = 0,
    pScissors: [*c]const Rect2D = std.mem.zeroes([*c]const Rect2D),
};

pub const PipelineRasterizationStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineRasterizationStateCreateFlags = std.mem.zeroes(c.VkPipelineRasterizationStateCreateFlags),
    depthClampEnable: s.Bool32 = s.FALSE,
    rasterizerDiscardEnable: s.Bool32 = s.FALSE,
    polygonMode: s.PolygonMode = std.mem.zeroes(s.PolygonMode),
    cullMode: s.CullModeFlags = std.mem.zeroes(s.CullModeFlags),
    frontFace: s.FrontFace = std.mem.zeroes(s.FrontFace),
    depthBiasEnable: s.Bool32 = s.FALSE,
    depthBiasConstantFactor: f32 = 0.0,
    depthBiasClamp: f32 = 0.0,
    depthBiasSlopeFactor: f32 = 0.0,
    lineWidth: f32 = 0.0,
};

pub const PipelineMultisampleStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineMultisampleStateCreateFlags = std.mem.zeroes(c.VkPipelineMultisampleStateCreateFlags),
    rasterizationSamples: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    sampleShadingEnable: s.Bool32 = s.FALSE,
    minSampleShading: f32 = 0.0,
    pSampleMask: [*c]const c.VkSampleMask = std.mem.zeroes([*c]const c.VkSampleMask),
    alphaToCoverageEnable: s.Bool32 = s.FALSE,
    alphaToOneEnable: s.Bool32 = s.FALSE,
};

pub const PipelineDepthStencilStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineDepthStencilStateCreateFlags = std.mem.zeroes(c.VkPipelineDepthStencilStateCreateFlags),
    depthTestEnable: s.Bool32 = s.FALSE,
    depthWriteEnable: s.Bool32 = s.FALSE,
    depthCompareOp: c.VkCompareOp = std.mem.zeroes(c.VkCompareOp),
    depthBoundsTestEnable: s.Bool32 = s.FALSE,
    stencilTestEnable: s.Bool32 = s.FALSE,
    front: c.VkStencilOpState = std.mem.zeroes(c.VkStencilOpState),
    back: c.VkStencilOpState = std.mem.zeroes(c.VkStencilOpState),
    minDepthBounds: f32 = 0.0,
    maxDepthBounds: f32 = 0.0,
};

pub const PipelineColorBlendAttachmentState = extern struct {
    blendEnable: s.Bool32 = s.FALSE,
    srcColorBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    dstColorBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    colorBlendOp: s.BlendOp = std.mem.zeroes(s.BlendOp),
    srcAlphaBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    dstAlphaBlendFactor: s.BlendFactor = std.mem.zeroes(s.BlendFactor),
    alphaBlendOp: s.BlendOp = std.mem.zeroes(s.BlendOp),
    colorWriteMask: s.ColorComponentFlags = std.mem.zeroes(s.ColorComponentFlags),
};

pub const PipelineColorBlendStateCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineColorBlendStateCreateFlags = std.mem.zeroes(c.VkPipelineColorBlendStateCreateFlags),
    logicOpEnable: s.Bool32 = s.FALSE,
    logicOp: s.LogicOp = std.mem.zeroes(s.LogicOp),
    attachmentCount: u32 = 0,
    pAttachments: [*c]const PipelineColorBlendAttachmentState = null,
    blendConstants: [4]f32 = std.mem.zeroes([4]f32),
};

pub const PipelineLayoutCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineLayoutCreateFlags = std.mem.zeroes(c.VkPipelineLayoutCreateFlags),
    setLayoutCount: u32 = 0,
    pSetLayouts: [*c]const c.VkDescriptorSetLayout = std.mem.zeroes([*c]const c.VkDescriptorSetLayout),
    pushConstantRangeCount: u32 = 0,
    pPushConstantRanges: [*c]const c.VkPushConstantRange = std.mem.zeroes([*c]const c.VkPushConstantRange),
};

pub const AttachmentDescription = extern struct {
    flags: c.VkAttachmentDescriptionFlags = std.mem.zeroes(c.VkAttachmentDescriptionFlags),
    format: s.Format = std.mem.zeroes(s.Format),
    samples: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
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
    pInputAttachments: [*c]const s.AttachmentReference = null,
    colorAttachmentCount: u32 = 0,
    pColorAttachments: [*c]const AttachmentReference = null,
    pResolveAttachments: [*c]const s.AttachmentReference = null,
    pDepthStencilAttachment: [*c]const s.AttachmentReference = null,
    preserveAttachmentCount: u32 = 0,
    pPreserveAttachments: [*c]const u32 = null,
};

pub const RenderPassCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
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
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkPipelineCreateFlags = std.mem.zeroes(c.VkPipelineCreateFlags),
    stageCount: u32 = 0,
    pStages: [*c]const PipelineShaderStageCreateInfo = null,
    pVertexInputState: ?*const PipelineVertexInputStateCreateInfo = null,
    pInputAssemblyState: ?*const PipelineInputAssemblyStateCreateInfo = null,
    pTessellationState: ?*const PipelineTessellationStateCreateInfo = null,
    pViewportState: ?*const PipelineViewportStateCreateInfo = null,
    pRasterizationState: ?*const PipelineRasterizationStateCreateInfo = null,
    pMultisampleState: ?*const PipelineMultisampleStateCreateInfo = null,
    pDepthStencilState: ?*const PipelineDepthStencilStateCreateInfo = null,
    pColorBlendState: ?*const PipelineColorBlendStateCreateInfo = null,
    pDynamicState: ?*const PipelineDynamicStateCreateInfo = null,
    layout: s.PipelineLayout = std.mem.zeroes(s.PipelineLayout),
    renderPass: s.RenderPass = null,
    subpass: u32 = 0,
    basePipelineHandle: s.Pipeline = null,
    basePipelineIndex: i32 = 0,
};

pub const FramebufferCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
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
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.CommandPoolCreateFlags = std.mem.zeroes(s.CommandPoolCreateFlags),
    queueFamilyIndex: u32 = 0,
};

pub const CommandBufferAllocateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    commandPool: s.CommandPool = null,
    level: s.CommandBufferLevel = std.mem.zeroes(s.CommandBufferLevel),
    commandBufferCount: u32 = 0,
};

pub const CommandBufferBeginInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkCommandBufferUsageFlags = std.mem.zeroes(c.VkCommandBufferUsageFlags),
    pInheritanceInfo: [*c]const c.VkCommandBufferInheritanceInfo = std.mem.zeroes([*c]const c.VkCommandBufferInheritanceInfo),
};

pub const RenderPassBeginInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    renderPass: s.RenderPass = null,
    framebuffer: s.Framebuffer = null,
    renderArea: Rect2D = std.mem.zeroes(Rect2D),
    clearValueCount: u32 = 0,
    pClearValues: ?[*]const ClearValue = null,
};

pub const SemaphoreCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkSemaphoreCreateFlags = std.mem.zeroes(c.VkSemaphoreCreateFlags),
};

pub const FenceCreateInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: s.FenceCreateFlags = std.mem.zeroes(s.FenceCreateFlags),
};

pub const SubmitInfo = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
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
    srcAccessMask: s.AccessFlags = std.mem.zeroes(s.AccessFlags),
    dstAccessMask: s.AccessFlags = std.mem.zeroes(s.AccessFlags),
    dependencyFlags: c.VkDependencyFlags = std.mem.zeroes(c.VkDependencyFlags),
};

pub const PresentInfoKHR = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
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
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkDebugUtilsMessengerCallbackDataFlagsEXT = std.mem.zeroes(c.VkDebugUtilsMessengerCallbackDataFlagsEXT),
    pMessageIdName: [*c]const u8 = std.mem.zeroes([*c]const u8),
    messageIdNumber: i32 = 0,
    pMessage: [*c]const u8 = std.mem.zeroes([*c]const u8),
    queueLabelCount: u32 = 0,
    pQueueLabels: [*c]const c.VkDebugUtilsLabelEXT = std.mem.zeroes([*c]const c.VkDebugUtilsLabelEXT),
    cmdBufLabelCount: u32 = 0,
    pCmdBufLabels: [*c]const c.VkDebugUtilsLabelEXT = std.mem.zeroes([*c]const c.VkDebugUtilsLabelEXT),
    objectCount: u32 = 0,
    pObjects: [*c]const c.VkDebugUtilsObjectNameInfoEXT = std.mem.zeroes([*c]const c.VkDebugUtilsObjectNameInfoEXT),
};

pub const DebugUtilsMessengerCreateInfoEXT = extern struct {
    sType: s.StructureType = std.mem.zeroes(s.StructureType),
    pNext: ?*const anyopaque = null,
    flags: c.VkDebugUtilsMessengerCreateFlagsEXT = std.mem.zeroes(c.VkDebugUtilsMessengerCreateFlagsEXT),
    messageSeverity: s.DebugUtilsMessageSeverityFlagsEXT = std.mem.zeroes(s.DebugUtilsMessageSeverityFlagsEXT),
    messageType: s.DebugUtilsMessageTypeFlagsEXT = std.mem.zeroes(s.DebugUtilsMessageTypeFlagsEXT),
    pfnUserCallback: s.DebugUtilsMessengerCallback = null,
    pUserData: ?*anyopaque = null,
};
