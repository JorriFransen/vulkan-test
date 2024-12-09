const builtin = @import("builtin");

pub usingnamespace @cImport({
    @cInclude("vulkan/vulkan.h");

    if (builtin.target.os.tag == .windows) {
        @cInclude("windows.h");
        @cInclude("vulkan/vulkan_win32.h");
    } else {
        @cInclude("X11/Xlib.h");
        @cInclude("X11/Xlib-xcb.h");
        @cInclude("xcb/xcb.h");

        @cInclude("vulkan/vulkan_xcb.h");
        @cInclude("vulkan/vulkan_xlib.h");
    }
});
