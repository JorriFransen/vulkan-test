pub const CLIENT_API: c_int = 0x00022001;
pub const NO_API: c_int = 0;

pub extern fn glfwInit() callconv(.C) c_int;
pub extern fn glfwGetError(description: ?*const [*:0]const u8) callconv(.C) c_int;
pub extern fn glfwWindowHint(hint: c_int, value: c_int) callconv(.C) void;
pub extern fn glfwCreateWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*GLFWmonitor, share: ?*GLFWwindow) callconv(.C) ?*GLFWwindow;
pub extern fn glfwWindowShouldClose(window: *GLFWwindow) callconv(.C) c_int;
pub extern fn glfwPollEvents() callconv(.C) void;
pub extern fn glfwDestroyWindow(window: *GLFWwindow) callconv(.C) void;
pub extern fn glfwTerminate() callconv(.C) void;

pub const GLFWwindow = extern struct { dummy: c_long = 0 };
pub const GLFWmonitor = extern struct { dummy: c_long = 0 };
