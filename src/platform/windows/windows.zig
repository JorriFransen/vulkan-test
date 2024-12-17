const std = @import("std");
const assert = std.debug.assert;
const ccast = std.zig.c_translation.cast;
const zeroinit = std.mem.zeroes;

const builtin = @import("builtin");

pub usingnamespace @import("messages.zig");
pub usingnamespace @import("keys.zig");

pub const WORD = u16;
pub const DWORD = u32;
pub const CHAR = u8;
pub const WCHAR = u16;
pub const INT = c_int;
pub const UINT = c_uint;
pub const SIZE_T = usize;
pub const BOOL = i32;
pub const LONG_PTR = u64;
pub const COLORREF = DWORD;
pub const BYTE = u8;
pub const LONG = c_long;
pub const ULONG = c_ulong;

pub const LANGID = u16;

pub const LPCSTR = [*:0]const CHAR;
pub const PWSTR = [*:0]WCHAR;
pub const PCWSTR = [*:0]const WCHAR;
pub const LPWSTR = [*:0]WCHAR;
pub const LPCWSTR = [*:0]const WCHAR;
pub const LPCVOID = *const anyopaque;
pub const LPVOID = *anyopaque;
pub const ResourceNamePtrW = [*:0]align(1) const WCHAR;

pub const HMODULE = *align(4) opaque {};
pub const HANDLE = *align(4) opaque {};
pub const HINSTANCE = *align(4) opaque {};
pub const HWND = *align(4) opaque {};
pub const HDC = *opaque {};
pub const HGLRC = *opaque {};
pub const HICON = *opaque {};
pub const HCURSOR = HICON;
pub const HBRUSH = *opaque {};
pub const HMENU = *opaque {};
pub const HRESULT = i32;
pub const HGDIOBJ = *opaque {};
pub const HRGN = HGDIOBJ;
pub const va_list = *opaque {};

pub const WPARAM = usize;
pub const LPARAM = isize;
pub const LRESULT = isize;

pub const PROC = *const fn () callconv(.C) isize;
pub const FARPROC = PROC;
pub const WNDPROC = *const fn (p0: ?HWND, p1: u32, p2: WPARAM, p3: LPARAM) callconv(.C) LRESULT;

pub const TRUE: BOOL = 1;
pub const FALSE: BOOL = 0;
pub const FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
pub const FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200;
pub const LANG_NEUTRAL = 0;
pub const SUBLANG_DEFAULT = 1;
pub const CW_USEDEFAULT = @as(i32, -2147483648);

pub const FILE_MAP_WRITE = FILE_MAP{ .WRITE = 1 };
pub const FILE_MAP_READ = FILE_MAP{ .READ = 1 };
pub const FILE_MAP_ALL_ACCESS = FILE_MAP{ .COPY = 1, .WRITE = 1, .READ = 1, ._3 = 1, ._4 = 1, ._16 = 1, ._17 = 1, ._18 = 1, ._19 = 1 };

pub const FILE_MAP_EXECUTE = FILE_MAP{ .EXECUTE = 1 };
pub const FILE_MAP_COPY = FILE_MAP{ .COPY = 1 };
pub const FILE_MAP_RESERVE = FILE_MAP{ .RESERVE = 1 };
pub const FILE_MAP_TARGETS_INVALID = FILE_MAP{ .TARGETS_INVALID = 1 };
pub const FILE_MAP_LARGE_PAGES = FILE_MAP{ .LARGE_PAGES = 1 };
pub const SYNCHRONIZE: DWORD = 0x00100000;

pub const COLOR_WINDOW = SYS_COLOR_INDEX.WINDOW;

pub const S_OK: HRESULT = 0x00000000;
pub const E_ABORT: HRESULT = 0x80004004;
pub const E_ACCESSDENIED: HRESULT = 0x80070005;
pub const E_FAIL: HRESULT = 0x80004005;
pub const E_HANDLE: HRESULT = 0x80070006;
pub const E_INVALIDARG: HRESULT = 0x80070057;
pub const E_NOINTERFACE: HRESULT = 0x80004002;
pub const E_NOTIMPL: HRESULT = 0x80004001;
pub const E_OUTOFMEMORY: HRESULT = 0x8007000E;
pub const E_POINTER: HRESULT = 0x80004003;
pub const E_UNEXPECTED: HRESULT = 0x8000FFFF;

pub const IDC_ARROW = ccast(LPCWSTR, 32512);
pub const IDC_IBEAM = ccast(LPCWSTR, 32513);
pub const IDC_WAIT = ccast(LPCWSTR, 32514);
pub const IDC_CROSS = ccast(LPCWSTR, 32515);
pub const IDC_UPARROW = ccast(LPCWSTR, 32516);
pub const IDC_SIZEWSE = ccast(LPCWSTR, 32642);
pub const IDC_SIZEESW = ccast(LPCWSTR, 32643);
pub const IDC_SIZEWE = ccast(LPCWSTR, 32644);
pub const IDC_SIZENS = ccast(ResourceNamePtrW, 32645);
pub const IDC_SIZEALL = ccast(LPCWSTR, 32646);
pub const IDC_NO = ccast(LPCWSTR, 32648);
pub const IDC_HAND = ccast(LPCWSTR, 32649);
pub const IDC_APPSTARTING = ccast(LPCWSTR, 32650);
pub const IDC_HELP = ccast(LPCWSTR, 32650);
pub const IDC_PIN = ccast(LPCWSTR, 32671);
pub const IDC_PERSON = ccast(LPCWSTR, 32762);

pub const DWM_BB_ENABLE: u32 = 1;
pub const DWM_BB_BLURREGION: u32 = 2;

pub const GWL_EXSTYLE: c_int = -20;
pub const HTNOWHERE = 0;

pub const NIM_ADD: DWORD = 0x00;
pub const NIM_MODIFY: DWORD = 0x01;
pub const NIM_DELETE: DWORD = 0x02;
pub const NIM_SETFOCUS: DWORD = 0x03;
pub const NIM_SETVERSION: DWORD = 0x04;

pub const NIF_MESSAGE: UINT = 0x001;
pub const NIF_ICON: UINT = 0x002;
pub const NIF_TIP: UINT = 0x004;
pub const NIF_STATE: UINT = 0x008;
pub const NIF_INFO: UINT = 0x010;
pub const NIF_GUID: UINT = 0x020;
pub const NIF_REALTIME: UINT = 0x040;
pub const NIF_SHOWTIP: UINT = 0x080;

pub const NOTIFYICON_VERSION_4 = 4;

pub const IDI_APPLICATION = 32512;
pub const IDI_ERROR = 32513;
pub const IDI_QUESTION = 32514;
pub const IDI_WARNING = 32515;
pub const IDI_INFORMATION = 32516;
pub const IDI_WINLOGO = 32517;
pub const IDI_SHIELD = 32518;

pub const IMAGE_BITMAP: u32 = 0;
pub const IMAGE_CURSOR: u32 = 2;
pub const IMAGE_ICON: u32 = 1;

pub const LR_CREATEDIBSECTION: UINT = 0x00002000;
pub const LR_DEFAULTCOLOR: UINT = 0x00000000;
pub const LR_DEFAULTSIZE: UINT = 0x00000040;
pub const LR_LOADFROMFILE: UINT = 0x00000010;
pub const LR_LOADMAP3DCOLORS: UINT = 0x00001000;
pub const LR_LOADTRANSPARENT: UINT = 0x00000020;
pub const LR_MONOCHROME: UINT = 0x00000001;
pub const LR_SHARED: UINT = 0x00008000;
pub const LR_VGACOLOR: UINT = 0x00000080;

