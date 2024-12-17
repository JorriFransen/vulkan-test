pub inline fn externFn(comptime name: []const u8, comptime T: type) *const T {
    return @extern(*const T, .{ .name = name });
}
