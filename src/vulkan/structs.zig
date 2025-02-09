const std = @import("std");
const s = @import("vulkan.zig");

const zero = std.mem.zeroes;

pub const ApplicationInfo = extern struct {
    sType: s.StructureType = .APPLICATION_INFO,
    pNext: ?*const anyopaque = null,
    pApplicationName: ?[*:0]const u8 = null,
    applicationVersion: u32 = 0,
    pEngineName: ?[*:0]const u8 = null,
    engineVersion: u32 = 0,
    apiVersion: u32 = 0,
};

pub const ExtensionProperties = extern struct {
    extensionName: [256]u8 = zero([256]u8),
    specVersion: u32 = 0,
};

pub const LayerProperties = extern struct {
    layerName: [256]u8 = zero([256]u8),
    specVersion: u32 = 0,
    implementationVersion: u32 = 0,
    description: [256]u8 = zero([256]u8),
};

pub const InstanceCreateInfo = extern struct {
    sType: s.StructureType = .INSTANCE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.InstanceCreateFlags = .{},
    pApplicationInfo: *const ApplicationInfo,
    enabledLayerCount: u32,
    ppEnabledLayerNames: [*]const [*:0]const u8,
    enabledExtensionCount: u32,
    ppEnabledExtensionNames: [*]const [*:0]const u8,
};

pub const AllocationCallbacks = extern struct {
    pUserData: ?*anyopaque = null,
    pfnAllocation: s.PFN_AllocationFunction = null,
    pfnReallocation: s.PFN_ReallocationFunction = null,
    pfnFree: s.PFN_FreeFunction = null,
    pfnInternalAllocation: s.PFN_InternalAllocationNotification = null,
    pfnInternalFree: s.PFN_InternalFreeNotification = null,
};

pub const PhysicalDeviceProperties = extern struct {
    apiVersion: u32,
    driverVersion: u32,
    vendorID: u32,
    deviceID: u32,
    deviceType: s.PhysicalDeviceType = @enumFromInt(0),
    deviceName: [256]u8 = zero([256]u8),
    pipelineCacheUUID: [16]u8 = zero([16]u8),
    limits: PhysicalDeviceLimits = .{},
    sparseProperties: PhysicalDeviceSparseProperties = .{},
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
    maxComputeWorkGroupCount: [3]u32 = zero([3]u32),
    maxComputeWorkGroupInvocations: u32 = 0,
    maxComputeWorkGroupSize: [3]u32 = zero([3]u32),
    subPixelPrecisionBits: u32 = 0,
    subTexelPrecisionBits: u32 = 0,
    mipmapPrecisionBits: u32 = 0,
    maxDrawIndexedIndexValue: u32 = 0,
    maxDrawIndirectCount: u32 = 0,
    maxSamplerLodBias: f32 = 0,
    maxSamplerAnisotropy: f32 = 0,
    maxViewports: u32 = 0,
    maxViewportDimensions: [2]u32 = zero([2]u32),
    viewportBoundsRange: [2]f32 = zero([2]f32),
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
    framebufferColorSampleCounts: s.SampleCountFlags = .{},
    framebufferDepthSampleCounts: s.SampleCountFlags = .{},
    framebufferStencilSampleCounts: s.SampleCountFlags = .{},
    framebufferNoAttachmentsSampleCounts: s.SampleCountFlags = .{},
    maxColorAttachments: u32 = 0,
    sampledImageColorSampleCounts: s.SampleCountFlags = .{},
    sampledImageIntegerSampleCounts: s.SampleCountFlags = .{},
    sampledImageDepthSampleCounts: s.SampleCountFlags = .{},
    sampledImageStencilSampleCounts: s.SampleCountFlags = .{},
    storageImageSampleCounts: s.SampleCountFlags = .{},
    maxSampleMaskWords: u32 = 0,
    timestampComputeAndGraphics: s.Bool32 = s.FALSE,
    timestampPeriod: f32 = 0,
    maxClipDistances: u32 = 0,
    maxCullDistances: u32 = 0,
    maxCombinedClipAndCullDistances: u32 = 0,
    discreteQueuePriorities: u32 = 0,
    pointSizeRange: [2]f32 = zero([2]f32),
    lineWidthRange: [2]f32 = zero([2]f32),
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
    queueFlags: s.QueueFlags = .{},
    queueCount: u32 = 0,
    timestampValidBits: u32 = 0,
    minImageTransferGranularity: Extent3D = .{},
};

