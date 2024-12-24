const std = @import("std");
const builtin = @import("builtin");
const vk = @import("vulkan");

const platform = @import("platform");
const Api = platform.WindowApi;
const Key = platform.Key;
const KeyAction = platform.KeyAction;

const Callback = @import("callback").Callback;

const Win32Window = @import("win32_window.zig");
const GlfwWindow = @import("glfw_window.zig");

pub const WindowImpl = if (builtin.os.tag == .windows)
    Win32Window
else if (builtin.os.tag == .linux)
    GlfwWindow
else
    @compileError("Unsupported platform");

pub const FrameBufferResizeCallback = Callback(&.{ *@This(), c_int, c_int });
pub const KeyCallback = Callback(&.{ *@This(), Key, KeyAction, c_int });

pub fn initSystem() !void {
    try WindowImpl.initSystem();
}

pub fn deinitSystem() void {
    WindowImpl.deinitSystem();
}

impl: WindowImpl,
framebuffer_resize_callback: ?FrameBufferResizeCallback = null,
key_callback: ?KeyCallback = null,

pub fn create(allocator: std.mem.Allocator, title: [:0]const u8) !*@This() {
    const result = try allocator.create(@This());
    errdefer allocator.destroy(result);

    try result.init(title);

    return result;
}

pub fn destroy(this: *@This(), allocator: std.mem.Allocator) void {
    this.deinit();
    allocator.destroy(this);
}

pub fn init(this: *@This(), title: [:0]const u8) !void {
    try this.impl.init(title);
}

pub fn deinit(this: *@This()) void {
    this.impl.deinit();
}

pub fn shouldClose(this: *const @This()) bool {
    return this.impl.shouldClose();
}

pub fn requestClose(this: *@This()) void {
    this.impl.requestClose();
}

pub fn pollEvents(this: *@This()) void {
    this.impl.pollEvents();
}

pub fn waitEvents(this: *@This()) void {
    this.impl.waitEvents();
}

pub fn frameBufferSize(this: *const @This(), width: *i32, height: *i32) void {
    this.impl.frameBufferSize(width, height);
}

pub fn requiredVulkanInstanceExtensions(this: *const @This()) ![]const [*:0]const u8 {
    return this.impl.requiredVulkanInstanceExtensions();
}

pub fn createVulkanSurface(this: *const @This(), instance: vk.Instance) !vk.SurfaceKHR {
    return this.impl.createVulkanSurface(instance);
}
