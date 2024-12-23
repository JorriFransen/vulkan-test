const std = @import("std");
const dlog = std.log.debug;

pub fn Callback(comptime param_types: []const type) type {
    const param_count = param_types.len;
    const Param = std.builtin.Type.Fn.Param;

    const params = blk: {
        var params: [param_count]Param = undefined;
        for (&params, param_types) |*p, pt| {
            p.* = .{ .is_generic = false, .is_noalias = false, .type = pt };
        }
        break :blk params;
    };

    return struct {
        fun: *const @Type(.{ .@"fn" = .{
            .calling_convention = .auto,
            .is_generic = false,
            .is_var_args = false,
            .return_type = void,
            .params = &params ++ .{Param{ .is_generic = false, .is_noalias = false, .type = ?*anyopaque }},
        } }),

        user_data: ?*anyopaque = null,
    };
}