pub const DeviceQueueCreateInfo = extern struct {
    sType: s.StructureType = .DEVICE_QUEUE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.DeviceQueueCreateFlags = .{},
    queueFamilyIndex: u32 = 0,
    queueCount: u32 = 0,
    pQueuePriorities: [*]const f32,
};

pub const DeviceCreateInfo = extern struct {
    sType: s.StructureType = .DEVICE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.DeviceCreateFlags = 0,
    queueCreateInfoCount: u32 = 0,
    pQueueCreateInfos: [*]const DeviceQueueCreateInfo,
    enabledLayerCount: u32,
    ppEnabledLayerNames: [*]const [*:0]const u8,
    enabledExtensionCount: u32,
    ppEnabledExtensionNames: [*]const [*:0]const u8,
    pEnabledFeatures: ?*const PhysicalDeviceFeatures = null,
};

pub const XcbSurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType = .XCB_SURFACE_CREATE_INFO_KHR,
    pNext: ?*const anyopaque = null,
    flags: s.XcbSurfaceCreateFlagsKHR = 0,
    connection: *s.x.xcb_connection_t,
    window: s.x.xcb_window_t,
};

pub const XlibSurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType = .XLIB_SURFACE_CREATE_INFO_KHR,
    pNext: ?*const anyopaque = null,
    flags: s.XlibSurfaceCreateFlagsKHR = 0,
    dpy: *s.x.Display,
    window: s.x.Window,
};

pub const Win32SurfaceCreateInfoKHR = extern struct {
    sType: s.StructureType = .WIN32_SURFACE_CREATE_INFO_KHR,
    pNext: ?*const anyopaque = null,
    flags: s.Win32SurfaceCreateFlagsKHR = 0,
    hinstance: s.win32.HINSTANCE,
    hwnd: s.win32.HWND,
};

pub const SurfaceCapabilitiesKHR = extern struct {
    minImageCount: u32 = 0,
    maxImageCount: u32 = 0,
    currentExtent: Extent2D = .{},
    minImageExtent: Extent2D = .{},
    maxImageExtent: Extent2D = .{},
    maxImageArrayLayers: u32 = 0,
    supportedTransforms: s.SurfaceTransformFlagsKHR = .{},
    currentTransform: s.SurfaceTransformFlagsKHR = .{},
    supportedCompositeAlpha: s.CompositeAlphaFlagsKHR = .{},
    supportedUsageFlags: s.ImageUsageFlags = .{},
};

pub const SurfaceFormatKHR = extern struct {
    format: s.Format = @enumFromInt(0),
    colorSpace: s.ColorSpaceKHR = @enumFromInt(0),
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
    sType: s.StructureType = .SWAPCHAIN_CREATE_INFO_KHR,
    pNext: ?*const anyopaque = null,
    flags: s.SwapchainCreateFlagsKHR = .{},
    surface: s.SurfaceKHR = null,
    minImageCount: u32 = 0,
    imageFormat: s.Format = @enumFromInt(0),
    imageColorSpace: s.ColorSpaceKHR = @enumFromInt(0),
    imageExtent: Extent2D = .{},
    imageArrayLayers: u32 = 0,
    imageUsage: s.ImageUsageFlags = .{},
    imageSharingMode: s.SharingMode = @enumFromInt(0),
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ?[*]const u32,
    preTransform: s.SurfaceTransformFlagsKHR = .{},
    compositeAlpha: s.CompositeAlphaFlagsKHR = .{},
    presentMode: s.PresentModeKHR = @enumFromInt(0),
    clipped: s.Bool32 = s.FALSE,
    oldSwapchain: s.SwapchainKHR = null,
};

