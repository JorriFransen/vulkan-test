const std = @import("std");
const dlog = std.log.debug;
const assert = std.debug.assert;

const platform = @import("platform");
pub const x = platform.x;

pub const Renderer = @import("renderer.zig");

const s = @This();

pub const Flags = u32;
pub const Bool32 = u32;
pub const SampleMask = u32;
pub const DeviceSize = u64;
pub const VoidFunction = ?*const fn () callconv(.C) void;

pub const PFN_AllocationFunction = ?*const fn (?*anyopaque, usize, usize, s.SystemAllocationScope) callconv(.C) ?*anyopaque;
pub const PFN_ReallocationFunction = ?*const fn (?*anyopaque, ?*anyopaque, usize, usize, s.SystemAllocationScope) callconv(.C) ?*anyopaque;
pub const PFN_FreeFunction = ?*const fn (?*anyopaque, ?*anyopaque) callconv(.c) void;
pub const PFN_InternalAllocationNotification = ?*const fn (?*anyopaque, usize, s.InternalAllocationType, s.SystemAllocationScope) callconv(.c) void;
pub const PFN_InternalFreeNotification = ?*const fn (?*anyopaque, usize, s.InternalAllocationType, s.SystemAllocationScope) callconv(.c) void;
pub const DebugUtilsMessengerCallback = ?*const fn (s.DebugUtilsMessageSeverityFlagsEXT, s.DebugUtilsMessageTypeFlagsEXT, [*c]const s.DebugUtilsMessengerCallbackData, ?*anyopaque) callconv(.C) s.Bool32;

pub const handles = @import("handles.zig");
pub usingnamespace handles;

pub const structs = @import("structs.zig");
pub usingnamespace structs;

pub const functions = @import("functions.zig");
pub usingnamespace functions;

pub inline fn MAKE_VERSION(major: u32, minor: u32, patch: u32) u32 {
    return ((major << 22) | minor << 12) | patch;
}

pub inline fn MAKE_API_VERSION(variant: u32, major: u32, minor: u32, patch: u32) u32 {
    return ((variant << 29) | (major << 22) | (minor << 12) | patch);
}

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
