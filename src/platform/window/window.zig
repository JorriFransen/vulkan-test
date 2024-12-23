const std = @import("std");
const builtin = @import("builtin");
const Callback = @import("callback").Callback;

pub const Window = if (builtin.os.tag == .windows)
    @import("win32_window.zig")
else if (builtin.os.tag == .linux)
    @import("glfw_window.zig")
else
    @compileError("Unsupported platform");

pub const FrameBufferResizeCallback = Callback(&.{ *const Window, c_int, c_int });