pub const ImageViewCreateInfo = extern struct {
    sType: s.StructureType = .IMAGE_VIEW_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.ImageViewCreateFlags = .{},
    image: s.Image = null,
    viewType: s.ImageViewType = @enumFromInt(0),
    format: s.Format = @enumFromInt(0),
    components: ComponentMapping = .{},
    subresourceRange: ImageSubresourceRange = .{},
};

pub const ComponentMapping = extern struct {
    r: s.ComponentSwizzle = .IDENTITY,
    g: s.ComponentSwizzle = .IDENTITY,
    b: s.ComponentSwizzle = .IDENTITY,
    a: s.ComponentSwizzle = .IDENTITY,
};

pub const ImageSubresourceRange = extern struct {
    aspectMask: s.ImageAspectFlags = zero(s.ImageAspectFlags),
    baseMipLevel: u32 = 0,
    levelCount: u32 = 0,
    baseArrayLayer: u32 = 0,
    layerCount: u32 = 0,
};

pub const ShaderModuleCreateInfo = extern struct {
    sType: s.StructureType = .SHADER_MODULE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.ShaderModuleCreateFlags = .{},
    codeSize: usize,
    pCode: [*]const u32,
};

pub const PipelineShaderStageCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineShaderStageCreateFlags = 0,
    stage: s.ShaderStageFlags = .{},
    module: s.ShaderModule = null,
    pName: [*:0]const u8,
    pSpecializationInfo: ?*const SpecializationInfo = null,
};

pub const SpecializationInfo = extern struct {
    mapEntryCount: u32 = 0,
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
    sType: s.StructureType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineDynamicStateCreateFlags = 0,
    dynamicStateCount: u32,
    pDynamicStates: [*]const s.DynamicState,
};

pub const VertexInputBindingDescription = extern struct {
    binding: u32 = 0,
    stride: u32 = 0,
    inputRate: s.VertexInputRate = @enumFromInt(0),
};

pub const VertexInputAttributeDescription = extern struct {
    location: u32 = 0,
    binding: u32 = 0,
    format: s.Format = @enumFromInt(0),
    offset: u32 = 0,
};

pub const PipelineVertexInputStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineVertexInputStateCreateFlags = 0,
    vertexBindingDescriptionCount: u32,
    pVertexBindingDescriptions: ?[*]const VertexInputBindingDescription,
    vertexAttributeDescriptionCount: u32,
    pVertexAttributeDescriptions: ?[*]const VertexInputAttributeDescription,
};

pub const PipelineInputAssemblyStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineInputAssemblyStateCreateFlags = 0,
    topology: s.PrimitiveTopology = @enumFromInt(0),
    primitiveRestartEnable: s.Bool32 = s.FALSE,
};

pub const PipelineTessellationStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_TESSELLATION_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineTessellationStateCreateFlags = 0,
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

pub const Offset3D = extern struct {
    x: i32 = 0,
    y: i32 = 0,
    z: i32 = 0,
};

pub const Rect2D = extern struct {
    offset: Offset2D = .{},
    extent: Extent2D = .{},
};

pub const PipelineViewportStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineViewportStateCreateFlags = 0,
    viewportCount: u32,
    pViewports: ?[*]const s.Viewport,
    scissorCount: u32,
    pScissors: ?[*]const Rect2D,
};

