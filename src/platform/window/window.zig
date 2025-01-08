const std = @import("std");
const builtin = @import("builtin");
const vk = @import("vulkan");
const options = @import("options");

const platform = @import("platform");
const Api = platform.WindowApi;
const Key = platform.Key;
const KeyAction = platform.KeyAction;

const Callback = @import("callback").Callback;

const log = std.log.scoped(.window);
pub const dlog = log.debug;
pub const elog = log.err;
pub const ilog = log.info;

pub const Win32Window = if (builtin.os.tag == .windows) @import("win32_window.zig") else Stub;
pub const GlfwWindow = if (options.glfw_support) @import("glfw_window.zig") else Stub;

pub const FrameBufferResizeCallback = Callback(&.{ *@This(), c_int, c_int });
pub const KeyCallback = Callback(&.{ *@This(), Key, KeyAction, c_int });

pub const InitSystemError = error{ InvalidGLFWWindowApi, nativeInitFailed };
pub const InitError = error{ApiUnavailable};
pub const OpenError = error{ NativeCreateFailed, InvalidUtf8, TitleTooLong };
pub const CreateVulkanSurfaceError = error{NativeCreateSurfaceFailed};

pub const Size = struct {
    width: i32 = 0,
    height: i32 = 0,
};

pub const Impl = union {
    win32_window: Win32Window,
    glfw_window: GlfwWindow,
};

pub const InitSystemOptions = struct {
    window_api: platform.WindowApi = .default,
    glfw_api: platform.GlfwWindowApi = .default,
};

impl: Impl,

initSystemFn: *const fn (options: InitSystemOptions) InitSystemError!void,
deinitSystemFn: *const fn () void,
openFn: *const fn (*anyopaque, [:0]const u8) OpenError!void,
closeFn: *const fn (*const anyopaque) void,
shouldCloseFn: *const fn (*const anyopaque) bool,
requestCloseFn: *const fn (*anyopaque) void,
pollEventsFn: *const fn (*anyopaque) void,
waitEventsFn: *const fn (*anyopaque) void,
requiredVulkanInstanceExtensionsFn: *const fn () error{VulkanApiUnavailable}![]const [*:0]const u8,
createVulkanSurfaceFn: *const fn (*const anyopaque, vk.Instance) CreateVulkanSurfaceError!vk.SurfaceKHR,
framebufferSizeFn: *const fn (*const anyopaque) Size,
setFramebufferResizeCallbackFn: *const fn (*anyopaque, callback: FrameBufferResizeCallback) void,
setKeyCallbackFn: *const fn (*anyopaque, callback: KeyCallback) void,

pub fn init(api_or_default: Api) InitError!@This() {
    const api = if (api_or_default == .default)
        if (builtin.os.tag == .windows) .win32 else .glfw
    else
        api_or_default;

    const api_supported = switch (api) {
        .default => unreachable,
        .win32 => builtin.os.tag == .windows,
        .glfw => options.glfw_support,
    };

    if (!api_supported) {
        elog("Window api not supported: {s}", .{@tagName(api)});
        return error.ApiUnavailable;
    }

    return switch (api) {
        .default => unreachable,
        .win32 => initT(Win32Window, .{ .win32_window = .{} }),
        .glfw => initT(GlfwWindow, .{ .glfw_window = .{} }),
    };
}

