const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;
const W = std.unicode.utf8ToUtf16LeStringLiteral;

var gpa_data = std.heap.GeneralPurposeAllocator(.{}).init;
const gpa = gpa_data.allocator();

const w = @import("windows/windows.zig");

pub fn init_system() !void {
    // if (w.AttachConsole(w.ATTACH_PARENT_PROCESS) == 0) {
    //     if (w.CreateFileW(W("nul"), w.GENERIC_READ | w.GENERIC_WRITE, 0, null, w.OPEN_EXISTING, w.FILE_ATTRIBUTE_NORMAL, null)) |nul_handle| {
    //         _ = w.SetStdHandle(w.STD_INPUT_HANDLE, nul_handle);
    //         _ = w.SetStdHandle(w.STD_OUTPUT_HANDLE, nul_handle);
    //         _ = w.SetStdHandle(w.STD_ERROR_HANDLE, nul_handle);
    //     } else {
    //         _ = w.MessageBoxW(null, W("Failed to attach default streams"), W("Error"), w.MB_ICONERROR);
    //         return 1;
    //     }
    // }
}

pub fn deinit_system() void {}

handle: ?w.HWND = null,
close_requested: bool = false,

pub fn create(this: *@This(), _: [:0]const u8) !void {
    var instance: w.HINSTANCE = undefined;
    if (w.GetModuleHandleW(null)) |i_handle| {
        instance = @ptrCast(i_handle);
    } else {
        return error.GetModuleHandle_Failed;
    }

    const window_class = w.WNDCLASSEXW{
        .style = .{},
        .lpfnWndProc = window_proc,
        .hInstance = instance,
        .hbrBackground = @ptrFromInt(0),
        .lpszClassName = W("VKTZ"),
        .hCursor = @ptrCast(w.LoadImageW(null, w.IDC_ARROW, w.IMAGE_CURSOR, 0, 0, w.LR_DEFAULTSIZE | w.LR_SHARED)),
        .hIcon = null,
        .cbWndExtra = @sizeOf(*@This()),
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

    const result = try gpa.create(@This());
    const setval = @intFromPtr(result);
    _ = w.SetWindowLongPtrW(window_handle, 0, setval);

    // _ = w.ShowWindow(window_handle, @bitCast(cmd_show));
    _ = w.ShowWindow(window_handle, .{ .SHOWNORMAL = 1 });

    this.* = .{
        .handle = window_handle,
    };
}

pub fn should_close(this: *const @This()) bool {
    return this.close_requested;
}

pub fn update(_: *@This()) void {
    var msg: w.MSG = undefined;

    while (w.PeekMessageW(&msg, null, 0, 0, .{ .REMOVE = 1 }) == w.TRUE) {
        _ = w.TranslateMessage(&msg);
        _ = w.DispatchMessageW(&msg);

        if (msg.message == w.WM_QUIT) break;
    }
}

pub fn close(this: *@This()) void {
    _ = w.DestroyWindow(this.handle);
}

// pub export fn wWinMain(instance: w.HINSTANCE, prev_instance: ?w.HINSTANCE, cmd_line: w.PWSTR, cmd_show: w.INT) callconv(.C) w.INT {
//     _ = prev_instance;
//     _ = cmd_line;
//
//     if (w.AttachConsole(w.ATTACH_PARENT_PROCESS) == 0) {
//         if (w.CreateFileW(W("nul"), w.GENERIC_READ | w.GENERIC_WRITE, 0, null, w.OPEN_EXISTING, w.FILE_ATTRIBUTE_NORMAL, null)) |nul_handle| {
//             _ = w.SetStdHandle(w.STD_INPUT_HANDLE, nul_handle);
//             _ = w.SetStdHandle(w.STD_OUTPUT_HANDLE, nul_handle);
//             _ = w.SetStdHandle(w.STD_ERROR_HANDLE, nul_handle);
//         } else {
//             _ = w.MessageBoxW(null, W("Failed to attach default streams"), W("Error"), w.MB_ICONERROR);
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

fn window_proc(_hwnd: ?w.HWND, uMsg: u32, wParam: w.WPARAM, lParam: w.LPARAM) callconv(.C) isize {
    const hwnd = _hwnd.?;

    const data_int = w.GetWindowLongPtrW(hwnd, 0);
    if (data_int == 0) {
        // This gets called before the user data can be set
        return w.DefWindowProcW(hwnd, uMsg, wParam, lParam);
    }

    const data: *@This() = @ptrFromInt(data_int);

    switch (uMsg) {
        w.WM_DESTROY => {
            w.PostQuitMessage(0);
            data.close_requested = true;
            return 0;
        },
        else => return w.DefWindowProcW(hwnd, uMsg, wParam, lParam),
    }
}
