pub const enumerateInstanceExtensionProperties = f("vkEnumerateInstanceExtensionProperties", fn (pLayerName: ?[*:0]const u8, pPropertyCount: *u32, pProperties: ?[*]VkExtensionProperties) callconv(.C) VkResult);

inline fn f(comptime name: []const u8, comptime T: type) *const T {
    return @extern(*const T, .{ .name = name });
}

pub const VK_MAX_EXTENSION_NAME_SIZE = 256;

pub const VkExtensionProperties = extern struct {
    extensionName: [VK_MAX_EXTENSION_NAME_SIZE]u8,
    specVersion: u32,
};

pub const VkResult = struct {
    pub const VK_SUCCESS = 0;
    pub const VK_NOT_READY = 1;
    pub const VK_TIMEOUT = 2;
    pub const VK_EVENT_SET = 3;
    pub const VK_EVENT_RESET = 4;
    pub const VK_INCOMPLETE = 5;
    pub const VK_ERROR_OUT_OF_HOST_MEMORY = -1;
    pub const VK_ERROR_OUT_OF_DEVICE_MEMORY = -2;
    pub const VK_ERROR_INITIALIZATION_FAILED = -3;
    pub const VK_ERROR_DEVICE_LOST = -4;
    pub const VK_ERROR_MEMORY_MAP_FAILED = -5;
    pub const VK_ERROR_LAYER_NOT_PRESENT = -6;
    pub const VK_ERROR_EXTENSION_NOT_PRESENT = -7;
    pub const VK_ERROR_FEATURE_NOT_PRESENT = -8;
    pub const VK_ERROR_INCOMPATIBLE_DRIVER = -9;
    pub const VK_ERROR_TOO_MANY_OBJECTS = -10;
    pub const VK_ERROR_FORMAT_NOT_SUPPORTED = -11;
    pub const VK_ERROR_FRAGMENTED_POOL = -12;
    pub const VK_ERROR_UNKNOWN = -13;
    // Provided by VK_VERSION_1_1
    pub const VK_ERROR_OUT_OF_POOL_MEMORY = -1000069000;
    // Provided by VK_VERSION_1_1
    pub const VK_ERROR_INVALID_EXTERNAL_HANDLE = -1000072003;
    // Provided by VK_VERSION_1_2
    pub const VK_ERROR_FRAGMENTATION = -1000161000;
    // Provided by VK_VERSION_1_2
    pub const VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS = -1000257000;
    // Provided by VK_VERSION_1_3
    pub const VK_PIPELINE_COMPILE_REQUIRED = 1000297000;
    // Provided by VK_VERSION_1_4
    pub const VK_ERROR_NOT_PERMITTED = -1000174001;
    // Provided by VK_KHR_surface
    pub const VK_ERROR_SURFACE_LOST_KHR = -1000000000;
    // Provided by VK_KHR_surface
    pub const VK_ERROR_NATIVE_WINDOW_IN_USE_KHR = -1000000001;
    // Provided by VK_KHR_swapchain
    pub const VK_SUBOPTIMAL_KHR = 1000001003;
    // Provided by VK_KHR_swapchain
    pub const VK_ERROR_OUT_OF_DATE_KHR = -1000001004;
    // Provided by VK_KHR_display_swapchain
    pub const VK_ERROR_INCOMPATIBLE_DISPLAY_KHR = -1000003001;
    // Provided by VK_EXT_debug_report
    pub const VK_ERROR_VALIDATION_FAILED_EXT = -1000011001;
    // Provided by VK_NV_glsl_shader
    pub const VK_ERROR_INVALID_SHADER_NV = -1000012000;
    // Provided by VK_KHR_video_queue
    pub const VK_ERROR_IMAGE_USAGE_NOT_SUPPORTED_KHR = -1000023000;
    // Provided by VK_KHR_video_queue
    pub const VK_ERROR_VIDEO_PICTURE_LAYOUT_NOT_SUPPORTED_KHR = -1000023001;
    // Provided by VK_KHR_video_queue
    pub const VK_ERROR_VIDEO_PROFILE_OPERATION_NOT_SUPPORTED_KHR = -1000023002;
    // Provided by VK_KHR_video_queue
    pub const VK_ERROR_VIDEO_PROFILE_FORMAT_NOT_SUPPORTED_KHR = -1000023003;
    // Provided by VK_KHR_video_queue
    pub const VK_ERROR_VIDEO_PROFILE_CODEC_NOT_SUPPORTED_KHR = -1000023004;
    // Provided by VK_KHR_video_queue
    pub const VK_ERROR_VIDEO_STD_VERSION_NOT_SUPPORTED_KHR = -1000023005;
    // Provided by VK_EXT_image_drm_format_modifier
    pub const VK_ERROR_INVALID_DRM_FORMAT_MODIFIER_PLANE_LAYOUT_EXT = -1000158000;
    // Provided by VK_EXT_full_screen_exclusive
    pub const VK_ERROR_FULL_SCREEN_EXCLUSIVE_MODE_LOST_EXT = -1000255000;
    // Provided by VK_KHR_deferred_host_operations
    pub const VK_THREAD_IDLE_KHR = 1000268000;
    // Provided by VK_KHR_deferred_host_operations
    pub const VK_THREAD_DONE_KHR = 1000268001;
    // Provided by VK_KHR_deferred_host_operations
    pub const VK_OPERATION_DEFERRED_KHR = 1000268002;
    // Provided by VK_KHR_deferred_host_operations
    pub const VK_OPERATION_NOT_DEFERRED_KHR = 1000268003;
    // Provided by VK_KHR_video_encode_queue
    pub const VK_ERROR_INVALID_VIDEO_STD_PARAMETERS_KHR = -1000299000;
    // Provided by VK_EXT_image_compression_control
    pub const VK_ERROR_COMPRESSION_EXHAUSTED_EXT = -1000338000;
    // Provided by VK_EXT_shader_object
    pub const VK_INCOMPATIBLE_SHADER_BINARY_EXT = 1000482000;
    // Provided by VK_KHR_pipeline_binary
    pub const VK_PIPELINE_BINARY_MISSING_KHR = 1000483000;
    // Provided by VK_KHR_pipeline_binary
    pub const VK_ERROR_NOT_ENOUGH_SPACE_KHR = -1000483000;
    // Provided by VK_KHR_maintenance1
    pub const VK_ERROR_OUT_OF_POOL_MEMORY_KHR = VK_ERROR_OUT_OF_POOL_MEMORY;
    // Provided by VK_KHR_external_memory
    pub const VK_ERROR_INVALID_EXTERNAL_HANDLE_KHR = .VK_ERROR_INVALID_EXTERNAL_HANDLE;
    // Provided by VK_EXT_descriptor_indexing
    pub const VK_ERROR_FRAGMENTATION_EXT = .VK_ERROR_FRAGMENTATION;
    // Provided by VK_EXT_global_priority
    pub const VK_ERROR_NOT_PERMITTED_EXT = .VK_ERROR_NOT_PERMITTED;
    // Provided by VK_KHR_global_priority
    pub const VK_ERROR_NOT_PERMITTED_KHR = .VK_ERROR_NOT_PERMITTED;
    // Provided by VK_EXT_buffer_device_address
    pub const VK_ERROR_INVALID_DEVICE_ADDRESS_EXT = .VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS;
    // Provided by VK_KHR_buffer_device_address
    pub const VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS_KHR = .VK_ERROR_INVALID_OPAQUE_CAPTURE_ADDRESS;
    // Provided by VK_EXT_pipeline_creation_cache_control
    pub const VK_PIPELINE_COMPILE_REQUIRED_EXT = .VK_PIPELINE_COMPILE_REQUIRED;
    // Provided by VK_EXT_pipeline_creation_cache_control
    pub const VK_ERROR_PIPELINE_COMPILE_REQUIRED_EXT = .VK_PIPELINE_COMPILE_REQUIRED;
    // Provided by VK_EXT_shader_object
    // VK_ERROR_INCOMPATIBLE_SHADER_BINARY_EXT is a deprecated alias
    pub const VK_ERROR_INCOMPATIBLE_SHADER_BINARY_EXT = .VK_INCOMPATIBLE_SHADER_BINARY_EXT;
};
