const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const alloc = @import("alloc");
const builtin_shaders = @import("shaders");
const options = @import("options");
const platform = @import("platform");
const Window = platform.Window;
const vk = @import("vulkan");
const vke = vk.extensions;
const vkl = vk.loader;

const vlog = std.log.scoped(.vulkan);
const dlog = vlog.debug;
const elog = vlog.err;
const ilog = vlog.info;

const debug = builtin.mode == .Debug;
const debug_verbose = debug and options.vulkan_verbose;
const is_mac = true;
// const is_mac = builtin.target.os.tag == .macos;

const Renderer = @This();

instance: vk.Instance = null,
surface: vk.SurfaceKHR = null,
device: vk.Device = null,
device_info: PDevInfo = undefined,
graphics_que: vk.Queue = null,
present_que: vk.Queue = null,
swapchain: SwapchainData = undefined,
render_pass: vk.RenderPass = null,
pipeline_layout: vk.PipelineLayout = null,
graphics_pipeline: vk.Pipeline = null,
command_pool: vk.CommandPool = null,
command_buffer: vk.CommandBuffer = null,
image_available_semaphore: vk.Semaphore = null,
render_finished_semaphore: vk.Semaphore = null,
in_flight_fence: vk.Fence = null,
debug_messenger: vk.DebugUtilsMessengerEXT = null,

const PDevInfo = struct {
    score: u32,
    name: [256]u8 = std.mem.zeroes([256]u8),
    queue_info: QueueFamilyInfo,
    swapchain_info: SwapchainInfo,
    physical_device: vk.PhysicalDevice = null,
};

const QueueFamilyInfo = struct {
    graphics_index: u32 = undefined,
    present_index: u32 = undefined,
};

const SwapchainInfo = struct {
    min_image_count: u32,
    surface_capabilities: vk.SurfaceCapabilitiesKHR,
    surface_format: vk.SurfaceFormatKHR,
    present_mode: vk.PresentModeKHR,
};

