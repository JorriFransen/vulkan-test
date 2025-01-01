const std = @import("std");
const s = @import("vulkan.zig");

pub const ApplicationInfo = extern struct {
    sType: s.StructureType,
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
    sType: s.StructureType,
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
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.DeviceQueueCreateFlags = std.mem.zeroes(s.DeviceQueueCreateFlags),
    queueFamilyIndex: u32 = 0,
    queueCount: u32 = 0,
    pQueuePriorities: [*]const f32,
};

pub const DeviceCreateInfo = extern struct {
    sType: s.StructureType,
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
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.XcbSurfaceCreateFlagsKHR = std.mem.zeroes(s.XcbSurfaceCreateFlagsKHR),
    connection: *s.x.xcb_connection_t,
    window: s.x.xcb_window_t = 0,
};

pub const XlibSurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.XlibSurfaceCreateFlagsKHR = std.mem.zeroes(s.XlibSurfaceCreateFlagsKHR),
    dpy: *s.x.Display,
    window: s.x.Window,
};

pub const Win32SurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.Win32SurfaceCreateFlagsKHR = std.mem.zeroes(s.Win32SurfaceCreateFlagsKHR),
    hinstance: s.win32.HINSTANCE,
    hwnd: s.win32.HWND,
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
    sType: s.StructureType,
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
    sType: s.StructureType,
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
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.ShaderModuleCreateFlags = std.mem.zeroes(s.ShaderModuleCreateFlags),
    codeSize: usize,
    pCode: [*]const u32,
};

pub const PipelineShaderStageCreateInfo = extern struct {
    sType: s.StructureType,
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
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineDynamicStateCreateFlags = std.mem.zeroes(s.PipelineDynamicStateCreateFlags),
    dynamicStateCount: u32,
    pDynamicStates: [*]const s.DynamicState,
};

pub const VertexInputBindingDescription = extern struct {
    binding: u32,
    stride: u32,
    inputRate: s.VertexInputRate,
};

pub const VertexInputAttributeDescription = extern struct {
    location: u32,
    binding: u32,
    format: s.Format,
    offset: u32,
};

pub const PipelineVertexInputStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineVertexInputStateCreateFlags = 0,
    vertexBindingDescriptionCount: u32,
    pVertexBindingDescriptions: ?[*]const VertexInputBindingDescription,
    vertexAttributeDescriptionCount: u32,
    pVertexAttributeDescriptions: ?[*]const VertexInputAttributeDescription,
};

pub const PipelineInputAssemblyStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineInputAssemblyStateCreateFlags = std.mem.zeroes(s.PipelineInputAssemblyStateCreateFlags),
    topology: s.PrimitiveTopology = std.mem.zeroes(s.PrimitiveTopology),
    primitiveRestartEnable: s.Bool32 = s.FALSE,
};

pub const PipelineTessellationStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineTessellationStateCreateFlags = std.mem.zeroes(s.PipelineTessellationStateCreateFlags),
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

pub const Offset2D = extern struct {
    x: i32 = 0,
    y: i32 = 0,
};

pub const Rect2D = extern struct {
    offset: Offset2D = .{},
    extent: Extent2D = .{},
};

pub const PipelineViewportStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineViewportStateCreateFlags = std.mem.zeroes(s.PipelineViewportStateCreateFlags),
    viewportCount: u32,
    pViewports: ?[*]const s.Viewport = null,
    scissorCount: u32,
    pScissors: ?[*]const Rect2D = null,
};

pub const PipelineRasterizationStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineRasterizationStateCreateFlags = std.mem.zeroes(s.PipelineRasterizationStateCreateFlags),
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
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineMultisampleStateCreateFlags = std.mem.zeroes(s.PipelineMultisampleStateCreateFlags),
    rasterizationSamples: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    sampleShadingEnable: s.Bool32 = s.FALSE,
    minSampleShading: f32 = 0.0,
    pSampleMask: ?[*]const s.SampleMask = null,
    alphaToCoverageEnable: s.Bool32 = s.FALSE,
    alphaToOneEnable: s.Bool32 = s.FALSE,
};

pub const PipelineDepthStencilStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineDepthStencilStateCreateFlags = std.mem.zeroes(s.PipelineDepthStencilStateCreateFlags),
    depthTestEnable: s.Bool32 = s.FALSE,
    depthWriteEnable: s.Bool32 = s.FALSE,
    depthCompareOp: s.CompareOp = std.mem.zeroes(s.CompareOp),
    depthBoundsTestEnable: s.Bool32 = s.FALSE,
    stencilTestEnable: s.Bool32 = s.FALSE,
    front: StencilOpState = std.mem.zeroes(StencilOpState),
    back: StencilOpState = std.mem.zeroes(StencilOpState),
    minDepthBounds: f32 = 0.0,
    maxDepthBounds: f32 = 0.0,
};