pub const TPM_LEFTALIGN = 0x0000;
pub const TPM_TOPALIGN = 0x0000;
pub const TPM_CENTERALIGN = 0x0004;
pub const TPM_RIGHTALIGN = 0x0008;
pub const TPM_VCENTERALIGN = 0x0010;
pub const TPM_BOTTOMALIGN = 0x0020;
pub const TPM_NONOTIFY = 0x0080;
pub const TPM_RETURNCMD = 0x0100;
pub const TPM_LEFTBUTTON = 0x0000;
pub const TPM_RIGHTBUTTON = 0x0002;
pub const TPM_HORNEGANIMATION = 0x0800;
pub const TPM_HORPOSANIMATION = 0x0400;
pub const TPM_NOANIMATION = 0x4000;
pub const TPM_VERNEGANIMATION = 0x2000;
pub const TPM_VERPOSANIMATION = 0x1000;

pub const MB_ABORTRETRYIGNORE = 0x00000002; // The message box contains three push buttons: Abort, Retry, and Ignore.
pub const MB_CANCELTRYCONTINUE = 0x00000006; // The message box contains three push buttons: Cancel, Try Again, Continue. Use this message box type instead of MB_ABORTRETRYIGNORE.
pub const MB_HELP = 0x00004000; // Adds a Help button to the message box. When the user clicks the Help button or presses F1, the system sends a WM_HELP message to the owner.
pub const MB_OK = 0x00000000; // The message box contains one push button: OK. This is the default.
pub const MB_OKCANCEL = 0x00000001; // The message box contains two push buttons: OK and Cancel.
pub const MB_RETRYCANCEL = 0x00000005; // The message box contains two push buttons: Retry and Cancel.
pub const MB_YESNO = 0x00000004; // The message box contains two push buttons: Yes and No.
pub const MB_YESNOCANCEL = 0x00000003; // The message box contains three push buttons: Yes, No, and Cancel.
pub const MB_ICONEXCLAMATION = 0x00000030; // An exclamation-point icon appears in the message box.
pub const MB_ICONWARNING = 0x00000030; // An exclamation-point icon appears in the message box.
pub const MB_ICONINFORMATION = 0x00000040; // An icon consisting of a lowercase letter i in a circle appears in the message box.
pub const MB_ICONASTERISK = 0x00000040; // An icon consisting of a lowercase letter i in a circle appears in the message box.
pub const MB_ICONQUESTION = 0x00000020; // A question-mark icon appears in the message box. The question-mark message icon is no longer recommended because it does not clearly represent a specific type of message and because the phrasing of a message as a question could apply to any message type. In addition, users can confuse the message symbol question mark with Help information. Therefore, do not use this question mark message symbol in your message boxes. The system continues to support its inclusion only for backward compatibility.
pub const MB_ICONSTOP = 0x00000010; // A stop-sign icon appears in the message box.
pub const MB_ICONERROR = 0x00000010; // A stop-sign icon appears in the message box.
pub const MB_ICONHAND = 0x00000010; // A stop-sign icon appears in the message box.
pub const MB_DEFBUTTON1 = 0x00000000; // The first button is the default button. MB_DEFBUTTON1 is the default unless MB_DEFBUTTON2, MB_DEFBUTTON3, or MB_DEFBUTTON4 is specified.
pub const MB_DEFBUTTON2 = 0x00000100; // The second button is the default button.
pub const MB_DEFBUTTON3 = 0x00000200; // The third button is the default button.
pub const MB_DEFBUTTON4 = 0x00000300; // The fourth button is the default button.
pub const MB_APPLMODAL = 0x00000000; // The user must respond to the message box before continuing work in the window identified by the hWnd parameter. However, the user can move to the windows of other threads and work in those windows. Depending on the hierarchy of windows in the application, the user may be able to move to other windows within the thread. All child windows of the parent of the message box are automatically disabled, but pop-up windows are not. MB_APPLMODAL is the default if neither MB_SYSTEMMODAL nor MB_TASKMODAL is specified.
pub const MB_SYSTEMMODAL = 0x00001000; // Same as MB_APPLMODAL except that the message box has the WS_EX_TOPMOST style. Use system-modal message boxes to notify the user of serious, potentially damaging errors that require immediate attention (for example, running out of memory). This flag has no effect on the user's ability to interact with windows other than those associated with hWnd.
pub const MB_TASKMODAL = 0x00002000; // Same as MB_APPLMODAL except that all the top-level windows belonging to the current thread are disabled if the hWnd parameter is NULL. Use this flag when the calling application or library does not have a window handle available but still needs to prevent input to other windows in the calling thread without suspending other threads.
pub const MB_DEFAULT_DESKTOP_ONLY = 0x00020000; // Same as desktop of the interactive window station. For more information, see Window Stations. If the current input desktop is not the default desktop, MessageBox does not return until the user switches to the default desktop.
pub const MB_RIGHT = 0x00080000; // The text is right-justified.
pub const MB_RTLREADING = 0x00100000; // Displays message and caption text using right-to-left reading order on Hebrew and Arabic systems.
pub const MB_SETFOREGROUND = 0x00010000; // The message box becomes the foreground window. Internally, the system calls the SetForegroundWindow function for the message box.
pub const MB_TOPMOST = 0x00040000; // The message box is created with the WS_EX_TOPMOST window style.
pub const MB_SERVICE_NOTIFICATION = 0x00200000; // The caller is a service notifying the user of an event. The function displays a message box on the current active desktop, even if there is no user logged on to the computer. Terminal Services: If the calling thread has an impersonation token, the function directs the message box to the session specified in the impersonation token. If this flag is set, the hWnd parameter must be NULL. This is so that the message box can appear on a desktop other than the desktop corresponding to the hWnd. For information on security considerations in regard to using this flag, see Interactive Services. In particular, be aware that this flag can produce interactive content on a locked desktop and should therefore be used for only a very limited set of scenarios, such as resource exhaustion.

pub const IDABORT = 3; // The Abort button was selected.
pub const IDCANCEL = 2; // The Cancel button was selected.
pub const IDCONTINUE = 11; // The Continue button was selected.
pub const IDIGNORE = 5; // The Ignore button was selected.
pub const IDNO = 7; // The No button was selected.
pub const IDOK = 1; // The OK button was selected.
pub const IDRETRY = 4; // The Retry button was selected.
pub const IDTRYAGAIN = 10; // The Try Again button was selected.
pub const IDYES = 6; // The Yes button was selected.

pub const HWND_BOTTOM = ccast(HWND, 1); // Places the window at the bottom of the Z order. If the hWnd parameter identifies a topmost window, the window loses its topmost status and is placed at the bottom of all other windows.
pub const HWND_NOTOPMOST = ccast(HWND, -2); // Places the window above all non-topmost windows (that is, behind all topmost windows). This flag has no effect if the window is already a non-topmost window.
pub const HWND_TOP = ccast(HWND, 0); // Places the window at the top of the Z order.
pub const HWND_TOPMOST = ccast(HWND, -1); // Places the window above all non-topmost windows. The window maintains its topmost position even when it is deactivated.

