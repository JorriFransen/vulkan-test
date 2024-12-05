const c = @cImport(@cInclude("vulkan/vulkan.h"));

// Structs
pub const ApplicationInfo = c.VkApplicationInfo;
pub const ExtensionProperties = c.VkExtensionProperties;
pub const InstanceCreateInfo = c.VkInstanceCreateInfo;
pub const Instance = c.VkInstance;

// Functions
pub const enumerateInstanceExtensionProperties = c.vkEnumerateInstanceExtensionProperties;
pub const createInstance = c.vkCreateInstance;
pub const destroyInstance = c.vkDestroyInstance;

// Macros
pub const MAKE_VERSION = c.VK_MAKE_VERSION;

// Constants
pub const API_VERSION_1_0 = c.VK_API_VERSION_1_0;
pub const API_VERSION_1_1 = c.VK_API_VERSION_1_1;
pub const API_VERSION_1_2 = c.VK_API_VERSION_1_2;
pub const API_VERSION_1_3 = c.VK_API_VERSION_1_3;

pub const SUCCESS = c.VK_SUCCESS;

pub const INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR = c.VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
pub const KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME = c.VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME;

pub const Structure_Type = struct {
    m: c_int,

    pub const APPLICATION_INFO = c.VK_STRUCTURE_TYPE_APPLICATION_INFO;
    pub const INSTANCE_CREATE_INFO = c.VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
};
