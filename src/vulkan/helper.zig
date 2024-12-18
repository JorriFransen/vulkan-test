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
const vkd = vk.loader.debug_utils;

const vlog = std.log.scoped(.vulkan);
const dlog = vlog.debug;
const elog = vlog.err;
const ilog = vlog.info;

const debug = builtin.mode == .Debug;
const debug_verbose = debug and options.vulkan_verbose;
const is_mac = builtin.target.os.tag == .macos;

var instance: vk.Instance = undefined;
var surface: vk.SurfaceKHR = undefined;
var physical_device: vk.PhysicalDevice = null;
var device: vk.Device = null;
var graphics_que: vk.Queue = null;
var present_que: vk.Queue = null;
var swapchain: SwapchainData = undefined;
var render_pass: vk.RenderPass = undefined;
var pipeline_layout: vk.PipelineLayout = undefined;
var graphics_pipeline: vk.Pipeline = undefined;
var swapchain_framebuffers: []vk.Framebuffer = undefined; // TODO: Move this to SwapchainData
var debug_messenger: vke.DebugUtilsMessenger = undefined;

const PDevInfo = struct {
    score: u32,
    name: [256]u8 = std.mem.zeroes([256]u8),
    queue_info: QueueFamilyInfo,
    swapchain_info: SwapchainInfo,
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

    pub fn deinit(this: *@This(), allocator: std.mem.Allocator) void {
        for (this.image_views) |v| vk.destroyImageView(device, v, null);
        allocator.free(this.image_views);
        allocator.free(this.images);
        vk.destroySwapchainKHR(device, this.handle, null);
    }
};

const validation_layers: []const [*:0]const u8 = if (debug) &.{
    "VK_LAYER_KHRONOS_validation",
} else &.{};

const mac_instance_extensions: []const [*:0]const u8 = if (is_mac) &.{
    vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
} else &.{};

const debug_instance_extensions: []const [*:0]const u8 = if (debug) &.{
    vke.EXT_DEBUG_UTILS_EXTENSION_NAME,
} else &.{};

const instance_extensions = mac_instance_extensions ++ debug_instance_extensions;

const required_device_extensions: []const [*:0]const u8 = &.{
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
};

pub fn initSystem(window: *const Window) !void {
    try createInstance(window);
    surface = try window.createVulkanSurface(instance);

    const device_info = try choosePhysicalDevice();
    try createLogicalDevice(&device_info);

    swapchain = try createSwapchain(window, &device_info);

    try createRenderPass();
    try createGraphicsPipeline();
    try createFrameBuffers();
}

pub fn deinitSystem() void {
    for (swapchain_framebuffers) |fb| vk.destroyFramebuffer(device, fb, null);

    alloc.gpa.free(swapchain_framebuffers);
    vk.destroyPipeline(device, graphics_pipeline, null);
    vk.destroyPipelineLayout(device, pipeline_layout, null);
    vk.destroyRenderPass(device, render_pass, null);
    swapchain.deinit(alloc.gpa);
    vk.destroyDevice(device, null);
    vk.destroySurfaceKHR(instance, surface, null);
    if (debug) vke.destroyDebugUtilsMessenger(instance, debug_messenger, null);
    vk.destroyInstance(instance, null);
}

fn createInstance(window: *const Window) !void {
    var extension_count: u32 = undefined;
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, null);
    dlog("{} Vulkan extensions supported", .{extension_count});

    const extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, extension_count);
    defer alloc.gpa.free(extension_props);
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, extension_props.ptr);
    // for (extension_props) |p| dlog("supported extension: '{s}'", .{@as([*:0]const u8, @ptrCast(&p.extensionName))});

    const app_info = vk.ApplicationInfo{
        .sType = vk.structure_type.APPLICATION_INFO,
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

    const debug_messenger_create_info = vke.DebugUtilsMessengerCreateInfo{
        .sType = vke.structure_type.DEBUG_UTILS_MESSENGER_CREATE_INFO,
        .messageSeverity = vke.DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT | vke.DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT | vke.DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT,
        .messageType = vke.DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT | vke.DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT | vke.DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT,
        .pfnUserCallback = vk_debug_callback,
        .pUserData = null,
    };
    const instance_debug_messenger_create_info = debug_messenger_create_info;

    const instance_create_info = vk.InstanceCreateInfo{
        .sType = vk.structure_type.INSTANCE_CREATE_INFO,
        .pApplicationInfo = &app_info,
        .flags = if (is_mac) vk.INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR else 0,
        .enabledExtensionCount = @intCast(required_instance_extensions.items.len),
        .ppEnabledExtensionNames = required_instance_extensions.items.ptr,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
        .pNext = if (debug) &instance_debug_messenger_create_info else null,
    };

    dlog("vkCreateInstance: ...", .{});
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

    if (debug) {
        _ = vke.createDebugUtilsMessenger(instance, &debug_messenger_create_info, null, &debug_messenger);
    }
}

