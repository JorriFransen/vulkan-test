const builtin = @import("builtin");

pub const Input_State = struct {
    escape_pressed: bool = false,
};

pub const Window = if (builtin.os.tag == .windows)
    @import("window/win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("window/glfw_window.zig")
else
    @compileError("Unsupported platform");
