const builtin = @import("builtin");

pub const windows = @import("platform/windows/windows.zig");
pub const glfw = @import("platform/window/glfw.zig");
pub const x = @import("platform/window/x.zig");

pub const Window = if (builtin.os.tag == .windows)
    @import("platform/window/win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("platform/window/glfw_window.zig")
else
    @compileError("Unsupported platform");

pub const InputState = struct {
    escape_pressed: bool = false,
};

pub const WindowApi = enum {
    default,
    win32,
    wayland,
    x11,
};