pub const StencilOpState = extern struct {
    failOp: s.StencilOp,
    passOp: s.StencilOp,
    depthFailOp: s.StencilOp,
    compareOp: s.CompareOp,
    compareMask: u32 = 0,
    writeMask: u32 = 0,
    reference: u32 = 0,
};

pub const PipelineColorBlendAttachmentState = extern struct {
    blendEnable: s.Bool32 = s.FALSE,
    srcColorBlendFactor: s.BlendFactor,
    dstColorBlendFactor: s.BlendFactor,
    colorBlendOp: s.BlendOp,
    srcAlphaBlendFactor: s.BlendFactor,
    dstAlphaBlendFactor: s.BlendFactor,
    alphaBlendOp: s.BlendOp,
    colorWriteMask: s.ColorComponentFlags,
};

pub const PipelineColorBlendStateCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineColorBlendStateCreateFlags = std.mem.zeroes(s.PipelineColorBlendStateCreateFlags),
    logicOpEnable: s.Bool32 = s.FALSE,
    logicOp: s.LogicOp,
    attachmentCount: u32 = 0,
    pAttachments: ?[*]const PipelineColorBlendAttachmentState = null,
    blendConstants: [4]f32 = std.mem.zeroes([4]f32),
};

pub const PipelineLayoutCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineLayoutCreateFlags,
    setLayoutCount: u32,
    pSetLayouts: ?[*]const s.DescriptorSetLayout = null,
    pushConstantRangeCount: u32,
    pPushConstantRanges: ?[*]const s.PushConstantRange,
};

pub const PushConstantRange = extern struct {
    stageFlags: s.ShaderStageFlags,
    offset: u32,
    size: u32,
};

pub const AttachmentDescription = extern struct {
    flags: s.AttachmentDescriptionFlags = std.mem.zeroes(s.AttachmentDescriptionFlags),
    format: s.Format,
    samples: s.SampleCountFlags,
    loadOp: s.AttachmentLoadOp,
    storeOp: s.AttachmentStoreOp,
    stencilLoadOp: s.AttachmentLoadOp,
    stencilStoreOp: s.AttachmentStoreOp,
    initialLayout: s.ImageLayout,
    finalLayout: s.ImageLayout,
};

pub const AttachmentReference = extern struct {
    attachment: u32,
    layout: s.ImageLayout,
};

pub const SubpassDescription = extern struct {
    flags: s.SubpassDescriptionFlags = std.mem.zeroes(s.SubpassDescriptionFlags),
    pipelineBindPoint: s.PipelineBindPoint = std.mem.zeroes(s.PipelineBindPoint),
    inputAttachmentCount: u32,
    pInputAttachments: ?[*]const s.AttachmentReference = null,
    colorAttachmentCount: u32,
    pColorAttachments: ?[*]const AttachmentReference = null,
    pResolveAttachments: ?[*]const s.AttachmentReference = null,
    pDepthStencilAttachment: ?[*]const s.AttachmentReference = null,
    preserveAttachmentCount: u32,
    pPreserveAttachments: ?[*]const u32 = null,
};

pub const RenderPassCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.RenderPassCreateFlags = std.mem.zeroes(s.RenderPassCreateFlags),
    attachmentCount: u32,
    pAttachments: ?[*]const AttachmentDescription = null,
    subpassCount: u32,
    pSubpasses: ?[*]const SubpassDescription = null,
    dependencyCount: u32,
    pDependencies: ?[*]const SubpassDependency = null,
};

pub const GraphicsPipelineCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineCreateFlags = std.mem.zeroes(s.PipelineCreateFlags),
    stageCount: u32,
    pStages: [*]const PipelineShaderStageCreateInfo,
    pVertexInputState: ?*const PipelineVertexInputStateCreateInfo = null,
    pInputAssemblyState: ?*const PipelineInputAssemblyStateCreateInfo = null,
    pTessellationState: ?*const PipelineTessellationStateCreateInfo = null,
    pViewportState: ?*const PipelineViewportStateCreateInfo = null,
    pRasterizationState: ?*const PipelineRasterizationStateCreateInfo = null,
    pMultisampleState: ?*const PipelineMultisampleStateCreateInfo = null,
    pDepthStencilState: ?*const PipelineDepthStencilStateCreateInfo = null,
    pColorBlendState: ?*const PipelineColorBlendStateCreateInfo = null,
    pDynamicState: ?*const PipelineDynamicStateCreateInfo = null,
    layout: s.PipelineLayout,
    renderPass: s.RenderPass,
    subpass: u32,
    basePipelineHandle: s.Pipeline,
    basePipelineIndex: i32,
};