pub const PipelineRasterizationStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineRasterizationStateCreateFlags = 0,
    depthClampEnable: s.Bool32 = s.FALSE,
    rasterizerDiscardEnable: s.Bool32 = s.FALSE,
    polygonMode: s.PolygonMode = @enumFromInt(0),
    cullMode: s.CullModeFlags = .{},
    frontFace: s.FrontFace = @enumFromInt(0),
    depthBiasEnable: s.Bool32 = s.FALSE,
    depthBiasConstantFactor: f32 = 0.0,
    depthBiasClamp: f32 = 0.0,
    depthBiasSlopeFactor: f32 = 0.0,
    lineWidth: f32 = 0.0,
};

pub const PipelineMultisampleStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineMultisampleStateCreateFlags = 0,
    rasterizationSamples: s.SampleCountFlags = .{},
    sampleShadingEnable: s.Bool32 = s.FALSE,
    minSampleShading: f32 = 0.0,
    pSampleMask: ?[*]const s.SampleMask,
    alphaToCoverageEnable: s.Bool32 = s.FALSE,
    alphaToOneEnable: s.Bool32 = s.FALSE,
};

pub const PipelineDepthStencilStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_DEPTH_STENCIL_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineDepthStencilStateCreateFlags = .{},
    depthTestEnable: s.Bool32 = s.FALSE,
    depthWriteEnable: s.Bool32 = s.FALSE,
    depthCompareOp: s.CompareOp = @enumFromInt(0),
    depthBoundsTestEnable: s.Bool32 = s.FALSE,
    stencilTestEnable: s.Bool32 = s.FALSE,
    front: StencilOpState = .{},
    back: StencilOpState = .{},
    minDepthBounds: f32 = 0.0,
    maxDepthBounds: f32 = 0.0,
};

pub const StencilOpState = extern struct {
    failOp: s.StencilOp = @enumFromInt(0),
    passOp: s.StencilOp = @enumFromInt(0),
    depthFailOp: s.StencilOp = @enumFromInt(0),
    compareOp: s.CompareOp = @enumFromInt(0),
    compareMask: u32 = 0,
    writeMask: u32 = 0,
    reference: u32 = 0,
};

pub const PipelineColorBlendAttachmentState = extern struct {
    blendEnable: s.Bool32 = s.FALSE,
    srcColorBlendFactor: s.BlendFactor = @enumFromInt(0),
    dstColorBlendFactor: s.BlendFactor = @enumFromInt(0),
    colorBlendOp: s.BlendOp = @enumFromInt(0),
    srcAlphaBlendFactor: s.BlendFactor = @enumFromInt(0),
    dstAlphaBlendFactor: s.BlendFactor = @enumFromInt(0),
    alphaBlendOp: s.BlendOp = @enumFromInt(0),
    colorWriteMask: s.ColorComponentFlags = .{},
};

pub const PipelineColorBlendStateCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineColorBlendStateCreateFlags = .{},
    logicOpEnable: s.Bool32 = s.FALSE,
    logicOp: s.LogicOp = @enumFromInt(0),
    attachmentCount: u32 = 0,
    pAttachments: ?[*]const PipelineColorBlendAttachmentState,
    blendConstants: [4]f32 = zero([4]f32),
};

pub const PipelineLayoutCreateInfo = extern struct {
    sType: s.StructureType = .PIPELINE_LAYOUT_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineLayoutCreateFlags = .{},
    setLayoutCount: u32 = 0,
    pSetLayouts: ?[*]const s.DescriptorSetLayout,
    pushConstantRangeCount: u32 = 0,
    pPushConstantRanges: ?[*]const s.PushConstantRange,
};

pub const PushConstantRange = extern struct {
    stageFlags: s.ShaderStageFlags = .{},
    offset: u32 = 0,
    size: u32 = 0,
};