pub const MF_BYCOMMAND = 0x00000000; // Indicates that the uPosition parameter gives the identifier of the menu item. The MF_BYCOMMAND flag is the default if neither the MF_BYCOMMAND nor MF_BYPOSITION flag is specified.
pub const MF_BYPOSITION = 0x00000400; // Indicates that the uPosition parameter gives the zero-based relative position of the menu item.
pub const MF_BITMAP = 0x00000004; // Uses a bitmap as the menu item. The lpNewItem parameter contains a handle to the bitmap.
pub const MF_CHECKED = 0x00000008; // Places a check mark next to the item. If your application provides check-mark bitmaps (see the SetMenuItemBitmaps function), this flag displays a selected bitmap next to the menu item.
pub const MF_DISABLED = 0x00000002; // Disables the menu item so that it cannot be selected, but this flag does not gray it.
pub const MF_ENABLED = 0x00000000; // Enables the menu item so that it can be selected and restores it from its grayed state.
pub const MF_GRAYED = 0x00000001; // Disables the menu item and grays it so that it cannot be selected.
pub const MF_MENUBARBREAK = 0x00000020; // Functions the same as the MF_MENUBREAK flag for a menu bar. For a drop-down menu, submenu, or shortcut menu, the new column is separated from the old column by a vertical line.
pub const MF_MENUBREAK = 0x00000040; // Places the item on a new line (for menu bars) or in a new column (for a drop-down menu, submenu, or shortcut menu) without separating columns.
pub const MF_OWNERDRAW = 0x00000100; // Specifies that the item is an owner-drawn item. Before the menu is displayed for the first time, the window that owns the menu receives a WM_MEASUREITEM message to retrieve the width and height of the menu item. The WM_DRAWITEM message is then sent to the window procedure of the owner window whenever the appearance of the menu item must be updated.
pub const MF_POPUP = 0x00000010; // Specifies that the menu item opens a drop-down menu or submenu. The uIDNewItem parameter specifies a handle to the drop-down menu or submenu. This flag is used to add a menu name to a menu bar or a menu item that opens a submenu to a drop-down menu, submenu, or shortcut menu.
pub const MF_SEPARATOR = 0x00000800; // Draws a horizontal dividing line. This flag is used only in a drop-down menu, submenu, or shortcut menu. The line cannot be grayed, disabled, or highlighted. The lpNewItem and uIDNewItem parameters are ignored.
pub const MF_STRING = 0x00000000; // Specifies that the menu item is a text string; the lpNewItem parameter is a pointer to the string.
pub const MF_UNCHECKED = 0x00000000; // Does not place a check mark next to the item (the default). If your application supplies check-mark bitmaps (see the SetMenuItemBitmaps function), this flag displays a clear bitmap next to the menu item.

pub const LWA_ALPHA = 0x00000002; // Use bAlpha to determine the opacity of the layered window.
pub const LWA_COLORKEY = 0x00000001; // Use crKey as the transparency color.

pub const MOD_ALT = 0x0001; // Either ALT key must be held down.
pub const MOD_CONTROL = 0x0002; // Either CTRL key must be held down.
pub const MOD_NOREPEAT = 0x4000; // Changes the hotkey behavior so that the keyboard auto-repeat does not yield multiple hotkey notifications. Windows Vista: This flag is not supported.
pub const MOD_SHIFT = 0x0004; // Either SHIFT key must be held down.
pub const MOD_WIN = 0x0008; // Either WINDOWS key must be held down. These keys are labeled with the Windows logo. Keyboard shortcuts that involve the WINDOWS key are reserved for use by the operating system.

pub const ATTACH_PARENT_PROCESS: DWORD = @bitCast(@as(i32, -1));

pub const GENERIC_ALL = 0x10000000; // All possible access rights
pub const GENERIC_EXECUTE = 0x20000000; // Execute access
pub const GENERIC_WRITE = 0x40000000; // Write access
pub const GENERIC_READ = 0x80000000; // Read access

pub const CREATE_ALWAYS = 2; // Creates a new file, always. If the specified file exists and is writable, the function truncates the file, the function succeeds, and last-error code is set to ERROR_ALREADY_EXISTS (183). If the specified file does not exist and is a valid path, a new file is created, the function succeeds, and the last-error code is set to zero. For more information, see the Remarks section of this topic.
pub const CREATE_NEW = 1; // Creates a new file, only if it does not already exist. If the specified file exists, the function fails and the last-error code is set to ERROR_FILE_EXISTS (80). If the specified file does not exist and is a valid path to a writable location, a new file is created.
pub const OPEN_ALWAYS = 4; // Opens a file, always. If the specified file exists, the function succeeds and the last-error code is set to ERROR_ALREADY_EXISTS (183). If the specified file does not exist and is a valid path to a writable location, the function creates a file and the last-error code is set to zero.
pub const OPEN_EXISTING = 3; // Opens a file or device, only if it exists. If the specified file or device does not exist, the function fails and the last-error code is set to ERROR_FILE_NOT_FOUND (2). For more information about devices, see the Remarks section.
pub const TRUNCATE_EXISTING = 5; // Opens a file and truncates it so that its size is zero bytes, only if it exists. If the specified file does not exist, the function fails and the last-error code is set to ERROR_FILE_NOT_FOUND (2). The calling process must open the file with the GENERIC_WRITE bit set as part of the dwDesiredAccess parameter.

pub const STD_INPUT_HANDLE: DWORD = @bitCast(@as(i32, -10)); // The standard input device. Initially, this is the console input buffer, CONIN$.
pub const STD_OUTPUT_HANDLE: DWORD = @bitCast(@as(i32, -11)); // The standard output device. Initially, this is the active console screen buffer, CONOUT$.
pub const STD_ERROR_HANDLE: DWORD = @bitCast(@as(i32, -12)); // The standard error device. Initially, this is the active console screen buffer, CONOUT$.

pub const MAX_PATH = 256;

pub const INVALID_FILE_ATTRIBUTES: DWORD = @bitCast(@as(i32, -1));
pub const FILE_ATTRIBUTE_READONLY: DWORD = 1; // (0x00000001) A file that is read-only. Applications can read the file, but cannot write to it or delete it. This attribute is not honored on directories. For more information, see You cannot view or change the Read-only or the System attributes of folders in Windows Server 2003, in Windows XP, in Windows Vista or in Windows 7.
pub const FILE_ATTRIBUTE_HIDDEN: DWORD = 2; // (0x00000002) The file or directory is hidden. It is not included in an ordinary directory listing.
pub const FILE_ATTRIBUTE_SYSTEM: DWORD = 4; // (0x00000004) A file or directory that the operating system uses a part of, or uses exclusively.
pub const FILE_ATTRIBUTE_DIRECTORY: DWORD = 16; // (0x00000010) The handle that identifies a directory.
pub const FILE_ATTRIBUTE_ARCHIVE: DWORD = 32; // (0x00000020) A file or directory that is an archive file or directory. Applications typically use this attribute to mark files for backup or removal.
pub const FILE_ATTRIBUTE_DEVICE: DWORD = 64; // (0x00000040) This value is reserved for system use.
pub const FILE_ATTRIBUTE_NORMAL: DWORD = 128; // (0x00000080) A file that does not have other attributes set. This attribute is valid only when used alone.
pub const FILE_ATTRIBUTE_TEMPORARY: DWORD = 256; // (0x00000100) A file that is being used for temporary storage. File systems avoid writing data back to mass storage if sufficient cache memory is available, because typically, an application deletes a temporary file after the handle is closed. In that scenario, the system can entirely avoid writing the data. Otherwise, the data is written after the handle is closed.
pub const FILE_ATTRIBUTE_SPARSE_FILE: DWORD = 512; // (0x00000200) A file that is a sparse file.
pub const FILE_ATTRIBUTE_REPARSE_POINT: DWORD = 1024; // (0x00000400) A file or directory that has an associated reparse point, or a file that is a symbolic link.
pub const FILE_ATTRIBUTE_COMPRESSED: DWORD = 2048; // (0x00000800) A file or directory that is compressed. For a file, all of the data in the file is compressed. For a directory, compression is the default for newly created files and subdirectories.
pub const FILE_ATTRIBUTE_OFFLINE: DWORD = 4096; // (0x00001000) The data of a file is not available immediately. This attribute indicates that the file data is physically moved to offline storage. This attribute is used by Remote Storage, which is the hierarchical storage management software. Applications should not arbitrarily change this attribute.
pub const FILE_ATTRIBUTE_NOT_CONTENT_INDEXED: DWORD = 8192; // (0x00002000) The file or directory is not to be indexed by the content indexing service.
pub const FILE_ATTRIBUTE_ENCRYPTED: DWORD = 16384; // (0x00004000) A file or directory that is encrypted. For a file, all data streams in the file are encrypted. For a directory, encryption is the default for newly created files and subdirectories.
pub const FILE_ATTRIBUTE_INTEGRITY_STREAM: DWORD = 32768; // (0x00008000) The directory or user data stream is configured with integrity (only supported on ReFS volumes). It is not included in an ordinary directory listing. The integrity setting persists with the file if it's renamed. If a file is copied the destination file will have integrity set if either the source file or destination directory have integrity set.
pub const FILE_ATTRIBUTE_VIRTUAL: DWORD = 65536; // (0x00010000) This value is reserved for system use.
pub const FILE_ATTRIBUTE_NO_SCRUB_DATA: DWORD = 131072; // (0x00020000) The user data stream not to be read by the background data integrity scanner (AKA scrubber). When set on a directory it only provides inheritance. This flag is only supported on Storage Spaces and ReFS volumes. It is not included in an ordinary directory listing.

