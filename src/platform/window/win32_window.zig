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
const Window = platform.Window;
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

handle: win32.HWND = null,
close_requested: bool = false,
title: [MAX_TITLE]u16 = std.mem.zeroes([MAX_TITLE]u16),
new_fb_size: ?win32.POINT = null,

pub fn init(this: *@This(), title_utf8: [:0]const u8) !void {
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

    var title: [MAX_TITLE]u16 = std.mem.zeroes([MAX_TITLE]u16);
    if (try std.unicode.checkUtf8ToUtf16LeOverflow(title_utf8, &title)) {
        elog("Title too long!", .{});
        return error.Title_Too_Long;
    }

    const title_len = try std.unicode.utf8ToUtf16Le(&title, title_utf8);
    if (title_len >= MAX_TITLE) {
        elog("Title too long!", .{});
        return error.Title_Too_Long;
    }
    title[title_len] = 0;

    const style = win32.WINDOW_STYLE.OVERLAPPED_WINDOW();

    var handle: win32.HWND = undefined;
    const handle_opt = win32.CreateWindowExW(.{}, window_class.lpszClassName, @ptrCast(&title), style, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, win32.CW_USEDEFAULT, null, null, instance, null);
    if (handle_opt) |h| {
        handle = h;
    } else try win32.report_error();

    this.* = .{
        .handle = handle,
        .title = title,
        .new_fb_size = null,
    };

    const setval = @intFromPtr(this);
    _ = win32.SetWindowLongPtrW(this.handle, 0, setval);

    // _ = win32.ShowWindow(window_handle, @bitCast(cmd_show));
    _ = win32.ShowWindow(handle, .{ .SHOWNORMAL = 1 });

    this.pollEvents();
}

pub fn shouldClose(this: *const @This()) bool {
    return this.close_requested;
}

pub fn requestClose(this: *@This()) void {
    this.close_requested = true;
    win32.PostQuitMessage(0);
}

pub fn pollEvents(this: *@This()) void {
    var msg: win32.MSG = undefined;

    while (win32.PeekMessageW(&msg, this.handle, 0, 0, .{ .REMOVE = 1 }) == win32.TRUE) {
        _ = win32.TranslateMessage(&msg);
        _ = win32.DispatchMessageW(&msg);

        if (msg.message == win32.WM_QUIT) {
            this.close_requested = true;
            break;
        }
    }

    if (this.new_fb_size) |s| {
        const window: *Window = @fieldParentPtr("impl", this);
        if (window.framebuffer_resize_callback) |cb| {
            cb.fun(window, s.x, s.y, cb.user_data);
        }
        this.new_fb_size = null;
    }
}

pub fn waitEvents(this: *@This()) void {
    _ = win32.WaitMessage();
    this.pollEvents();
}

