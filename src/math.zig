pub const Vec2 = extern struct {
    x: f32,
    y: f32,
};

pub const Vec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const Mat4 = extern struct {
    m: [4][4]f32,

    pub const identity = @This(){ .m = .{
        .{ 1, 0, 0, 0 },
        .{ 0, 1, 0, 0 },
        .{ 0, 0, 1, 0 },
        .{ 0, 0, 0, 1 },
    } };

    pub fn rotation_z(r: f32) @This() {
        return .{ .m = .{
            .{ @cos(r), -@sin(r), 0, 0 },
            .{ @sin(r), @cos(r), 0, 0 },
            .{ 0, 0, 1, 0 },
            .{ 0, 0, 0, 1 },
        } };
    }
};