pub const FILE_ATTRIBUTE_EA: DWORD = 262144; // (0x00040000) A file or directory with extended attributes. IMPORTANT: This constant is for internal use only.
pub const FILE_ATTRIBUTE_PINNED: DWORD = 524288; // (0x00080000) This attribute indicates user intent that the file or directory should be kept fully present locally even when not being actively accessed. This attribute is for use with hierarchical storage management software.
pub const FILE_ATTRIBUTE_UNPINNED: DWORD = 1048576; // (0x00100000) This attribute indicates that the file or directory should not be kept fully present locally except when being actively accessed. This attribute is for use with hierarchical storage management software.
pub const FILE_ATTRIBUTE_RECALL_ON_OPEN: DWORD = 262144; // (0x00040000) This attribute only appears in directory enumeration classes (FILE_DIRECTORY_INFORMATION, FILE_BOTH_DIR_INFORMATION, etc.). When this attribute is set, it means that the file or directory has no physical representation on the local system; the item is virtual. Opening the item will be more expensive than normal, e.g. it will cause at least some of it to be fetched from a remote store.
pub const FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS: DWORD = 4194304; // (0x00400000) When this attribute is set, it means that the file or directory is not fully present locally. For a file that means that not all of its data is on local storage (e.g. it may be sparse with some data still in remote storage). For a directory it means that some of the directory contents are being virtualized from another location. Reading the file / enumerating the directory will be more expensive than normal, e.g. it will cause at least some of the file/directory content to be fetched from a remote store. Only kernel-mode callers can set this bit. File system mini filters below the 180000 – 189999 altitude range (FSFilter HSM Load Order Group) must not issue targeted cached reads or writes to files that have this attribute set. This could lead to cache pollution and potential file corruption. For more information, see Handling placeholders.

//0 0x00000000 Prevents other processes from opening a file or device if they request delete, read, or write access.
pub const FILE_SHARE_DELETE = 0x00000004; // Enables subsequent open operations on a file or device to request delete access. Otherwise, other processes cannot open the file or device if they request delete access. If this flag is not specified, but the file or device has been opened for delete access, the function fails. Note  Delete access allows both delete and rename operations.
pub const FILE_SHARE_READ = 0x00000001; // Enables subsequent open operations on a file or device to request read access. Otherwise, other processes cannot open the file or device if they request read access. If this flag is not specified, but the file or device has been opened for read access, the function fails.
pub const FILE_SHARE_WRITE = 0x00000002; // Enables subsequent open operations on a file or device to request write access. Otherwise, other processes cannot open the file or device if they request write access. If this flag is not specified, but the file or device has been opened for write access or has a file mapping with write access, the function fails.

