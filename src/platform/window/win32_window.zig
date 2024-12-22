const std = @import("std");
const assert = std.debug.assert;
const W = std.unicode.utf8ToUtf16LeStringLiteral;

const log = std.log.scoped(.window);
const dlog = log.debug;
const elog = log.err;
const ilog = log.info;

const vk = @import("vulkan");

const root = @import("root");
const platform = @import("platform");
const win32 = platform.windows;

pub fn initSystem() !void {
    assert(root.cmd_line_options.glfw_window_api == .win32 or root.cmd_line_options.glfw_window_api == .default);
    // if (win32.AttachConsole(win32.ATTACH_PARENT_PROCESS) == 0) {
    //     if (win32.CreateFileW(W("nul"), win32.GENERIC_READ | win32.GENERIC_WRITE, 0, null, win32.OPEN_EXISTING, win32.FILE_ATTRIBUTE_NORMAL, null)) |nul_handle| {
    //         _ = win32.SetStdHandle(win32.STD_INPUT_HANDLE, nul_handle);
    //         _ = win32.SetStdHandle(win32.STD_OUTPUT_HANDLE, nul_handle);
    //         _ = win32.SetStdHandle(win32.STD_ERROR_HANDLE, nul_handle);
    //     } else {
    //         _ = win32.MessageBoxW(null, W("Failed to attach default streams"), W("Error"), win32.MB_ICONERROR);
    //         return 1;
    //     }
    // }
}

pub fn deinitSystem() void {}

const MAX_TITLE = 1024;

handle: win32.HWND,
close_requested: bool = false,
title: [MAX_TITLE]u16 = std.mem.zeroes([MAX_TITLE]u16),
new_fb_size: ?win32.POINT,

input: platform.InputState = .{},
last_input: platform.InputState = .{},
framebuffer_resize_callback: ?platform.window.PFN_FramebufferResize,

pub fn create(this: *@This(), title: [:0]const u8) !void {
    var instance: win32.HINSTANCE = undefined;
    if (win32.GetModuleHandleW(null)) |i_handle| {
        instance = @ptrCast(i_handle);
    } else {
        return error.GetModuleHandle_Failed;
    }

    const window_class = win32.WNDCLASSEXW{
        .style = .{},
        .lpfnWndProc = windowProc,
        .hInstance = instance,
        .hbrBackground = @ptrFromInt(0),
        .lpszClassName = W("VKTZ"),
        .hCursor = @ptrCast(win32.LoadImageW(null, win32.IDC_ARROW, win32.IMAGE_CURSOR, 0, 0, win32.LR_DEFAULTSIZE | win32.LR_SHARED)),
        .hIcon = null,
        .cbWndExtra = @sizeOf(*@This()),
    };

    if (win32.RegisterClassExW(&window_class) == 0) {
        try win32.report_error();
    }

    if (try std.unicode.checkUtf8ToUtf16LeOverflow(title, &this.title)) {
        elog("Title too long!", .{});
        return error.Title_Too_Long;
    }

    const title_len = try std.unicode.utf8ToUtf16Le(&this.title, title);
    if (title_len >= MAX_TITLE) {
        elog("Title too long!", .{});
        return error.Title_Too_Long;
    }
    this.title[title_len] = 0;

    const style = win32.WINDOW_STYLE.OVERLAPPED_WINDOW();

    if (win32.CreateWindowExW(.{}, window_class.lpszClassName, @ptrCast(&this.title), style, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, instance, null)) |handle| {
        this.handle = handle;
    } else {
        try win32.report_error();
    }

    const setval = @intFromPtr(this);
    _ = win32.SetWindowLongPtrW(this.handle, 0, setval);

    // _ = win32.ShowWindow(window_handle, @bitCast(cmd_show));
    _ = win32.ShowWindow(this.handle, .{ .SHOWNORMAL = 1 });
}

pub fn shouldClose(this: *const @This()) bool {
    return this.close_requested;
}

pub fn requestClose(this: *@This()) void {
    this.close_requested = true;
    win32.PostQuitMessage(0);
}

pub fn update(this: *@This()) void {
    var msg: win32.MSG = undefined;

    this.last_input = this.input;
    this.input = .{};

    while (win32.PeekMessageW(&msg, this.handle, 0, 0, .{ .REMOVE = 1 }) == win32.TRUE) {
        _ = win32.TranslateMessage(&msg);
        _ = win32.DispatchMessageW(&msg);

        if (msg.message == win32.WM_QUIT) {
            this.close_requested = true;
            break;
        }
    }

    if (this.new_fb_size) |s| {
        if (this.framebuffer_resize_callback) |cb| cb(this, s.x, s.y);
        this.new_fb_size = null;
    }
}

