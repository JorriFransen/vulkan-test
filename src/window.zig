const builtin = @import("builtin");

pub const Input_State = struct {
    escape_pressed: bool = false,
};

pub const Window = if (builtin.os.tag == .windows)
    @import("platform/win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("platform/glfw_window.zig")
else
    @compileError("Unsupported platform");
