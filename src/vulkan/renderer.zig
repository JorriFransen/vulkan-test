const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const alloc = @import("../alloc.zig");
const builtin_shaders = @import("shaders");
const math = @import("../math.zig");
const options = @import("options");
const platform = @import("../platform.zig");
const Window = platform.Window;
const vk = @import("vulkan.zig");
const vke = vk.extensions;
const vkl = vk.loader;

const stbi = @import("../stb/stb.zig").image;
const tol = @import("../tol/tol.zig");

const Vec2 = math.Vec2f32;
const Vec3 = math.Vec3f32;
const Mat4 = math.Mat4f32;

const DTimer = @import("../debug_timer.zig").Timer;

const vlog = std.log.scoped(.vulkan);
const dlog = vlog.debug;
const elog = vlog.err;
const ilog = vlog.info;

const debug = builtin.mode == .Debug;
const is_mac = builtin.target.os.tag == .macos;

const Renderer = @This();

const MAX_FRAMES_IN_FLIGHT = 2;
const MAX_SWAPCHAIN_IMAGES = 8;
const UBO_COUNT = 1;

window: *Window = undefined,
instance: vk.Instance = null,
surface: vk.SurfaceKHR = null,
device: vk.Device = null,
device_info: PDevInfo = undefined,
graphics_que: vk.Queue = null,
present_que: vk.Queue = null,
// transfer_que: vk.Queue = null,

swapchain: vk.SwapchainKHR = null,
swapchain_extent: vk.Extent2D = undefined,
image_count: usize = 0,
framebuffer_resized: bool = false,

render_pass: vk.RenderPass = null,
descriptor_set_layout: vk.DescriptorSetLayout = null,
descriptor_pool: vk.DescriptorPool = null,
descriptor_sets: [MAX_FRAMES_IN_FLIGHT]vk.DescriptorSet = .{null} ** MAX_FRAMES_IN_FLIGHT,
pipeline_layout: vk.PipelineLayout = null,
graphics_pipeline: vk.Pipeline = null,
command_pool: vk.CommandPool = null,
// tmp_command_pool: vk.CommandPool = null,
current_frame: u32 = 0,
debug_messenger: vk.DebugUtilsMessengerEXT = null,

// swapchain
images: [MAX_SWAPCHAIN_IMAGES]vk.Image = undefined,
image_views: [MAX_SWAPCHAIN_IMAGES]vk.ImageView = undefined,
framebuffers: [MAX_SWAPCHAIN_IMAGES]vk.Framebuffer = undefined,

// presentation
command_buffers: [MAX_FRAMES_IN_FLIGHT]vk.CommandBuffer = .{null} ** MAX_FRAMES_IN_FLIGHT,
image_available_semaphores: [MAX_FRAMES_IN_FLIGHT]vk.Semaphore = .{null} ** MAX_FRAMES_IN_FLIGHT,
render_finished_semaphores: [MAX_FRAMES_IN_FLIGHT]vk.Semaphore = .{null} ** MAX_FRAMES_IN_FLIGHT,
in_flight_fences: [MAX_FRAMES_IN_FLIGHT]vk.Fence = .{null} ** MAX_FRAMES_IN_FLIGHT,

index_buffer: vk.Buffer = null,
vertex_buffer: vk.Buffer = null,
uniform_buffers: [MAX_FRAMES_IN_FLIGHT]vk.Buffer = .{null} ** MAX_FRAMES_IN_FLIGHT,
uniform_buffers_mapped: [MAX_FRAMES_IN_FLIGHT][UBO_COUNT]*UniformBufferObject = undefined,

// index_buffer_memory: vk.DeviceMemory = null,
// vertex_buffer_memory: vk.DeviceMemory = null,
uniform_buffers_memory: [MAX_FRAMES_IN_FLIGHT]vk.DeviceMemory = .{null} ** MAX_FRAMES_IN_FLIGHT,
combined_buffer_memory: vk.DeviceMemory = null,

setup_command_buffer: vk.CommandBuffer = null,

texture_image: vk.Image = undefined,
texture_image_memory: vk.DeviceMemory = undefined,
texture_image_view: vk.ImageView = undefined,
texture_sampler: vk.Sampler = undefined,

depth_image: vk.Image = undefined,
depth_image_memory: vk.DeviceMemory = undefined,
depth_image_view: vk.ImageView = undefined,

timer: std.time.Timer = undefined,

vertices: std.ArrayList(Vertex) = undefined,
indices: std.ArrayList(IndexType) = undefined,

const IndexType = u32;

const UniformBufferObject = extern struct {
    model: Mat4 align(16),
    view: Mat4 align(16),
    proj: Mat4 align(16),
};

const Vertex = extern struct {
    pos: Vec3,
    color: Vec3,
    uv: Vec2,

    pub const binding_description: vk.VertexInputBindingDescription = .{ .binding = 0, .stride = @sizeOf(@This()), .inputRate = .VERTEX };

    const field_count = @typeInfo(@This()).@"struct".fields.len;
    pub const attribute_descriptions: [field_count]vk.VertexInputAttributeDescription = blk: {
        var result: [field_count]vk.VertexInputAttributeDescription = undefined;

        for (&result, 0..) |*desc, i| {
            const field_info = @typeInfo(@This()).@"struct".fields[i];

            desc.* = .{
                .binding = 0,
                .location = i,
                .format = switch (field_info.type) {
                    else => @compileError(std.fmt.comptimePrint("Unhandled Vertex member type '{}'", .{field_info.type})),
                    Vec2 => .R32G32_SFLOAT,
                    Vec3 => .R32G32B32_SFLOAT,
                },
                .offset = @offsetOf(@This(), field_info.name),
            };
        }
        break :blk result;
    };
};

const MODEL_PATH: [:0]const u8 = "./res/viking_room.obj";
const TEXTURE_PATH: [:0]const u8 = "res/viking_room.png";
// const MODEL_PATH: [:0]const u8 = "res/cube.obj";
// const TEXTURE_PATH: [:0]const u8 = "res/cube.png";

const PDevInfo = struct {
    score: u32,
    properties: vk.PhysicalDeviceProperties,
    queue_info: QueueFamilyInfo,
    swapchain_info: SwapchainInfo,
    physical_device: vk.PhysicalDevice,
};

const QueueFamilyInfo = struct {
    graphics_index: u32 = undefined,
    present_index: u32 = undefined,

    pub inline fn familyIndices(this: *const @This()) []const u32 {
        if (this.graphics_index == this.present_index) {
            return &.{this.graphics_index};
        } else {
            return &.{ this.graphics_index, this.present_index };
        }
    }
};

const SwapchainInfo = struct {
    min_image_count: u32,
    surface_capabilities: vk.SurfaceCapabilitiesKHR,
    surface_format: vk.SurfaceFormatKHR,
    present_mode: vk.PresentModeKHR,
};

const validation_layers: []const [*:0]const u8 = if (debug) &.{
    "VK_LAYER_KHRONOS_validation",
} else &.{};

const mac_instance_extensions: []const [*:0]const u8 = if (is_mac) &.{
    vkl.portability_enumeration.name,
} else &.{};

const debug_instance_extensions: []const [*:0]const u8 = if (debug) &.{
    vkl.debug_utils.name,
} else &.{};

const instance_extensions = mac_instance_extensions ++ debug_instance_extensions;

const required_device_extensions: []const [*:0]const u8 = &.{
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
};

pub fn init(this: *@This(), window: *Window) !void {
    const instance = try createInstance(window);
    const debug_messenger = createDebugMessenger(instance);
    const surface = try window.createVulkanSurface(instance);
    const device_info = try choosePhysicalDevice(instance, surface);

    this.* = .{
        .window = window,
        .instance = instance,
        .surface = surface,
        .device_info = device_info,
        .debug_messenger = debug_messenger,
    };

    try this.createLogicalDevice();

    try this.createSwapchain();
    try this.createImageViews();

    try this.createRenderPass();
    try this.createDescriptorSetLayout();
    try this.createGraphicsPipeline();
    try this.createCommandPools();
    try this.createCommandBuffers();
    try this.createDepthResources();
    try this.createFrameBuffers();
    try this.createTextureImage();
    try this.createTextureImageView();
    try this.createTextureSampler();

    try this.loadModel();
    // try this.createVertexBuffer();
    // try this.createIndexBuffer();
    try this.createCombinedBuffer();

    try this.createUniformBuffers();
    try this.createDescriptorPool();
    try this.createDescriptorSets();

    try this.createSyncObjects();

    this.timer = try std.time.Timer.start();
}

pub fn deinit(this: *const @This()) void {
    const dev = this.device;

    this.vertices.deinit();
    this.indices.deinit();

    _ = vk.deviceWaitIdle(this.device);

    this.cleanupSwapchain();

    vk.destroySampler(this.device, this.texture_sampler, null);
    vk.destroyImageView(this.device, this.texture_image_view, null);
    vk.destroyImage(this.device, this.texture_image, null);
    vk.freeMemory(this.device, this.texture_image_memory, null);

    vk.destroyBuffer(this.device, this.vertex_buffer, null);
    // vk.freeMemory(this.device, this.vertex_buffer_memory, null);

    vk.destroyBuffer(this.device, this.index_buffer, null);
    // vk.freeMemory(this.device, this.index_buffer_memory, null);

    for (this.uniform_buffers) |ub| vk.destroyBuffer(this.device, ub, null);
    for (this.uniform_buffers_memory) |ubm| vk.freeMemory(this.device, ubm, null);

    vk.freeMemory(this.device, this.combined_buffer_memory, null);

    for (0..MAX_FRAMES_IN_FLIGHT) |i| {
        vk.destroyFence(dev, this.in_flight_fences[i], null);
        vk.destroySemaphore(dev, this.render_finished_semaphores[i], null);
        vk.destroySemaphore(dev, this.image_available_semaphores[i], null);
    }

    vk.destroyCommandPool(dev, this.command_pool, null);
    // vk.destroyCommandPool(dev, this.tmp_command_pool, null);
    vk.destroyPipeline(dev, this.graphics_pipeline, null);
    vk.destroyPipelineLayout(dev, this.pipeline_layout, null);
    vk.destroyDescriptorPool(dev, this.descriptor_pool, null);
    vk.destroyDescriptorSetLayout(dev, this.descriptor_set_layout, null);
    vk.destroyRenderPass(dev, this.render_pass, null);

    vk.destroyDevice(dev, null);
    vk.destroySurfaceKHR(this.instance, this.surface, null);
    if (debug) vke.destroyDebugUtilsMessenger(this.instance, this.debug_messenger, null);
    vk.destroyInstance(this.instance, null);
}