pub const AttachmentDescription = extern struct {
    flags: s.AttachmentDescriptionFlags = .{},
    format: s.Format = @enumFromInt(0),
    samples: s.SampleCountFlags = .{},
    loadOp: s.AttachmentLoadOp = @enumFromInt(0),
    storeOp: s.AttachmentStoreOp = @enumFromInt(0),
    stencilLoadOp: s.AttachmentLoadOp = @enumFromInt(0),
    stencilStoreOp: s.AttachmentStoreOp = @enumFromInt(0),
    initialLayout: s.ImageLayout = @enumFromInt(0),
    finalLayout: s.ImageLayout = @enumFromInt(0),
};

pub const AttachmentReference = extern struct {
    attachment: u32 = 0,
    layout: s.ImageLayout = @enumFromInt(0),
};

pub const SubpassDescription = extern struct {
    flags: s.SubpassDescriptionFlags = .{},
    pipelineBindPoint: s.PipelineBindPoint = @enumFromInt(0),
    inputAttachmentCount: u32 = 0,
    pInputAttachments: ?[*]const s.AttachmentReference = null,
    colorAttachmentCount: u32 = 0,
    pColorAttachments: ?[*]const AttachmentReference = null,
    pResolveAttachments: ?[*]const s.AttachmentReference = null,
    pDepthStencilAttachment: ?[*]const s.AttachmentReference = null,
    preserveAttachmentCount: u32 = 0,
    pPreserveAttachments: ?[*]const u32 = null,
};

pub const RenderPassCreateInfo = extern struct {
    sType: s.StructureType = .RENDER_PASS_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.RenderPassCreateFlags = .{},
    attachmentCount: u32 = 0,
    pAttachments: ?[*]const AttachmentDescription = null,
    subpassCount: u32 = 0,
    pSubpasses: ?[*]const SubpassDescription = null,
    dependencyCount: u32 = 0,
    pDependencies: ?[*]const SubpassDependency = null,
};

pub const GraphicsPipelineCreateInfo = extern struct {
    sType: s.StructureType = .GRAPHICS_PIPELINE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.PipelineCreateFlags = .{},
    stageCount: u32 = 0,
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
    layout: s.PipelineLayout = null,
    renderPass: s.RenderPass = null,
    subpass: u32 = 0,
    basePipelineHandle: s.Pipeline = null,
    basePipelineIndex: i32 = 0,
};

pub const FramebufferCreateInfo = extern struct {
    sType: s.StructureType = .FRAMEBUFFER_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.FramebufferCreateFlags = .{},
    renderPass: s.RenderPass = null,
    attachmentCount: u32 = 0,
    pAttachments: ?[*]const s.ImageView = null,
    width: u32 = 0,
    height: u32 = 0,
    layers: u32 = 0,
};

pub const CommandPoolCreateInfo = extern struct {
    sType: s.StructureType = .COMMAND_POOL_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.CommandPoolCreateFlags = .{},
    queueFamilyIndex: u32 = 0,
};

pub const CommandBufferAllocateInfo = extern struct {
    sType: s.StructureType = .COMMAND_BUFFER_ALLOCATE_INFO,
    pNext: ?*const anyopaque = null,
    commandPool: s.CommandPool = null,
    level: s.CommandBufferLevel = @enumFromInt(0),
    commandBufferCount: u32 = 0,
};

pub const CommandBufferBeginInfo = extern struct {
    sType: s.StructureType = .COMMAND_BUFFER_BEGIN_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.CommandBufferUsageFlags = .{},
    pInheritanceInfo: ?*const s.CommandBufferInheritanceInfo = null,
};

pub const CommandBufferInheritanceInfo = extern struct {
    sType: s.StructureType = .COMMAND_BUFFER_INHERITANCE_INFO,
    pNext: ?*const anyopaque = null,
    renderPass: s.RenderPass = null,
    subpass: u32 = 0,
    framebuffer: s.Framebuffer = null,
    occlusionQueryEnable: s.Bool32 = s.FALSE,
    queryFlags: s.QueryControlFlags = .{},
    pipelineStatistics: s.QueryPipelineStatisticFlags = .{},
};