const SwapchainData = struct {
    handle: vk.SwapchainKHR = null,
    image_format: vk.Format,
    extent: vk.Extent2D,

    images: []vk.Image = std.mem.zeroes([]vk.Image),
    image_views: []vk.ImageView = std.mem.zeroes([]vk.ImageView),

    framebuffers: []vk.Framebuffer = std.mem.zeroes([]vk.Framebuffer),

    pub fn deinit(this: *const @This(), renderer: *const Renderer, allocator: std.mem.Allocator) void {
        for (this.framebuffers) |fb| {
            vk.destroyFramebuffer(renderer.device, fb, null);
        }
        alloc.gpa.free(this.framebuffers);

        for (this.image_views) |v| vk.destroyImageView(renderer.device, v, null);
        allocator.free(this.image_views);
        allocator.free(this.images);
        vk.destroySwapchainKHR(renderer.device, this.handle, null);
    }
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

pub fn init(window: *const Window) !Renderer {
    const instance = try createInstance(window);
    const debug_messenger = createDebugMessenger(instance);
    const surface = try window.createVulkanSurface(instance);
    const device_info = try choosePhysicalDevice(instance, surface);

    var result: Renderer = .{
        .instance = instance,
        .surface = surface,
        .device_info = device_info,
        .debug_messenger = debug_messenger,
    };

    try result.createLogicalDevice();

    var width: c_int = undefined;
    var height: c_int = undefined;
    window.frameBufferSize(&width, &height);
    try result.createSwapchain(width, height);

    try result.createRenderPass();
    try result.createGraphicsPipeline();
    try result.createFrameBuffers();
    try result.createCommandPool();
    try result.createCommandBuffer();
    try result.createSyncObjects();

    return result;
}

pub fn deinit(this: *const @This()) void {
    const dev = this.device;

    _ = vk.deviceWaitIdle(dev);
    vk.destroyFence(dev, this.in_flight_fence, null);
    vk.destroySemaphore(dev, this.render_finished_semaphore, null);
    vk.destroySemaphore(dev, this.image_available_semaphore, null);
    vk.destroyCommandPool(dev, this.command_pool, null);
    vk.destroyPipeline(dev, this.graphics_pipeline, null);
    vk.destroyPipelineLayout(dev, this.pipeline_layout, null);
    vk.destroyRenderPass(dev, this.render_pass, null);
    this.swapchain.deinit(this, alloc.gpa);
    vk.destroyDevice(dev, null);
    vk.destroySurfaceKHR(this.instance, this.surface, null);
    if (debug) vke.destroyDebugUtilsMessenger(this.instance, this.debug_messenger, null);
    vk.destroyInstance(this.instance, null);
}

fn createInstance(window: *const Window) !vk.Instance {
    var extension_count: u32 = undefined;
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, null);
    dlog("{} Vulkan extensions supported", .{extension_count});

    const extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, extension_count);
    defer alloc.gpa.free(extension_props);
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, extension_props.ptr);
    // for (extension_props) |p| dlog("supported extension: '{s}'", .{@as([*:0]const u8, @ptrCast(&p.extensionName))});

    const app_info = vk.ApplicationInfo{
        .sType = .APPLICATION_INFO,
        .pApplicationName = "Vulkan app",
        .applicationVersion = vk.MAKE_VERSION(1, 0, 0),
        .pEngineName = "Vulkan engine",
        .engineVersion = vk.MAKE_VERSION(1, 0, 0),
        .apiVersion = vk.API_VERSION_1_0,
    };

    const window_required_extensions = try window.requiredVulkanInstanceExtensions();

    const instance_ext_count = window_required_extensions.len + instance_extensions.len;

    var required_instance_extensions = try std.ArrayList([*:0]const u8).initCapacity(alloc.gpa, instance_ext_count);
    defer required_instance_extensions.deinit();
    required_instance_extensions.appendSliceAssumeCapacity(window_required_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(instance_extensions);

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

    var available_layers: []const vk.LayerProperties = undefined;

    if (debug) {
        var count: u32 = undefined;
        var res = vk.enumerateInstanceLayerProperties(&count, null);
        assert(res == vk.SUCCESS);

        available_layers = try alloc.gpa.alloc(vk.LayerProperties, count);
        res = vk.enumerateInstanceLayerProperties(&count, @constCast(available_layers.ptr));
        assert(res == vk.SUCCESS);

        // for (available_layers) |l| dlog("available layer '{s}'", .{@as([*:0]const u8, @ptrCast(&l.layerName))});
    }
    defer if (debug) alloc.gpa.free(available_layers);

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

    const debug_messenger_create_info = vk.DebugUtilsMessengerCreateInfoEXT{
        .sType = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
        .messageSeverity = .{ .VERBOSE = 1, .WARNING = 1, .ERROR = 1 },
        .messageType = .{ .GENERAL = 1, .VALIDATION = 1, .PERFORMANCE = 1 },
        .pfnUserCallback = vk_debug_callback,
        .pUserData = null,
    };

    const instance_create_info = vk.InstanceCreateInfo{
        .sType = .INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
        .flags = if (is_mac) vk.INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR else 0,
        .enabledExtensionCount = @intCast(required_instance_extensions.items.len),
        .ppEnabledExtensionNames = required_instance_extensions.items.ptr,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
        .pNext = if (debug) &debug_messenger_create_info else null,
    };

    var instance: vk.Instance = undefined;
    switch (vk.createInstance(&instance_create_info, null, &instance)) {
        vk.SUCCESS => {
            dlog("vkCreateInstance: OK", .{});
        },
        else => |v| {
            elog("vkCreateInstance returned '{}'", .{v});
            return error.vkCreateInstance_Failed;
        },
    }

    vk.loader.load(instance, required_instance_extensions.items);

    return instance;
}

