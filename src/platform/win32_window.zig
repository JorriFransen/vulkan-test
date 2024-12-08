const std = @import("std");
const log = std.log.scoped(.window);
const dlog = log.debug;
const elog = log.err;
const ilog = log.info;
const W = std.unicode.utf8ToUtf16LeStringLiteral;

const gpa = @import("alloc").gpa;
const w = @import("window");
const win32 = @import("windows/windows.zig");

pub fn init_system() !void {
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

pub fn deinit_system() void {}

pub fn required_instance_extensions() ![]const [*:0]const u8 {
    return &.{
        "VK_KHR_surface",
        "VK_KHR_win32_surface",
    };
}

handle: win32.HWND,
title: [:0]u16,
close_requested: bool = false,

input: w.Input_State = .{},
last_input: w.Input_State = .{},

pub fn create(this: *@This(), title: [:0]const u8) !void {
    var instance: win32.HINSTANCE = undefined;
    if (win32.GetModuleHandleW(null)) |i_handle| {
        instance = @ptrCast(i_handle);
    } else {
        return error.GetModuleHandle_Failed;
    }

    const window_class = win32.WNDCLASSEXW{
        .style = .{},
        .lpfnWndProc = window_proc,
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

    const titleW = try std.unicode.utf8ToUtf16LeAllocZ(gpa, title);

    const style = win32.WINDOW_STYLE.OVERLAPPED_WINDOW();

    var window_handle: win32.HWND = undefined;
    if (win32.CreateWindowExW(.{}, window_class.lpszClassName, titleW, style, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, 800, 600, null, null, instance, null)) |handle| {
        window_handle = handle;
    } else {
        try win32.report_error();
    }

    const setval = @intFromPtr(this);
    _ = win32.SetWindowLongPtrW(window_handle, 0, setval);

    // _ = win32.ShowWindow(window_handle, @bitCast(cmd_show));
    _ = win32.ShowWindow(window_handle, .{ .SHOWNORMAL = 1 });

    this.* = .{
        .handle = window_handle,
        .title = titleW,
    };
}

pub fn should_close(this: *const @This()) bool {
    return this.close_requested;
}

pub fn request_close(this: *@This()) void {
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
}

pub fn close(this: *@This()) void {
    _ = win32.DestroyWindow(this.handle);
    gpa.free(this.title);
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

const Key_LParam = packed struct {
    repeat_count: u16,
    scan_code: u8,
    extended: u1,
    reserved: u4,
    context_code: u1,
    previous_state: u1,
    transition_state: u1,
};

fn window_proc(_hwnd: ?win32.HWND, uMsg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(.C) isize {
    const hwnd = _hwnd.?;

    const data_int = win32.GetWindowLongPtrW(hwnd, 0);
    if (data_int == 0) {
        // This gets called before the user data can be set
        return win32.DefWindowProcW(hwnd, uMsg, wParam, lParam);
    }

    const this: *@This() = @ptrFromInt(data_int);

    switch (uMsg) {
        win32.WM_DESTROY => {
            win32.PostQuitMessage(0);
            this.close_requested = true;
            return 0;
        },

        win32.WM_KEYDOWN => {
            const flags: Key_LParam = @bitCast(@as(u32, @intCast(lParam)));
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