pub const RenderPassBeginInfo = extern struct {
    sType: s.StructureType = .RENDER_PASS_BEGIN_INFO,
    pNext: ?*const anyopaque = null,
    renderPass: s.RenderPass = null,
    framebuffer: s.Framebuffer = null,
    renderArea: Rect2D = .{},
    clearValueCount: u32 = 0,
    pClearValues: ?[*]const ClearValue = null,
};

pub const SemaphoreCreateInfo = extern struct {
    sType: s.StructureType = .SEMAPHORE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.SemaphoreCreateFlags = 0,
};

pub const FenceCreateInfo = extern struct {
    sType: s.StructureType = .FENCE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.FenceCreateFlags = .{},
};

pub const SubmitInfo = extern struct {
    sType: s.StructureType = .SUBMIT_INFO,
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
    srcSubpass: u32 = 0,
    dstSubpass: u32 = 0,
    srcStageMask: s.PipelineStageFlags = .{},
    dstStageMask: s.PipelineStageFlags = .{},
    srcAccessMask: s.AccessFlags = .{},
    dstAccessMask: s.AccessFlags = .{},
    dependencyFlags: s.DependencyFlags = .{},
};

pub const PresentInfoKHR = extern struct {
    sType: s.StructureType = .PRESENT_INFO_KHR,
    pNext: ?*const anyopaque = null,
    waitSemaphoreCount: u32 = 0,
    pWaitSemaphores: [*]const s.Semaphore,
    swapchainCount: u32 = 0,
    pSwapchains: [*]const s.SwapchainKHR,
    pImageIndices: [*]const u32,
    pResults: ?[*]s.Result = null,
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
    sType: s.StructureType = .DEBUG_UTILS_LABEL_EXT,
    pNext: ?*const anyopaque = null,
    pLabelName: [*:0]const u8,
    color: [4]f32 = zero([4]f32),
};

pub const DebugUtilsObjectNameInfoEXT = extern struct {
    sType: s.StructureType = .DEBUG_UTILS_OBJECT_NAME_INFO_EXT,
    pNext: ?*const anyopaque = null,
    objectType: s.ObjectType = @enumFromInt(0),
    objectHandle: u64 = 0,
    pObjectName: [*:0]const u8,
};

pub const DebugUtilsMessengerCallbackData = extern struct {
    sType: s.StructureType = .DEBUG_UTILS_MESSENGER_CALLBACK_DATA_EXT,
    pNext: ?*const anyopaque = null,
    flags: s.DebugUtilsMessengerCallbackDataFlagsEXT = 0,
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
    sType: s.StructureType = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
    pNext: ?*const anyopaque = null,
    flags: s.DebugUtilsMessengerCreateFlagsEXT = 0,
    messageSeverity: s.DebugUtilsMessageSeverityFlagsEXT = .{},
    messageType: s.DebugUtilsMessageTypeFlagsEXT = .{},
    pfnUserCallback: s.DebugUtilsMessengerCallback,
    pUserData: ?*anyopaque = null,
};

pub const BufferCreateInfo = extern struct {
    sType: s.StructureType = .BUFFER_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.BufferCreateFlags = .{},
    size: s.DeviceSize = 0,
    usage: s.BufferUsageFlags = .{},
    sharingMode: s.SharingMode = @enumFromInt(0),
    queueFamilyIndexCount: u32 = 0,
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
    propertyFlags: s.MemoryPropertyFlags = .{},
    heapIndex: u32 = 0,
};

pub const MemoryHeap = extern struct {
    size: s.DeviceSize = 0,
    flags: s.MemoryHeapFlags = .{},
};

pub const MemoryAllocateInfo = extern struct {
    sType: s.StructureType = .MEMORY_ALLOCATE_INFO,
    pNext: ?*const anyopaque = null,
    allocationSize: s.DeviceSize = 0,
    memoryTypeIndex: u32 = 0,
};