pub extern "kernel32" fn CloseHandle(hObject: ?HANDLE) callconv(.C) BOOL;
pub extern "kernel32" fn LoadLibraryW(lpLibFileName: ?LPCWSTR) callconv(.C) ?HMODULE;
pub extern "kernel32" fn FreeLibrary(hLibModule: ?HMODULE) callconv(.C) BOOL;
pub extern "kernel32" fn GetProcAddress(hModule: ?HMODULE, lpProcName: ?LPCSTR) callconv(.C) ?FARPROC;
pub extern "kernel32" fn OpenFileMappingW(dwDesiredAccess: FILE_MAP, bInheritHandle: BOOL, lpName: ?LPCWSTR) callconv(.C) ?HANDLE;
pub extern "kernel32" fn MapViewOfFile(hFileMappingObject: ?HANDLE, dwDesiredAccess: FILE_MAP, dwFileOffsetHigh: DWORD, dwFileOffsetLow: DWORD, dwNumberOfBytesToMap: SIZE_T) callconv(.C) ?*anyopaque;
pub extern "kernel32" fn UnmapViewOfFile(lpBaseAddress: ?*const anyopaque) callconv(.C) BOOL;
pub extern "kernel32" fn OpenEventW(dwDesiredAccess: DWORD, bInheritHandle: BOOL, lpName: ?LPCWSTR) callconv(.C) ?HANDLE;
pub extern "kernel32" fn FormatMessageW(dwFlags: DWORD, lpSource: ?LPCVOID, dwMessageId: DWORD, dwLanguageId: DWORD, lpBuffer: LPWSTR, nSize: DWORD, Arguments: ?*va_list) callconv(.C) DWORD;
pub extern "kernel32" fn QueryPerformanceFrequency(lpFrequency: *i64) callconv(.C) BOOL;
pub extern "kernel32" fn QueryPerformanceCounter(lpPerformanceCount: *i64) callconv(.C) BOOL;
pub extern "kernel32" fn Sleep(dwMilliseconds: DWORD) callconv(.C) void;
pub extern "kernel32" fn AttachConsole(dwProcessId: DWORD) callconv(.C) BOOL;
pub extern "kernel32" fn CreateFileW(lpFileName: LPCWSTR, dwDesiredAccess: DWORD, dwShareMode: DWORD, lpSecurityAttributes: ?*SECURITY_ATTRIBUTES, dwCreationDisposition: DWORD, dwFlagsAndAttributes: DWORD, hTemplateFile: ?HANDLE) callconv(.C) ?HANDLE;
pub extern "kernel32" fn SetStdHandle(nStdHandle: DWORD, hHandle: HANDLE) callconv(.C) BOOL;
pub extern "kernel32" fn GetPrivateProfileStringW(lpAppName: LPCWSTR, lpKeyName: LPCWSTR, lpDefault: LPCWSTR, lpReturnedString: LPWSTR, nSize: DWORD, lpFileName: LPCWSTR) callconv(.C) DWORD;
pub extern "kernel32" fn WritePrivateProfileStringW(lpAppName: LPCWSTR, lpKeyName: LPCWSTR, lpString: LPCWSTR, lpFileName: LPCWSTR) callconv(.C) BOOL;
pub extern "kernel32" fn GetFullPathNameW(lpFileName: LPCWSTR, nBufferLength: DWORD, lpBuffer: LPWSTR, lpFilePart: ?*LPWSTR) callconv(.C) DWORD;
pub extern "kernel32" fn GetModuleHandleW(lpModuleName: ?LPCWSTR) callconv(.C) ?HMODULE;
pub extern "user32" fn DefWindowProcW(hHwnd: ?HWND, Msg: u32, wParam: WPARAM, lParam: LPARAM) callconv(.C) LRESULT;
pub extern "user32" fn GetLastError() callconv(.C) DWORD;
pub extern "user32" fn SetLastError(dwErrCode: DWORD) callconv(.C) void;
pub extern "user32" fn RegisterClassW(lpWndClass: ?*const WNDCLASSW) callconv(.C) u16;
pub extern "user32" fn RegisterClassExW(param0: ?*const WNDCLASSEXW) callconv(.C) u16;
pub extern "user32" fn CreateWindowExW(dwExStyle: WINDOW_EX_STYLE, lpClassName: ?LPCWSTR, lpWindowName: ?LPCWSTR, dwStyle: WINDOW_STYLE, X: i32, Y: i32, nWidth: i32, nHeight: i32, hWndParent: ?HWND, hMenu: ?HMENU, hInstance: ?HINSTANCE, lpParam: ?*anyopaque) callconv(.C) ?HWND;
pub extern "user32" fn DestroyWindow(hWnd: ?HWND) callconv(.C) BOOL;
pub extern "user32" fn ShowWindow(hWnd: ?HWND, nCmdShow: SHOW_WINDOW_CMD) callconv(.C) BOOL;
pub extern "user32" fn SetWindowPos(hWnd: HWND, hWndInsertAfter: ?HWND, X: c_int, Y: c_int, cx: c_int, cy: c_int, uFlags: SET_WINDOW_POS_FLAGS) callconv(.C) BOOL;
pub extern "user32" fn PeekMessageW(lpMsg: ?*MSG, hWnd: ?HWND, wMsgFilterMin: u32, wMsgFilterMax: u32, wRemoveMsg: PEEK_MESSAGE_REMOVE_TYPE) callconv(.C) BOOL;
pub extern "user32" fn TranslateMessage(lpMsg: ?*const MSG) callconv(.C) BOOL;
pub extern "user32" fn DispatchMessageW(lpMsg: ?*const MSG) callconv(.C) LRESULT;
pub extern "user32" fn PostQuitMessage(nExitCode: i32) callconv(.C) void;
pub extern "user32" fn GetDC(hHwnd: ?HWND) callconv(.C) ?HDC;
pub extern "user32" fn ReleaseDC(hWnd: ?HWND, hDC: ?HDC) callconv(.C) i32;
pub extern "user32" fn GetSystemMetrics(nIndex: SYSTEM_METRICS_INDEX) callconv(.C) i32;
pub extern "user32" fn LoadCursorW(hInstance: ?HINSTANCE, lpCursorName: LPCWSTR) callconv(.C) ?HCURSOR;
pub extern "user32" fn GetWindowLongPtrW(hWnd: HWND, nIndex: c_int) callconv(.C) LONG_PTR;
pub extern "user32" fn SetWindowLongPtrW(hWnd: HWND, nIndex: c_int, dwNewLong: LONG_PTR) callconv(.C) LONG_PTR;
pub extern "user32" fn SetLayeredWindowAttributes(hWnd: HWND, crKey: COLORREF, bAlpha: BYTE, dwFlags: DWORD) callconv(.C) BOOL;
pub extern "user32" fn LoadIconW(hInstance: ?HINSTANCE, lpIconName: ResourceNamePtrW) callconv(.C) HICON;
pub extern "user32" fn LoadImageW(hInst: ?HINSTANCE, name: ResourceNamePtrW, @"type": UINT, cx: c_int, cy: c_int, fuLoad: UINT) callconv(.C) ?HANDLE;
pub extern "user32" fn ValidateRect(hWnd: ?HWND, lpRect: ?*const RECT) callconv(.C) BOOL;
pub extern "user32" fn LoadStringW(hInstance: HINSTANCE, uID: UINT, lpBuffer: LPWSTR, cchBufferMax: c_int) callconv(.C) c_int;
pub extern "user32" fn SetActiveWindow(hWnd: ?HWND) callconv(.C) ?HWND;
pub extern "user32" fn SetForegroundWindow(hWnd: ?HWND) callconv(.C) BOOL;
pub extern "user32" fn SetFocus(hWnd: ?HWND) callconv(.C) ?HWND;
pub extern "user32" fn LoadMenuW(hInstance: ?HINSTANCE, lpMenuName: ResourceNamePtrW) callconv(.C) ?HMENU;
pub extern "user32" fn SetMenu(hWnd: ?HWND, hMenu: HMENU) callconv(.C) BOOL;
pub extern "user32" fn GetMenu(hWnd: HWND) callconv(.C) ?HMENU;
pub extern "user32" fn DestroyMenu(hMenu: HMENU) callconv(.C) BOOL;
pub extern "user32" fn GetSubMenu(hMenu: HMENU, nPos: c_int) callconv(.C) ?HMENU;
pub extern "user32" fn ModifyMenuW(hMenu: HMENU, uPosition: UINT, uFlags: UINT, uIDNewItem: *UINT, lpNewItem: ?LPCWSTR) callconv(.C) BOOL;
pub extern "user32" fn CheckMenuItem(hMenu: HMENU, uIDCheckItem: UINT, uCheck: UINT) callconv(.C) DWORD;
pub extern "user32" fn TrackPopupMenuEx(hMenu: HMENU, uFlags: UINT, x: c_int, y: c_int, hwnd: HWND, lptpm: ?*TPMPARAMS) callconv(.C) BOOL;
pub extern "user32" fn ClientToScreen(hWnd: HWND, lpPoint: *POINT) callconv(.C) BOOL;
pub extern "user32" fn ScreenToClient(hWnd: HWND, lpPoint: *POINT) callconv(.C) BOOL;
pub extern "user32" fn GetCursorPos(lpPoint: *POINT) callconv(.C) BOOL;
pub extern "user32" fn MessageBoxW(hWnd: ?HWND, lpText: ?LPCWSTR, lpCaption: ?LPCWSTR, uType: UINT) callconv(.C) c_int;
pub extern "user32" fn ShellMessageBoxW(hAppInst: ?HINSTANCE, hWnd: ?HWND, lpText: ?LPCWSTR, lpCaption: ?LPCWSTR, uType: UINT) callconv(.C) c_int;
pub extern "user32" fn GetMouseMovePointsEx(cbSize: UINT, lppt: *MOUSEMOVEPOINT, lpptBuf: [*c]MOUSEMOVEPOINT, nBufPoints: c_int, resolution: DWORD) callconv(.C) c_int;
pub extern "user32" fn RegisterHotKey(hWnd: ?HWND, id: c_int, fsModifiers: UINT, vk: UINT) callconv(.C) BOOL;
pub extern "user32" fn SetCursor(hCursor: ?HCURSOR) callconv(.C) HCURSOR;
pub extern "user32" fn GetCursor() callconv(.C) HCURSOR;
pub extern "user32" fn PostMessageW(hWnd: ?HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) callconv(.C) BOOL;
pub extern "user32" fn SetCapture(hWnd: HWND) callconv(.C) ?HWND;
pub extern "user32" fn GetWindowRect(hwnd: HWND, lpRect: *RECT) callconv(.C) BOOL;
pub extern "user32" fn GetClientRect(hwnd: HWND, lpRect: *RECT) callconv(.C) BOOL;
// pub extern "dwmapi" fn DwmIsCompositionEnabled(pfEnabled: ?*BOOL) callconv(.C) HRESULT;
// pub extern "dwmapi" fn DwmGetColorizationColor(pcrColorization: *DWORD, pfOpaqueBlend: *BOOL) callconv(.C) HRESULT;
// pub extern "dwmapi" fn DwmEnableBlurBehindWindow(hWnd: HWND, pBlurBehind: *const DWM_BLURBEHIND) callconv(.C) HRESULT;
pub extern "dwmapi" fn DwmExtendFrameIntoClientArea(hWnd: HWND, pMarInset: *const MARGINS) callconv(.C) HRESULT;
pub extern "gdi32" fn ChoosePixelFormat(hdc: ?HDC, ppfd: ?*const PIXELFORMATDESCRIPTOR) callconv(.C) i32;
pub extern "gdi32" fn SetPixelFormat(hdc: ?HDC, format: i32, ppfd: ?*const PIXELFORMATDESCRIPTOR) callconv(.C) BOOL;
pub extern "gdi32" fn DescribePixelFormat(hdc: ?HDC, iPixelFormat: i32, nBytes: u32, ppfd: ?*PIXELFORMATDESCRIPTOR) callconv(.C) i32;
pub extern "gdi32" fn SwapBuffers(param0: ?HDC) callconv(.C) BOOL;
pub extern "gdi32" fn CreateRectRgn(x1: c_int, y1: c_int, x2: c_int, y2: c_int) callconv(.C) HRGN;
pub extern "gdi32" fn DeleteObject(ho: HGDIOBJ) callconv(.C) BOOL;
pub extern "shell32" fn Shell_NotifyIconW(dwMessage: DWORD, lpData: *const NOTIFYICONDATAW) callconv(.C) BOOL;

