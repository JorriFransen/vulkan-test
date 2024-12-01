const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;
const W = std.unicode.utf8ToUtf16LeStringLiteral;

const w = @import("../windows/windows.zig");

pub export fn wWinMain(instance: w.HINSTANCE, prev_instance: ?w.HINSTANCE, cmd_line: w.PWSTR, cmd_show: w.INT) callconv(.C) w.INT {
    _ = prev_instance;
    _ = cmd_line;

    if (w.AttachConsole(w.ATTACH_PARENT_PROCESS) == 0) {
        if (w.CreateFileW(W("nul"), w.GENERIC_READ | w.GENERIC_WRITE, 0, null, w.OPEN_EXISTING, w.FILE_ATTRIBUTE_NORMAL, null)) |nul_handle| {
            _ = w.SetStdHandle(w.STD_INPUT_HANDLE, nul_handle);
            _ = w.SetStdHandle(w.STD_OUTPUT_HANDLE, nul_handle);
            _ = w.SetStdHandle(w.STD_ERROR_HANDLE, nul_handle);
        } else {
            _ = w.MessageBoxW(null, W("Failed to attach default streams"), W("Error"), w.MB_ICONERROR);
            return 1;
        }
    }

    vmain(instance, cmd_show) catch |err| {
        elog("{s}", .{@errorName(err)});
        if (@errorReturnTrace()) |trace| {
            std.debug.dumpStackTrace(trace.*);
        }
        return 1;
    };

    return 0;
}

pub fn vmain(instance: w.HINSTANCE, cmd_show: w.INT) !void {
    const window_class = w.WNDCLASSEXW{
        .style = .{},
        .lpfnWndProc = window_proc,
        .hInstance = instance,
        .hbrBackground = @ptrFromInt(0),
        .lpszClassName = W("VKTZ"),
        .hCursor = @ptrCast(w.LoadImageW(null, w.IDC_ARROW, w.IMAGE_CURSOR, 0, 0, w.LR_DEFAULTSIZE | w.LR_SHARED)),
        .hIcon = null,
    };

    if (w.RegisterClassExW(&window_class) == 0) {
        try w.report_error();
    }

    const style = w.WINDOW_STYLE.OVERLAPPED_WINDOW();

    var window_handle: w.HWND = undefined;
    if (w.CreateWindowExW(.{}, window_class.lpszClassName, W("Vulkan test"), style, 0, 0, 800, 600, null, null, instance, null)) |handle| {
        window_handle = handle;
    } else {
        try w.report_error();
    }

    _ = w.ShowWindow(window_handle, @bitCast(cmd_show));
    _ = w.ShowWindow(window_handle, .{ .SHOWNORMAL = 1 });

    var msg: w.MSG = undefined;

    running: while (true) {
        while (w.PeekMessageW(&msg, null, 0, 0, .{ .REMOVE = 1 }) == w.TRUE) {
            _ = w.TranslateMessage(&msg);
            _ = w.DispatchMessageW(&msg);

            if (msg.message == w.WM_QUIT) break :running;
        }
    }

    w.DestroyWindow(window_handle);
}

fn window_proc(hwnd: ?w.HWND, uMsg: u32, wParam: w.WPARAM, lParam: w.LPARAM) callconv(.C) isize {
    switch (uMsg) {
        w.WM_DESTROY => {
            w.PostQuitMessage(0);
            return 0;
        },
        else => return w.DefWindowProcW(hwnd, uMsg, wParam, lParam),
    }
}
