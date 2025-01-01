pub const CLIENT_API: c_int = 0x00022001;
pub const WAYLAND_APP_ID = 0x00026001;
pub const PLATFORM = 0x00050003;

pub const NO_API: c_int = 0;

pub const TRUE = 1;
pub const FALSE = 0;

const platform = @import("platform");
const x = platform.x;
const vk = @import("vulkan");

pub extern fn glfwInit() callconv(.C) c_int;
pub extern fn glfwInitHint(hint: c_int, value: c_int) callconv(.C) void;
pub extern fn glfwGetError(description: ?*const [*:0]const u8) callconv(.C) c_int;
pub extern fn glfwWindowHint(hint: c_int, value: c_int) callconv(.C) void;
pub extern fn glfwWindowHintString(hint: c_int, value: [*:0]const u8) callconv(.C) void;
pub extern fn glfwCreateWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*GLFWmonitor, share: ?*GLFWwindow) callconv(.C) ?*GLFWwindow;
pub extern fn glfwWindowShouldClose(window: ?*GLFWwindow) callconv(.C) c_int;
pub extern fn glfwSetWindowShouldClose(window: ?*GLFWwindow, value: c_int) callconv(.C) void;
pub extern fn glfwPollEvents() callconv(.C) void;
pub extern fn glfwWaitEvents() callconv(.C) void;
pub extern fn glfwSetKeyCallback(window: ?*GLFWwindow, callback: GLFWkeyfun) callconv(.C) GLFWkeyfun;
pub extern fn glfwSetFramebufferSizeCallback(window: ?*GLFWwindow, callback: GLFWframebuffersizefun) callconv(.C) GLFWframebuffersizefun;
pub extern fn glfwDestroyWindow(window: ?*GLFWwindow) callconv(.C) void;
pub extern fn glfwTerminate() callconv(.C) void;
pub extern fn glfwGetFramebufferSize(window: ?*const GLFWwindow, width: ?*c_int, height: ?*c_int) callconv(.C) void;
pub extern fn glfwSwapBuffers(window: ?*const GLFWwindow) callconv(.C) void;

pub extern fn glfwPlatformSupported(platform: Platform) callconv(.C) c_int;
pub extern fn glfwGetPlatform() callconv(.C) Platform;
pub extern fn glfwVulkanSupported() callconv(.C) c_int;
pub extern fn glfwGetRequiredInstanceExtensions(count: *u32) callconv(.C) ?[*][*:0]const u8;
pub extern fn glfwSetWindowUserPointer(window: ?*GLFWwindow, ptr: *anyopaque) callconv(.C) void;
pub extern fn glfwGetWindowUserPointer(window: ?*GLFWwindow) callconv(.C) *anyopaque;
pub extern fn glfwGetX11Display() callconv(.C) *x.Display;
pub extern fn glfwGetX11Window(window: ?*GLFWwindow) callconv(.C) x.Window;
pub extern fn glfwCreateWindowSurface(instance: vk.Instance, window: ?*GLFWwindow, allocator: ?*vk.AllocationCallbacks, surface: *vk.SurfaceKHR) vk.Result;

pub const GLFWwindow = extern struct { dummy: c_long = 0 };
pub const GLFWmonitor = extern struct { dummy: c_long = 0 };
pub const GLFWkeyfun = *const fn (window: ?*GLFWwindow, key: Key, scancode: c_int, action: Action, mods: c_int) callconv(.C) void;
pub const GLFWframebuffersizefun = *const fn (window: ?*GLFWwindow, width: c_int, height: c_int) callconv(.C) void;

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
