const std = @import("std");
const builtin = @import("builtin");
const vk = @import("vulkan");

const platform = @import("platform");
const Api = platform.WindowApi;
const Key = platform.Key;
const KeyAction = platform.KeyAction;

const Callback = @import("callback").Callback;

pub const Win32Window = @import("win32_window.zig");
pub const GlfwWindow = @import("glfw_window.zig");

pub const FrameBufferResizeCallback = Callback(&.{ *@This(), c_int, c_int });
pub const KeyCallback = Callback(&.{ *@This(), Key, KeyAction, c_int });

pub const InitSystemError = error{ InvalidGLFWWindowApi, nativeInitFailed };
pub const OpenError = error{NativeCreateFailed};
pub const CreateVulkanSurfaceError = error{NativeCreateSurfaceFailed};

pub const Impl = union {
    win32_window: Win32Window,
    glfw_window: GlfwWindow,
};

impl: Impl,

framebuffer_resize_callback: ?FrameBufferResizeCallback = null,
key_callback: ?KeyCallback = null,

initSystemFn: *const fn () InitSystemError!void,
deinitSystemFn: *const fn () void,
openFn: *const fn (*anyopaque, [*:0]const u8) OpenError!void,
closeFn: *const fn (*const anyopaque) void,
shouldCloseFn: *const fn (*const anyopaque) bool,
requestCloseFn: *const fn (*anyopaque) void,
pollEventsFn: *const fn (*anyopaque) void,
waitEventsFn: *const fn (*anyopaque) void,
requiredVulkanInstanceExtensionsFn: *const fn () error{VulkanApiUnavailable}![]const [*:0]const u8,
createVulkanSurfaceFn: *const fn (*const anyopaque, vk.Instance) CreateVulkanSurfaceError!vk.SurfaceKHR,
framebufferSizeFn: *const fn (*const anyopaque, *i32, *i32) void,

pub fn init(api_or_default: Api) @This() {
    const api = if (api_or_default == .default)
        if (builtin.os.tag == .windows) .win32 else .glfw
    else
        api_or_default;

    return switch (api) {
        .default => unreachable,
        .win32 => unreachable,
        .glfw => initT(GlfwWindow, .{ .glfw_window = .{} }),
    };
}

fn initT(comptime T: type, impl: Impl) @This() {
    return .{
        .impl = impl,
        .initSystemFn = T.initSystem,
        .deinitSystemFn = T.deinitSystem,
        .openFn = T.open,
        .closeFn = T.close,
        .shouldCloseFn = T.shouldClose,
        .requestCloseFn = T.requestClose,
        .pollEventsFn = T.pollEvents,
        .waitEventsFn = T.waitEvents,
        .requiredVulkanInstanceExtensionsFn = T.requiredVulkanInstanceExtensions,
        .createVulkanSurfaceFn = T.createVulkanSurface,
        .framebufferSizeFn = T.framebufferSize,
    };
}

pub fn initSystem(this: *@This()) InitSystemError!void {
    try this.initSystemFn();
}

pub fn deinitSystem(this: @This()) void {
    this.deinitSystemFn();
}

pub fn open(this: *@This(), title: [*:0]const u8) OpenError!void {
    try this.openFn(&this.impl, title);
}

pub fn close(this: *const @This()) void {
    this.closeFn(&this.impl);
}

pub fn shouldClose(this: *const @This()) bool {
    return this.shouldCloseFn(&this.impl);
}

pub fn requestClose(this: *@This()) void {
    this.requestCloseFn(&this.impl);
}

pub fn pollEvents(this: *@This()) void {
    this.pollEventsFn(&this.impl);
}

pub fn waitEvents(this: *@This()) void {
    this.waitEventsFn(&this.impl);
}

pub fn requiredVulkanInstanceExtensions(this: *const @This()) error{VulkanApiUnavailable}![]const [*:0]const u8 {
    return try this.requiredVulkanInstanceExtensionsFn();
}

pub fn createVulkanSurface(this: *const @This(), instance: vk.Instance) CreateVulkanSurfaceError!vk.SurfaceKHR {
    return try this.createVulkanSurfaceFn(&this.impl, instance);
}

pub fn framebufferSize(this: *const @This(), width: *i32, height: *i32) void {
    return this.framebufferSizeFn(&this.impl, width, height);
}
