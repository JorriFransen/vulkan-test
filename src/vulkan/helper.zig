const std = @import("std");
const assert = std.debug.assert;
const builtin = @import("builtin");

const alloc = @import("alloc");
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
const debug_verbose = debug and true;
const is_mac = builtin.target.os.tag == .macos;

var instance: vk.Instance = undefined;
var surface: vk.SurfaceKHR = undefined;
var physical_device: vk.PhysicalDevice = null;
var device: vk.Device = null;
var graphics_que: vk.Queue = null;
var present_que: vk.Queue = null;
var debug_messenger: vke.DebugUtilsMessenger = undefined;

const validation_layers: []const [*:0]const u8 = if (debug) &.{
    "VK_LAYER_KHRONOS_validation",
} else &.{};

const mac_instance_extensions: []const [*:0]const u8 = if (is_mac) &.{
    vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
} else &.{};

const debug_instance_extensions: []const [*:0]const u8 = if (debug) &.{
    vke.EXT_DEBUG_UTILS_EXTENSION_NAME,
} else &.{};

const required_device_extensions: []const [*:0]const u8 = &.{
    vk.KHR_SWAPCHAIN_EXTENSION_NAME,
};

pub fn init_system(window: *const Window) !void {
    try create_instance();
    surface = try window.create_vulkan_surface(instance);

    const device_info = try choose_physical_device();
    try create_logical_device(device_info);
}