pub const BufferCopy = extern struct {
    srcOffset: s.DeviceSize = 0,
    dstOffset: s.DeviceSize = 0,
    size: s.DeviceSize = 0,
};

pub const DescriptorSetLayoutBinding = extern struct {
    binding: u32 = 0,
    descriptorType: s.DescriptorType = @enumFromInt(0),
    descriptorCount: u32 = 0,
    stageFlags: s.ShaderStageFlags = .{},
    pImmutableSamplers: ?[*]const s.Sampler = null,
};

pub const DescriptorSetLayoutCreateInfo = extern struct {
    sType: s.StructureType = .DESCRIPTOR_SET_LAYOUT_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.DescriptorSetLayoutCreateFlags = .{},
    bindingCount: u32 = 0,
    pBindings: [*]const s.DescriptorSetLayoutBinding,
};

pub const DescriptorPoolSize = extern struct {
    type: s.DescriptorType = @enumFromInt(0),
    descriptorCount: u32 = 0,
};

pub const DescriptorPoolCreateInfo = extern struct {
    sType: s.StructureType = .DESCRIPTOR_POOL_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.DescriptorPoolCreateFlags = .{},
    maxSets: u32 = 0,
    poolSizeCount: u32 = 0,
    pPoolSizes: [*]const s.DescriptorPoolSize,
};

pub const DescriptorSetAllocateInfo = extern struct {
    sType: s.StructureType = .DESCRIPTOR_SET_ALLOCATE_INFO,
    pNext: ?*const anyopaque = null,
    descriptorPool: s.DescriptorPool = null,
    descriptorSetCount: u32 = 0,
    pSetLayouts: [*]const s.DescriptorSetLayout,
};

pub const DescriptorBufferInfo = extern struct {
    buffer: s.Buffer = null,
    offset: s.DeviceSize = 0,
    range: s.DeviceSize = 0,
};

pub const WriteDescriptorSet = extern struct {
    sType: s.StructureType = .WRITE_DESCRIPTOR_SET,
    pNext: ?*const anyopaque = null,
    dstSet: s.DescriptorSet = null,
    dstBinding: u32 = 0,
    dstArrayElement: u32 = 0,
    descriptorCount: u32 = 0,
    descriptorType: s.DescriptorType = @enumFromInt(0),
    pImageInfo: ?[*]const s.DescriptorImageInfo = null,
    pBufferInfo: ?[*]const s.DescriptorBufferInfo = null,
    pTexelBufferView: ?[*]const s.BufferView = null,
};

pub const DescriptorImageInfo = extern struct {
    sampler: s.Sampler = null,
    imageView: s.ImageView = null,
    imageLayout: s.ImageLayout = @enumFromInt(0),
};

pub const CopyDescriptorSet = extern struct {
    sType: s.StructureType = .COPY_DESCRIPTOR_SET,
    pNext: ?*const anyopaque = null,
    srcSet: s.DescriptorSet = null,
    srcBinding: u32 = 0,
    srcArrayElement: u32 = 0,
    dstSet: s.DescriptorSet = null,
    dstBinding: u32 = 0,
    dstArrayElement: u32 = 0,
    descriptorCount: u32 = 0,
};

pub const ImageCreateInfo = extern struct {
    sType: s.StructureType = .IMAGE_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.ImageCreateFlags = std.mem.zeroes(s.ImageCreateFlags),
    imageType: s.ImageType = std.mem.zeroes(s.ImageType),
    format: s.Format = std.mem.zeroes(s.Format),
    extent: s.Extent3D,
    mipLevels: u32,
    arrayLayers: u32,
    samples: s.SampleCountFlags = std.mem.zeroes(s.SampleCountFlags),
    tiling: s.ImageTiling = std.mem.zeroes(s.ImageTiling),
    usage: s.ImageUsageFlags = std.mem.zeroes(s.ImageUsageFlags),
    sharingMode: s.SharingMode = std.mem.zeroes(s.SharingMode),
    queueFamilyIndexCount: u32,
    pQueueFamilyIndices: ?[*]const u32,
    initialLayout: s.ImageLayout = std.mem.zeroes(s.ImageLayout),
};

