pub const image = struct {
    pub const c = @cImport(@cInclude("stb_image.h"));

    pub const load = f("stbi_load", fn (path: [*:0]const u8, x: *c_int, y: *c_int, c: *c_int, desired_c: c_int) callconv(.C) ?[*]const u8);
    pub const free = f("stbi_image_free", fn (data: [*]const u8) callconv(.C) void);

    pub const rgb_alpha = c.STBI_rgb_alpha;
};

fn f(comptime name: []const u8, comptime T: type) *const T {
    return @extern(*const T, .{ .name = name, .library_name = "c" });
}
