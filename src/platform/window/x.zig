const f = @import("externFn").externFn;

pub const xcb_connection_t = opaque {};
pub const xcb_window_t = u32;
pub const Display = opaque {};
pub const XID = c_ulong;
pub const Window = XID;

pub const getXCBConnection = f("XGetXCBConnection", fn (display: *Display) callconv(.C) *xcb_connection_t);