pub const ImageMemoryBarrier = extern struct {
    sType: s.StructureType = .IMAGE_MEMORY_BARRIER,
    pNext: ?*const anyopaque = null,
    srcAccessMask: s.AccessFlags = .{},
    dstAccessMask: s.AccessFlags = .{},
    oldLayout: s.ImageLayout = .UNDEFINED,
    newLayout: s.ImageLayout = .UNDEFINED,
    srcQueueFamilyIndex: u32 = 0,
    dstQueueFamilyIndex: u32 = 0,
    image: s.Image = null,
    subresourceRange: ImageSubresourceRange = .{},
};

pub const BufferMemoryBarrier = extern struct {
    sType: s.StructureType = .BUFFER_MEMORY_BARRIER,
    pNext: ?*const anyopaque = null,
    srcAccessMask: s.AccessFlags = .{},
    dstAccessMask: s.AccessFlags = .{},
    srcQueueFamilyIndex: u32 = 0,
    dstQueueFamilyIndex: u32 = 0,
    buffer: s.Buffer = null,
    offset: s.DeviceSize = 0,
    size: s.DeviceSize = 0,
};

pub const MemoryBarrier = extern struct {
    sType: s.StructureType = .MEMORY_BARRIER,
    pNext: ?*const anyopaque = null,
    srcAccessMask: s.AccessFlags = .{},
    dstAccessMask: s.AccessFlags = .{},
};

pub const BufferImageCopy = extern struct {
    bufferOffset: s.DeviceSize = 0,
    bufferRowLength: u32 = 0,
    bufferImageHeight: u32 = 0,
    imageSubresource: s.ImageSubresourceLayers = .{},
    imageOffset: s.Offset3D = .{},
    imageExtent: Extent3D = .{},
};

pub const ImageSubresourceLayers = extern struct {
    aspectMask: s.ImageAspectFlags = .{},
    mipLevel: u32 = 0,
    baseArrayLayer: u32 = 0,
    layerCount: u32 = 0,
};

pub const SamplerCreateInfo = extern struct {
    sType: s.StructureType = .SAMPLER_CREATE_INFO,
    pNext: ?*const anyopaque = null,
    flags: s.SamplerCreateFlags = .{},
    magFilter: s.Filter = @enumFromInt(0),
    minFilter: s.Filter = @enumFromInt(0),
    mipmapMode: s.SamplerMipmapMode = @enumFromInt(0),
    addressModeU: s.SamplerAddressMode = @enumFromInt(0),
    addressModeV: s.SamplerAddressMode = @enumFromInt(0),
    addressModeW: s.SamplerAddressMode = @enumFromInt(0),
    mipLodBias: f32 = 0,
    anisotropyEnable: s.Bool32 = s.FALSE,
    maxAnisotropy: f32 = 0,
    compareEnable: s.Bool32 = s.FALSE,
    compareOp: s.CompareOp = @enumFromInt(0),
    minLod: f32 = 0,
    maxLod: f32 = 0,
    borderColor: s.BorderColor = @enumFromInt(0),
    unnormalizedCoordinates: s.Bool32 = s.FALSE,
};

pub const FormatProperties = extern struct {
    linearTilingFeatures: s.FormatFeatureFlags = .{},
    optimalTilingFeatures: s.FormatFeatureFlags = .{},
    bufferFeatures: s.FormatFeatureFlags = .{},
};

pub const ImageBlit = extern struct {
    srcSubresource: ImageSubresourceLayers,
    srcOffsets: [2]Offset3D,
    dstSubresource: ImageSubresourceLayers,
    dstOffsets: [2]Offset3D,
};