fn initT(comptime T: type, impl: Impl) @This() {
    const gen = struct {
        pub fn open(ptr: *anyopaque, title: [:0]const u8) OpenError!void {
            const this: *T = @ptrCast(@alignCast(ptr));
            try this.open(title);
        }

        pub fn close(ptr: *const anyopaque) void {
            const this: *const T = @ptrCast(@alignCast(ptr));
            this.close();
        }

        pub fn shouldClose(ptr: *const anyopaque) bool {
            const this: *const T = @ptrCast(@alignCast(ptr));
            return this.shouldClose();
        }

        pub fn requestClose(ptr: *anyopaque) void {
            const this: *T = @ptrCast(@alignCast(ptr));
            this.requestClose();
        }

        pub fn pollEvents(ptr: *anyopaque) void {
            const this: *T = @ptrCast(@alignCast(ptr));
            this.pollEvents();
        }

        pub fn waitEvents(ptr: *anyopaque) void {
            const this: *T = @ptrCast(@alignCast(ptr));
            this.waitEvents();
        }

        pub fn createVulkanSurface(ptr: *const anyopaque, instance: vk.Instance) CreateVulkanSurfaceError!vk.SurfaceKHR {
            const this: *const T = @ptrCast(@alignCast(ptr));
            return try this.createVulkanSurface(instance);
        }

        pub fn framebufferSize(ptr: *const anyopaque) Size {
            const this: *const T = @ptrCast(@alignCast(ptr));
            return this.framebufferSize();
        }

        pub fn setFramebufferResizeCallback(ptr: *anyopaque, callback: FrameBufferResizeCallback) void {
            const this: *T = @ptrCast(@alignCast(ptr));
            this.setFramebufferResizeCallback(callback);
        }

        pub fn setKeyCallback(ptr: *anyopaque, callback: KeyCallback) void {
            const this: *T = @ptrCast(@alignCast(ptr));
            this.setKeyCallback(callback);
        }
    };

    return .{
        .impl = impl,
        .initSystemFn = T.initSystem,
        .deinitSystemFn = T.deinitSystem,
        .openFn = gen.open,
        .closeFn = gen.close,
        .shouldCloseFn = gen.shouldClose,
        .requestCloseFn = gen.requestClose,
        .pollEventsFn = gen.pollEvents,
        .waitEventsFn = gen.waitEvents,
        .requiredVulkanInstanceExtensionsFn = T.requiredVulkanInstanceExtensions,
        .createVulkanSurfaceFn = gen.createVulkanSurface,
        .framebufferSizeFn = gen.framebufferSize,
        .setFramebufferResizeCallbackFn = gen.setFramebufferResizeCallback,
        .setKeyCallbackFn = gen.setKeyCallback,
    };
}

pub fn initSystem(this: *@This(), init_options: InitSystemOptions) InitSystemError!void {
    try this.initSystemFn(init_options);
}

pub fn deinitSystem(this: @This()) void {
    this.deinitSystemFn();
}

pub fn open(this: *@This(), title: [:0]const u8) OpenError!void {
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

pub fn framebufferSize(this: *const @This()) Size {
    return this.framebufferSizeFn(&this.impl);
}

pub fn setFramebufferResizeCallback(this: *@This(), callback: FrameBufferResizeCallback) void {
    this.setFramebufferResizeCallbackFn(&this.impl, callback);
}

pub fn setKeyCallback(this: *@This(), callback: KeyCallback) void {
    this.setKeyCallbackFn(&this.impl, callback);
}

const Stub = struct {
    pub fn initSystem(_: InitSystemOptions) InitSystemError!void {}
    pub fn deinitSystem() void {}
    pub fn open(_: *@This(), _: [:0]const u8) OpenError!void {}
    pub fn close(_: *const @This()) void {}
    pub fn shouldClose(_: *const @This()) bool {
        return false;
    }
    pub fn requestClose(_: *@This()) void {}
    pub fn pollEvents(_: *@This()) void {}
    pub fn waitEvents(_: *@This()) void {}
    pub fn requiredVulkanInstanceExtensions() error{VulkanApiUnavailable}![]const [*:0]const u8 {
        return &.{};
    }
    pub fn createVulkanSurface(_: *const @This(), _: vk.Instance) CreateVulkanSurfaceError!vk.SurfaceKHR {
        return null;
    }
    pub fn framebufferSize(_: *const @This()) Size {
        return .{};
    }
    pub fn setFramebufferResizeCallback(_: *@This(), _: FrameBufferResizeCallback) void {}
    pub fn setKeyCallback(_: *@This(), _: KeyCallback) void {}
};