fn createInstance(window: *const Window) !vk.Instance {
    var create_instance_timer = DTimer.start("create_instance");

    var enumerate_extension_props_timer = DTimer.start("enumerate_extension_props");
    enumerate_extension_props_timer.reset();
    var extension_count: u32 = undefined;
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, null);
    dlog("{} Vulkan extensions supported", .{extension_count});
    enumerate_extension_props_timer.lap();

    const extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, extension_count);
    defer alloc.gpa.free(extension_props);
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, extension_props.ptr);
    // for (extension_props) |p| dlog("supported extension: '{s}'", .{@as([*:0]const u8, @ptrCast(&p.extensionName))});
    enumerate_extension_props_timer.lap();

    const window_required_extensions = try window.requiredVulkanInstanceExtensions();

    const instance_ext_count = window_required_extensions.len + instance_extensions.len;

    var required_instance_extensions = try std.ArrayList([*:0]const u8).initCapacity(alloc.gpa, instance_ext_count);
    defer required_instance_extensions.deinit();
    required_instance_extensions.appendSliceAssumeCapacity(window_required_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(instance_extensions);

    var req_inst_ext_timer = DTimer.start("req_inst_ext");

    for (required_instance_extensions.items) |required| {
        var found = false;
        const r: []const u8 = std.mem.span(required);

        dlog("window required instance extension: '{s}'", .{r});

        for (extension_props) |*available| {
            const a: @TypeOf(r) = std.mem.span(@as([*:0]const u8, @ptrCast(&available.extensionName)));
            if (std.mem.eql(u8, r, a)) {
                found = true;
                break;
            }
        }

        if (!found) {
            elog("missing required extension: '{s}'", .{required});
            return error.Missing_Required_Extension;
        }
    }

    req_inst_ext_timer.lap();

    var available_layers: []const vk.LayerProperties = undefined;

    if (debug) {
        var count: u32 = undefined;
        var res = vk.enumerateInstanceLayerProperties(&count, null);
        assert(res == .SUCCESS);

        available_layers = try alloc.gpa.alloc(vk.LayerProperties, count);
        res = vk.enumerateInstanceLayerProperties(&count, @constCast(available_layers.ptr));
        assert(res == .SUCCESS);

        // for (available_layers) |l| dlog("available layer '{s}'", .{@as([*:0]const u8, @ptrCast(&l.layerName))});
    }
    defer if (debug) alloc.gpa.free(available_layers);

    var validation_layers_timer = DTimer.start("Validation_layers");

    for (validation_layers) |rl| {
        var found = false;
        const r: []const u8 = std.mem.span(rl);

        dlog("instance required layer: '{s}'", .{r});

        for (available_layers) |*available| {
            const a: []const u8 = std.mem.span(@as([*:0]const u8, @ptrCast(&available.layerName)));
            if (std.mem.eql(u8, r, a)) {
                found = true;
                break;
            }
        }

        if (!found) {
            elog("missing required layer: '{s}'", .{r});
            return error.Missing_Required_Layer;
        }
    }

    validation_layers_timer.lap();

    const app_info = vk.ApplicationInfo{
        .pApplicationName = "Vulkan app",
        .applicationVersion = vk.MAKE_VERSION(1, 0, 0),
        .pEngineName = "Vulkan engine",
        .engineVersion = vk.MAKE_VERSION(1, 0, 0),
        .apiVersion = vk.API_VERSION_1_0,
    };

    const debug_messenger_create_info = vk.DebugUtilsMessengerCreateInfoEXT{
        .messageSeverity = .{ .VERBOSE_BIT_EXT = 1, .WARNING_BIT_EXT = 1, .ERROR_BIT_EXT = 1 },
        .messageType = .{ .GENERAL = 1, .VALIDATION = 1, .PERFORMANCE = 1 },
        .pfnUserCallback = vk_debug_callback,
        .pUserData = null,
    };

    const instance_create_info = vk.InstanceCreateInfo{
        .pApplicationInfo = &app_info,
        .flags = .{ .ENUMERATE_PORTABILITY_BIT_KHR = if (is_mac) 1 else 0 },
        .enabledExtensionCount = @intCast(required_instance_extensions.items.len),
        .ppEnabledExtensionNames = required_instance_extensions.items.ptr,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
        .pNext = if (debug) &debug_messenger_create_info else null,
    };

    var instance: vk.Instance = undefined;
    switch (vk.createInstance(&instance_create_info, null, &instance)) {
        .SUCCESS => {
            dlog("vkCreateInstance: OK", .{});
        },
        else => |v| {
            elog("vkCreateInstance returned '{}'", .{v});
            return error.vkCreateInstance_Failed;
        },
    }

    vk.loader.load(instance, required_instance_extensions.items);

    create_instance_timer.lap();
    return instance;
}

fn createDebugMessenger(instance: vk.Instance) vk.DebugUtilsMessengerEXT {
    if (debug) {
        const debug_messenger_create_info = vk.DebugUtilsMessengerCreateInfoEXT{
            .messageSeverity = .{ .VERBOSE_BIT_EXT = 1, .WARNING_BIT_EXT = 1, .ERROR_BIT_EXT = 1 },
            .messageType = .{ .GENERAL = 1, .VALIDATION = 1, .PERFORMANCE = 1 },
            .pfnUserCallback = vk_debug_callback,
            .pUserData = null,
        };

        var result: vk.DebugUtilsMessengerEXT = null;
        _ = vke.createDebugUtilsMessenger(instance, &debug_messenger_create_info, null, &result);
        return result;
    }

    return null;
}

fn choosePhysicalDevice(instance: vk.Instance, surface: vk.SurfaceKHR) !PDevInfo {
    var device_count: u32 = 0;
    _ = vk.enumeratePhysicalDevices(instance, &device_count, null);
    if (device_count == 0) {
        elog("Failed to find gpu(s) with Vulkan support!", .{});
        return error.No_Vulkan_Support_Gpu_Found;
    }

    const devices = try alloc.gpa.alloc(vk.PhysicalDevice, device_count);
    defer alloc.gpa.free(devices);

    _ = vk.enumeratePhysicalDevices(instance, &device_count, devices.ptr);

    var suitable_device_found = false;
    var best_device_index: usize = undefined;
    var best_device_info: PDevInfo = undefined;

    for (devices, 0..) |pdev, i| {
        var props: vk.PhysicalDeviceProperties = undefined;
        vk.getPhysicalDeviceProperties(pdev, &props);

        var features: vk.PhysicalDeviceFeatures = undefined;
        vk.getPhysicalDeviceFeatures(pdev, &features);

        dlog("pd_props[{}]: name: {s}", .{ i, props.deviceName });
        dlog("pd_props[{}]: type: {s}", .{ i, @tagName(props.deviceType) });
        dlog("pd_props[{}]: limits.maxImageDimension2D: {}", .{ i, props.limits.maxImageDimension2D });
        dlog("pd_feat[{}]: geometryShader: {}", .{ i, features.geometryShader });

        const type_score: u32 = switch (props.deviceType) {
            .OTHER => 1,
            .VIRTUAL_GPU => 2,
            .CPU => 3,
            .INTEGRATED_GPU => 4,
            .DISCRETE_GPU => 5,
        };

        const image_dim_score = props.limits.maxImageDimension2D / 4096;

        const queue_info_opt = try queryQueueFamiliesInfo(pdev, surface);
        const queue_info = queue_info_opt orelse {
            dlog("pd[{}] does not have required queue families, skipping...", .{i});
            continue;
        };

        if (!try queryDeviceExtensionsSuitable(pdev)) {
            dlog("pd[{}] does not have required extensions, skipping...", .{i});
            continue;
        }

        const swapchain_info_opt = try querySwapchainInfo(pdev, surface);
        const swapchain_info = swapchain_info_opt orelse {
            dlog("pd[{}] does not meet swapchain requirements, skipping...", .{i});
            continue;
        };

        if (features.samplerAnisotropy != vk.TRUE) {
            dlog("pd[{}] does not meet sampler anisotropy requirements, skipping...", .{i});
            continue;
        }

        const score = type_score * image_dim_score;
        dlog("pd[{}]: score: {}", .{ i, score });

        dlog("===========================", .{});

        const info = PDevInfo{
            .score = score,
            .properties = props,
            .queue_info = queue_info,
            .swapchain_info = swapchain_info,
            .physical_device = null,
        };

        const new_best = if (suitable_device_found) info.score > best_device_info.score else true;
        if (new_best) {
            suitable_device_found = true;
            best_device_info = info;
            best_device_index = i;
        }
    }

    if (!suitable_device_found) {
        elog("Failed to find suitable gpu!", .{});
        return error.No_Suitable_Gpu_Found;
    }

    best_device_info.physical_device = devices[best_device_index];
    ilog("using device: {} ({s})", .{ best_device_index, best_device_info.properties.deviceName });

    return best_device_info;
}

fn queryQueueFamiliesInfo(pdev: vk.PhysicalDevice, surface: vk.SurfaceKHR) !?QueueFamilyInfo {
    var que_family_count: u32 = undefined;
    vk.getPhysicalDeviceQueueFamilyProperties(pdev, &que_family_count, null);

    const queue_families = try alloc.gpa.alloc(vk.QueueFamilyProperties, que_family_count);
    defer alloc.gpa.free(queue_families);
    vk.getPhysicalDeviceQueueFamilyProperties(pdev, &que_family_count, queue_families.ptr);

    var result: QueueFamilyInfo = undefined;

    var graphics_que_found = false;
    var present_que_found = false;

    for (queue_families, 0..) |qf, qi| {
        if (qf.queueFlags.GRAPHICS_BIT == 1) {
            result.graphics_index = @intCast(qi);
            graphics_que_found = true;
        }

        if (!present_que_found) {
            var supported: vk.Bool32 = vk.FALSE;
            _ = vk.getPhysicalDeviceSurfaceSupportKHR(pdev, @intCast(qi), surface, &supported);
            if (supported == vk.TRUE) {
                result.present_index = @intCast(qi);
                present_que_found = true;
            }
        }

        if (graphics_que_found and present_que_found) return result;
    }

    return null;
}

