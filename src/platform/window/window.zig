const builtin = @import("builtin");

pub const PFN_FramebufferResize = *const fn (window: *const Window, width: c_int, height: c_int) void;

pub const Window = if (builtin.os.tag == .windows)
    @import("win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("glfw_window.zig")
else
    @compileError("Unsupported platform");
