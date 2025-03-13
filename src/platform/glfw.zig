const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

const f = @import("../externFn.zig").externFn;

pub const CLIENT_API: c_int = c.GLFW_CLIENT_API;
pub const WAYLAND_APP_ID = c.GLFW_WAYLAND_APP_ID;
pub const PLATFORM = c.GLFW_PLATFORM;

pub const NO_API: c_int = c.GLFW_NO_API;

pub const TRUE = c.GLFW_TRUE;
pub const FALSE = c.GLFW_FALSE;

const platform = @import("../platform.zig");
const x = platform.x;
const vk = @import("../vulkan/vulkan.zig");

pub const Window = ?*c.GLFWwindow;

pub const init = f("glfwInit", fn () callconv(.C) c_int);
pub const initHint = f("glfwInitHint", fn (hint: c_int, value: c_int) callconv(.C) void);
pub const getError = f("glfwGetError", fn (description: ?*const [*:0]const u8) callconv(.C) c_int);
pub const windowHint = f("glfwWindowHint", fn (hint: c_int, value: c_int) callconv(.C) void);
pub const windowHintString = f("glfwWindowHintString", fn (hint: c_int, value: [*:0]const u8) callconv(.C) void);
pub const createWindow = f("glfwCreateWindow", fn (width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*GLFWmonitor, share: ?*c.GLFWwindow) callconv(.C) ?*c.GLFWwindow);
pub const windowShouldClose = f("glfwWindowShouldClose", fn (window: ?*c.GLFWwindow) callconv(.C) c_int);
pub const setWindowShouldClose = f("glfwSetWindowShouldClose", fn (window: ?*c.GLFWwindow, value: c_int) callconv(.C) void);
pub const pollEvents = f("glfwPollEvents", fn () callconv(.C) void);
pub const waitEvents = f("glfwWaitEvents", fn () callconv(.C) void);
pub const setKeyCallback = f("glfwSetKeyCallback", fn (window: ?*c.GLFWwindow, callback: GLFWkeyfun) callconv(.C) GLFWkeyfun);
pub const setFramebufferSizeCallback = f("glfwSetFramebufferSizeCallback", fn (window: ?*c.GLFWwindow, callback: GLFWframebuffersizefun) callconv(.C) GLFWframebuffersizefun);
pub const destroyWindow = f("glfwDestroyWindow", fn (window: ?*c.GLFWwindow) callconv(.C) void);
pub const terminate = f("glfwTerminate", fn () callconv(.C) void);
pub const getFramebufferSize = f("glfwGetFramebufferSize", fn (window: ?*const c.GLFWwindow, width: ?*c_int, height: ?*c_int) callconv(.C) void);
pub const swapBuffers = f("glfwSwapBuffers", fn (window: ?*const c.GLFWwindow) callconv(.C) void);

pub const platformSupported = f("glfwPlatformSupported", fn (platform: Platform) callconv(.C) c_int);
pub const getPlatform = f("glfwGetPlatform", fn () callconv(.C) Platform);
pub const vulkanSupported = f("glfwVulkanSupported", fn () callconv(.C) c_int);
pub const getRequiredInstanceExtensions = f("glfwGetRequiredInstanceExtensions", fn (count: *u32) callconv(.C) ?[*][*:0]const u8);
pub const setWindowUserPointer = f("glfwSetWindowUserPointer", fn (window: ?*c.GLFWwindow, ptr: *anyopaque) callconv(.C) void);
pub const getWindowUserPointer = f("glfwGetWindowUserPointer", fn (window: ?*c.GLFWwindow) callconv(.C) *anyopaque);
pub const getX11Display = f("glfwGetX11Display", fn () callconv(.C) *x.Display);
pub const getX11Window = f("glfwGetX11Window", fn (window: ?*c.GLFWwindow) callconv(.C) x.Window);
pub const createWindowSurface = f("glfwCreateWindowSurface", fn (instance: vk.Instance, window: ?*c.GLFWwindow, allocator: ?*vk.AllocationCallbacks, surface: *vk.SurfaceKHR) callconv(.C) vk.Result);

// pub const c.GLFWwindow = extern struct { dummy: c_long = 0 };
pub const GLFWmonitor = extern struct { dummy: c_long = 0 };
pub const GLFWkeyfun = *const fn (window: ?*c.GLFWwindow, key: Key, scancode: c_int, action: Action, mods: c_int) callconv(.C) void;
pub const GLFWframebuffersizefun = *const fn (window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void;
//
pub const Platform = enum(c_int) {
    ANY = 0x00060000,
    WIN32 = 0x00060001,
    COCOA = 0x00060002,
    WAYLAND = 0x00060003,
    X11 = 0x00060004,
    NULL = 0x00060005,
};

pub const Action = enum(c_int) {
    release = 0,
    press = 1,
    repeat = 2,
};

pub const Key = platform.Key;