fn queryDeviceExtensionsSuitable(pdev: vk.PhysicalDevice) !bool {
    var prop_count: u32 = undefined;
    _ = vk.enumerateDeviceExtensionProperties(pdev, null, &prop_count, null);

    const dev_extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, prop_count);
    defer alloc.gpa.free(dev_extension_props);
    _ = vk.enumerateDeviceExtensionProperties(pdev, null, &prop_count, dev_extension_props.ptr);

    for (required_device_extensions) |re| {
        var found = false;
        const r: []const u8 = std.mem.span(re);
        for (dev_extension_props) |*prop| {
            const a: []const u8 = std.mem.span(@as([*:0]const u8, @ptrCast(&prop.extensionName)));
            if (std.mem.eql(u8, r, a)) {
                found = true;
                break;
            }
        }
        if (!found) {
            return false;
        }
    }

    return true;
}

fn querySwapchainInfo(pdev: vk.PhysicalDevice, surface: vk.SurfaceKHR) !?SwapchainInfo {
    var surface_capabilities: vk.SurfaceCapabilitiesKHR = undefined;
    if (vk.getPhysicalDeviceSurfaceCapabilitiesKHR(pdev, surface, &surface_capabilities) != .SUCCESS) {
        return error.Get_Physical_Device_Surface_Capabilities_Failed;
    }

    var format_count: u32 = undefined;
    if (vk.getPhysicalDeviceSurfaceFormatsKHR(pdev, surface, &format_count, null) != .SUCCESS) {
        return error.Get_Physical_Device_Surface_Formats_Failed;
    }
    if (format_count == 0) return null;

    var formats: []vk.SurfaceFormatKHR = undefined;
    formats = try alloc.gpa.alloc(vk.SurfaceFormatKHR, format_count);
    if (vk.getPhysicalDeviceSurfaceFormatsKHR(pdev, surface, &format_count, @ptrCast(formats.ptr)) != .SUCCESS) {
        return error.Get_Physical_Device_Surface_Formats_Failed;
    }
    defer alloc.gpa.free(formats);

    var present_mode_count: u32 = undefined;
    if (vk.getPhysicalDeviceSurfacePresentModesKHR(pdev, surface, &present_mode_count, null) != .SUCCESS) {
        return error.Get_Physical_Device_Surface_Presentmodes_Failed;
    }
    if (present_mode_count == 0) return null;

    var present_modes: []vk.PresentModeKHR = undefined;
    present_modes = try alloc.gpa.alloc(vk.PresentModeKHR, present_mode_count);
    if (vk.getPhysicalDeviceSurfacePresentModesKHR(pdev, surface, &present_mode_count, @ptrCast(present_modes.ptr)) != .SUCCESS) {
        return error.Get_Physical_Device_Surface_Presentmodes_Failed;
    }
    defer alloc.gpa.free(present_modes);

    const chosen_format = for (formats) |format| {
        if (format.format == .B8G8R8A8_SRGB and format.colorSpace == .SRGB_NONLINEAR_KHR) {
            break format;
        }
    } else formats[0];

    dlog("chosen format: {}", .{chosen_format});

    const chosen_present_mode = for (present_modes) |mode| {
        if (mode == .MAILBOX_KHR) {
            break mode;
        }
    } else .IMMEDIATE_KHR;

    dlog("chosen present mode: {}", .{chosen_present_mode});

    var image_count = surface_capabilities.minImageCount + 1;
    if (surface_capabilities.maxImageCount > 0 and image_count > surface_capabilities.maxImageCount)
        image_count = surface_capabilities.maxImageCount;
    dlog("swapchain image_count: {}", .{image_count});

    return .{
        .min_image_count = image_count,
        .surface_capabilities = surface_capabilities,
        .surface_format = chosen_format,
        .present_mode = chosen_present_mode,
    };
}

fn createLogicalDevice(this: *@This()) !void {
    const dev_info = this.device_info;

    var fin_array = [_]u32{
        dev_info.queue_info.graphics_index,
        dev_info.queue_info.present_index,
    };

    var fin: []u32 = &fin_array;
    std.mem.sort(u32, fin, .{}, struct {
        fn f(_: @TypeOf(.{}), l: u32, r: u32) bool {
            return l < r;
        }
    }.f);

    { // Rewrite the sorted list to unique number only
        var last_fi: i32 = -1;
        var fi_write_index: usize = 0;
        for (fin) |fi| {
            defer last_fi = @intCast(fi);

            if (fi == last_fi) continue;

            fin[fi_write_index] = fi;
            fi_write_index += 1;
        }
        fin = fin[0..fi_write_index];
        dlog("fin: {any}", .{fin});
    }

    var qci_array: [fin_array.len]vk.DeviceQueueCreateInfo = undefined;
    const qcis: []vk.DeviceQueueCreateInfo = qci_array[0..fin.len];
    const que_prios = [_]f32{1.0};

    for (qcis, fin) |*qci, fi| qci.* = .{
        .queueFamilyIndex = fi,
        .queueCount = 1,
        .pQueuePriorities = &que_prios,
    };

    const device_features = vk.PhysicalDeviceFeatures{
        .samplerAnisotropy = vk.TRUE,
    };

    const device_create_info = vk.DeviceCreateInfo{
        .pQueueCreateInfos = qcis.ptr,
        .queueCreateInfoCount = @intCast(qcis.len),
        .pEnabledFeatures = &device_features,
        .enabledExtensionCount = required_device_extensions.len,
        .ppEnabledExtensionNames = required_device_extensions.ptr,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
    };

    if (vk.createDevice(this.device_info.physical_device, &device_create_info, null, &this.device) != .SUCCESS) {
        elog("Failed to create logical device!", .{});
        return error.Logical_Device_Creation_Failed;
    }

    vk.getDeviceQueue(this.device, dev_info.queue_info.graphics_index, 0, &this.graphics_que);
    vk.getDeviceQueue(this.device, dev_info.queue_info.present_index, 0, &this.present_que);
    // vk.getDeviceQueue(this.device, dev_info.queue_info.transfer_index, 0, &this.transfer_que);
}

pub fn handleFramebufferResize(this: *@This(), _: c_int, _: c_int) void {
    this.framebuffer_resized = true;
}

pub fn recreateSwapchain(this: *@This()) !void {
    var size = this.window.framebufferSize();
    while (size.width == 0 or size.height == 0) {
        size = this.window.framebufferSize();
        this.window.waitEvents();
    }

    _ = vk.deviceWaitIdle(this.device);

    this.cleanupSwapchain();

    try this.createSwapchain();
    try this.createImageViews();
    try this.createDepthResources();
    try this.createFrameBuffers();
}

pub fn cleanupSwapchain(this: *const @This()) void {
    vk.destroyImageView(this.device, this.depth_image_view, null);
    vk.destroyImage(this.device, this.depth_image, null);
    vk.freeMemory(this.device, this.depth_image_memory, null);

    for (0..this.image_count) |i| vk.destroyFramebuffer(this.device, this.framebuffers[i], null);
    for (0..this.image_count) |i| vk.destroyImageView(this.device, this.image_views[i], null);

    vk.destroySwapchainKHR(this.device, this.swapchain, null);
}

pub fn createSwapchain(this: *@This()) !void {
    this.device_info.swapchain_info = try querySwapchainInfo(this.device_info.physical_device, this.surface) orelse @panic("Swapchain creation failed!");
    const dev_info = &this.device_info;
    const info = dev_info.swapchain_info;
    const cap = &info.surface_capabilities;

    const fb_size = this.window.framebufferSize();

    dlog("cap.currentExtent: {}", .{cap.currentExtent});
    this.swapchain_extent = switch (cap.currentExtent.width) {
        std.math.maxInt(u32) => blk: {
            var actual_extent = vk.Extent2D{ .width = @intCast(fb_size.width), .height = @intCast(fb_size.height) };
            actual_extent.width = std.math.clamp(actual_extent.width, cap.minImageExtent.width, cap.maxImageExtent.width);
            actual_extent.height = std.math.clamp(actual_extent.height, cap.minImageExtent.height, cap.maxImageExtent.height);

            break :blk actual_extent;
        },
        else => cap.currentExtent,
    };

    dlog("swapchain extent: {}", .{this.swapchain_extent});

    // const same_family = dev_info.queue_info.graphics_index == dev_info.queue_info.present_index;
    const queue_indices = dev_info.queue_info.familyIndices();

    const create_info = vk.SwapchainCreateInfoKHR{
        .surface = this.surface,
        .minImageCount = dev_info.swapchain_info.min_image_count,
        .imageFormat = dev_info.swapchain_info.surface_format.format,
        .imageColorSpace = dev_info.swapchain_info.surface_format.colorSpace,
        .imageExtent = this.swapchain_extent,
        .imageArrayLayers = 1,
        .imageUsage = .{ .COLOR_ATTACHMENT_BIT = 1 },
        .imageSharingMode = .EXCLUSIVE,
        .queueFamilyIndexCount = @intCast(queue_indices.len),
        .pQueueFamilyIndices = queue_indices.ptr,
        .preTransform = cap.currentTransform,
        .compositeAlpha = .{ .OPAQUE_BIT_KHR = 1 },
        .presentMode = dev_info.swapchain_info.present_mode,
        .clipped = vk.TRUE,
        .oldSwapchain = null,
    };

    if (vk.createSwapchainKHR(this.device, &create_info, null, &this.swapchain) != .SUCCESS) {
        return error.Create_Swapchain_Failed;
    }

    var image_count: u32 = undefined;
    if (vk.getSwapchainImagesKHR(this.device, this.swapchain, &image_count, null) != .SUCCESS) {
        return error.Get_Swapchain_Images_Failed;
    }

    assert(image_count <= MAX_SWAPCHAIN_IMAGES);
    this.image_count = image_count;

    if (vk.getSwapchainImagesKHR(this.device, this.swapchain, &image_count, &this.images) != .SUCCESS) {
        return error.Get_Swapchain_Images_Failed;
    }
}

fn createImageViews(this: *@This()) !void {
    for (0..this.image_count) |i|
        this.image_views[i] = try this.createImageView(
            this.images[i],
            this.device_info.swapchain_info.surface_format.format,
            .{ .COLOR_BIT = 1 },
        );
}