pub const FramebufferCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.FramebufferCreateFlags = std.mem.zeroes(s.FramebufferCreateFlags),
    renderPass: s.RenderPass,
    attachmentCount: u32,
    pAttachments: ?[*]const s.ImageView,
    width: u32,
    height: u32,
    layers: u32,
};

pub const CommandPoolCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.CommandPoolCreateFlags = std.mem.zeroes(s.CommandPoolCreateFlags),
    queueFamilyIndex: u32,
};

pub const CommandBufferAllocateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    commandPool: s.CommandPool,
    level: s.CommandBufferLevel = std.mem.zeroes(s.CommandBufferLevel),
    commandBufferCount: u32,
};

pub const CommandBufferBeginInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.CommandBufferUsageFlags = std.mem.zeroes(s.CommandBufferUsageFlags),
    pInheritanceInfo: ?*const s.CommandBufferInheritanceInfo = null,
};

pub const CommandBufferInheritanceInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    renderPass: s.RenderPass = null,
    subpass: u32,
    framebuffer: s.Framebuffer,
    occlusionQueryEnable: s.Bool32 = s.FALSE,
    queryFlags: s.QueryControlFlags = std.mem.zeroes(s.QueryControlFlags),
    pipelineStatistics: s.QueryPipelineStatisticFlags = std.mem.zeroes(s.QueryPipelineStatisticFlags),
};

pub const RenderPassBeginInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    renderPass: s.RenderPass,
    framebuffer: s.Framebuffer,
    renderArea: Rect2D = .{},
    clearValueCount: u32,
    pClearValues: ?[*]const ClearValue = null,
};

pub const SemaphoreCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.SemaphoreCreateFlags = std.mem.zeroes(s.SemaphoreCreateFlags),
};

pub const FenceCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.FenceCreateFlags = std.mem.zeroes(s.FenceCreateFlags),
};

pub const SubmitInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32 = 0,
    pWaitSemaphores: [*]const s.Semaphore = undefined,
    pWaitDstStageMask: [*]const s.PipelineStageFlags = undefined,
    commandBufferCount: u32 = 0,
    pCommandBuffers: [*]const s.CommandBuffer = undefined,
    signalSemaphoreCount: u32 = 0,
    pSignalSemaphores: [*]const s.Semaphore = undefined,
};

pub const SubpassDependency = extern struct {
    srcSubpass: u32,
    dstSubpass: u32,
    srcStageMask: s.PipelineStageFlags = std.mem.zeroes(s.PipelineStageFlags),
    dstStageMask: s.PipelineStageFlags = std.mem.zeroes(s.PipelineStageFlags),
    srcAccessMask: s.AccessFlags = std.mem.zeroes(s.AccessFlags),
    dstAccessMask: s.AccessFlags = std.mem.zeroes(s.AccessFlags),
    dependencyFlags: s.DependencyFlags = std.mem.zeroes(s.DependencyFlags),
};

pub const PresentInfoKHR = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32,
    pWaitSemaphores: [*]const s.Semaphore,
    swapchainCount: u32,
    pSwapchains: [*]const s.SwapchainKHR,
    pImageIndices: [*]const u32,
    pResults: ?[*]s.Result,
};

pub const ClearColorValue = extern union {
    float32: [4]f32,
    int32: [4]i32,
    uint32: [4]u32,
};

pub const ClearDepthStencilValue = extern struct {
    depth: f32 = 0.0,
    stencil: u32 = 0,
};

pub const ClearValue = extern union {
    color: s.ClearColorValue,
    depthStencil: s.ClearDepthStencilValue,
};

pub const DebugUtilsLabelEXT = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    pLabelName: [*:0]const u8,
    color: [4]f32,
};

pub const DebugUtilsObjectNameInfoEXT = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = std.mem.zeroes(?*const anyopaque),
    objectType: s.ObjectType = std.mem.zeroes(s.ObjectType),
    objectHandle: u64 = 0,
    pObjectName: [*:0]const u8,
};

