pub inline fn extern_f(comptime name: []const u8, comptime T: type) *const T {
    return @extern(*const T, .{ .name = name });
}