pub fn report_error() !void {
    const err_code = GetLastError();
    const err: std.os.windows.Win32Error = @enumFromInt(err_code);
    switch (err) {
        .SUCCESS => return,

        else => {
            var buf_wstr: [614:0]WCHAR = undefined;

            const len = FormatMessageW(FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, null, err_code, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), &buf_wstr, buf_wstr.len, null);

            const err_str = std.unicode.fmtUtf16Le(buf_wstr[0..@intCast(len - 2)]); // Strip newline and carriage return from end.

            std.debug.print("Windows error: {}:{s}: {s}\n", .{ err_code, @tagName(err), err_str });

            return error.Win32_Error;
        },
    }
}

pub inline fn LOWORD(l: anytype) WORD {
    return @truncate(@as(DWORD, @intCast(l)) & 0xffff);
}

pub inline fn HIWORD(l: anytype) WORD {
    return @truncate(@as(DWORD, @intCast(l >> 16)) & 0xffff);
}

pub inline fn GET_X_LPARAM(lp: anytype) c_int {
    return @as(c_short, @intCast(LOWORD(lp)));
}

pub inline fn GET_Y_LPARAM(lp: anytype) c_int {
    return @as(c_short, @intCast(HIWORD(lp)));
}

pub inline fn MAKELANGID(p: c_ushort, s: c_ushort) LANGID {
    return (s << 10) | p;
}

pub inline fn MAKEINTRESOURCEW(id: u16) ResourceNamePtrW {
    return @ptrFromInt(@as(usize, id));
}

pub const SECURITY_ATTRIBUTES = extern struct {
    nLength: DWORD,
    lpSecurityDescriptor: LPVOID,
    bInheritHandle: BOOL,
};

pub const MOUSEMOVEPOINT = extern struct {
    x: c_int,
    y: c_int,
    time: DWORD,
    dwExtraInfo: *ULONG,
};

pub const RECT = extern struct {
    left: LONG,
    top: LONG,
    right: LONG,
    bottom: LONG,
};

pub const MARGINS = extern struct {
    cxLeftWidth: c_int,
    cxRightWidth: c_int,
    cyTopHeight: c_int,
    cyBottomHeight: c_int,

    pub fn init(v: c_int) MARGINS {
        return .{
            .cxLeftWidth = v,
            .cxRightWidth = v,
            .cyTopHeight = v,
            .cyBottomHeight = v,
        };
    }
};

pub const TPMPARAMS = extern struct {
    cbSize: UINT,
    rcExclude: RECT,
};

pub const DWM_BLURBEHIND = extern struct {
    dwFlags: u32 align(1) = zeroinit(u32),
    fEnable: BOOL align(1) = zeroinit(BOOL),
    hRgnBlur: ?HRGN align(1) = zeroinit(?HRGN),
    fTransitionOnMaximized: BOOL align(1) = zeroinit(BOOL),
};

pub const MSG = extern struct {
    hwnd: ?HWND,
    message: u32,
    wParam: WPARAM,
    lParam: LPARAM,
    time: u32,
    pt: POINT,
};

pub const POINT = extern struct {
    x: i32,
    y: i32,
};

pub const PEEK_MESSAGE_REMOVE_TYPE = packed struct(u32) {
    REMOVE: u1 = 0,
    NOYIELD: u1 = 0,
    _2: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    QS_PAINT: u1 = 0,
    QS_SENDMESSAGE: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};

pub const WNDCLASS_STYLES = packed struct(u32) {
    VREDRAW: u1 = 0,
    HREDRAW: u1 = 0,
    _2: u1 = 0,
    DBLCLKS: u1 = 0,
    _4: u1 = 0,
    OWNDC: u1 = 0,
    CLASSDC: u1 = 0,
    PARENTDC: u1 = 0,
    _8: u1 = 0,
    NOCLOSE: u1 = 0,
    _10: u1 = 0,
    SAVEBITS: u1 = 0,
    BYTEALIGNCLIENT: u1 = 0,
    BYTEALIGNWINDOW: u1 = 0,
    GLOBALCLASS: u1 = 0,
    _15: u1 = 0,
    IME: u1 = 0,
    DROPSHADOW: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};

pub const WINDOW_STYLE = packed struct(u32) {
    ACTIVECAPTION: u1 = 0,
    _1: u1 = 0,
    _2: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    TABSTOP: u1 = 0,
    GROUP: u1 = 0,
    THICKFRAME: u1 = 0,
    SYSMENU: u1 = 0,
    HSCROLL: u1 = 0,
    VSCROLL: u1 = 0,
    DLGFRAME: u1 = 0,
    BORDER: u1 = 0,
    MAXIMIZE: u1 = 0,
    CLIPCHILDREN: u1 = 0,
    CLIPSIBLINGS: u1 = 0,
    DISABLED: u1 = 0,
    VISIBLE: u1 = 0,
    MINIMIZE: u1 = 0,
    CHILD: u1 = 0,
    POPUP: u1 = 0,
    // MINIMIZEBOX (bit index 17) conflicts with GROUP
    // MAXIMIZEBOX (bit index 16) conflicts with TABSTOP
    // ICONIC (bit index 29) conflicts with MINIMIZE
    // SIZEBOX (bit index 18) conflicts with THICKFRAME
    // CHILDWINDOW (bit index 30) conflicts with CHILD

    const WS_OVERLAPPED = 0x00000000;
    const WS_CAPTION = 0x00C00000;

    pub inline fn OVERLAPPED_WINDOW() WINDOW_STYLE {
        const result = WINDOW_STYLE{
            .SYSMENU = 1,
            .THICKFRAME = 1,
            .GROUP = 1, // MINIMIZEBOX
            .TABSTOP = 1, // MAXIMIZEBOX
        };
        const ires = @as(u32, @bitCast(result)) | WS_OVERLAPPED | WS_CAPTION;
        return @bitCast(ires);
    }
};

