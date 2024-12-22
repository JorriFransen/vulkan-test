pub const windows = @import("platform/windows/windows.zig");
pub const glfw = @import("platform/glfw.zig");
pub const x = @import("platform/x.zig");

pub const window = @import("platform/window/window.zig");
pub const Window = window.Window;

pub const InputState = struct {
    escape_pressed: bool = false,
};

pub const WindowApi = enum {
    default,
    win32,
    wayland,
    x11,
};
