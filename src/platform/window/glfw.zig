pub const CLIENT_API: c_int = 0x00022001;
pub const WAYLAND_APP_ID = 0x00026001;
pub const PLATFORM = 0x00050003;

pub const NO_API: c_int = 0;

pub const TRUE = 1;
pub const FALSE = 0;

const c = @import("platform").c;
const vk = @import("vulkan");

pub extern fn glfwInit() callconv(.C) c_int;
pub extern fn glfwInitHint(hint: c_int, value: c_int) callconv(.C) void;
pub extern fn glfwGetError(description: ?*const [*:0]const u8) callconv(.C) c_int;
pub extern fn glfwWindowHint(hint: c_int, value: c_int) callconv(.C) void;
pub extern fn glfwWindowHintString(hint: c_int, value: [*:0]const u8) callconv(.C) void;
pub extern fn glfwCreateWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*GLFWmonitor, share: ?*GLFWwindow) callconv(.C) ?*GLFWwindow;
pub extern fn glfwWindowShouldClose(window: *GLFWwindow) callconv(.C) c_int;
pub extern fn glfwSetWindowShouldClose(window: *GLFWwindow, value: c_int) callconv(.C) void;
pub extern fn glfwPollEvents() callconv(.C) void;
pub extern fn glfwSetKeyCallback(window: *GLFWwindow, callback: GLFWkeyfun) callconv(.C) GLFWkeyfun;
pub extern fn glfwDestroyWindow(window: *GLFWwindow) callconv(.C) void;
pub extern fn glfwTerminate() callconv(.C) void;
pub extern fn glfwGetFramebufferSize(window: *const GLFWwindow, width: ?*c_int, height: ?*c_int) callconv(.C) void;
pub extern fn glfwSwapBuffers(window: *const GLFWwindow) callconv(.C) void;

pub extern fn glfwPlatformSupported(platform: Platform) callconv(.C) c_int;
pub extern fn glfwGetPlatform() callconv(.C) Platform;
pub extern fn glfwVulkanSupported() callconv(.C) c_int;
pub extern fn glfwGetRequiredInstanceExtensions(count: *u32) callconv(.C) [*c][*c]const u8;
pub extern fn glfwSetWindowUserPointer(window: *GLFWwindow, ptr: *anyopaque) callconv(.C) void;
pub extern fn glfwGetWindowUserPointer(window: *GLFWwindow) callconv(.C) *anyopaque;
pub extern fn glfwGetX11Display() callconv(.C) *c.Display;
pub extern fn glfwGetX11Window(window: *GLFWwindow) callconv(.C) c.Window;
pub extern fn glfwCreateWindowSurface(instance: vk.Instance, window: *GLFWwindow, allocator: ?*vk.AllocationCallbacks, surface: *vk.SurfaceKHR) vk.Result;

pub const GLFWwindow = extern struct { dummy: c_long = 0 };
pub const GLFWmonitor = extern struct { dummy: c_long = 0 };
pub const GLFWkeyfun = *const fn (window: *GLFWwindow, key: Key, scancode: c_int, action: Action, mods: c_int) callconv(.C) void;

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

pub const Key = enum(c_int) {
    space = 32,
    apostrophe = 39, //  '
    comma = 44, //  ,
    minus = 45, //  -
    period = 46, //  .
    slash = 47, //  /
    @"0" = 48,
    @"1" = 49,
    @"2" = 50,
    @"3" = 51,
    @"4" = 52,
    @"5" = 53,
    @"6" = 54,
    @"7" = 55,
    @"8" = 56,
    @"9" = 57,
    semicolon = 59, //  ,
    equal = 61, //  =
    a = 65,
    b = 66,
    c = 67,
    d = 68,
    e = 69,
    f = 70,
    g = 71,
    h = 72,
    i = 73,
    j = 74,
    k = 75,
    l = 76,
    m = 77,
    n = 78,
    o = 79,
    p = 80,
    q = 81,
    r = 82,
    s = 83,
    t = 84,
    u = 85,
    v = 86,
    w = 87,
    x = 88,
    y = 89,
    z = 90,
    left_bracket = 91, //  [
    backslash = 92, //  \
    right_bracket = 93, //  ]
    grave_accent = 96, //  `
    world_1 = 161, //  NON-us #1
    world_2 = 162, //  NON-us #2
    escape = 256,
    enter = 257,
    tab = 258,
    backspace = 259,
    insert = 260,
    delete = 261,
    right = 262,
    left = 263,
    down = 264,
    up = 265,
    page_up = 266,
    page_down = 267,
    home = 268,
    end = 269,
    caps_lock = 280,
    scroll_lock = 281,
    num_lock = 282,
    print_screen = 283,
    pause = 284,
    f1 = 290,
    f2 = 291,
    f3 = 292,
    f4 = 293,
    f5 = 294,
    f6 = 295,
    f7 = 296,
    f8 = 297,
    f9 = 298,
    f10 = 299,
    f11 = 300,
    f12 = 301,
    f13 = 302,
    f14 = 303,
    f15 = 304,
    f16 = 305,
    f17 = 306,
    f18 = 307,
    f19 = 308,
    f20 = 309,
    f21 = 310,
    f22 = 311,
    f23 = 312,
    f24 = 313,
    f25 = 314,
    kp_0 = 320,
    kp_1 = 321,
    kp_2 = 322,
    kp_3 = 323,
    kp_4 = 324,
    kp_5 = 325,
    kp_6 = 326,
    kp_7 = 327,
    kp_8 = 328,
    kp_9 = 329,
    kp_decimal = 330,
    kp_divide = 331,
    kp_multiply = 332,
    kp_subtract = 333,
    kp_add = 334,
    kp_enter = 335,
    kp_equal = 336,
    left_shift = 340,
    left_control = 341,
    left_alt = 342,
    left_super = 343,
    right_shift = 344,
    right_control = 345,
    right_alt = 346,
    right_super = 347,
    menu = 348,
    // last = .menu,
};