pub const WINDOW_EX_STYLE = packed struct(u32) {
    DLGMODALFRAME: u1 = 0,
    _1: u1 = 0,
    NOPARENTNOTIFY: u1 = 0,
    TOPMOST: u1 = 0,
    ACCEPTFILES: u1 = 0,
    TRANSPARENT: u1 = 0,
    MDICHILD: u1 = 0,
    TOOLWINDOW: u1 = 0,
    WINDOWEDGE: u1 = 0,
    CLIENTEDGE: u1 = 0,
    CONTEXTHELP: u1 = 0,
    _11: u1 = 0,
    RIGHT: u1 = 0,
    RTLREADING: u1 = 0,
    LEFTSCROLLBAR: u1 = 0,
    _15: u1 = 0,
    CONTROLPARENT: u1 = 0,
    STATICEDGE: u1 = 0,
    APPWINDOW: u1 = 0,
    LAYERED: u1 = 0,
    NOINHERITLAYOUT: u1 = 0,
    NOREDIRECTIONBITMAP: u1 = 0,
    LAYOUTRTL: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    COMPOSITED: u1 = 0,
    _26: u1 = 0,
    NOACTIVATE: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
};

pub const WNDCLASSW = extern struct {
    style: WNDCLASS_STYLES = zeroinit(WNDCLASS_STYLES),
    lpfnWndProc: ?WNDPROC,
    cbClsExtra: i32 = zeroinit(i32),
    cbWndExtra: i32 = zeroinit(i32),
    hInstance: ?HINSTANCE,
    hIcon: ?HICON = zeroinit(?HICON),
    hCursor: ?HCURSOR = zeroinit(?HCURSOR),
    hbrBackground: ?HBRUSH = zeroinit(?HBRUSH),
    lpszMenuName: ?LPCWSTR = zeroinit(?LPCWSTR),
    lpszClassName: LPCWSTR,
};

pub const WNDCLASSEXW = extern struct {
    cbSize: u32 = @sizeOf(@This()),
    style: WNDCLASS_STYLES = zeroinit(WNDCLASS_STYLES),
    lpfnWndProc: ?WNDPROC = zeroinit(?WNDPROC),
    cbClsExtra: i32 = zeroinit(i32),
    cbWndExtra: i32 = zeroinit(i32),
    hInstance: ?HINSTANCE = zeroinit(?HINSTANCE),
    hIcon: ?HICON = zeroinit(?HICON),
    hCursor: ?HCURSOR = zeroinit(?HCURSOR),
    hbrBackground: ?HBRUSH = zeroinit(?HBRUSH),
    lpszMenuName: ?LPCWSTR = zeroinit(?LPCWSTR),
    lpszClassName: ?LPCWSTR = zeroinit(?LPCWSTR),
    hIconSm: ?HICON = zeroinit(?HICON),
};

pub const PFD_FLAGS = packed struct(u32) {
    DOUBLEBUFFER: u1 = 0,
    STEREO: u1 = 0,
    DRAW_TO_WINDOW: u1 = 0,
    DRAW_TO_BITMAP: u1 = 0,
    SUPPORT_GDI: u1 = 0,
    SUPPORT_OPENGL: u1 = 0,
    GENERIC_FORMAT: u1 = 0,
    NEED_PALETTE: u1 = 0,
    NEED_SYSTEM_PALETTE: u1 = 0,
    SWAP_EXCHANGE: u1 = 0,
    SWAP_COPY: u1 = 0,
    SWAP_LAYER_BUFFERS: u1 = 0,
    GENERIC_ACCELERATED: u1 = 0,
    SUPPORT_DIRECTDRAW: u1 = 0,
    DIRECT3D_ACCELERATED: u1 = 0,
    SUPPORT_COMPOSITION: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    DEPTH_DONTCARE: u1 = 0,
    DOUBLEBUFFER_DONTCARE: u1 = 0,
    STEREO_DONTCARE: u1 = 0,
};

pub const PFD_PIXEL_TYPE = enum(i8) {
    RGBA = 0,
    COLORINDEX = 1,
};

pub const PFD_LAYER_TYPE = enum(i8) {
    UNDERLAY_PLANE = -1,
    MAIN_PLANE = 0,
    OVERLAY_PLANE = 1,
};

pub const PIXELFORMATDESCRIPTOR = extern struct {
    nSize: u16 = @sizeOf(@This()),
    nVersion: u16 = zeroinit(u16),
    dwFlags: PFD_FLAGS = zeroinit(PFD_FLAGS),
    iPixelType: PFD_PIXEL_TYPE = zeroinit(PFD_PIXEL_TYPE),
    cColorBits: u8 = zeroinit(u8),
    cRedBits: u8 = zeroinit(u8),
    cRedShift: u8 = zeroinit(u8),
    cGreenBits: u8 = zeroinit(u8),
    cGreenShift: u8 = zeroinit(u8),
    cBlueBits: u8 = zeroinit(u8),
    cBlueShift: u8 = zeroinit(u8),
    cAlphaBits: u8 = zeroinit(u8),
    cAlphaShift: u8 = zeroinit(u8),
    cAccumBits: u8 = zeroinit(u8),
    cAccumRedBits: u8 = zeroinit(u8),
    cAccumGreenBits: u8 = zeroinit(u8),
    cAccumBlueBits: u8 = zeroinit(u8),
    cAccumAlphaBits: u8 = zeroinit(u8),
    cDepthBits: u8 = zeroinit(u8),
    cStencilBits: u8 = zeroinit(u8),
    cAuxBuffers: u8 = zeroinit(u8),
    iLayerType: PFD_LAYER_TYPE = zeroinit(PFD_LAYER_TYPE),
    bReserved: u8 = zeroinit(u8),
    dwLayerMask: u32 = zeroinit(u32),
    dwVisibleMask: u32 = zeroinit(u32),
    dwDamageMask: u32 = zeroinit(u32),
};

pub const SYSTEM_METRICS_INDEX = enum(u32) {
    ARRANGE = 56,
    CLEANBOOT = 67,
    CMONITORS = 80,
    CMOUSEBUTTONS = 43,
    CONVERTIBLESLATEMODE = 8195,
    CXBORDER = 5,
    CXCURSOR = 13,
    CXDLGFRAME = 7,
    CXDOUBLECLK = 36,
    CXDRAG = 68,
    CXEDGE = 45,
    // CXFIXEDFRAME = 7, this enum value conflicts with CXDLGFRAME
    CXFOCUSBORDER = 83,
    CXFRAME = 32,
    CXFULLSCREEN = 16,
    CXHSCROLL = 21,
    CXHTHUMB = 10,
    CXICON = 11,
    CXICONSPACING = 38,
    CXMAXIMIZED = 61,
    CXMAXTRACK = 59,
    CXMENUCHECK = 71,
    CXMENUSIZE = 54,
    CXMIN = 28,
    CXMINIMIZED = 57,
    CXMINSPACING = 47,
    CXMINTRACK = 34,
    CXPADDEDBORDER = 92,
    CXSCREEN = 0,
    CXSIZE = 30,
    // CXSIZEFRAME = 32, this enum value conflicts with CXFRAME
    CXSMICON = 49,
    CXSMSIZE = 52,
    CXVIRTUALSCREEN = 78,
    CXVSCROLL = 2,
    CYBORDER = 6,
    CYCAPTION = 4,
    CYCURSOR = 14,
    CYDLGFRAME = 8,
    CYDOUBLECLK = 37,
    CYDRAG = 69,
    CYEDGE = 46,
    // CYFIXEDFRAME = 8, this enum value conflicts with CYDLGFRAME
    CYFOCUSBORDER = 84,
    CYFRAME = 33,
    CYFULLSCREEN = 17,
    CYHSCROLL = 3,
    CYICON = 12,
    CYICONSPACING = 39,
    CYKANJIWINDOW = 18,
    CYMAXIMIZED = 62,
    CYMAXTRACK = 60,
    CYMENU = 15,
    CYMENUCHECK = 72,
    CYMENUSIZE = 55,
    CYMIN = 29,
    CYMINIMIZED = 58,
    CYMINSPACING = 48,
    CYMINTRACK = 35,
    CYSCREEN = 1,
    CYSIZE = 31,
    // CYSIZEFRAME = 33, this enum value conflicts with CYFRAME
    CYSMCAPTION = 51,
    CYSMICON = 50,
    CYSMSIZE = 53,
    CYVIRTUALSCREEN = 79,
    CYVSCROLL = 20,
    CYVTHUMB = 9,
    DBCSENABLED = 42,
    DEBUG = 22,
    DIGITIZER = 94,
    IMMENABLED = 82,
    MAXIMUMTOUCHES = 95,
    MEDIACENTER = 87,
    MENUDROPALIGNMENT = 40,
    MIDEASTENABLED = 74,
    MOUSEPRESENT = 19,
    MOUSEHORIZONTALWHEELPRESENT = 91,
    MOUSEWHEELPRESENT = 75,
    NETWORK = 63,
    PENWINDOWS = 41,
    REMOTECONTROL = 8193,
    REMOTESESSION = 4096,
    SAMEDISPLAYFORMAT = 81,
    SECURE = 44,
    SERVERR2 = 89,
    SHOWSOUNDS = 70,
    SHUTTINGDOWN = 8192,
    SLOWMACHINE = 73,
    STARTER = 88,
    SWAPBUTTON = 23,
    SYSTEMDOCKED = 8196,
    TABLETPC = 86,
    XVIRTUALSCREEN = 76,
    YVIRTUALSCREEN = 77,
};

