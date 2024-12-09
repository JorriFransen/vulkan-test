const builtin = @import("builtin");

pub const c = @import("platform/c.zig");
pub const windows = @import("platform/windows/windows.zig");
pub const glfw = @import("platform/window/glfw.zig");

pub const Window = if (builtin.os.tag == .windows)
    @import("platform/window/win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("platform/window/glfw_window.zig")
else
    @compileError("Unsupported platform");

pub const Input_State = struct {
    escape_pressed: bool = false,
};