pub fn deinit(this: *@This()) void {
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

pub fn requiredVulkanInstanceExtensions() ![]const [*:0]const u8 {
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
        return error.NativeCreateSurfaceFailed;
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

fn windowProc(_hwnd: win32.HWND, uMsg: u32, wParam: win32.WPARAM, lParam: win32.LPARAM) callconv(.C) isize {
    const hwnd = _hwnd.?;

    const data_int = win32.GetWindowLongPtrW(hwnd, 0);
    if (data_int == 0) {
        // This gets called before the user data can be set
        return win32.DefWindowProcW(hwnd, uMsg, wParam, lParam);
    }

    const impl: *@This() = @ptrFromInt(data_int);
    const window: *Window = @fieldParentPtr("impl", impl);

    switch (uMsg) {
        win32.WM_SIZE => {
            impl.new_fb_size = .{ .x = win32.LOWORD(lParam), .y = win32.HIWORD(lParam) };
            return 0;
        },
        win32.WM_DESTROY => {
            win32.PostQuitMessage(0);
            impl.close_requested = true;
            return 0;
        },

        win32.WM_KEYDOWN => {
            if (window.key_callback) |cb| {
                const flags: KeyLParam = @bitCast(@as(u32, @intCast(lParam)));

                const action: platform.KeyAction = if (flags.previous_state == 0) .press else .repeat;
                const key = if (wParam < 255) virtualKeyToPlatformKey(@enumFromInt(wParam), flags) else .unknown;

                cb.fun(window, key, action, flags.scan_code, cb.user_data);
            }
            return 0;
        },

        win32.WM_KEYUP => {
            if (window.key_callback) |cb| {
                const flags: KeyLParam = @bitCast(@as(u32, @intCast(lParam)));
                const key = if (wParam < 255) virtualKeyToPlatformKey(@enumFromInt(wParam), flags) else .unknown;

                cb.fun(window, key, .release, flags.scan_code, cb.user_data);
            }
            return 0;
        },

        else => return win32.DefWindowProcW(hwnd, uMsg, wParam, lParam),
    }
}

fn virtualKeyToPlatformKey(vkey: win32.VIRTUAL_KEY, flags: KeyLParam) platform.Key {
    return switch (vkey) {
        .@"0" => .@"0",
        .@"1" => .@"1",
        .@"2" => .@"2",
        .@"3" => .@"3",
        .@"4" => .@"4",
        .@"5" => .@"5",
        .@"6" => .@"6",
        .@"7" => .@"7",
        .@"8" => .@"8",
        .@"9" => .@"9",
        .A => .a,
        .B => .b,
        .C => .c,
        .D => .d,
        .E => .e,
        .F => .f,
        .G => .g,
        .H => .h,
        .I => .i,
        .J => .j,
        .K => .k,
        .L => .l,
        .M => .m,
        .N => .n,
        .O => .o,
        .P => .p,
        .Q => .q,
        .R => .r,
        .S => .s,
        .T => .t,
        .U => .u,
        .V => .v,
        .W => .w,
        .X => .x,
        .Y => .y,
        .Z => .z,
        .LBUTTON => .unknown,
        .RBUTTON => .unknown,
        .CANCEL => .unknown,
        .MBUTTON => .unknown,
        .XBUTTON1 => .unknown,
        .XBUTTON2 => .unknown,
        .BACK => .backspace,
        .TAB => .tab,
        .CLEAR => .unknown,
        .RETURN => .enter,
        .SHIFT => .left_shift,
        .CONTROL => if (flags.extended == 1) .right_control else .left_control,
        .MENU => .menu,
        .PAUSE => .pause,
        .CAPITAL => .caps_lock,
        .KANA => unreachable,
        .IME_ON => unreachable,
        .JUNJA => unreachable,
        .FINAL => unreachable,
        .HANJA => unreachable,
        .IME_OFF => unreachable,
        .ESCAPE => .escape,
        .CONVERT => unreachable,
        .NONCONVERT => unreachable,
        .ACCEPT => unreachable,
        .MODECHANGE => unreachable,
        .SPACE => .space,
        .PRIOR => .page_up,
        .NEXT => .page_down,
        .END => .end,
        .HOME => .home,
        .LEFT => .left,
        .UP => .up,
        .RIGHT => .right,
        .DOWN => .down,
        .SELECT => unreachable,
        .PRINT => .print_screen,
        .EXECUTE => .unknown,
        .SNAPSHOT => .unknown,
        .INSERT => .insert,
        .DELETE => .delete,
        .HELP => .unknown,
        .LWIN => .left_super,
        .RWIN => .right_super,
        .APPS => .menu,
        .SLEEP => .unknown,
        .NUMPAD0 => .kp_0,
        .NUMPAD1 => .kp_1,
        .NUMPAD2 => .kp_2,
        .NUMPAD3 => .kp_3,
        .NUMPAD4 => .kp_4,
        .NUMPAD5 => .kp_5,
        .NUMPAD6 => .kp_6,
        .NUMPAD7 => .kp_7,
        .NUMPAD8 => .kp_8,
        .NUMPAD9 => .kp_9,
        .MULTIPLY => .kp_multiply,
        .ADD => .kp_add,
        .SEPARATOR => .kp_enter,
        .SUBTRACT => .kp_subtract,
        .DECIMAL => .kp_decimal,
        .DIVIDE => .kp_divide,
        .F1 => .f1,
        .F2 => .f2,
        .F3 => .f3,
        .F4 => .f4,
        .F5 => .f5,
        .F6 => .f6,
        .F7 => .f7,
        .F8 => .f8,
        .F9 => .f9,
        .F10 => .f10,
        .F11 => .f11,
        .F12 => .f12,
        .F13 => .f13,
        .F14 => .f14,
        .F15 => .f15,
        .F16 => .f16,
        .F17 => .f17,
        .F18 => .f18,
        .F19 => .f19,
        .F20 => .f20,
        .F21 => .f21,
        .F22 => .f22,
        .F23 => .f23,
        .F24 => .f24,
        .NAVIGATION_VIEW => .unknown,
        .NAVIGATION_MENU => .unknown,
        .NAVIGATION_UP => .unknown,
        .NAVIGATION_DOWN => .unknown,
        .NAVIGATION_LEFT => .unknown,
        .NAVIGATION_RIGHT => .unknown,
        .NAVIGATION_ACCEPT => .unknown,
        .NAVIGATION_CANCEL => .unknown,
        .NUMLOCK => .num_lock,
        .SCROLL => .scroll_lock,
        .OEM_NEC_EQUAL => .kp_equal,
        .OEM_FJ_MASSHOU => .unknown,
        .OEM_FJ_TOUROKU => .unknown,
        .OEM_FJ_LOYA => .unknown,
        .OEM_FJ_ROYA => .unknown,
        .LSHIFT => .left_shift,
        .RSHIFT => .right_shift,
        .LCONTROL => .left_control,
        .RCONTROL => .right_control,
        .LMENU => .menu,
        .RMENU => .menu,
        .BROWSER_BACK => .unknown,
        .BROWSER_FORWARD => .unknown,
        .BROWSER_REFRESH => .unknown,
        .BROWSER_STOP => .unknown,
        .BROWSER_SEARCH => .unknown,
        .BROWSER_FAVORITES => .unknown,
        .BROWSER_HOME => .unknown,
        .VOLUME_MUTE => .unknown,
        .VOLUME_DOWN => .unknown,
        .VOLUME_UP => .unknown,
        .MEDIA_NEXT_TRACK => .unknown,
        .MEDIA_PREV_TRACK => .unknown,
        .MEDIA_STOP => .unknown,
        .MEDIA_PLAY_PAUSE => .unknown,
        .LAUNCH_MAIL => .unknown,
        .LAUNCH_MEDIA_SELECT => .unknown,
        .LAUNCH_APP1 => .unknown,
        .LAUNCH_APP2 => .unknown,
        .OEM_1 => .semicolon,
        .OEM_PLUS => .equal,
        .OEM_COMMA => .comma,
        .OEM_MINUS => .minus,
        .OEM_PERIOD => .period,
        .OEM_2 => .slash,
        .OEM_3 => .grave_accent,
        .GAMEPAD_A => .unknown,
        .GAMEPAD_B => .unknown,
        .GAMEPAD_X => .unknown,
        .GAMEPAD_Y => .unknown,
        .GAMEPAD_RIGHT_SHOULDER => .unknown,
        .GAMEPAD_LEFT_SHOULDER => .unknown,
        .GAMEPAD_LEFT_TRIGGER => .unknown,
        .GAMEPAD_RIGHT_TRIGGER => .unknown,
        .GAMEPAD_DPAD_UP => .unknown,
        .GAMEPAD_DPAD_DOWN => .unknown,
        .GAMEPAD_DPAD_LEFT => .unknown,
        .GAMEPAD_DPAD_RIGHT => .unknown,
        .GAMEPAD_MENU => .unknown,
        .GAMEPAD_VIEW => .unknown,
        .GAMEPAD_LEFT_THUMBSTICK_BUTTON => .unknown,
        .GAMEPAD_RIGHT_THUMBSTICK_BUTTON => .unknown,
        .GAMEPAD_LEFT_THUMBSTICK_UP => .unknown,
        .GAMEPAD_LEFT_THUMBSTICK_DOWN => .unknown,
        .GAMEPAD_LEFT_THUMBSTICK_RIGHT => .unknown,
        .GAMEPAD_LEFT_THUMBSTICK_LEFT => .unknown,
        .GAMEPAD_RIGHT_THUMBSTICK_UP => .unknown,
        .GAMEPAD_RIGHT_THUMBSTICK_DOWN => .unknown,
        .GAMEPAD_RIGHT_THUMBSTICK_RIGHT => .unknown,
        .GAMEPAD_RIGHT_THUMBSTICK_LEFT => .unknown,
        .OEM_4 => .left_bracket,
        .OEM_5 => .backslash,
        .OEM_6 => .right_bracket,
        .OEM_7 => .apostrophe,
        .OEM_8 => .unknown,
        .OEM_AX => .unknown,
        .OEM_102 => .unknown,
        .ICO_HELP => .unknown,
        .ICO_00 => .unknown,
        .PROCESSKEY => .unknown,
        .ICO_CLEAR => .unknown,
        .PACKET => .unknown,
        .OEM_RESET => .unknown,
        .OEM_JUMP => .unknown,
        .OEM_PA1 => .unknown,
        .OEM_PA2 => .unknown,
        .OEM_PA3 => .unknown,
        .OEM_WSCTRL => .unknown,
        .OEM_CUSEL => .unknown,
        .OEM_ATTN => .unknown,
        .OEM_FINISH => .unknown,
        .OEM_COPY => .unknown,
        .OEM_AUTO => .unknown,
        .OEM_ENLW => .unknown,
        .OEM_BACKTAB => .unknown,
        .ATTN => .unknown,
        .CRSEL => .unknown,
        .EXSEL => .unknown,
        .EREOF => .unknown,
        .PLAY => .unknown,
        .ZOOM => .unknown,
        .NONAME => .unknown,
        .PA1 => .unknown,
        .OEM_CLEAR => .unknown,
    };
}