fn createRenderPass(this: *@This()) !void {
    const color_attachment = vk.AttachmentDescription{
        .format = this.device_info.swapchain_info.surface_format.format,
        .samples = .{ .@"1_BIT" = 1 },
        .loadOp = .CLEAR,
        .storeOp = .STORE,
        .stencilLoadOp = .DONT_CARE,
        .stencilStoreOp = .DONT_CARE,
        .initialLayout = .UNDEFINED,
        .finalLayout = .PRESENT_SRC_KHR,
    };

    const color_attachment_refs = [_]vk.AttachmentReference{.{
        .attachment = 0,
        .layout = .COLOR_ATTACHMENT_OPTIMAL,
    }};

    const depth_attachment = vk.AttachmentDescription{
        .format = try this.findDepthFormat(),
        .samples = .{ .@"1_BIT" = 1 },
        .loadOp = .CLEAR,
        .storeOp = .DONT_CARE,
        .stencilLoadOp = .DONT_CARE,
        .stencilStoreOp = .DONT_CARE,
        .initialLayout = .UNDEFINED,
        .finalLayout = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    };

    const depth_attachment_refs = [_]vk.AttachmentReference{.{
        .attachment = 1,
        .layout = .DEPTH_STENCIL_ATTACHMENT_OPTIMAL,
    }};

    const subpasses = [_]vk.SubpassDescription{.{
        .pipelineBindPoint = .GRAPHICS,
        .inputAttachmentCount = 0,
        .preserveAttachmentCount = 0,
        .colorAttachmentCount = color_attachment_refs.len,
        .pColorAttachments = &color_attachment_refs,
        .pDepthStencilAttachment = &depth_attachment_refs,
    }};

    const dependencies = [_]vk.SubpassDependency{.{
        .srcSubpass = vk.SUBPASS_EXTERNAL,
        .dstSubpass = 0,
        .srcStageMask = .{ .COLOR_ATTACHMENT_OUTPUT_BIT = 1, .EARLY_FRAGMENT_TESTS_BIT = 1 },
        .srcAccessMask = vk.AccessFlags.NONE,
        .dstStageMask = .{ .COLOR_ATTACHMENT_OUTPUT_BIT = 1, .EARLY_FRAGMENT_TESTS_BIT = 1 },
        .dstAccessMask = .{ .COLOR_ATTACHMENT_WRITE_BIT = 1, .DEPTH_STENCIL_ATTACHMENT_WRITE_BIT = 1 },
    }};

    const attachments = [_]vk.AttachmentDescription{
        color_attachment, depth_attachment,
    };

    const render_pass_create_info = vk.RenderPassCreateInfo{
        .attachmentCount = attachments.len,
        .pAttachments = &attachments,
        .subpassCount = subpasses.len,
        .pSubpasses = &subpasses,
        .dependencyCount = 1,
        .pDependencies = &dependencies,
    };

    if (vk.createRenderPass(this.device, &render_pass_create_info, null, &this.render_pass) != .SUCCESS) {
        return error.CreateRenderPassFailed;
    }
}

fn createDescriptorSetLayout(this: *@This()) !void {
    const layout_bindings = [_]vk.DescriptorSetLayoutBinding{
        .{
            .binding = 0,
            .descriptorType = .UNIFORM_BUFFER,
            .descriptorCount = 1,
            .stageFlags = .{ .VERTEX_BIT = 1 },
            .pImmutableSamplers = null,
        },
        .{
            .binding = 1,
            .descriptorType = .COMBINED_IMAGE_SAMPLER,
            .descriptorCount = 1,
            .stageFlags = .{ .FRAGMENT_BIT = 1 },
            .pImmutableSamplers = null,
        },
    };

    const layout_info = vk.DescriptorSetLayoutCreateInfo{
        .flags = .{},
        .bindingCount = layout_bindings.len,
        .pBindings = &layout_bindings,
    };

    if (vk.createDescriptorSetLayout(this.device, &layout_info, null, &this.descriptor_set_layout) != .SUCCESS) {
        return error.CreateDescriptorSetLayoutFailed;
    }
}

fn createGraphicsPipeline(this: *@This()) !void {
    const vert_shader_module = try this.createShaderModule(&builtin_shaders.@"color_triangle.vert");
    defer vk.destroyShaderModule(this.device, vert_shader_module, null);

    const frag_shader_module = try this.createShaderModule(&builtin_shaders.@"color_triangle.frag");
    defer vk.destroyShaderModule(this.device, frag_shader_module, null);

    const shader_stages = [_]vk.PipelineShaderStageCreateInfo{
        .{
            .stage = .{ .VERTEX_BIT = 1 },
            .module = vert_shader_module,
            .pName = "main",
        },
        .{
            .stage = .{ .FRAGMENT_BIT = 1 },
            .module = frag_shader_module,
            .pName = "main",
        },
    };

    const dynamic_states = [_]vk.DynamicState{
        vk.DynamicState.VIEWPORT,
        vk.DynamicState.SCISSOR,
    };

    const dynamic_state_create_info = vk.PipelineDynamicStateCreateInfo{
        .dynamicStateCount = dynamic_states.len,
        .pDynamicStates = &dynamic_states,
    };

    const vertex_input_state_create_info = vk.PipelineVertexInputStateCreateInfo{
        .vertexBindingDescriptionCount = 1,
        .pVertexBindingDescriptions = @ptrCast(&Vertex.binding_description),
        .vertexAttributeDescriptionCount = Vertex.attribute_descriptions.len,
        .pVertexAttributeDescriptions = &Vertex.attribute_descriptions,
    };

    const input_assembly_create_info = vk.PipelineInputAssemblyStateCreateInfo{
        .topology = .TRIANGLE_LIST,
        .primitiveRestartEnable = vk.FALSE,
    };

    const viewport_create_info = vk.PipelineViewportStateCreateInfo{
        .viewportCount = 1,
        .pViewports = null,
        .scissorCount = 1,
        .pScissors = null,
    };

    const rasterizer_create_info = vk.PipelineRasterizationStateCreateInfo{
        .depthClampEnable = vk.FALSE,
        .rasterizerDiscardEnable = vk.FALSE,
        .polygonMode = .FILL,
        .lineWidth = 1,
        .cullMode = .{ .BACK_BIT = 1 },
        .frontFace = .COUNTER_CLOCKWISE,
        .depthBiasEnable = vk.FALSE,
        .depthBiasConstantFactor = 0,
        .depthBiasClamp = 0,
        .depthBiasSlopeFactor = 0,
    };

    const multisampling_create_info = vk.PipelineMultisampleStateCreateInfo{
        .sampleShadingEnable = vk.FALSE,
        .rasterizationSamples = .{ .@"1_BIT" = 1 },
        .minSampleShading = 1,
        .pSampleMask = null,
        .alphaToCoverageEnable = vk.FALSE,
        .alphaToOneEnable = vk.FALSE,
    };

    const depth_stencil_create_info = vk.PipelineDepthStencilStateCreateInfo{
        .depthTestEnable = vk.TRUE,
        .depthWriteEnable = vk.TRUE,
        .depthCompareOp = .LESS,
        .depthBoundsTestEnable = vk.FALSE,
        .minDepthBounds = 0,
        .maxDepthBounds = 1,
        .stencilTestEnable = vk.FALSE,
    };

    const color_blend_attachments = [_]vk.PipelineColorBlendAttachmentState{.{
        .colorWriteMask = vk.ColorComponentFlags{ .R_BIT = 1, .G_BIT = 1, .B_BIT = 1, .A_BIT = 1 },
        .blendEnable = vk.TRUE,
        .srcColorBlendFactor = .SRC_ALPHA,
        .dstColorBlendFactor = .ONE_MINUS_SRC_ALPHA,
        .colorBlendOp = .ADD,
        .srcAlphaBlendFactor = .ONE,
        .dstAlphaBlendFactor = .ZERO,
        .alphaBlendOp = .ADD,
    }};

    const blend_create_info = vk.PipelineColorBlendStateCreateInfo{
        .logicOpEnable = vk.FALSE,
        .logicOp = .COPY,
        .attachmentCount = color_blend_attachments.len,
        .pAttachments = &color_blend_attachments,
        .blendConstants = .{ 0, 0, 0, 0 },
    };

    const descriptor_set_layouts = [_]vk.DescriptorSetLayout{this.descriptor_set_layout};

    const pipeline_layout_create_info = vk.PipelineLayoutCreateInfo{
        .flags = .{},
        .setLayoutCount = descriptor_set_layouts.len,
        .pSetLayouts = &descriptor_set_layouts,
        .pushConstantRangeCount = 0,
        .pPushConstantRanges = null,
    };

    if (vk.createPipelineLayout(this.device, &pipeline_layout_create_info, null, &this.pipeline_layout) != .SUCCESS) {
        return error.CreatePipelineLayoutFailed;
    }

    const pipeline_create_infos = [_]vk.GraphicsPipelineCreateInfo{.{
        .stageCount = shader_stages.len,
        .pStages = &shader_stages,
        .pVertexInputState = &vertex_input_state_create_info,
        .pInputAssemblyState = &input_assembly_create_info,
        .pViewportState = &viewport_create_info,
        .pRasterizationState = &rasterizer_create_info,
        .pMultisampleState = &multisampling_create_info,
        .pDepthStencilState = &depth_stencil_create_info,
        .pColorBlendState = &blend_create_info,
        .pDynamicState = &dynamic_state_create_info,
        .layout = this.pipeline_layout,
        .renderPass = this.render_pass,
        .subpass = 0,
        .basePipelineHandle = null,
        .basePipelineIndex = -1,
    }};

    if (vk.createGraphicsPipelines(this.device, null, pipeline_create_infos.len, &pipeline_create_infos, null, &this.graphics_pipeline) != .SUCCESS) {
        return error.CreateGraphicsPipelinesFailed;
    }
}

fn createFrameBuffers(this: *@This()) !void {
    for (0..this.image_count) |i| {
        const attachments = [_]vk.ImageView{ this.image_views[i], this.depth_image_view };

        const framebuffer_create_info = vk.FramebufferCreateInfo{
            .renderPass = this.render_pass,
            .attachmentCount = attachments.len,
            .pAttachments = &attachments,
            .width = this.swapchain_extent.width,
            .height = this.swapchain_extent.height,
            .layers = 1,
        };

        if (vk.createFramebuffer(this.device, &framebuffer_create_info, null, &this.framebuffers[i]) != .SUCCESS) {
            return error.CreateFramebufferFailed;
        }
    }
}

fn createCommandPools(this: *@This()) !void {
    assert(this.device_info.queue_info.graphics_index == this.device_info.queue_info.present_index);

    const create_info = vk.CommandPoolCreateInfo{
        .flags = .{ .RESET_COMMAND_BUFFER = 1 },
        .queueFamilyIndex = this.device_info.queue_info.graphics_index,
    };

    if (vk.createCommandPool(this.device, &create_info, null, &this.command_pool) != .SUCCESS) {
        return error.CreateCommandPoolFailed;
    }
}

