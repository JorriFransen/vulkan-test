const vk = @import("vk");
const vke = vk.extensions;
const vkd = vk.loader.debug_utils;

const alloc = @import("alloc");
const Window = @import("window").Window;

const std = @import("std");
const assert = std.debug.assert;
const vlog = std.log.scoped(.vulkan);
const dlog = vlog.debug;
const elog = vlog.err;

const builtin = @import("builtin");

var instance: vk.Instance = undefined;
var physical_device: vk.PhysicalDevice = null;
var debug_messenger: vke.DebugUtilsMessenger = undefined;

const debug = builtin.mode == .Debug;
const debug_verbose = debug and false;
const is_mac = builtin.target.os.tag == .macos;

pub fn init_system() !void {
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

    const mac_extensions: []const [*:0]const u8 = if (is_mac) &.{
        vk.KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME,
    } else &.{};

    const debug_extensions: []const [*:0]const u8 = if (debug) &.{
        vke.EXT_DEBUG_UTILS_EXTENSION_NAME,
    } else &.{};

    const instance_ext_count = window_required_extensions.len + mac_extensions.len + debug_extensions.len;

    var required_instance_extensions = try std.ArrayList([*:0]const u8).initCapacity(alloc.gpa, instance_ext_count);
    defer required_instance_extensions.deinit();
    required_instance_extensions.appendSliceAssumeCapacity(window_required_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(mac_extensions);
    required_instance_extensions.appendSliceAssumeCapacity(debug_extensions);

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

    const validation_layers: []const [*:0]const u8 = if (debug) &.{
        "VK_LAYER_KHRONOS_validation",
    } else &.{};

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

    const create_info = vk.InstanceCreateInfo{
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
    switch (vk.createInstance(&create_info, null, &instance)) {
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

    var device_count: u32 = 0;
    _ = vk.enumeratePhysicalDevices(instance, &device_count, null);
    if (device_count == 0) {
        elog("Failed to find gpu(s) with Vulkan support!", .{});
        return error.No_Vulkan_Support_Gpu_Found;
    }

    const devices = try alloc.gpa.alloc(vk.PhysicalDevice, device_count);
    defer alloc.gpa.free(devices);

    const is_suitable = struct {
        fn f(device: *const vk.PhysicalDevice) bool {
            _ = device;
            return true;
        }
    }.f;

    for (devices) |d| if (is_suitable(&d)) {
        physical_device = d;
        break;
    };

    if (physical_device == null) {
        elog("Failed to find suitable gpu!", .{});
        return error.No_Suitable_Gpu_Found;
    }
}

pub fn deinit_system() void {
    if (debug) vke.destroyDebugUtilsMessenger(instance, debug_messenger, null);
    vk.destroyInstance(instance, null);
}

fn vk_debug_callback(message_severity: vke.DebugUtilsMessageSeverityFlagBits, message_type: vke.DebugUtilsMessageTypeFlags, _callback_data: [*c]const vke.DebugUtilsMessengerCallbackData, user_data: ?*anyopaque) callconv(.C) vk.Bool32 {
    _ = message_type;
    _ = user_data;

    const callback_data: *const vke.DebugUtilsMessengerCallbackData = _callback_data;

    const fmt = "{s}";
    const args = .{callback_data.pMessage};

    switch (message_severity) {
        vke.DEBUG_UTILS_MESSAGE_SEVERITY_VERBOSE_BIT => if (debug_verbose) vlog.debug(fmt, args),
        vke.DEBUG_UTILS_MESSAGE_SEVERITY_WARNING_BIT => vlog.warn(fmt, args),
        vke.DEBUG_UTILS_MESSAGE_SEVERITY_ERROR_BIT => vlog.err(fmt, args),
        else => {
            elog("Invalid message severity '{}'", .{message_severity});
            vlog.err(fmt, args);
        },
    }

    return vk.FALSE;
}