pub fn close(this: *@This()) void {
    _ = win32.DestroyWindow(this.handle);
}

pub fn frameBufferSize(this: *const @This(), width: *i32, height: *i32) void {
    var rect: win32.RECT = undefined;
    const res = win32.GetClientRect(this.handle, &rect);
    assert(res == win32.TRUE);

    assert(rect.left == 0);
    assert(rect.top == 0);

    width.* = rect.right;
    height.* = rect.bottom;
}

pub fn requiredVulkanInstanceExtensions(_: *const @This()) ![]const [*:0]const u8 {
    return &.{
        "VK_KHR_surface",
        "VK_KHR_win32_surface",
    };
}

pub fn createVulkanSurface(this: *const @This(), instance: vk.Instance) !vk.SurfaceKHR {
    var surface: vk.SurfaceKHR = undefined;

    const create_info = vk.Win32SurfaceCreateInfoKHR{
        .sType = .WIN32_SURFACE_CREATE_INFO_KHR,
        .hwnd = @ptrCast(this.handle),
        .hinstance = @ptrCast(win32.GetModuleHandleW(null)),
    };

    if (vk.createWin32SurfaceKHR(instance, &create_info, null, &surface) != .SUCCESS) {
        elog("vkCreateWin32SurfaceKHR failed!", .{});
        return error.Vulkan_Surface_Creation_Failed;
    }

    return surface;
}

// pub export fn wWinMain(instance: win32.HINSTANCE, prev_instance: ?win32.HINSTANCE, cmd_line: win32.PWSTR, cmd_show: win32.INT) callconv(.C) win32.INT {
//     _ = prev_instance;
//     _ = cmd_line;
//
//     if (win32.AttachConsole(win32.ATTACH_PARENT_PROCESS) == 0) {
//         if (win32.CreateFileW(W("nul"), win32.GENERIC_READ | win32.GENERIC_WRITE, 0, null, win32.OPEN_EXISTING, win32.FILE_ATTRIBUTE_NORMAL, null)) |nul_handle| {
//             _ = win32.SetStdHandle(win32.STD_INPUT_HANDLE, nul_handle);
//             _ = win32.SetStdHandle(win32.STD_OUTPUT_HANDLE, nul_handle);
//             _ = win32.SetStdHandle(win32.STD_ERROR_HANDLE, nul_handle);
//         } else {
//             _ = win32.MessageBoxW(null, W("Failed to attach default streams"), W("Error"), win32.MB_ICONERROR);
//             return 1;
//         }
//     }
//
//     vmain(instance, cmd_show) catch |err| {
//         elog("{s}", .{@errorName(err)});
//         if (@errorReturnTrace()) |trace| {
//             std.debug.dumpStackTrace(trace.*);
//         }
//         return 1;
//     };
//
//     return 0;
// }

const KeyLParam = packed struct {
    repeat_count: u16,
    scan_code: u8,
    extended: u1,
    reserved: u4,
    context_code: u1,
    previous_state: u1,
    transition_state: u1,
};

fn windowProc(_hwnd: ?win32.HWND, uMsg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(.C) isize {
    const hwnd = _hwnd.?;

    const data_int = win32.GetWindowLongPtrW(hwnd, 0);
    if (data_int == 0) {
        // This gets called before the user data can be set
        return win32.DefWindowProcW(hwnd, uMsg, wParam, lParam);
    }

    const this: *@This() = @ptrFromInt(data_int);

    switch (uMsg) {
        win32.WM_SIZE => {
            this.new_fb_size = .{ .x = win32.LOWORD(lParam), .y = win32.HIWORD(lParam) };
            return 0;
        },
        win32.WM_DESTROY => {
            win32.PostQuitMessage(0);
            this.close_requested = true;
            return 0;
        },

        win32.WM_KEYDOWN => {
            const flags: KeyLParam = @bitCast(@as(u32, @intCast(lParam)));
            this.input.escape_pressed = wParam == win32.VK_ESCAPE and flags.previous_state == 0;
            return 0;
        },

        win32.WM_KEYUP => {
            if (wParam == win32.VK_ESCAPE) this.input.escape_pressed = false;
            return 0;
        },

        else => return win32.DefWindowProcW(hwnd, uMsg, wParam, lParam),
    }
}