fn createImage(this: *@This(), width: usize, height: usize, format: vk.Format, tiling: vk.ImageTiling, usage: vk.ImageUsageFlags, properties: vk.MemoryPropertyFlags, memory: *vk.DeviceMemory) !vk.Image {
    const image_info = vk.ImageCreateInfo{
        .sType = .IMAGE_CREATE_INFO,
        .imageType = .@"2D",
        .extent = .{ .width = @intCast(width), .height = @intCast(height), .depth = 1 },
        .mipLevels = 1,
        .arrayLayers = 1,
        .format = format,
        .tiling = tiling,
        .initialLayout = .UNDEFINED,
        .usage = usage,
        .sharingMode = .EXCLUSIVE,
        .samples = .{ .@"1_BIT" = 1 },
        .queueFamilyIndexCount = 0,
        .pQueueFamilyIndices = null,
    };

    var result: vk.Image = undefined;

    if (vk.createImage(this.device, &image_info, null, &result) != .SUCCESS) {
        return error.CreateImageFailed;
    }

    var mem_req: vk.MemoryRequirements = undefined;
    vk.getImageMemoryRequirements(this.device, result, &mem_req);

    const alloc_info = vk.MemoryAllocateInfo{
        .sType = .MEMORY_ALLOCATE_INFO,
        .allocationSize = mem_req.size,
        .memoryTypeIndex = this.findMemoryType(mem_req.memoryTypeBits, properties) orelse {
            return error.FindMemoryTypeFailed;
        },
    };

    if (vk.allocateMemory(this.device, &alloc_info, null, memory) != .SUCCESS) {
        return error.AllocateMemoryFailed;
    }

    if (vk.bindImageMemory(this.device, result, memory.*, 0) != .SUCCESS) {
        return error.BindImageMemoryFailed;
    }

    return result;
}

fn findSupportedFormat(this: *@This(), candidates: []const vk.Format, tiling: vk.ImageTiling, features: vk.FormatFeatureFlags) !vk.Format {
    for (candidates) |format| {
        var props: vk.FormatProperties = undefined;
        vk.getPhysicalDeviceFormatProperties(this.device_info.physical_device, format, &props);

        const feat_int = @as(vk.Flags, @bitCast(features));

        switch (tiling) {
            .LINEAR => {
                const lin_int = @as(vk.Flags, @bitCast(props.linearTilingFeatures));
                if (lin_int & feat_int == feat_int) return format;
            },
            .OPTIMAL => {
                const opt_int = @as(vk.Flags, @bitCast(props.optimalTilingFeatures));
                if (opt_int & feat_int == feat_int) return format;
            },
            else => return error.FailedToFindSupportedFormat,
        }
    }

    return error.FailedToFindSupportedFormat;
}

inline fn depthFormatHasStencilComponent(format: vk.Format) bool {
    return format == .D32_SFLOAT_S8_UINT or format == .D24_UNORM_S8_UINT;
}

fn findDepthFormat(this: *@This()) !vk.Format {
    return try this.findSupportedFormat(
        &.{
            .D32_SFLOAT,
            .D32_SFLOAT_S8_UINT,
            .D24_UNORM_S8_UINT,
        },
        .OPTIMAL,
        .{ .DEPTH_STENCIL_ATTACHMENT_BIT = 1 },
    );
}

fn createDepthResources(this: *@This()) !void {
    const depth_format = try this.findDepthFormat();
    dlog("Chosen depth format: {}", .{depth_format});

    const extent = this.swapchain_extent;

    this.depth_image = try this.createImage(
        extent.width,
        extent.height,
        depth_format,
        .OPTIMAL,
        .{ .DEPTH_STENCIL_ATTACHMENT_BIT = 1 },
        .{ .DEVICE_LOCAL_BIT = 1 },
        &this.depth_image_memory,
    );

    this.depth_image_view = try this.createImageView(this.depth_image, depth_format, .{ .DEPTH_BIT = 1 });

    dlog("Transitioning: {any}", .{this.depth_image});

    // TODO: FIXME: This is not required here because it is done in the render pass
    // try this.transitionImageLayout(this.depth_image, depth_format, .UNDEFINED, .DEPTH_STENCIL_ATTACHMENT_OPTIMAL);
    try this.flushSetupCommands();
}

fn createTextureImage(this: *@This()) !void {
    var width: c_int = undefined;
    var height: c_int = undefined;
    const channels = stbi.rgb_alpha;
    var __channels: c_int = undefined;

    var pixels: [*]const u8 = undefined;
    if (stbi.load(TEXTURE_PATH, &width, &height, &__channels, channels)) |p| {
        pixels = p;
    } else {
        return error.stbi_loadFailed;
    }
    defer stbi.free(pixels);

    const size: vk.DeviceSize = @intCast(width * height * channels);

    var staging_buffer_mem: vk.DeviceMemory = undefined;
    const staging_buffer = try this.createBuffer(size, .{ .TRANSFER_SRC_BIT = 1 }, .{ .HOST_VISIBLE_BIT = 1, .HOST_COHERENT_BIT = 1 }, &staging_buffer_mem);
    defer {
        vk.destroyBuffer(this.device, staging_buffer, null);
        vk.freeMemory(this.device, staging_buffer_mem, null);
    }

    var data: [*]u8 = undefined;
    if (vk.mapMemory(this.device, staging_buffer_mem, 0, size, .{}, @ptrCast(&data)) != .SUCCESS) {
        return error.VkMapMemoryFailed;
    }

    std.mem.copyForwards(u8, data[0..size], pixels[0..size]);
    vk.unmapMemory(this.device, staging_buffer_mem);

    this.texture_image = try this.createImage(
        @intCast(width),
        @intCast(height),
        .R8G8B8A8_SRGB,
        .OPTIMAL,
        .{ .TRANSFER_DST_BIT = 1, .SAMPLED_BIT = 1 },
        .{ .DEVICE_LOCAL_BIT = 1 },
        &this.texture_image_memory,
    );

    try this.transitionImageLayout(this.texture_image, .R8G8B8A8_SRGB, .UNDEFINED, .TRANSFER_DST_OPTIMAL);
    this.copyBufferToImage(staging_buffer, this.texture_image, @intCast(width), @intCast(height));
    try this.transitionImageLayout(this.texture_image, .R8G8B8A8_SRGB, .TRANSFER_DST_OPTIMAL, .SHADER_READ_ONLY_OPTIMAL);
    try this.flushSetupCommands();
}

fn createTextureImageView(this: *@This()) !void {
    this.texture_image_view = try this.createImageView(this.texture_image, .R8G8B8A8_SRGB, .{ .COLOR_BIT = 1 });
}