fn choosePhysicalDevice() !PDevInfo {
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

        const queue_info_opt = try queryQueueFamiliesInfo(pdev);
        const queue_info = queue_info_opt orelse {
            dlog("pd[{}] does not have required queue families, skipping...", .{i});
            continue;
        };

        if (!try queryDeviceExtensionsSuitable(pdev)) {
            dlog("pd[{}] does not have required extensions, skipping...", .{i});
            continue;
        }

        const swapchain_info_opt = try querySwapchainInfo(pdev);
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

    physical_device = devices[best_device_index];
    ilog("using device: {} ({s})", .{ best_device_index, best_device_info.name });

    return best_device_info;
}

fn queryQueueFamiliesInfo(pdev: vk.PhysicalDevice) !?QueueFamilyInfo {
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

fn querySwapchainInfo(pdev: vk.PhysicalDevice) !?SwapchainInfo {
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

fn createLogicalDevice(pdev_info: *const PDevInfo) !void {
    var fin_array = [_]u32{ pdev_info.queue_info.graphics_index, pdev_info.queue_info.present_index };
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
        .sType = vk.structure_type.DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = fi,
        .queueCount = 1,
        .pQueuePriorities = &que_prio,
    };

    const device_features = vk.PhysicalDeviceFeatures{};

    const device_create_info = vk.DeviceCreateInfo{
        .sType = vk.structure_type.DEVICE_CREATE_INFO,
        .pQueueCreateInfos = qcis.ptr,
        .queueCreateInfoCount = @intCast(qcis.len),
        .pEnabledFeatures = &device_features,
        .enabledExtensionCount = required_device_extensions.len,
        .ppEnabledExtensionNames = required_device_extensions.ptr,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
    };

    if (vk.createDevice(physical_device, &device_create_info, null, &device) != vk.SUCCESS) {
        elog("Failed to create logical device!", .{});
        return error.Logical_Device_Creation_Failed;
    }

    vk.getDeviceQueue(device, pdev_info.queue_info.graphics_index, 0, &graphics_que);
    vk.getDeviceQueue(device, pdev_info.queue_info.present_index, 0, &present_que);
}

pub fn createSwapchain(window: *const Window, info: *const PDevInfo) !SwapchainData {
    const cap = &info.swapchain_info.surface_capabilities;
    dlog("cap.currentExtent: {}", .{cap.currentExtent});
    const extent = switch (cap.currentExtent.width) {
        std.math.maxInt(u32) => blk: {
            var width: c_int = undefined;
            var height: c_int = undefined;
            window.frameBufferSize(&width, &height);

            var actual_extent = vk.Extent2D{ .width = @intCast(width), .height = @intCast(height) };
            actual_extent.width = std.math.clamp(actual_extent.width, cap.minImageExtent.width, cap.maxImageExtent.width);
            actual_extent.height = std.math.clamp(actual_extent.height, cap.minImageExtent.height, cap.maxImageExtent.height);

            break :blk actual_extent;
        },
        else => cap.currentExtent,
    };

    dlog("swapchain extent: {}", .{extent});

    const same_family = info.queue_info.graphics_index == info.queue_info.present_index;

    const create_info = vk.SwapchainCreateInfoKHR{
        .sType = vk.structure_type.SWAPCHAIN_CREATE_INFO_KHR,
        .surface = surface,
        .minImageCount = info.swapchain_info.min_image_count,
        .imageFormat = info.swapchain_info.surface_format.format,
        .imageColorSpace = info.swapchain_info.surface_format.colorSpace,
        .imageExtent = extent,
        .imageArrayLayers = 1,
        .imageUsage = vk.IMAGE_USAGE_COLOR_ATTACHMENT_BIT,
        .imageSharingMode = if (same_family) vk.SHARING_MODE_EXCLUSIVE else vk.SHARING_MODE_CONCURRENT,
        .queueFamilyIndexCount = if (same_family) 0 else 2,
        .pQueueFamilyIndices = if (same_family) null else @ptrCast(&.{ info.queue_info.graphics_index, info.queue_info.present_index }),
        .preTransform = cap.currentTransform,
        .compositeAlpha = vk.COMPOSITE_ALPHA_OPAQUE_BIT_KHR,
        .presentMode = info.swapchain_info.present_mode,
        .clipped = vk.TRUE,
        .oldSwapchain = null,
    };

    var swapchain_handle: vk.SwapchainKHR = undefined;
    if (vk.createSwapchainKHR(device, &create_info, null, &swapchain_handle) != vk.SUCCESS) {
        return error.Create_Swapchain_Failed;
    }

    var image_count: u32 = undefined;
    if (vk.getSwapchainImagesKHR(device, swapchain_handle, &image_count, null) != vk.SUCCESS) {
        return error.Get_Swapchain_Images_Failed;
    }

    const images = try alloc.gpa.alloc(vk.Image, image_count);
    if (vk.getSwapchainImagesKHR(device, swapchain_handle, &image_count, images.ptr) != vk.SUCCESS) {
        return error.Get_Swapchain_Images_Failed;
    }
    assert(image_count == images.len);

    const image_views = try alloc.gpa.alloc(vk.ImageView, image_count);
    for (images, image_views) |image, *view| {
        const view_create_info = vk.ImageViewCreateInfo{
            .sType = vk.structure_type.IMAGE_VIEW_CREATE_INFO,
            .image = image,
            .viewType = vk.IMAGE_VIEW_TYPE_2D,
            .format = info.swapchain_info.surface_format.format,
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

        if (vk.createImageView(device, &view_create_info, null, view) != vk.SUCCESS) {
            return error.Create_Image_View_Failed;
        }
    }

    return .{
        .handle = swapchain_handle,
        .images = images,
        .image_views = image_views,
        .image_format = info.swapchain_info.surface_format.format,
        .extent = extent,
    };
}

fn createRenderPass() !void {
    const color_attachments = [_]vk.AttachmentDescription{.{
        .format = swapchain.image_format,
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

    const render_pass_create_info = vk.RenderPassCreateInfo{
        .sType = vk.structure_type.RENDER_PASS_CREATE_INFO,
        .attachmentCount = color_attachments.len,
        .pAttachments = &color_attachments,
        .subpassCount = subpasses.len,
        .pSubpasses = &subpasses,
    };

    if (vk.createRenderPass(device, &render_pass_create_info, null, &render_pass) != vk.SUCCESS) {
        return error.CreateRenderPassFailed;
    }
}

fn createGraphicsPipeline() !void {
    const vert_shader_module = try createShaderModule(&builtin_shaders.@"triangle.vert");
    defer vk.destroyShaderModule(device, vert_shader_module, null);

    const frag_shader_module = try createShaderModule(&builtin_shaders.@"triangle.frag");
    defer vk.destroyShaderModule(device, frag_shader_module, null);

    const shader_stages = [_]vk.PipelineShaderStageCreateInfo{
        .{
            .sType = vk.structure_type.PIPELINE_SHADER_STAGE_CREATE_INFO,
            .stage = vk.shader_stage_bit.VERTEX,
            .module = vert_shader_module,
            .pName = "main",
        },
        .{
            .sType = vk.structure_type.PIPELINE_SHADER_STAGE_CREATE_INFO,
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
        .sType = vk.structure_type.PIPELINE_DYNAMIC_STATE_CREATE_INFO,
        .dynamicStateCount = dynamic_states.len,
        .pDynamicStates = &dynamic_states,
    };

    const vertex_input_state_create_info = vk.PipelineVertexInputStateCreateInfo{
        .sType = vk.structure_type.PIPELINE_VERTEX_INPUT_STATE_CREATE_INFO,
        .vertexBindingDescriptionCount = 0,
        .pVertexBindingDescriptions = null,
        .vertexAttributeDescriptionCount = 0,
        .pVertexAttributeDescriptions = null,
    };

    const input_assembly_create_info = vk.PipelineInputAssemblyStateCreateInfo{
        .sType = vk.structure_type.PIPELINE_INPUT_ASSEMBLY_STATE_CREATE_INFO,
        .topology = .TRIANGLE_LIST,
        .primitiveRestartEnable = vk.FALSE,
    };

    const viewport = vk.Viewport{
        .x = 0,
        .y = 0,
        .width = @floatFromInt(swapchain.extent.width),
        .height = @floatFromInt(swapchain.extent.height),
        .minDepth = 0,
        .maxDepth = 1,
    };

    const scissor = vk.Rect2D{
        .offset = .{ .x = 0, .y = 0 },
        .extent = swapchain.extent,
    };

    const viewport_create_info = vk.PipelineViewportStateCreateInfo{
        .sType = vk.structure_type.PIPELINE_VIEWPORT_STATE_CREATE_INFO,
        .viewportCount = 1,
        .scissorCount = 1,
    };

    const rasterizer_create_info = vk.PipelineRasterizationStateCreateInfo{
        .sType = vk.structure_type.PIPELINE_RASTERIZATION_STATE_CREATE_INFO,
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
        .sType = vk.structure_type.PIPELINE_MULTISAMPLE_STATE_CREATE_INFO,
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
        .sType = vk.structure_type.PIPELINE_COLOR_BLEND_STATE_CREATE_INFO,
        .logicOpEnable = vk.FALSE,
        .logicOp = .COPY,
        .attachmentCount = color_blend_attachments.len,
        .pAttachments = &color_blend_attachments,
        .blendConstants = .{ 0, 0, 0, 0 },
    };

    const pipeline_layout_create_info = vk.PipelineLayoutCreateInfo{
        .sType = vk.structure_type.PIPELINE_LAYOUT_CREATE_INFO,
        .setLayoutCount = 0,
        .pSetLayouts = null,
        .pushConstantRangeCount = 0,
        .pPushConstantRanges = null,
    };

    if (vk.createPipelineLayout(device, &pipeline_layout_create_info, null, &pipeline_layout) != vk.SUCCESS) {
        return error.CreatePipelineLayoutFailed;
    }

    const pipeline_create_infos = [_]vk.GraphicsPiplineCreateInfo{.{
        .sType = vk.structure_type.GRAPHICS_PIPELINE_CREATE_INFO,
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
        .layout = pipeline_layout,
        .renderPass = render_pass,
        .subpass = 0,
        .basePipelineHandle = null,
        .basePipelineIndex = -1,
    }};

    if (vk.createGraphicsPipelines(device, null, pipeline_create_infos.len, &pipeline_create_infos, null, &graphics_pipeline) != vk.SUCCESS) {
        return error.CreateGraphicsPipelinesFailed;
    }

    _ = scissor;
    _ = viewport;
}

fn createFrameBuffers() !void {
    swapchain_framebuffers = try alloc.gpa.alloc(vk.Framebuffer, swapchain.image_views.len);

    for (swapchain.image_views, 0..) |iv, i| {
        const attachments = [_]vk.ImageView{iv};

        const framebuffer_create_info = vk.FramebufferCreateInfo{
            .sType = vk.structure_type.FRAMEBUFFER_CREATE_INFO,
            .renderPass = render_pass,
            .attachmentCount = attachments.len,
            .pAttachments = &attachments,
            .width = swapchain.extent.width,
            .height = swapchain.extent.height,
            .layers = 1,
        };

        if (vk.createFramebuffer(device, &framebuffer_create_info, null, &swapchain_framebuffers[i]) != vk.SUCCESS) {
            return error.CreateFramebufferFailed;
        }
    }
}

fn createShaderModule(code: []const u8) !vk.ShaderModule {
    const create_info = vk.ShaderModuleCreateInfo{
        .sType = vk.structure_type.SHADER_MODULE_CREATE_INFO,
        .codeSize = code.len,
        .pCode = @alignCast(@ptrCast(code.ptr)),
    };

    var shader_module: vk.ShaderModule = undefined;
    if (vk.createShaderModule(device, &create_info, null, &shader_module) != vk.SUCCESS) {
        return error.createShaderModuleFailed;
    }

    return shader_module;
}

fn vk_debug_callback(message_severity: vke.DebugUtilsMessageSeverityFlagBits, message_type: vke.DebugUtilsMessageTypeFlags, _callback_data: [*c]const vke.DebugUtilsMessengerCallbackData, user_data: ?*anyopaque) callconv(.C) vk.Bool32 {
    _ = message_type;
    _ = user_data;

    const log = std.log.scoped(.@"vulkan message");
    const callback_data: *const vke.DebugUtilsMessengerCallbackData = _callback_data;

    const fmt = "{s}";
    const args = .{callback_data.pMessage};

    switch (message_severity) {
        vke.DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT => if (debug_verbose) log.debug(fmt, args),
        vke.DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT => log.warn(fmt, args),
        vke.DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT => log.err(fmt, args),
        else => {
            elog("Invalid message severity '{}'", .{message_severity});
            log.err(fmt, args);
        },
    }

    return vk.FALSE;
}