fn createDebugMessenger(instance: vk.Instance) vk.DebugUtilsMessengerEXT {
    if (debug) {
        const debug_messenger_create_info = vk.DebugUtilsMessengerCreateInfoEXT{
            .sType = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
            .messageSeverity = .{ .VERBOSE = 1, .WARNING = 1, .ERROR = 1 },
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

        const type_score: u32 =
            switch (props.deviceType) {
            .OTHER => 1,
            .VIRTUAL_GPU => 2,
            .CPU => 3,
            .INTEGRATED_GPU => 4,
            .DISCRETE_GPU => 5,
            .MAX_ENUM => @panic("Invalid vulkan device type"),
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

        const score = type_score * image_dim_score;
        dlog("pd[{}]: score: {}", .{ i, score });

        dlog("===========================", .{});

        const info = PDevInfo{
            .score = score,
            .name = props.deviceName,
            .queue_info = queue_info,
            .swapchain_info = swapchain_info,
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
    ilog("using device: {} ({s})", .{ best_device_index, best_device_info.name });

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
    }

    return if (graphics_que_found and present_que_found) result else null;
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
    if (vk.getPhysicalDeviceSurfaceCapabilitiesKHR(pdev, surface, &surface_capabilities) != vk.SUCCESS) {
        return error.Get_Physical_Device_Surface_Capabilities_Failed;
    }

    var format_count: u32 = undefined;
    if (vk.getPhysicalDeviceSurfaceFormatsKHR(pdev, surface, &format_count, null) != vk.SUCCESS) {
        return error.Get_Physical_Device_Surface_Formats_Failed;
    }
    if (format_count == 0) return null;

    var formats: []vk.SurfaceFormatKHR = undefined;
    formats = try alloc.gpa.alloc(vk.SurfaceFormatKHR, format_count);
    if (vk.getPhysicalDeviceSurfaceFormatsKHR(pdev, surface, &format_count, @ptrCast(formats.ptr)) != vk.SUCCESS) {
        return error.Get_Physical_Device_Surface_Formats_Failed;
    }
    defer alloc.gpa.free(formats);

    var present_mode_count: u32 = undefined;
    if (vk.getPhysicalDeviceSurfacePresentModesKHR(pdev, surface, &present_mode_count, null) != vk.SUCCESS) {
        return error.Get_Physical_Device_Surface_Presentmodes_Failed;
    }
    if (present_mode_count == 0) return null;

    var present_modes: []vk.PresentModeKHR = undefined;
    present_modes = try alloc.gpa.alloc(vk.PresentModeKHR, present_mode_count);
    if (vk.getPhysicalDeviceSurfacePresentModesKHR(pdev, surface, &present_mode_count, @ptrCast(present_modes.ptr)) != vk.SUCCESS) {
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

    var fin_array = [_]u32{ dev_info.queue_info.graphics_index, dev_info.queue_info.present_index };
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
        // dlog("fin: {any}", .{fin});
    }

    var qci_array: [fin_array.len]vk.DeviceQueueCreateInfo = undefined;
    const qcis: []vk.DeviceQueueCreateInfo = qci_array[0..fin.len];
    const que_prio: f32 = 1.0;

    for (qcis, fin) |*qci, fi| qci.* = .{
        .sType = .DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = fi,
        .queueCount = 1,
        .pQueuePriorities = &que_prio,
    };

    const device_features = vk.PhysicalDeviceFeatures{};

    const device_create_info = vk.DeviceCreateInfo{
        .sType = .DEVICE_CREATE_INFO,
        .pQueueCreateInfos = qcis.ptr,
        .queueCreateInfoCount = @intCast(qcis.len),
        .pEnabledFeatures = &device_features,
        .enabledExtensionCount = required_device_extensions.len,
        .ppEnabledExtensionNames = required_device_extensions.ptr,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
    };

    if (vk.createDevice(this.device_info.physical_device, &device_create_info, null, &this.device) != vk.SUCCESS) {
        elog("Failed to create logical device!", .{});
        return error.Logical_Device_Creation_Failed;
    }

    vk.getDeviceQueue(this.device, dev_info.queue_info.graphics_index, 0, &this.graphics_que);
    vk.getDeviceQueue(this.device, dev_info.queue_info.present_index, 0, &this.present_que);
}

pub fn createSwapchain(this: *@This(), fb_width: c_int, fb_height: c_int) !void {
    const dev_info = &this.device_info;
    const cap = &dev_info.swapchain_info.surface_capabilities;

    dlog("cap.currentExtent: {}", .{cap.currentExtent});
    const extent = switch (cap.currentExtent.width) {
        std.math.maxInt(u32) => blk: {
            // window.frameBufferSize(&width, &height);

            var actual_extent = vk.Extent2D{ .width = @intCast(fb_width), .height = @intCast(fb_height) };
            actual_extent.width = std.math.clamp(actual_extent.width, cap.minImageExtent.width, cap.maxImageExtent.width);
            actual_extent.height = std.math.clamp(actual_extent.height, cap.minImageExtent.height, cap.maxImageExtent.height);

            break :blk actual_extent;
        },
        else => cap.currentExtent,
    };

    dlog("swapchain extent: {}", .{extent});

    const same_family = dev_info.queue_info.graphics_index == dev_info.queue_info.present_index;

    const create_info = vk.SwapchainCreateInfoKHR{
        .sType = .SWAPCHAIN_CREATE_INFO_KHR,
        .surface = this.surface,
        .minImageCount = dev_info.swapchain_info.min_image_count,
        .imageFormat = dev_info.swapchain_info.surface_format.format,
        .imageColorSpace = dev_info.swapchain_info.surface_format.colorSpace,
        .imageExtent = extent,
        .imageArrayLayers = 1,
        .imageUsage = vk.IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = if (same_family) vk.SHARING_MODE_EXCLUSIVE else vk.SHARING_MODE_CONCURRENT,
        .queueFamilyIndexCount = if (same_family) 0 else 2,
        .pQueueFamilyIndices = if (same_family) null else @ptrCast(&.{ dev_info.queue_info.graphics_index, dev_info.queue_info.present_index }),
        .preTransform = cap.currentTransform,
        .compositeAlpha = vk.COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = dev_info.swapchain_info.present_mode,
        .clipped = vk.TRUE,
        .oldSwapchain = null,
    };

    var swapchain_handle: vk.SwapchainKHR = undefined;
    if (vk.createSwapchainKHR(this.device, &create_info, null, &swapchain_handle) != vk.SUCCESS) {
        return error.Create_Swapchain_Failed;
    }

    var image_count: u32 = undefined;
    if (vk.getSwapchainImagesKHR(this.device, swapchain_handle, &image_count, null) != vk.SUCCESS) {
        return error.Get_Swapchain_Images_Failed;
    }

    const images = try alloc.gpa.alloc(vk.Image, image_count);
    if (vk.getSwapchainImagesKHR(this.device, swapchain_handle, &image_count, images.ptr) != vk.SUCCESS) {
        return error.Get_Swapchain_Images_Failed;
    }
    assert(image_count == images.len);

    const image_views = try alloc.gpa.alloc(vk.ImageView, image_count);
    for (images, image_views) |image, *view| {
        const view_create_info = vk.ImageViewCreateInfo{
            .sType = .IMAGE_VIEW_CREATE_INFO,
            .image = image,
            .viewType = vk.IMAGE_VIEW_TYPE_2D,
            .format = dev_info.swapchain_info.surface_format.format,
            .components = .{
                .r = vk.COMPONENT_SWIZZLE_IDENTITY,
                .g = vk.COMPONENT_SWIZZLE_IDENTITY,
                .b = vk.COMPONENT_SWIZZLE_IDENTITY,
                .a = vk.COMPONENT_SWIZZLE_IDENTITY,
            },
            .subresourceRange = .{
                .aspectMask = vk.IMAGE_ASPECT_COLOR_BIT,
                .baseMipLevel = 0,
                .levelCount = 1,
                .baseArrayLayer = 0,
                .layerCount = 1,
            },
        };

        if (vk.createImageView(this.device, &view_create_info, null, view) != vk.SUCCESS) {
            return error.Create_Image_View_Failed;
        }
    }

    this.swapchain = .{
        .handle = swapchain_handle,
        .images = images,
        .image_views = image_views,
        .image_format = dev_info.swapchain_info.surface_format.format,
        .extent = extent,
    };
}

fn createRenderPass(this: *@This()) !void {
    const color_attachments = [_]vk.AttachmentDescription{.{
        .format = this.swapchain.image_format,
        .samples = vk.sample_count_flag_bits.@"1_BIT",
        .loadOp = .CLEAR,
        .storeOp = .STORE,
        .stencilLoadOp = .DONT_CARE,
        .stencilStoreOp = .DONT_CARE,
        .initialLayout = .UNDEFINED,
        .finalLayout = .PRESENT_SRC_KHR,
    }};

    const color_attachment_refs = [_]vk.AttachmentReference{.{
        .attachment = 0,
        .layout = .COLOR_ATTACHMENT_OPTIMAL,
    }};

    const subpasses = [_]vk.SubpassDescription{.{
        .pipelineBindPoint = .GRAPHICS,
        .colorAttachmentCount = color_attachment_refs.len,
        .pColorAttachments = &color_attachment_refs,
    }};

    const dependencies = [_]vk.SubpassDependency{.{
        .srcSubpass = vk.SUBPASS_EXTERNAL,
        .dstSubpass = 0,
        .srcStageMask = .{ .COLOR_ATTACHMENT_OUTPUT = 1 },
        .srcAccessMask = 0,
        .dstStageMask = .{ .COLOR_ATTACHMENT_OUTPUT = 1 },
        .dstAccessMask = vk.access_flags.COLOR_ATTACHMENT_WRITE_BIT,
    }};
    const render_pass_create_info = vk.RenderPassCreateInfo{
        .sType = .RENDER_PASS_CREATE_INFO,
        .attachmentCount = color_attachments.len,
        .pAttachments = &color_attachments,
        .subpassCount = subpasses.len,
        .pSubpasses = &subpasses,
        .dependencyCount = 1,
        .pDependencies = &dependencies,
    };

    if (vk.createRenderPass(this.device, &render_pass_create_info, null, &this.render_pass) != vk.SUCCESS) {
        return error.CreateRenderPassFailed;
    }
}

fn createGraphicsPipeline(this: *@This()) !void {
    const vert_shader_module = try this.createShaderModule(&builtin_shaders.@"color_triangle.vert");
    defer vk.destroyShaderModule(this.device, vert_shader_module, null);

    const frag_shader_module = try this.createShaderModule(&builtin_shaders.@"color_triangle.frag");
    defer vk.destroyShaderModule(this.device, frag_shader_module, null);

    const shader_stages = [_]vk.PipelineShaderStageCreateInfo{
        .{
            .sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            .stage = vk.shader_stage_bit.VERTEX,
            .module = vert_shader_module,
            .pName = "main",
        },
        .{
            .sType = .PIPELINE_SHADER_STAGE_CREATE_INFO,
            .stage = vk.shader_stage_bit.FRAGMENT,
            .module = frag_shader_module,
            .pName = "main",
        },
    };

    const dynamic_states = [_]vk.DynamicState{
        vk.DynamicState.VIEWPORT,
        vk.DynamicState.SCISSOR,
    };

    const dynamic_state_create_info = vk.PipelineDynamicStateCreateInfo{
        .sType = .PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        .dynamicStateCount = dynamic_states.len,
        .pDynamicStates = &dynamic_states,
    };

    const vertex_input_state_create_info = vk.PipelineVertexInputStateCreateInfo{
        .sType = .PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        .vertexBindingDescriptionCount = 0,
        .pVertexBindingDescriptions = null,
        .vertexAttributeDescriptionCount = 0,
        .pVertexAttributeDescriptions = null,
    };

    const input_assembly_create_info = vk.PipelineInputAssemblyStateCreateInfo{
        .sType = .PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        .topology = .TRIANGLE_LIST,
        .primitiveRestartEnable = vk.FALSE,
    };

    const viewport_create_info = vk.PipelineViewportStateCreateInfo{
        .sType = .PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        .viewportCount = 1,
        .scissorCount = 1,
    };

    const rasterizer_create_info = vk.PipelineRasterizationStateCreateInfo{
        .sType = .PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
        .depthClampEnable = vk.FALSE,
        .rasterizerDiscardEnable = vk.FALSE,
        .polygonMode = .FILL,
        .lineWidth = 1,
        .cullMode = .BACK_BIT,
        .frontFace = .CLOCKWISE,
        .depthBiasEnable = vk.FALSE,
        .depthBiasConstantFactor = 0,
        .depthBiasClamp = 0,
        .depthBiasSlopeFactor = 0,
    };

    const multisampling_create_info = vk.PipelineMultisampleStateCreateInfo{
        .sType = .PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
        .sampleShadingEnable = vk.FALSE,
        .rasterizationSamples = vk.sample_count_flag_bits.@"1_BIT",
        .minSampleShading = 1,
        .pSampleMask = null,
        .alphaToCoverageEnable = vk.FALSE,
        .alphaToOneEnable = vk.FALSE,
    };

    const color_blend_attachments = [_]vk.PipelineColorBlendAttachmentState{.{
        .colorWriteMask = vk.ColorComponentFlags{ .R = 1, .G = 1, .B = 1, .A = 1 },
        .blendEnable = vk.TRUE,
        .srcColorBlendFactor = .SRC_ALPHA,
        .dstColorBlendFactor = .ONE_MINUS_SRC_ALPHA,
        .colorBlendOp = .ADD,
        .srcAlphaBlendFactor = .ONE,
        .dstAlphaBlendFactor = .ZERO,
        .alphaBlendOp = .ADD,
    }};

    const blend_create_info = vk.PipelineColorBlendStateCreateInfo{
        .sType = .PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        .logicOpEnable = vk.FALSE,
        .logicOp = .COPY,
        .attachmentCount = color_blend_attachments.len,
        .pAttachments = &color_blend_attachments,
        .blendConstants = .{ 0, 0, 0, 0 },
    };

    const pipeline_layout_create_info = vk.PipelineLayoutCreateInfo{
        .sType = .PIPELINE_LAYOUT_CREATE_INFO,
        .setLayoutCount = 0,
        .pSetLayouts = null,
        .pushConstantRangeCount = 0,
        .pPushConstantRanges = null,
    };

    if (vk.createPipelineLayout(this.device, &pipeline_layout_create_info, null, &this.pipeline_layout) != vk.SUCCESS) {
        return error.CreatePipelineLayoutFailed;
    }

    const pipeline_create_infos = [_]vk.GraphicsPipelineCreateInfo{.{
        .sType = .GRAPHICS_PIPELINE_CREATE_INFO,
        .stageCount = shader_stages.len,
        .pStages = &shader_stages,
        .pVertexInputState = &vertex_input_state_create_info,
        .pInputAssemblyState = &input_assembly_create_info,
        .pViewportState = &viewport_create_info,
        .pRasterizationState = &rasterizer_create_info,
        .pMultisampleState = &multisampling_create_info,
        .pDepthStencilState = null,
        .pColorBlendState = &blend_create_info,
        .pDynamicState = &dynamic_state_create_info,
        .layout = this.pipeline_layout,
        .renderPass = this.render_pass,
        .subpass = 0,
        .basePipelineHandle = null,
        .basePipelineIndex = -1,
    }};

    if (vk.createGraphicsPipelines(this.device, null, pipeline_create_infos.len, &pipeline_create_infos, null, &this.graphics_pipeline) != vk.SUCCESS) {
        return error.CreateGraphicsPipelinesFailed;
    }
}

fn createFrameBuffers(this: *@This()) !void {
    this.swapchain.framebuffers = try alloc.gpa.alloc(vk.Framebuffer, this.swapchain.image_views.len);

    for (this.swapchain.image_views, this.swapchain.framebuffers) |*iv, *fb| {
        const framebuffer_create_info = vk.FramebufferCreateInfo{
            .sType = .FRAMEBUFFER_CREATE_INFO,
            .renderPass = this.render_pass,
            .attachmentCount = 1,
            .pAttachments = iv,
            .width = this.swapchain.extent.width,
            .height = this.swapchain.extent.height,
            .layers = 1,
        };

        if (vk.createFramebuffer(this.device, &framebuffer_create_info, null, fb) != vk.SUCCESS) {
            return error.CreateFramebufferFailed;
        }
    }
}

fn createCommandPool(this: *@This()) !void {
    const create_info = vk.CommandPoolCreateInfo{
        .sType = .COMMAND_POOL_CREATE_INFO,
        .flags = .{ .RESET_COMMAND_BUFFER = 1 },
        .queueFamilyIndex = this.device_info.queue_info.graphics_index,
    };

    if (vk.createCommandPool(this.device, &create_info, null, &this.command_pool) != vk.SUCCESS) {
        return error.CreateCommandPoolFailed;
    }
}

fn createCommandBuffer(this: *@This()) !void {
    const alloc_info = vk.CommandBufferAllocateInfo{
        .sType = .COMMAND_BUFFER_ALLOCATE_INFO,
        .commandPool = this.command_pool,
        .level = .PRIMARY,
        .commandBufferCount = 1,
    };

    if (vk.allocateCommandBuffers(this.device, &alloc_info, &this.command_buffer) != vk.SUCCESS) {
        return error.AllocateCommandBuffersFailed;
    }
}

fn createSyncObjects(this: *@This()) !void {
    const sem_create_info = vk.SemaphoreCreateInfo{
        .sType = .SEMAPHORE_CREATE_INFO,
    };

    const fence_create_info = vk.FenceCreateInfo{
        .sType = .FENCE_CREATE_INFO,
        .flags = .{ .SIGNALED = 1 },
    };

    if (vk.createSemaphore(this.device, &sem_create_info, null, &this.image_available_semaphore) != vk.SUCCESS or
        vk.createSemaphore(this.device, &sem_create_info, null, &this.render_finished_semaphore) != vk.SUCCESS)
    {
        return error.CreateSemaphoreFailed;
    }

    if (vk.createFence(this.device, &fence_create_info, null, &this.in_flight_fence) != vk.SUCCESS) {
        return error.CreateFenceFailed;
    }
}

fn recordCommandBuffer(this: *const @This(), image_index: u32) void {
    const begin_info = vk.CommandBufferBeginInfo{
        .sType = .COMMAND_BUFFER_BEGIN_INFO,
        .flags = 0,
        .pInheritanceInfo = null,
    };

    if (vk.beginCommandBuffer(this.command_buffer, &begin_info) != vk.SUCCESS) {
        @panic("beginCommandBuffer failed!");
    }

    const clear_values = [_]vk.ClearValue{.{ .color = .{ .float32 = .{ 0, 0, 0, 1 } } }};

    const render_pass_info = vk.RenderPassBeginInfo{
        .sType = .RENDER_PASS_BEGIN_INFO,
        .renderPass = this.render_pass,
        .framebuffer = this.swapchain.framebuffers[image_index],
        .renderArea = .{
            .offset = .{ .x = 0, .y = 0 },
            .extent = this.swapchain.extent,
        },
        .clearValueCount = 1,
        .pClearValues = &clear_values,
    };

    vk.cmdBeginRenderPass(this.command_buffer, &render_pass_info, .INLINE);
    vk.cmdBindPipeline(this.command_buffer, .GRAPHICS, this.graphics_pipeline);

    const viewport = vk.Viewport{
        .x = 0,
        .y = 0,
        .width = @floatFromInt(this.swapchain.extent.width),
        .height = @floatFromInt(this.swapchain.extent.height),
        .minDepth = 0,
        .maxDepth = 1,
    };
    vk.cmdSetViewport(this.command_buffer, 0, 1, &viewport);

    const scissor = vk.Rect2D{
        .offset = .{ .x = 0, .y = 0 },
        .extent = this.swapchain.extent,
    };
    vk.cmdSetScissor(this.command_buffer, 0, 1, &scissor);

    vk.cmdDraw(this.command_buffer, 3, 1, 0, 0);

    vk.cmdEndRenderPass(this.command_buffer);

    if (vk.endCommandBuffer(this.command_buffer) != vk.SUCCESS) {
        @panic("endCommandBuffer failed!");
    }
}

pub fn drawFrame(this: *const @This()) void {
    _ = vk.waitForFences(this.device, 1, @ptrCast(&this.in_flight_fence), vk.TRUE, std.math.maxInt(u64));
    _ = vk.resetFences(this.device, 1, @ptrCast(&this.in_flight_fence));

    var image_index: u32 = undefined;
    if (vk.acquireNextImageKHR(this.device, this.swapchain.handle, std.math.maxInt(u64), this.image_available_semaphore, null, &image_index) != vk.SUCCESS) {
        @panic("acquirenextImageKHR failed!");
    }

    _ = vk.resetCommandBuffer(this.command_buffer, .{});

    this.recordCommandBuffer(image_index);

    const wait_semaphores = [_]vk.Semaphore{this.image_available_semaphore};
    const wait_stages = [wait_semaphores.len]vk.PipelineStageFlags{.{ .COLOR_ATTACHMENT_OUTPUT = 1 }};
    const command_buffers = [_]vk.CommandBuffer{this.command_buffer};
    const signal_semaphores = [_]vk.Semaphore{this.render_finished_semaphore};

    const submit_infos = [_]vk.SubmitInfo{.{
        .sType = .SUBMIT_INFO,
        .waitSemaphoreCount = wait_semaphores.len,
        .pWaitSemaphores = &wait_semaphores,
        .pWaitDstStageMask = &wait_stages,
        .commandBufferCount = command_buffers.len,
        .pCommandBuffers = &command_buffers,
        .signalSemaphoreCount = signal_semaphores.len,
        .pSignalSemaphores = &signal_semaphores,
    }};

    if (vk.queueSubmit(this.graphics_que, submit_infos.len, &submit_infos, this.in_flight_fence) != vk.SUCCESS) {
        @panic("queueSubmit failed!");
    }

    const swapchains = [_]vk.SwapchainKHR{this.swapchain.handle};
    const image_indices = [swapchains.len]u32{image_index};

    const present_info = vk.PresentInfoKHR{
        .sType = .PRESENT_INFO_KHR,
        .waitSemaphoreCount = signal_semaphores.len,
        .pWaitSemaphores = &signal_semaphores,
        .swapchainCount = swapchains.len,
        .pSwapchains = &swapchains,
        .pImageIndices = &image_indices,
        .pResults = null,
    };

    _ = vk.queuePresentKHR(this.present_que, &present_info);
}

fn createShaderModule(this: *const @This(), code: []const u8) !vk.ShaderModule {
    const create_info = vk.ShaderModuleCreateInfo{
        .sType = .SHADER_MODULE_CREATE_INFO,
        .codeSize = code.len,
        .pCode = @alignCast(@ptrCast(code.ptr)),
    };

    var shader_module: vk.ShaderModule = undefined;
    if (vk.createShaderModule(this.device, &create_info, null, &shader_module) != vk.SUCCESS) {
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

    if (message_severity.VERBOSE == 1) {
        if (debug_verbose) log.debug(fmt, args);
    } else if (message_severity.WARNING == 1) {
        log.warn(fmt, args);
    } else if (message_severity.ERROR == 1) {
        log.err(fmt, args);
    } else {
        elog("Invalid message severity '{}'", .{message_severity});
        log.err(fmt, args);
    }

    return vk.FALSE;
}