fn createImageView(this: *@This(), image: vk.Image, format: vk.Format, aspect_flags: vk.ImageAspectFlags) !vk.ImageView {
    const view_create_info = vk.ImageViewCreateInfo{
        .image = image,
        .viewType = .@"2D",
        .format = format,
        .components = .{ .r = .IDENTITY, .g = .IDENTITY, .b = .IDENTITY, .a = .IDENTITY },
        .subresourceRange = .{
            .aspectMask = aspect_flags,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
    };

    var image_view: vk.ImageView = undefined;
    if (vk.createImageView(this.device, &view_create_info, null, &image_view) != .SUCCESS) {
        return error.Create_Image_View_Failed;
    }

    return image_view;
}

fn createTextureSampler(this: *@This()) !void {
    const sampler_info = vk.SamplerCreateInfo{
        .magFilter = .LINEAR,
        .minFilter = .LINEAR,
        .addressModeU = .REPEAT,
        .addressModeV = .REPEAT,
        .addressModeW = .REPEAT,
        .anisotropyEnable = vk.TRUE,
        .maxAnisotropy = this.device_info.properties.limits.maxSamplerAnisotropy,
        .borderColor = .INT_OPAQUE_BLACK,
        .unnormalizedCoordinates = vk.FALSE,
        .compareEnable = vk.FALSE,
        .compareOp = .ALWAYS,
        .mipmapMode = .LINEAR,
        .mipLodBias = 0,
        .minLod = 0,
        .maxLod = 0,
    };

    if (vk.createSampler(this.device, &sampler_info, null, &this.texture_sampler) != .SUCCESS) {
        return error.CreateSamplerFailed;
    }
}

pub fn createBuffer(this: *const @This(), size: vk.DeviceSize, usage: vk.BufferUsageFlags, properties: vk.MemoryPropertyFlags, memory: *vk.DeviceMemory) !vk.Buffer {
    const qfis = this.device_info.queue_info.familyIndices();

    const create_info = vk.BufferCreateInfo{
        .size = size,
        .usage = usage,
        .sharingMode = .EXCLUSIVE,
        .queueFamilyIndexCount = @intCast(qfis.len),
        .pQueueFamilyIndices = qfis.ptr,
    };

    var buffer: vk.Buffer = null;

    if (vk.createBuffer(this.device, &create_info, null, &buffer) != .SUCCESS) {
        return error.CreateBufferFailed;
    }
    errdefer vk.destroyBuffer(this.device, buffer, null);

    var requirements: vk.MemoryRequirements = undefined;
    vk.getBufferMemoryRequirements(this.device, buffer, &requirements);

    const alloc_info: vk.MemoryAllocateInfo = .{
        .allocationSize = requirements.size,
        .memoryTypeIndex = this.findMemoryType(requirements.memoryTypeBits, properties) orelse
            return error.FindMemoryTypeFailed,
    };

    if (vk.allocateMemory(this.device, &alloc_info, null, memory) != .SUCCESS) {
        return error.AllocateMemoryFailed;
    }
    errdefer vk.freeMemory(this.device, memory.*, null);

    if (vk.bindBufferMemory(this.device, buffer, memory.*, 0) != .SUCCESS) {
        return error.BindBufferMemoryFailed;
    }

    return buffer;
}

pub fn copyBuffer(this: *@This(), src: vk.Buffer, src_offset: usize, dst: vk.Buffer, size: vk.DeviceSize) !void {
    const copy_regions = [_]vk.BufferCopy{.{ .srcOffset = src_offset, .size = size }};
    vk.cmdCopyBuffer(this.setup_command_buffer, src, dst, copy_regions.len, &copy_regions);
}

fn beginSingleTimeCommands(this: *const @This()) !vk.CommandBuffer {
    var cmd_bufs: [1]vk.CommandBuffer = undefined;
    const alloc_info = vk.CommandBufferAllocateInfo{
        .level = .PRIMARY,
        .commandPool = this.command_pool,
        .commandBufferCount = cmd_bufs.len,
    };

    if (vk.allocateCommandBuffers(this.device, &alloc_info, &cmd_bufs) != .SUCCESS) {
        return error.AllocateCommandBuffersFailed;
    }

    const begin_info = vk.CommandBufferBeginInfo{
        .flags = .{ .ONE_TIME_SUBMIT_BIT = 1 },
    };

    if (vk.beginCommandBuffer(cmd_bufs[0], &begin_info) != .SUCCESS) {
        return error.BeginCommandBufferFailed;
    }

    return cmd_bufs[0];
}

fn endSingleTimeCommands(this: *const @This(), cmd_buf: vk.CommandBuffer) !void {
    if (vk.endCommandBuffer(cmd_buf) != .SUCCESS) {
        return error.EndCommandBufferFailed;
    }

    const cmd_bufs = [_]vk.CommandBuffer{cmd_buf};
    const submit_infos = [_]vk.SubmitInfo{.{
        .commandBufferCount = cmd_bufs.len,
        .pCommandBuffers = &cmd_bufs,
    }};

    if (vk.queueSubmit(this.graphics_que, submit_infos.len, &submit_infos, null) != .SUCCESS) {
        return error.QueueSubmitFailed;
    }

    if (vk.queueWaitIdle(this.graphics_que) != .SUCCESS) {
        return error.QueueWaitIdleFailed;
    }
}

fn copyBufferToImage(this: *const @This(), buf: vk.Buffer, img: vk.Image, width: u32, height: u32) void {
    const region = vk.BufferImageCopy{
        .bufferOffset = 0,
        .bufferRowLength = 0,
        .bufferImageHeight = 0,
        .imageSubresource = .{
            .aspectMask = .{ .COLOR_BIT = 1 },
            .mipLevel = 0,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
        .imageOffset = .{},
        .imageExtent = .{ .width = width, .height = height, .depth = 1 },
    };

    vk.cmdCopyBufferToImage(this.setup_command_buffer, buf, img, .TRANSFER_DST_OPTIMAL, 1, @ptrCast(&region));
}

fn transitionImageLayout(this: *const @This(), image: vk.Image, format: vk.Format, old_layout: vk.ImageLayout, new_layout: vk.ImageLayout) !void {
    var src_access_mask = vk.AccessFlags{};
    var dst_access_mask = vk.AccessFlags{};
    var src_stage = vk.PipelineStageFlags{};
    var dst_stage = vk.PipelineStageFlags{};
    var aspect_flags = vk.ImageAspectFlags{ .COLOR_BIT = 1 };

    if (new_layout == .DEPTH_STENCIL_ATTACHMENT_OPTIMAL) {
        aspect_flags = .{ .DEPTH_BIT = 1 };
        if (depthFormatHasStencilComponent(format)) {
            aspect_flags.STENCIL_BIT = 1;
        }
    }

    if (old_layout == .UNDEFINED and new_layout == .TRANSFER_DST_OPTIMAL) {
        dst_access_mask = .{ .TRANSFER_WRITE_BIT = 1 };
        src_stage = .{ .TOP_OF_PIPE_BIT = 1 };
        dst_stage = .{ .TRANSFER_BIT = 1 };
    } else if (old_layout == .TRANSFER_DST_OPTIMAL and new_layout == .SHADER_READ_ONLY_OPTIMAL) {
        src_access_mask = .{ .TRANSFER_WRITE_BIT = 1 };
        dst_access_mask = .{ .SHADER_READ_BIT = 1 };
        src_stage = .{ .TRANSFER_BIT = 1 };
        dst_stage = .{ .FRAGMENT_SHADER_BIT = 1 };
    } else if (old_layout == .UNDEFINED and new_layout == .DEPTH_STENCIL_ATTACHMENT_OPTIMAL) {
        dst_access_mask = .{ .DEPTH_STENCIL_ATTACHMENT_READ_BIT = 1, .DEPTH_STENCIL_ATTACHMENT_WRITE_BIT = 1 };
        src_stage = .{ .TOP_OF_PIPE_BIT = 1 };
        dst_stage = .{ .EARLY_FRAGMENT_TESTS_BIT = 1 };
    } else {
        return error.UnsupportedLayoutTransition;
    }

    const barrier = vk.ImageMemoryBarrier{
        .sType = .IMAGE_MEMORY_BARRIER,
        .oldLayout = old_layout,
        .newLayout = new_layout,
        .srcQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
        .dstQueueFamilyIndex = vk.QUEUE_FAMILY_IGNORED,
        .image = image,
        .subresourceRange = .{
            .aspectMask = aspect_flags,
            .baseMipLevel = 0,
            .levelCount = 1,
            .baseArrayLayer = 0,
            .layerCount = 1,
        },
        .srcAccessMask = src_access_mask,
        .dstAccessMask = dst_access_mask,
    };

    vk.cmdPipelineBarrier(
        this.setup_command_buffer,
        src_stage,
        dst_stage,
        .{},
        0,
        null,
        0,
        null,
        1,
        @ptrCast(&barrier),
    );
}

fn loadModel(this: *@This()) !void {
    var attrib: tol.Attrib = undefined;
    var shapes: []tol.Shape = undefined;
    var materials: []tol.Material = undefined;

    try tol.parseObj(MODEL_PATH, &attrib, &shapes, &materials);
    dlog("\n\nobj attribs: {}", .{attrib});
    dlog("obj shapes[0]: {any}", .{shapes[0]});

    const obj_vertices = attrib.faces[0..attrib.num_faces]; // attrib.num_faces is actually the number of vertices (3 per face)

    const MapContext = struct {
        pub inline fn hash(_: @This(), v: Vertex) u64 {
            return std.hash.Wyhash.hash(0, slice(v));
        }
        pub inline fn eql(_: @This(), va: Vertex, vb: Vertex) bool {
            return std.mem.eql(u8, slice(va), slice(vb));
        }
        inline fn slice(v: Vertex) []const u8 {
            return @as([*]const u8, @ptrCast(&v))[0..@sizeOf(Vertex)];
        }
    };

    var unique_vertices = std.HashMap(Vertex, IndexType, MapContext, std.hash_map.default_max_load_percentage).init(alloc.gpa);
    defer unique_vertices.deinit();

    this.vertices = try std.ArrayList(Vertex).initCapacity(alloc.gpa, attrib.num_texcoords);
    this.indices = try std.ArrayList(IndexType).initCapacity(alloc.gpa, obj_vertices.len);

    std.debug.assert(shapes.len == 1); // length member of shapes doesn't reflect vertex count after triangulation

    for (obj_vertices) |f| {
        const vi: usize = @intCast(f.v_idx);
        const ti: usize = @intCast(f.vt_idx);

        const vertex = Vertex{
            .pos = .{
                .x = attrib.vertices[3 * vi + 0],
                .y = attrib.vertices[3 * vi + 1],
                .z = attrib.vertices[3 * vi + 2],
            },
            .uv = .{
                .x = attrib.texcoords[2 * ti + 0],
                .y = 1 - attrib.texcoords[2 * ti + 1],
            },
            .color = Vec3.initS(1),
        };

        if (!unique_vertices.contains(vertex)) {
            try unique_vertices.put(vertex, @intCast(this.vertices.items.len));
            try this.vertices.append(vertex);
        }

        try this.indices.append(unique_vertices.get(vertex).?);
    }

    dlog("vertices.len: {}", .{this.vertices.items.len});
    dlog("indices.len: {}", .{this.indices.items.len});

    tol.tinyobj_attrib_free(&attrib);
    if (shapes.len != 0) tol.tinyobj_shapes_free(shapes.ptr, shapes.len);
    if (materials.len != 0) tol.tinyobj_materials_free(materials.ptr, materials.len);
}

// fn createVertexBuffer(this: *@This()) !void {
//     const size = @sizeOf(Vertex) * this.vertices.len;
//
//     var staging_buffer_memory: vk.DeviceMemory = null;
//     const staging_buffer = try this.createBuffer(size, .{ .TRANSFER_SRC_BIT = 1 }, .{
//         .HOST_VISIBLE_BIT = 1,
//         .HOST_COHERENT_BIT = 1,
//     }, &staging_buffer_memory);
//     defer {
//         vk.destroyBuffer(this.device, staging_buffer, null);
//         vk.freeMemory(this.device, staging_buffer_memory, null);
//     }
//
//     var data: [*]Vertex = undefined;
//     if (vk.mapMemory(this.device, staging_buffer_memory, 0, size, .{}, @ptrCast(&data)) != .SUCCESS) {
//         return error.mapMemoryFailed;
//     }
//     std.mem.copyForwards(@TypeOf(this.vertices[0]), data[0..this.vertices.len], this.vertices);
//     vk.unmapMemory(this.device, staging_buffer_memory);
//
//     this.vertex_buffer = try this.createBuffer(
//         size,
//         .{ .TRANSFER_DST_BIT = 1, .VERTEX_BUFFER_BIT = 1 },
//         .{ .DEVICE_LOCAL_BIT = 1 },
//         &this.vertex_buffer_memory,
//     );
//
//     try this.copyBuffer(staging_buffer, 0, this.vertex_buffer, size);
//     try this.flushSetupCommands();
// }

// fn createIndexBuffer(this: *@This()) !void {
//     const size = @sizeOf(IndexType) * this.indices.len;
//
//     var staging_buffer_memory: vk.DeviceMemory = null;
//     const staging_buffer = try this.createBuffer(
//         size,
//         .{ .TRANSFER_SRC_BIT = 1 },
//         .{ .HOST_VISIBLE_BIT = 1, .HOST_COHERENT_BIT = 1 },
//         &staging_buffer_memory,
//     );
//     defer {
//         vk.destroyBuffer(this.device, staging_buffer, null);
//         vk.freeMemory(this.device, staging_buffer_memory, null);
//     }
//
//     var data: @TypeOf(this.indices) = undefined;
//     if (vk.mapMemory(this.device, staging_buffer_memory, 0, size, .{}, @ptrCast(&data)) != .SUCCESS) {
//         return error.MapMemoryFailed;
//     }
//     std.mem.copyForwards(@TypeOf(this.indices[0]), data, this.indices);
//     vk.unmapMemory(this.device, staging_buffer_memory);
//
//     this.index_buffer = try this.createBuffer(
//         size,
//         .{ .TRANSFER_DST_BIT = 1, .INDEX_BUFFER_BIT = 1 },
//         .{ .DEVICE_LOCAL_BIT = 1 },
//         &this.index_buffer_memory,
//     );
//
//     try this.copyBuffer(staging_buffer, 0, this.index_buffer, size);
//     try this.flushSetupCommands();
// }

fn makeSlice(comptime T: type, mem: []u8, offset: usize, len: usize) []T {
    const offset_ptr: *u8 = &mem[offset];
    return @as([*]T, @ptrCast(@alignCast(offset_ptr)))[0..len];
}

fn createCombinedBuffer(this: *@This()) !void {
    const idx_size = @sizeOf(IndexType) * this.indices.items.len;
    const verts_size = @sizeOf(Vertex) * this.vertices.items.len;

    const qfis = this.device_info.queue_info.familyIndices();

    const i_create_info = vk.BufferCreateInfo{
        .size = idx_size,
        .usage = .{ .TRANSFER_DST_BIT = 1, .INDEX_BUFFER_BIT = 1 },
        .sharingMode = .EXCLUSIVE,
        .queueFamilyIndexCount = @intCast(qfis.len),
        .pQueueFamilyIndices = qfis.ptr,
    };

    if (vk.createBuffer(this.device, &i_create_info, null, &this.index_buffer) != .SUCCESS) {
        return error.CreateBufferFailed;
    }
    errdefer vk.destroyBuffer(this.device, this.index_buffer, null);

    var i_requirements: vk.MemoryRequirements = undefined;
    vk.getBufferMemoryRequirements(this.device, this.index_buffer, &i_requirements);

    const v_create_info = vk.BufferCreateInfo{
        .size = verts_size,
        .usage = .{ .TRANSFER_DST_BIT = 1, .VERTEX_BUFFER_BIT = 1 },
        .sharingMode = .EXCLUSIVE,
        .queueFamilyIndexCount = @intCast(qfis.len),
        .pQueueFamilyIndices = qfis.ptr,
    };

    if (vk.createBuffer(this.device, &v_create_info, null, &this.vertex_buffer) != .SUCCESS) {
        return error.CreateBufferFailed;
    }
    errdefer vk.destroyBuffer(this.device, this.vertex_buffer, null);

    var v_requirements: vk.MemoryRequirements = undefined;
    vk.getBufferMemoryRequirements(this.device, this.vertex_buffer, &v_requirements);

    assert(i_requirements.memoryTypeBits == v_requirements.memoryTypeBits);

    const staging_size = i_requirements.size + v_requirements.size + @max(i_requirements.alignment, v_requirements.alignment);

    var staging_buffer_memory: vk.DeviceMemory = null;
    const staging_buffer = try this.createBuffer(
        staging_size,
        .{ .TRANSFER_SRC_BIT = 1 },
        .{ .HOST_VISIBLE_BIT = 1, .HOST_COHERENT_BIT = 1 },
        &staging_buffer_memory,
    );
    defer {
        vk.freeMemory(this.device, staging_buffer_memory, null);
        vk.destroyBuffer(this.device, staging_buffer, null);
    }

    var _data: [*]u8 = undefined;
    if (vk.mapMemory(this.device, staging_buffer_memory, 0, staging_size, .{}, @ptrCast(&_data)) != .SUCCESS) {
        return error.MapMemoryFailed;
    }

    const verts_offset = std.mem.alignForward(usize, idx_size, v_requirements.alignment);

    const data = _data[0..staging_size];
    const idata = makeSlice(IndexType, data, 0, this.indices.items.len);
    const vdata = makeSlice(Vertex, data, verts_offset, this.vertices.items.len);

    std.mem.copyForwards(@TypeOf(this.indices.items[0]), idata, this.indices.items);
    std.mem.copyForwards(@TypeOf(this.vertices.items[0]), vdata, this.vertices.items);

    vk.unmapMemory(this.device, staging_buffer_memory);

    dlog("ireq: {}", .{i_requirements});
    dlog("vreq: {}", .{v_requirements});

    const alloc_info: vk.MemoryAllocateInfo = .{
        .allocationSize = i_requirements.size + v_requirements.size + @max(i_requirements.alignment, v_requirements.alignment),
        .memoryTypeIndex = this.findMemoryType(i_requirements.memoryTypeBits, .{ .DEVICE_LOCAL_BIT = 1 }) orelse
            return error.FindMemoryTypeFailed,
    };

    dlog("Allocating combined buffer: size: {}", .{alloc_info.allocationSize});

    if (vk.allocateMemory(this.device, &alloc_info, null, &this.combined_buffer_memory) != .SUCCESS) {
        return error.AllocateMemoryFailed;
    }
    errdefer vk.freeMemory(this.device, this.combined_buffer_memory, null);

    if (vk.bindBufferMemory(this.device, this.index_buffer, this.combined_buffer_memory, 0) != .SUCCESS) {
        return error.BindBufferMemoryFailed;
    }

    if (vk.bindBufferMemory(this.device, this.vertex_buffer, this.combined_buffer_memory, verts_offset) != .SUCCESS) {
        return error.BindBufferMemoryFailed;
    }

    try this.copyBuffer(staging_buffer, 0, this.index_buffer, idx_size);
    try this.copyBuffer(staging_buffer, verts_offset, this.vertex_buffer, verts_size);
    try this.flushSetupCommands();
}

fn findMemoryType(this: *const @This(), type_filter: u32, properties: vk.MemoryPropertyFlags) ?u32 {
    var props: vk.PhysicalDeviceMemoryProperties = undefined;
    vk.getPhysicalDeviceMemoryProperties(this.device_info.physical_device, &props);

    for (0..props.memoryTypeCount) |i| {
        if ((type_filter & (@as(u32, @intCast(1)) << @intCast(i)) != 0) and props.memoryTypes[i].propertyFlags == properties)
            return @intCast(i);
    }
    return null;
}

fn createUniformBuffers(this: *@This()) !void {
    const buf_size: vk.DeviceSize = @sizeOf(UniformBufferObject) * UBO_COUNT;

    for (0..MAX_FRAMES_IN_FLIGHT) |i| {
        this.uniform_buffers[i] = try this.createBuffer(
            buf_size,
            .{ .UNIFORM_BUFFER_BIT = 1 },
            .{ .HOST_VISIBLE_BIT = 1, .HOST_COHERENT_BIT = 1 },
            &this.uniform_buffers_memory[i],
        );

        if (vk.mapMemory(
            this.device,
            this.uniform_buffers_memory[i],
            0,
            buf_size,
            .{},
            @ptrCast(@alignCast(&this.uniform_buffers_mapped[i])),
        ) != .SUCCESS) {
            return error.MapMemoryFailed;
        }
    }
}

fn createDescriptorPool(this: *@This()) !void {
    const pool_sizes = [_]vk.DescriptorPoolSize{
        .{
            .type = .UNIFORM_BUFFER,
            .descriptorCount = MAX_FRAMES_IN_FLIGHT,
        },
        .{
            .type = .COMBINED_IMAGE_SAMPLER,
            .descriptorCount = MAX_FRAMES_IN_FLIGHT,
        },
    };

    const pool_info = vk.DescriptorPoolCreateInfo{
        .poolSizeCount = pool_sizes.len,
        .pPoolSizes = &pool_sizes,
        .maxSets = MAX_FRAMES_IN_FLIGHT,
    };

    if (vk.createDescriptorPool(this.device, &pool_info, null, &this.descriptor_pool) != .SUCCESS) {
        return error.CreateDescriptorPoolFailed;
    }
}

fn createDescriptorSets(this: *@This()) !void {
    const layouts = [_]vk.DescriptorSetLayout{this.descriptor_set_layout} ** MAX_FRAMES_IN_FLIGHT;

    const alloc_info = vk.DescriptorSetAllocateInfo{
        .descriptorPool = this.descriptor_pool,
        .descriptorSetCount = layouts.len,
        .pSetLayouts = &layouts,
    };

    if (vk.allocateDescriptorSets(this.device, &alloc_info, &this.descriptor_sets) != .SUCCESS) {
        return error.AllocateDescriptorSetsFailed;
    }

    for (0..MAX_FRAMES_IN_FLIGHT) |i| {
        const buffer_infos = [_]vk.DescriptorBufferInfo{.{
            .buffer = this.uniform_buffers[i],
            .offset = 0,
            .range = @sizeOf(UniformBufferObject),
        }};

        const image_infos = [_]vk.DescriptorImageInfo{.{
            .imageLayout = .SHADER_READ_ONLY_OPTIMAL,
            .imageView = this.texture_image_view,
            .sampler = this.texture_sampler,
        }};

        const descriptor_writes = [_]vk.WriteDescriptorSet{
            .{
                .dstSet = this.descriptor_sets[i],
                .dstBinding = 0,
                .dstArrayElement = 0,
                .descriptorType = .UNIFORM_BUFFER,
                .descriptorCount = buffer_infos.len,
                .pBufferInfo = &buffer_infos,
            },
            .{
                .dstSet = this.descriptor_sets[i],
                .dstBinding = 1,
                .dstArrayElement = 0,
                .descriptorType = .COMBINED_IMAGE_SAMPLER,
                .descriptorCount = image_infos.len,
                .pImageInfo = &image_infos,
            },
        };

        vk.updateDescriptorSets(this.device, descriptor_writes.len, &descriptor_writes, 0, null);
    }
}

fn createCommandBuffers(this: *@This()) !void {
    const setup_alloc_info = vk.CommandBufferAllocateInfo{
        .commandPool = this.command_pool,
        .level = .PRIMARY,
        .commandBufferCount = 1,
    };

    if (vk.allocateCommandBuffers(this.device, &setup_alloc_info, @ptrCast(&this.setup_command_buffer)) != .SUCCESS) {
        return error.AllocateCommandBuffersFailed;
    }

    const begin_info = vk.CommandBufferBeginInfo{ .flags = .{ .ONE_TIME_SUBMIT_BIT = 1 } };
    if (vk.beginCommandBuffer(this.setup_command_buffer, &begin_info) != .SUCCESS) {
        return error.BeginCommandBufferFailed;
    }

    const presentation_alloc_info = vk.CommandBufferAllocateInfo{
        .commandPool = this.command_pool,
        .level = .PRIMARY,
        .commandBufferCount = this.command_buffers.len,
    };

    if (vk.allocateCommandBuffers(this.device, &presentation_alloc_info, &this.command_buffers) != .SUCCESS) {
        return error.AllocateCommandBuffersFailed;
    }
}

fn flushSetupCommands(this: *@This()) !void {
    if (vk.endCommandBuffer(this.setup_command_buffer) != .SUCCESS) {
        return error.EndCommandbufferFailed;
    }

    const cmd_bufs = [_]vk.CommandBuffer{this.setup_command_buffer};
    const submit_infos = [_]vk.SubmitInfo{.{
        .commandBufferCount = cmd_bufs.len,
        .pCommandBuffers = &cmd_bufs,
    }};

    if (vk.queueSubmit(this.graphics_que, submit_infos.len, &submit_infos, null) != .SUCCESS) {
        return error.QueueSubmitFailed;
    }

    if (vk.queueWaitIdle(this.graphics_que) != .SUCCESS) {
        return error.QueueWaitIdleFailed;
    }

    const begin_info = vk.CommandBufferBeginInfo{ .flags = .{ .ONE_TIME_SUBMIT_BIT = 1 } };
    if (vk.beginCommandBuffer(this.setup_command_buffer, &begin_info) != .SUCCESS) {
        return error.BeginCommandBufferFailed;
    }
}

fn createSyncObjects(this: *@This()) !void {
    const sem_create_info = vk.SemaphoreCreateInfo{};

    const fence_create_info = vk.FenceCreateInfo{
        .flags = .{ .SIGNALED = 1 },
    };

    for (0..MAX_FRAMES_IN_FLIGHT) |i| {
        if (vk.createSemaphore(this.device, &sem_create_info, null, &this.image_available_semaphores[i]) != .SUCCESS or
            vk.createSemaphore(this.device, &sem_create_info, null, &this.render_finished_semaphores[i]) != .SUCCESS)
        {
            return error.CreateSemaphoreFailed;
        }

        if (vk.createFence(this.device, &fence_create_info, null, &this.in_flight_fences[i]) != .SUCCESS) {
            return error.CreateFenceFailed;
        }
    }
}

fn recordCommandBuffer(this: *const @This(), cmd_buf: vk.CommandBuffer, image_index: u32) void {
    if (vk.beginCommandBuffer(cmd_buf, &.{}) != .SUCCESS) {
        @panic("beginCommandBuffer failed!");
    }

    const clear_values = [_]vk.ClearValue{
        .{ .color = .{ .float32 = .{ 0, 0, 0, 0 } } },
        .{ .depthStencil = .{ .depth = 1.0, .stencil = 0 } },
    };

    // cornflower blue
    // const clear_values = [_]vk.ClearValue{.{ .color = .{ .float32 = .{ 0.392, 0.584, 0.929, 1 } } }};

    const render_pass_info = vk.RenderPassBeginInfo{
        .renderPass = this.render_pass,
        .framebuffer = this.framebuffers[image_index],
        .renderArea = .{
            .offset = .{ .x = 0, .y = 0 },
            .extent = this.swapchain_extent,
        },
        .clearValueCount = clear_values.len,
        .pClearValues = &clear_values,
    };

    vk.cmdBeginRenderPass(cmd_buf, &render_pass_info, .INLINE);
    vk.cmdBindPipeline(cmd_buf, .GRAPHICS, this.graphics_pipeline);

    const viewport = vk.Viewport{
        .x = 0,
        .y = 0,
        .width = @floatFromInt(this.swapchain_extent.width),
        .height = @floatFromInt(this.swapchain_extent.height),
        .minDepth = 0,
        .maxDepth = 1,
    };
    vk.cmdSetViewport(cmd_buf, 0, 1, &viewport);

    const scissor = vk.Rect2D{
        .offset = .{ .x = 0, .y = 0 },
        .extent = this.swapchain_extent,
    };
    vk.cmdSetScissor(cmd_buf, 0, 1, &scissor);

    const vertex_buffers = [_]vk.Buffer{this.vertex_buffer};
    const offsets = [_]vk.DeviceSize{0};
    vk.cmdBindVertexBuffers(cmd_buf, 0, 1, &vertex_buffers, &offsets);

    assert(@sizeOf(@TypeOf(this.indices.items[0])) == 4);
    vk.cmdBindIndexBuffer(cmd_buf, this.index_buffer, 0, .UINT32);

    // vk.cmdDraw(cmd_buf, triangle_vertices.len, 1, 0, 0);
    vk.cmdBindDescriptorSets(cmd_buf, .GRAPHICS, this.pipeline_layout, 0, 1, &this.descriptor_sets[this.current_frame], 0, null);
    vk.cmdDrawIndexed(cmd_buf, @intCast(this.indices.items.len), 1, 0, 0, 0);

    vk.cmdEndRenderPass(cmd_buf);

    if (vk.endCommandBuffer(cmd_buf) != .SUCCESS) {
        @panic("endCommandBuffer failed!");
    }
}

fn updateUniformBuffer(this: *@This(), image_index: usize) void {
    // const elapsed = @as(f32, @floatFromInt(this.timer.read())) / 1000_000_000.0;

    const extent = Vec2.new(@floatFromInt(this.swapchain_extent.width), @floatFromInt(this.swapchain_extent.height));

    // const model = Mat4.rotation_z(@floatCast(elapsed * math.radians(90)));
    const model = Mat4.identity;
    const proj = Mat4.perspective(math.radians(45), extent.x / extent.y, 0.1, 10);
    const view = Mat4.lookAt(Vec3.new(2, 2, 2), Vec3.new(0, 0, 0), Vec3.new(0, 0, 1));

    const ubo = this.uniform_buffers_mapped[image_index][0];
    ubo.* = .{
        .model = model,
        .view = view,
        .proj = proj,
    };
    ubo.proj.data[5] *= -1;
}

pub fn drawFrame(this: *@This()) void {
    const cfi = this.current_frame;
    const cmd_buf = this.command_buffers[cfi];

    _ = vk.waitForFences(this.device, 1, @ptrCast(&this.in_flight_fences[cfi]), vk.TRUE, std.math.maxInt(u64));

    var image_index: u32 = undefined;
    switch (vk.acquireNextImageKHR(this.device, this.swapchain, std.math.maxInt(u64), this.image_available_semaphores[cfi], null, &image_index)) {
        .SUCCESS => {}, // ok
        .ERROR_OUT_OF_DATE_KHR => {
            dlog("swapchain out of date!", .{});
            this.recreateSwapchain() catch @panic("recreateSwapchain Failed!");
            return;
        },
        .SUBOPTIMAL_KHR => dlog("Using suboptimal swapchain...", .{}),
        else => @panic("AcquireNextImageKHR Failed!"),
    }

    this.updateUniformBuffer(cfi);

    _ = vk.resetFences(this.device, 1, @ptrCast(&this.in_flight_fences[cfi]));

    _ = vk.resetCommandBuffer(cmd_buf, .{});
    this.recordCommandBuffer(cmd_buf, image_index);

    const wait_semaphores = [_]vk.Semaphore{this.image_available_semaphores[cfi]};
    const wait_stages = [wait_semaphores.len]vk.PipelineStageFlags{.{ .COLOR_ATTACHMENT_OUTPUT_BIT = 1 }};
    const command_buffers = [_]vk.CommandBuffer{cmd_buf};
    const signal_semaphores = [_]vk.Semaphore{this.render_finished_semaphores[cfi]};

    const submit_infos = [_]vk.SubmitInfo{.{
        .waitSemaphoreCount = wait_semaphores.len,
        .pWaitSemaphores = &wait_semaphores,
        .pWaitDstStageMask = &wait_stages,
        .commandBufferCount = command_buffers.len,
        .pCommandBuffers = &command_buffers,
        .signalSemaphoreCount = signal_semaphores.len,
        .pSignalSemaphores = &signal_semaphores,
    }};

    if (vk.queueSubmit(this.graphics_que, submit_infos.len, &submit_infos, this.in_flight_fences[cfi]) != .SUCCESS) {
        @panic("queueSubmit failed!");
    }

    const swapchains = [_]vk.SwapchainKHR{this.swapchain};
    const image_indices = [swapchains.len]u32{image_index};

    const present_info = vk.PresentInfoKHR{
        .waitSemaphoreCount = signal_semaphores.len,
        .pWaitSemaphores = &signal_semaphores,
        .swapchainCount = swapchains.len,
        .pSwapchains = &swapchains,
        .pImageIndices = &image_indices,
        .pResults = null,
    };

    var recreate = false;
    switch (vk.queuePresentKHR(this.present_que, &present_info)) {
        .SUCCESS => {}, //ok
        .ERROR_OUT_OF_DATE_KHR, .SUBOPTIMAL_KHR => {
            dlog("swapchain out of date!", .{});
            recreate = true;
        },
        else => @panic("queuePresentKHR Failed!"),
    }

    if (recreate or this.framebuffer_resized) {
        this.framebuffer_resized = false;
        this.recreateSwapchain() catch @panic("recreateSwapchain Failed!");
    }

    this.current_frame = (this.current_frame + 1) % MAX_FRAMES_IN_FLIGHT;
}

fn createShaderModule(this: *const @This(), code: []const u8) !vk.ShaderModule {
    const create_info = vk.ShaderModuleCreateInfo{
        .codeSize = code.len,
        .pCode = @alignCast(@ptrCast(code.ptr)),
    };

    var shader_module: vk.ShaderModule = undefined;
    if (vk.createShaderModule(this.device, &create_info, null, &shader_module) != .SUCCESS) {
        return error.createShaderModuleFailed;
    }

    return shader_module;
}

fn vk_debug_callback(message_severity: vk.DebugUtilsMessageSeverityFlagsEXT, message_type: vk.DebugUtilsMessageTypeFlagsEXT, _callback_data: [*c]const vk.DebugUtilsMessengerCallbackData, user_data: ?*anyopaque) callconv(.C) vk.Bool32 {
    _ = message_type;
    _ = user_data;

    const log = std.log.scoped(.@"vulkan message");
    const callback_data: *const vk.DebugUtilsMessengerCallbackData = _callback_data;

    const fmt = "{s}";
    const args = .{callback_data.pMessage};

    if (message_severity.VERBOSE_BIT_EXT == 1) {
        if (@intFromEnum(options.vulkan_log_level) >= @intFromEnum(options.@"log.Level".debug)) log.debug(fmt, args);
    } else if (message_severity.WARNING_BIT_EXT == 1) {
        log.warn(fmt, args);
    } else if (message_severity.ERROR_BIT_EXT == 1) {
        log.err(fmt, args);
        // if (builtin.mode == .Debug) @panic("Vulkan error");
    } else {
        elog("Invalid message severity '{}'", .{message_severity});
        log.err(fmt, args);
    }

    return vk.TRUE;
}