pub const DebugUtilsMessengerCallbackData = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.DebugUtilsMessengerCallbackDataFlagsEXT,
    pMessageIdName: [*:0]const u8,
    messageIdNumber: i32 = 0,
    pMessage: [*:0]const u8,
    queueLabelCount: u32 = 0,
    pQueueLabels: [*]const s.DebugUtilsLabelEXT,
    cmdBufLabelCount: u32 = 0,
    pCmdBufLabels: [*]const s.DebugUtilsLabelEXT,
    objectCount: u32 = 0,
    pObjects: [*]const s.DebugUtilsObjectNameInfoEXT,
};

pub const DebugUtilsMessengerCreateInfoEXT = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.DebugUtilsMessengerCreateFlagsEXT = std.mem.zeroes(s.DebugUtilsMessengerCreateFlagsEXT),
    messageSeverity: s.DebugUtilsMessageSeverityFlagsEXT,
    messageType: s.DebugUtilsMessageTypeFlagsEXT,
    pfnUserCallback: s.DebugUtilsMessengerCallback,
    pUserData: ?*anyopaque = null,
};

pub const BufferCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.BufferCreateFlags = std.mem.zeroes(s.BufferCreateFlags),
    size: s.DeviceSize = 0,
    usage: s.BufferUsageFlags = std.mem.zeroes(s.BufferUsageFlags),
    sharingMode: s.SharingMode = std.mem.zeroes(s.SharingMode),
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ?[*]const u32 = null,
};

pub const MemoryRequirements = extern struct {
    size: s.DeviceSize = 0,
    alignment: s.DeviceSize = 0,
    memoryTypeBits: u32 = 0,
};

pub const PhysicalDeviceMemoryProperties = extern struct {
    memoryTypeCount: u32,
    memoryTypes: [s.MAX_MEMORY_TYPES]MemoryType,
    memoryHeapCount: u32,
    memoryHeaps: [s.MAX_MEMORY_HEAPS]MemoryHeap,
};

pub const MemoryType = extern struct {
    propertyFlags: s.MemoryPropertyFlags,
    heapIndex: u32,
};

pub const MemoryHeap = extern struct {
    size: s.DeviceSize,
    flags: s.MemoryHeapFlags,
};

pub const MemoryAllocateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    allocationSize: s.DeviceSize = std.mem.zeroes(s.DeviceSize),
    memoryTypeIndex: u32 = 0,
};

pub const BufferCopy = extern struct {
    srcOffset: s.DeviceSize = 0,
    dstOffset: s.DeviceSize = 0,
    size: s.DeviceSize,
};

pub const DescriptorSetLayoutBinding = extern struct {
    binding: u32,
    descriptorType: s.DescriptorType,
    descriptorCount: u32,
    stageFlags: s.ShaderStageFlags,
    pImmutableSamplers: ?[*]const s.Sampler = null,
};

pub const DescriptorSetLayoutCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.DescriptorSetLayoutCreateFlags,
    bindingCount: u32,
    pBindings: [*]const s.DescriptorSetLayoutBinding,
};

pub const DescriptorPoolSize = extern struct {
    type: s.DescriptorType,
    descriptorCount: u32,
};

pub const DescriptorPoolCreateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    flags: s.DescriptorPoolCreateFlags = std.mem.zeroes(s.DescriptorPoolCreateFlags),
    maxSets: u32,
    poolSizeCount: u32,
    pPoolSizes: [*]const s.DescriptorPoolSize,
};

pub const DescriptorSetAllocateInfo = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    descriptorPool: s.DescriptorPool,
    descriptorSetCount: u32,
    pSetLayouts: [*]const s.DescriptorSetLayout,
};

pub const DescriptorBufferInfo = extern struct {
    buffer: s.Buffer,
    offset: s.DeviceSize,
    range: s.DeviceSize,
};

pub const WriteDescriptorSet = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    dstSet: s.DescriptorSet,
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
    descriptorType: s.DescriptorType,
    pImageInfo: ?[*]const s.DescriptorImageInfo,
    pBufferInfo: ?[*]const s.DescriptorBufferInfo,
    pTexelBufferView: ?[*]const s.BufferView,
};

pub const DescriptorImageInfo = extern struct {
    sampler: s.Sampler,
    imageView: s.ImageView,
    imageLayout: s.ImageLayout,
};

pub const CopyDescriptorSet = extern struct {
    sType: s.StructureType,
    pNext: ?*const anyopaque = null,
    srcSet: s.DescriptorSet,
    srcBinding: u32,
    srcArrayElement: u32,
    dstSet: s.DescriptorSet,
    dstBinding: u32,
    dstArrayElement: u32,
    descriptorCount: u32,
};
