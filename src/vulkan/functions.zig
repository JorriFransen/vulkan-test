const f = @import("../externFn.zig").externFn;
const vk = @import("vulkan.zig");

const Result = vk.Result;
const Instance = vk.Instance;
const PhysicalDevice = vk.PhysicalDevice;
const Device = vk.Device;
const Queue = vk.Queue;
const Fence = vk.Fence;
const Semaphore = vk.Semaphore;
const SurfaceKHR = vk.SurfaceKHR;
const Bool32 = vk.Bool32;
const SwapchainKHR = vk.SwapchainKHR;
const ShaderModule = vk.ShaderModule;
const Pipeline = vk.Pipeline;
const Framebuffer = vk.Framebuffer;
const CommandPool = vk.CommandPool;
const CommandBuffer = vk.CommandBuffer;
const AllocationCallbacks = vk.AllocationCallbacks;
const Buffer = vk.Buffer;
const DeviceMemory = vk.DeviceMemory;

pub const createInstance = f("vkCreateInstance", fn (create_info: *const vk.InstanceCreateInfo, allocator: ?*const AllocationCallbacks, instance: *Instance) callconv(.C) Result);
pub const destroyInstance = f("vkDestroyInstance", fn (instance: Instance, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getInstanceProcAddr = f("vkGetInstanceProcAddr", fn (instance: Instance, name: [*:0]const u8) callconv(.C) vk.VoidFunction);
pub const enumerateInstanceExtensionProperties = f("vkEnumerateInstanceExtensionProperties", fn (layer_name: ?[*:0]const u8, ext_count: *u32, extensions: ?[*]vk.ExtensionProperties) callconv(.C) Result);
pub const enumerateInstanceLayerProperties = f("vkEnumerateInstanceLayerProperties", fn (count: *u32, layers: ?[*]vk.LayerProperties) callconv(.C) Result);
pub const enumeratePhysicalDevices = f("vkEnumeratePhysicalDevices", fn (instance: Instance, count: *u32, devices: ?[*]PhysicalDevice) callconv(.C) Result);
pub const enumerateDeviceExtensionProperties = f("vkEnumerateDeviceExtensionProperties", fn (device: PhysicalDevice, layer_name: ?[*:0]const u8, count: *u32, properties: ?[*]vk.ExtensionProperties) callconv(.c) Result);
pub const getPhysicalDeviceProperties = f("vkGetPhysicalDeviceProperties", fn (device: PhysicalDevice, properties: *vk.PhysicalDeviceProperties) callconv(.C) void);
pub const getPhysicalDeviceFeatures = f("vkGetPhysicalDeviceFeatures", fn (device: PhysicalDevice, properties: *vk.PhysicalDeviceFeatures) callconv(.C) void);
pub const getPhysicalDeviceQueueFamilyProperties = f("vkGetPhysicalDeviceQueueFamilyProperties", fn (device: PhysicalDevice, count: *u32, properties: ?[*]vk.QueueFamilyProperties) callconv(.C) void);
pub const createDevice = f("vkCreateDevice", fn (pdev: PhysicalDevice, create_info: *const vk.DeviceCreateInfo, allocator: ?*const AllocationCallbacks, device: *Device) callconv(.C) Result);
pub const destroyDevice = f("vkDestroyDevice", fn (device: Device, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const deviceWaitIdle = f("vkDeviceWaitIdle", fn (device: Device) callconv(.C) Result);
pub const getDeviceQueue = f("vkGetDeviceQueue", fn (device: Device, family_index: u32, queue_index: u32, queue: *Queue) callconv(.C) void);
pub const queueSubmit = f("vkQueueSubmit", fn (queue: Queue, submit_count: u32, submits: [*]const vk.SubmitInfo, fence: Fence) callconv(.C) Result);
pub const queueWaitIdle = f("vkQueueWaitIdle", fn (queue: Queue) callconv(.C) Result);
pub const queuePresentKHR = f("vkQueuePresentKHR", fn (queue: Queue, present_info: *const vk.PresentInfoKHR) callconv(.C) Result);
pub const createXcbSurfaceKHR = f("vkCreateXcbSurfaceKHR", fn (instance: Instance, create_info: *const vk.XcbSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createXlibSurfaceKHR = f("vkCreateXlibSurfaceKHR", fn (instance: Instance, create_info: *const vk.XlibSurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const createWin32SurfaceKHR = f("vkCreateWin32SurfaceKHR", fn (instance: Instance, create_info: *const vk.Win32SurfaceCreateInfoKHR, allocator: ?*const AllocationCallbacks, surface: *SurfaceKHR) callconv(.C) Result);
pub const destroySurfaceKHR = f("vkDestroySurfaceKHR", fn (instance: Instance, surface: SurfaceKHR, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getPhysicalDeviceSurfaceSupportKHR = f("vkGetPhysicalDeviceSurfaceSupportKHR", fn (device: PhysicalDevice, qf_index: u32, surface: SurfaceKHR, supported: *Bool32) callconv(.C) Result);
pub const getPhysicalDeviceSurfaceCapabilitiesKHR = f("vkGetPhysicalDeviceSurfaceCapabilitiesKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, capabailities: *vk.SurfaceCapabilitiesKHR) callconv(.C) Result);
pub const getPhysicalDeviceSurfaceFormatsKHR = f("vkGetPhysicalDeviceSurfaceFormatsKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, count: *u32, formats: ?*vk.SurfaceFormatKHR) callconv(.C) Result);
pub const getPhysicalDeviceSurfacePresentModesKHR = f("vkGetPhysicalDeviceSurfacePresentModesKHR", fn (device: PhysicalDevice, surface: SurfaceKHR, count: *u32, modes: ?*vk.PresentModeKHR) callconv(.C) Result);
pub const createSwapchainKHR = f("vkCreateSwapchainKHR", fn (device: Device, create_info: *const vk.SwapchainCreateInfoKHR, allocator: ?*const AllocationCallbacks, swapchain: *SwapchainKHR) callconv(.C) Result);
pub const destroySwapchainKHR = f("vkDestroySwapchainKHR", fn (device: Device, swapchain: SwapchainKHR, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getSwapchainImagesKHR = f("vkGetSwapchainImagesKHR", fn (device: Device, swapchain: SwapchainKHR, count: *u32, images: ?[*]vk.Image) callconv(.C) Result);
pub const createImageView = f("vkCreateImageView", fn (device: Device, create_info: *const vk.ImageViewCreateInfo, allocator: ?*const AllocationCallbacks, view: *vk.ImageView) callconv(.C) Result);
pub const destroyImageView = f("vkDestroyImageView", fn (device: Device, view: vk.ImageView, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createShaderModule = f("vkCreateShaderModule", fn (device: Device, create_info: *const vk.ShaderModuleCreateInfo, allocator: ?*const AllocationCallbacks, shader_module: *ShaderModule) callconv(.C) Result);
pub const destroyShaderModule = f("vkDestroyShaderModule", fn (device: Device, shader_module: ShaderModule, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createPipelineLayout = f("vkCreatePipelineLayout", fn (device: Device, create_info: *const vk.PipelineLayoutCreateInfo, allocator: ?*const AllocationCallbacks, pipeline_layout: *vk.PipelineLayout) callconv(.C) Result);
pub const destroyPipelineLayout = f("vkDestroyPipelineLayout", fn (device: Device, pipeline_layout: vk.PipelineLayout, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createRenderPass = f("vkCreateRenderPass", fn (device: Device, create_info: *const vk.RenderPassCreateInfo, allocator: ?*const AllocationCallbacks, render_pass: *vk.RenderPass) callconv(.C) Result);
pub const destroyRenderPass = f("vkDestroyRenderPass", fn (device: Device, render_pass: vk.RenderPass, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createGraphicsPipelines = f("vkCreateGraphicsPipelines", fn (device: Device, cache: vk.PipelineCache, create_info_count: u32, create_infos: [*]const vk.GraphicsPipelineCreateInfo, allocator: ?*const AllocationCallbacks, pipelines: *Pipeline) callconv(.C) Result);
pub const destroyPipeline = f("vkDestroyPipeline", fn (device: Device, pipeline: Pipeline, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createFramebuffer = f("vkCreateFramebuffer", fn (device: Device, create_info: *const vk.FramebufferCreateInfo, allocator: ?*const AllocationCallbacks, framebuffer: *Framebuffer) callconv(.C) Result);
pub const destroyFramebuffer = f("vkDestroyFramebuffer", fn (device: Device, framebuffer: Framebuffer, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createCommandPool = f("vkCreateCommandPool", fn (device: Device, create_info: *const vk.CommandPoolCreateInfo, allocator: ?*const AllocationCallbacks, command_pool: *CommandPool) callconv(.c) Result);
pub const destroyCommandPool = f("vkDestroyCommandPool", fn (device: Device, command_pool: CommandPool, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const allocateCommandBuffers = f("vkAllocateCommandBuffers", fn (device: Device, alloc_info: *const vk.CommandBufferAllocateInfo, command_buffers: [*]CommandBuffer) callconv(.C) Result);
pub const beginCommandBuffer = f("vkBeginCommandBuffer", fn (command_buffer: CommandBuffer, begin_info: *const vk.CommandBufferBeginInfo) callconv(.C) Result);
pub const endCommandBuffer = f("vkEndCommandBuffer", fn (command_buffer: CommandBuffer) callconv(.C) Result);
pub const resetCommandBuffer = f("vkResetCommandBuffer", fn (command_buffer: CommandBuffer, flags: vk.CommandBufferResetFlags) callconv(.C) Result);
pub const freeCommandBuffers = f("vkFreeCommandBuffers", fn (device: Device, commandPool: CommandPool, commandBufferCount: u32, pCommandBuffers: [*]const CommandBuffer) callconv(.C) void);
pub const cmdBeginRenderPass = f("vkCmdBeginRenderPass", fn (cmd_buf: CommandBuffer, begin_info: *const vk.RenderPassBeginInfo, contents: vk.SubpassContents) callconv(.C) void);
pub const cmdEndRenderPass = f("vkCmdEndRenderPass", fn (cmd_buf: CommandBuffer) callconv(.C) void);
pub const cmdBindPipeline = f("vkCmdBindPipeline", fn (cmd_buf: CommandBuffer, bind_point: vk.PipelineBindPoint, pipeline: Pipeline) callconv(.C) void);
pub const cmdSetViewport = f("vkCmdSetViewport", fn (cmd_buf: CommandBuffer, first_viewport: u32, viewport_count: u32, viewports: *const vk.Viewport) callconv(.C) void);
pub const cmdSetScissor = f("vkCmdSetScissor", fn (cmd_buf: CommandBuffer, first_scissor: u32, scissor_count: u32, scissors: *const vk.Rect2D) callconv(.C) void);
pub const cmdDraw = f("vkCmdDraw", fn (cmd_buf: CommandBuffer, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) callconv(.C) void);
pub const cmdBindVertexBuffers = f("vkCmdBindVertexBuffers", fn (cmd_buf: CommandBuffer, first_binding: u32, binding_count: u32, buffers: [*]const Buffer, offsets: [*]const vk.DeviceSize) callconv(.C) void);
pub const cmdBindIndexBuffer = f("vkCmdBindIndexBuffer", fn (commandBuffer: CommandBuffer, buffer: Buffer, offset: vk.DeviceSize, indexType: vk.IndexType) callconv(.C) void);
pub const cmdCopyBuffer = f("vkCmdCopyBuffer", fn (commandBuffer: CommandBuffer, srcBuffer: Buffer, dstBuffer: Buffer, regionCount: u32, pRegions: [*]const vk.BufferCopy) callconv(.C) void);
pub const cmdDrawIndexed = f("vkCmdDrawIndexed", fn (commandBuffer: CommandBuffer, indexCount: u32, instanceCount: u32, firstIndex: u32, vertexOffset: i32, firstInstance: u32) callconv(.C) void);
pub const cmdBindDescriptorSets = f("vkCmdBindDescriptorSets", fn (commandBuffer: CommandBuffer, pipelineBindPoint: vk.PipelineBindPoint, layout: vk.PipelineLayout, firstSet: u32, descriptorSetCount: u32, pDescriptorSets: *const vk.DescriptorSet, dynamicOffsetCount: u32, pDynamicOffsets: ?[*]const u32) callconv(.C) void);
pub const createSemaphore = f("vkCreateSemaphore", fn (device: Device, create_info: *const vk.SemaphoreCreateInfo, allocator: ?*const AllocationCallbacks, semaphore: *Semaphore) callconv(.C) Result);
pub const destroySemaphore = f("vkDestroySemaphore", fn (device: Device, semaphore: Semaphore, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createFence = f("vkCreateFence", fn (device: Device, create_info: *const vk.FenceCreateInfo, allocator: ?*const AllocationCallbacks, fence: *Fence) callconv(.C) Result);
pub const destroyFence = f("vkDestroyFence", fn (device: Device, fence: Fence, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const waitForFences = f("vkWaitForFences", fn (device: Device, count: u32, fences: [*]const Fence, wait_all: Bool32, timeout: u64) callconv(.C) Result);
pub const resetFences = f("vkResetFences", fn (device: Device, count: u32, fences: [*]const Fence) callconv(.C) Result);
pub const acquireNextImageKHR = f("vkAcquireNextImageKHR", fn (device: Device, swapchain: SwapchainKHR, timeout: u64, semaphore: Semaphore, fence: Fence, image_index: *u32) callconv(.C) Result);
pub const createBuffer = f("vkCreateBuffer", fn (device: Device, create_info: *const vk.BufferCreateInfo, allocator: ?*const AllocationCallbacks, buffer: *Buffer) callconv(.C) Result);
pub const destroyBuffer = f("vkDestroyBuffer", fn (device: Device, buffer: Buffer, allocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const getBufferMemoryRequirements = f("vkGetBufferMemoryRequirements", fn (device: Device, buffer: Buffer, requirements: *vk.MemoryRequirements) callconv(.C) void);
pub const getPhysicalDeviceMemoryProperties = f("vkGetPhysicalDeviceMemoryProperties", fn (device: PhysicalDevice, properties: *vk.PhysicalDeviceMemoryProperties) callconv(.C) void);
pub const allocateMemory = f("vkAllocateMemory", fn (device: Device, alloc_info: *const vk.MemoryAllocateInfo, allocator: ?*const AllocationCallbacks, memory: *DeviceMemory) callconv(.C) Result);
pub const freeMemory = f("vkFreeMemory", fn (device: Device, memory: DeviceMemory, allocator: ?*AllocationCallbacks) callconv(.C) void);
pub const bindBufferMemory = f("vkBindBufferMemory", fn (device: Device, buffer: Buffer, memory: DeviceMemory, offset: vk.DeviceSize) callconv(.C) Result);
pub const mapMemory = f("vkMapMemory", fn (device: Device, memory: DeviceMemory, offset: vk.DeviceSize, size: vk.DeviceSize, flags: vk.MemoryMapFlags, data: **anyopaque) callconv(.C) Result);
pub const unmapMemory = f("vkUnmapMemory", fn (device: Device, memory: DeviceMemory) callconv(.C) void);
pub const createDescriptorSetLayout = f("vkCreateDescriptorSetLayout", fn (device: Device, pCreateInfo: *const vk.DescriptorSetLayoutCreateInfo, pAllocator: ?*const AllocationCallbacks, pSetLayout: *vk.DescriptorSetLayout) callconv(.C) Result);
pub const destroyDescriptorSetLayout = f("vkDestroyDescriptorSetLayout", fn (device: Device, descriptorSetLayout: vk.DescriptorSetLayout, pAllocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const createDescriptorPool = f("vkCreateDescriptorPool", fn (device: Device, pCreateInfo: [*c]const vk.DescriptorPoolCreateInfo, pAllocator: [*c]const AllocationCallbacks, pDescriptorPool: *vk.DescriptorPool) callconv(.C) Result);
pub const destroyDescriptorPool = f("vkDestroyDescriptorPool", fn (device: Device, descriptorPool: vk.DescriptorPool, pAllocator: [*c]const AllocationCallbacks) callconv(.C) void);
pub const allocateDescriptorSets = f("vkAllocateDescriptorSets", fn (device: Device, pAllocateInfo: *const vk.DescriptorSetAllocateInfo, pDescriptorSets: [*]vk.DescriptorSet) callconv(.C) Result);
pub const updateDescriptorSets = f("vkUpdateDescriptorSets", fn (device: Device, descriptorWriteCount: u32, pDescriptorWrites: [*]const vk.WriteDescriptorSet, descriptorCopyCount: u32, pDescriptorCopies: ?[*]const vk.CopyDescriptorSet) callconv(.C) void);
pub const createImage = f("vkCreateImage", fn (device: Device, pCreateInfo: *const vk.ImageCreateInfo, pAllocator: ?*const AllocationCallbacks, pImage: *vk.Image) callconv(.C) Result);
pub const getImageMemoryRequirements = f("vkGetImageMemoryRequirements", fn (device: Device, image: vk.Image, pMemoryRequirements: *vk.MemoryRequirements) callconv(.C) void);
pub const destroyImage = f("vkDestroyImage", fn (device: Device, image: vk.Image, pAllocator: ?*const AllocationCallbacks) callconv(.C) void);
pub const bindImageMemory = f("vkBindImageMemory", fn (device: Device, image: vk.Image, memory: DeviceMemory, memoryOffset: vk.DeviceSize) callconv(.C) Result);
pub const cmdPipelineBarrier = f("vkCmdPipelineBarrier", fn (commandBuffer: CommandBuffer, srcStageMask: vk.PipelineStageFlags, dstStageMask: vk.PipelineStageFlags, dependencyFlags: vk.DependencyFlags, memoryBarrierCount: u32, pMemoryBarriers: ?*const vk.MemoryBarrier, bufferMemoryBarrierCount: u32, pBufferMemoryBarriers: ?*const vk.BufferMemoryBarrier, imageMemoryBarrierCount: u32, pImageMemoryBarriers: ?*const vk.ImageMemoryBarrier) callconv(.C) void);
pub const cmdCopyBufferToImage = f("vkCmdCopyBufferToImage", fn (commandBuffer: CommandBuffer, srcBuffer: Buffer, dstImage: vk.Image, dstImageLayout: vk.ImageLayout, regionCount: u32, pRegions: [*]const vk.BufferImageCopy) callconv(.C) void);
