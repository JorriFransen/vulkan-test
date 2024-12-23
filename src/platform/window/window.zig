const builtin = @import("builtin");

pub const Window = if (builtin.os.tag == .windows)
    @import("win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("glfw_window.zig")
else
    @compileError("Unsupported platform");

pub const FrameBufferResizeCallback = struct {
    pub const Function = *const fn (window: *const Window, width: c_int, height: c_int, user_data: *anyopaque) void;

    fun: Function,
    user_data: *anyopaque,
};