fn create_instance() !void {
    var extension_count: u32 = undefined;
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, null);
    dlog("{} Vulkan extensions supported", .{extension_count});

    const extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, extension_count);
    defer alloc.gpa.free(extension_props);
    _ = vk.enumerateInstanceExtensionProperties(null, &extension_count, extension_props.ptr);
    // for (extension_props) |p| dlog("supported extension: '{s}'", .{@as([*:0]const u8, @ptrCast(&p.extensionName))});

    const app_info = vk.ApplicationInfo{
        .sType = vk.Structure_Type.APPLICATION_INFO,

        .pApplicationName = "Vulkan app",
        .applicationVersion = vk.MAKE_VERSION(1, 0, 0),
        .pEngineName = "Vulkan engine",
        .engineVersion = vk.MAKE_VERSION(1, 0, 0),
        .apiVersion = vk.API_VERSION_1_0,
    };

    const window_required_extensions = try Window.required_instance_extensions();

    const instance_ext_count = window_required_extensions.len + mac_instance_extensions.len + debug_instance_extensions.len;

    var required_instance_extensions = try std.ArrayList([*:0]const u8).initCapacity(alloc.gpa, instance_ext_count);
    defer required_instance_extensions.deinit();
    required_instance_extensions.appendSliceAssumeCapacity(window_required_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(mac_instance_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(debug_instance_extensions);

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
        .sType = vke.Structure_Type.DEBUG_UTILS_MESSENGER_CREATE_INFO,
        .messageSeverity = vke.DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT | vke.DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT | vke.DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT,
        .messageType = vke.DEBUG_UTILS_MESSAGE_TYPE_GENERAL_BIT | vke.DEBUG_UTILS_MESSAGE_TYPE_VALIDATION_BIT | vke.DEBUG_UTILS_MESSAGE_TYPE_PERFORMANCE_BIT,
        .pfnUserCallback = vk_debug_callback,
        .pUserData = null,
    };
    const instance_debug_messenger_create_info = debug_messenger_create_info;

    const instance_create_info = vk.InstanceCreateInfo{
        .sType = vk.Structure_Type.INSTANCE_CREATE_INFO,
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

const PDev_Info = struct {
    score: u32,
    graphics_que_family_index: u32,
    present_que_family_index: u32,
    name: [256]u8 = std.mem.zeroes([256]u8),
};

fn choose_physical_device() !PDev_Info {
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
    var best_device_info: PDev_Info = undefined;

    for (devices, 0..) |pdev, i| {
        var props: vk.PhysicalDeviceProperties = undefined;
        vk.getPhysicalDeviceProperties(@ptrCast(pdev), &props);

        var features: vk.PhysicalDeviceFeatures = undefined;
        vk.getPhysicalDeviceFeatures(@ptrCast(pdev), &features);

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

        var que_family_count: u32 = undefined;
        vk.getPhysicalDeviceQueueFamilyProperties(pdev, &que_family_count, null);

        const queue_families = try alloc.gpa.alloc(vk.QueueFamilyProperties, que_family_count);
        defer alloc.gpa.free(queue_families);
        vk.getPhysicalDeviceQueueFamilyProperties(pdev, &que_family_count, queue_families.ptr);

        var graphics_que_family_index: u32 = undefined;
        var present_que_family_index: u32 = undefined;
        var graphics_que_found = false;
        var present_que_found = false;

        for (queue_families, 0..) |qf, qi| {
            if (qf.queueFlags.GRAPHICS_BIT == 1) {
                graphics_que_family_index = @intCast(qi);
                graphics_que_found = true;
            }

            if (!present_que_found) {
                var supported: vk.Bool32 = vk.FALSE;
                _ = vk.getPhysicalDeviceSurfaceSupportKHR(pdev, @intCast(qi), surface, &supported);
                if (supported == vk.TRUE) {
                    present_que_family_index = @intCast(qi);
                    present_que_found = true;
                }
            }
        }

        const queues_found = graphics_que_found and present_que_found;

        if (!queues_found) {
            dlog("pd[{}] does not have required queue families, skipping...", .{i});
            continue;
        }

        var prop_count: u32 = undefined;
        _ = vk.enumerateDeviceExtensionProperties(pdev, null, &prop_count, null);

        const dev_extension_props = try alloc.gpa.alloc(vk.ExtensionProperties, prop_count);
        defer alloc.gpa.free(dev_extension_props);
        _ = vk.enumerateDeviceExtensionProperties(pdev, null, &prop_count, dev_extension_props.ptr);

        var has_required_extensions = true;
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
                has_required_extensions = false;
                break;
            }
        }

        if (!has_required_extensions) {
            dlog("pd[{}] does not have required extensions, skipping...", .{i});
            continue;
        }

        dlog("pd[{}]: idim_score: {}", .{ i, image_dim_score });
        const score = type_score * image_dim_score;
        dlog("pd[{}]: score: {}", .{ i, score });

        dlog("===========================", .{});

        const info = PDev_Info{
            .score = score,
            .graphics_que_family_index = graphics_que_family_index,
            .present_que_family_index = present_que_family_index,
            .name = props.deviceName,
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

fn create_logical_device(pdev_info: PDev_Info) !void {
    var fin_array = [_]u32{ pdev_info.graphics_que_family_index, pdev_info.present_que_family_index };
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
    const que_prio: f32 = 1.0;

    for (qcis, fin) |*qci, fi| qci.* = .{
        .sType = vk.Structure_Type.DEVICE_QUEUE_CREATE_INFO,
        .queueFamilyIndex = fi,
        .queueCount = 1,
        .pQueuePriorities = &que_prio,
    };

    const device_features = vk.PhysicalDeviceFeatures{};

    const device_create_info = vk.DeviceCreateInfo{
        .sType = vk.Structure_Type.DEVICE_CREATE_INFO,
        .pQueueCreateInfos = qcis.ptr,
        .queueCreateInfoCount = @intCast(qcis.len),
        .pEnabledFeatures = &device_features,
        .enabledExtensionCount = 0,
        .enabledLayerCount = validation_layers.len,
        .ppEnabledLayerNames = validation_layers.ptr,
    };

    if (vk.createDevice(physical_device, &device_create_info, null, &device) != vk.SUCCESS) {
        elog("Failed to create logical device!", .{});
        return error.Logical_Device_Creation_Failed;
    }

    vk.getDeviceQueue(device, pdev_info.graphics_que_family_index, 0, &graphics_que);
    vk.getDeviceQueue(device, pdev_info.present_que_family_index, 0, &present_que);
}

pub fn deinit_system() void {
    vk.destroyDevice(device, null);
    vk.destroySurfaceKHR(instance, surface, null);
    if (debug) vke.destroyDebugUtilsMessenger(instance, debug_messenger, null);
    vk.destroyInstance(instance, null);
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
