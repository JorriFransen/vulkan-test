const builtin = @import("builtin");

pub usingnamespace @cImport({
    if (builtin.target.os.tag == .windows) {
        @cInclude("windows.h");
        @cInclude("vulkan/vulkan_win32.h");
    }
});
