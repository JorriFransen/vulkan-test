const std = @import("std");
const dlog = std.log.debug;
const assert = std.debug.assert;

pub const Renderer = @import("renderer.zig");

const s = @This();

// Types
pub const Bool32 = u32;
pub const Result = c_int;
pub const VoidFunction = ?*const fn () callconv(.c) void;
pub const DebugUtilsMessengerCallback = ?*const fn (s.DebugUtilsMessageSeverityFlagsEXT, s.DebugUtilsMessageTypeFlagsEXT, [*c]const s.DebugUtilsMessengerCallbackData, ?*anyopaque) callconv(.c) s.Bool32;

// Handles
pub const handles = @import("handles.zig");
pub usingnamespace handles;

// Structs
pub const structs = @import("structs.zig");
pub usingnamespace structs;

// Functions
pub const functions = @import("functions.zig");
pub usingnamespace functions;

// Macros
pub inline fn MAKE_VERSION(major: u32, minor: u32, patch: u32) u32 {
    return ((major << 22) | minor << 12) | patch;
}

// Constants
pub const constants = @import("constants.zig");
pub usingnamespace constants;

pub const loader = struct {
    pub const debug_utils = @import("ext_debug_utils.zig");
    pub const portability_enumeration = @import("ext_portability_enumeration.zig");

    pub fn load(instance: s.Instance, req_extensions: []const [*:0]const u8) void {
        for (req_extensions) |ext_name| {
            var found = false;
            const name = std.mem.span(ext_name);

            inline for (@typeInfo(@This()).@"struct".decls) |decl| {
                const ext_struct_type = @field(@This(), decl.name);
                if (@TypeOf(ext_struct_type) != type) continue;

                if (@typeInfo(ext_struct_type) == .@"struct") {
                    assert(@hasDecl(ext_struct_type, "name"));
                    // assert(@hasDecl(ext_struct_type, "loaded"));
                } else {
                    continue;
                }

                if (std.mem.eql(u8, name, @field(ext_struct_type, "name"))) {
                    found = true;
                    if (@hasDecl(ext_struct_type, "load")) {
                        assert(@hasDecl(ext_struct_type, "loaded"));
                        assert(!@field(ext_struct_type, "loaded"));
                        ext_struct_type.load(instance);
                    }
                    break;
                }
            }
        }
    }
};

pub const extensions = struct {
    pub usingnamespace loader.debug_utils;
    pub usingnamespace loader.portability_enumeration;
};