pub const SHOW_WINDOW_CMD = packed struct(u32) {
    SHOWNORMAL: u1 = 0,
    SHOWMINIMIZED: u1 = 0,
    SHOWNOACTIVATE: u1 = 0,
    SHOWNA: u1 = 0,
    SMOOTHSCROLL: u1 = 0,
    _5: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
    // NORMAL (bit index 0) conflicts with SHOWNORMAL
    // PARENTCLOSING (bit index 0) conflicts with SHOWNORMAL
    // OTHERZOOM (bit index 1) conflicts with SHOWMINIMIZED
    // OTHERUNZOOM (bit index 2) conflicts with SHOWNOACTIVATE
    // SCROLLCHILDREN (bit index 0) conflicts with SHOWNORMAL
    // INVALIDATE (bit index 1) conflicts with SHOWMINIMIZED
    // ERASE (bit index 2) conflicts with SHOWNOACTIVATE
};

pub const SET_WINDOW_POS_FLAGS = packed struct(u32) {
    NOSIZE: u1 = 0,
    NOMOVE: u1 = 0,
    NOZORDER: u1 = 0,
    NOREDRAW: u1 = 0,
    NOACTIVATE: u1 = 0,
    DRAWFRAME: u1 = 0,
    SHOWWINDOW: u1 = 0,
    HIDEWINDOW: u1 = 0,
    NOCOPYBITS: u1 = 0,
    NOOWNERZORDER: u1 = 0,
    NOSENDCHANGING: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    DEFERERASE: u1 = 0,
    ASYNCWINDOWPOS: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    _29: u1 = 0,
    _30: u1 = 0,
    _31: u1 = 0,
    // FRAMECHANGED (bit index 5) conflicts with DRAWFRAME
    // NOREPOSITION (bit index 9) conflicts with NOOWNERZORDER
};

pub const FILE_MAP = packed struct(DWORD) {
    COPY: u1 = 0,
    WRITE: u1 = 0,
    READ: u1 = 0,
    _3: u1 = 0,
    _4: u1 = 0,
    EXECUTE: u1 = 0,
    _6: u1 = 0,
    _7: u1 = 0,
    _8: u1 = 0,
    _9: u1 = 0,
    _10: u1 = 0,
    _11: u1 = 0,
    _12: u1 = 0,
    _13: u1 = 0,
    _14: u1 = 0,
    _15: u1 = 0,
    _16: u1 = 0,
    _17: u1 = 0,
    _18: u1 = 0,
    _19: u1 = 0,
    _20: u1 = 0,
    _21: u1 = 0,
    _22: u1 = 0,
    _23: u1 = 0,
    _24: u1 = 0,
    _25: u1 = 0,
    _26: u1 = 0,
    _27: u1 = 0,
    _28: u1 = 0,
    LARGE_PAGES: u1 = 0,
    TARGETS_INVALID: u1 = 0,
    RESERVE: u1 = 0,
};

const NOTIFYICONDATAW_DUMMYUNION = extern union {
    uTimeout: UINT,
    uVersion: UINT,
};

pub const NOTIFYICONDATAW = extern struct {
    cbSize: DWORD = @sizeOf(@This()),
    hWnd: ?HWND = null,
    uID: UINT = 0,
    uFlags: UINT = 0,
    uCallbackMessage: UINT = 0,
    hIcon: ?HICON = null,
    szTip: [128]WCHAR = zeroinit([128]WCHAR),
    dwState: DWORD = 0,
    dwStateMask: DWORD = 0,
    szInfo: [256]WCHAR = zeroinit([256]WCHAR),
    DUMMYUNIONNAME: NOTIFYICONDATAW_DUMMYUNION = zeroinit(NOTIFYICONDATAW_DUMMYUNION),
    szInfoTitle: [64]WCHAR = zeroinit([64]WCHAR),
    dwInfoFlags: DWORD = 0,
    guidItem: GUID = zeroinit(GUID),
    hBalloonIcon: ?HICON = null,
};

pub const GUID = extern struct {
    Data1: c_ulong,
    Data2: c_ushort,
    Data3: c_ushort,
    Data4: u64,
};

pub const SYS_COLOR_INDEX = enum(u32) {
    @"3DDKSHADOW" = 21,
    @"3DFACE" = 15,
    @"3DHIGHLIGHT" = 20,
    // @"3DHILIGHT" = 20, this enum value conflicts with @"3DHIGHLIGHT"
    @"3DLIGHT" = 22,
    @"3DSHADOW" = 16,
    ACTIVEBORDER = 10,
    ACTIVECAPTION = 2,
    APPWORKSPACE = 12,
    BACKGROUND = 1,
    // BTNFACE = 15, this enum value conflicts with @"3DFACE"
    // BTNHIGHLIGHT = 20, this enum value conflicts with @"3DHIGHLIGHT"
    // BTNHILIGHT = 20, this enum value conflicts with @"3DHIGHLIGHT"
    // BTNSHADOW = 16, this enum value conflicts with @"3DSHADOW"
    BTNTEXT = 18,
    CAPTIONTEXT = 9,
    // DESKTOP = 1, this enum value conflicts with BACKGROUND
    GRADIENTACTIVECAPTION = 27,
    GRADIENTINACTIVECAPTION = 28,
    GRAYTEXT = 17,
    HIGHLIGHT = 13,
    HIGHLIGHTTEXT = 14,
    HOTLIGHT = 26,
    INACTIVEBORDER = 11,
    INACTIVECAPTION = 3,
    INACTIVECAPTIONTEXT = 19,
    INFOBK = 24,
    INFOTEXT = 23,
    MENU = 4,
    MENUHILIGHT = 29,
    MENUBAR = 30,
    MENUTEXT = 7,
    SCROLLBAR = 0,
    WINDOW = 5,
    WINDOWFRAME = 6,
    WINDOWTEXT = 8,
};
