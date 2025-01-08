const std = @import("std");

pub const degrees = std.math.radiansToDegrees;
pub const radians = std.math.degreesToRadians;

pub const Vec2 = extern union {
    a: [2]f32,
    xy: extern struct { x: f32, y: f32 },

    pub fn new(x: f32, y: f32) @This() {
        return .{ .a = .{ x, y } };
    }
};

pub const Vec3 = extern union {
    a: [3]f32,
    xyz: extern struct { x: f32, y: f32, z: f32 },

    pub fn new(x: f32, y: f32, z: f32) @This() {
        return .{ .a = .{ x, y, z } };
    }
};

pub const Mat4 = extern union {
    a: [4 * 4]f32,
    cr: [4][4]f32,

    pub fn new(m0: f32, m1: f32, m2: f32, m3: f32, m4: f32, m5: f32, m6: f32, m7: f32, m8: f32, m9: f32, m10: f32, m11: f32, m12: f32, m13: f32, m14: f32, m15: f32) @This() {
        return .{ .a = .{
            m0,  m1,  m2,  m3,
            m4,  m5,  m6,  m7,
            m8,  m9,  m10, m11,
            m12, m13, m14, m15,
        } };
    }

    pub inline fn eq(a: Mat4, b: Mat4) bool {
        return std.mem.eql(f32, &a.a, &b.a);
    }

    pub const identity = @This(){ .a = .{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    } };

    pub fn rotation_z(r: f32) @This() {
        return .{ .a = .{
            @cos(r),  @sin(r), 0, 0,
            -@sin(r), @cos(r), 0, 0,
            0,        0,       1, 0,
            0,        0,       0, 1,
        } };
    }

    pub fn translation(x: f32, y: f32, z: f32) @This() {
        return .{ .a = .{
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            x, y, z, 1,
        } };
    }

    // pub fn look_at(eye: Vec3, to: Vec3, up: Vec3) @This() {}

    pub fn mul(a: *const @This(), b: @This()) @This() {
        return .{ .a = .{
            a.cr[0][0] * b.cr[0][0] + a.cr[0][1] * b.cr[1][0] + a.cr[0][2] * b.cr[2][0] + a.cr[0][3] * b.cr[3][0],
            a.cr[0][0] * b.cr[0][1] + a.cr[0][1] * b.cr[1][1] + a.cr[0][2] * b.cr[2][1] + a.cr[0][3] * b.cr[3][1],
            a.cr[0][0] * b.cr[0][2] + a.cr[0][1] * b.cr[1][2] + a.cr[0][2] * b.cr[2][2] + a.cr[0][3] * b.cr[3][2],
            a.cr[0][0] * b.cr[0][3] + a.cr[0][1] * b.cr[1][3] + a.cr[0][2] * b.cr[2][3] + a.cr[0][3] * b.cr[3][3],

            a.cr[1][0] * b.cr[0][0] + a.cr[1][1] * b.cr[1][0] + a.cr[1][2] * b.cr[2][0] + a.cr[1][3] * b.cr[3][0],
            a.cr[1][0] * b.cr[0][1] + a.cr[1][1] * b.cr[1][1] + a.cr[1][2] * b.cr[2][1] + a.cr[1][3] * b.cr[3][1],
            a.cr[1][0] * b.cr[0][2] + a.cr[1][1] * b.cr[1][2] + a.cr[1][2] * b.cr[2][2] + a.cr[1][3] * b.cr[3][2],
            a.cr[1][0] * b.cr[0][3] + a.cr[1][1] * b.cr[1][3] + a.cr[1][2] * b.cr[2][3] + a.cr[1][3] * b.cr[3][3],

            a.cr[2][0] * b.cr[0][0] + a.cr[2][1] * b.cr[1][0] + a.cr[2][2] * b.cr[2][0] + a.cr[2][3] * b.cr[3][0],
            a.cr[2][0] * b.cr[0][1] + a.cr[2][1] * b.cr[1][1] + a.cr[2][2] * b.cr[2][1] + a.cr[2][3] * b.cr[3][1],
            a.cr[2][0] * b.cr[0][2] + a.cr[2][1] * b.cr[1][2] + a.cr[2][2] * b.cr[2][2] + a.cr[2][3] * b.cr[3][2],
            a.cr[2][0] * b.cr[0][3] + a.cr[2][1] * b.cr[1][3] + a.cr[2][2] * b.cr[2][3] + a.cr[2][3] * b.cr[3][3],

            a.cr[3][0] * b.cr[0][0] + a.cr[3][1] * b.cr[1][0] + a.cr[3][2] * b.cr[2][0] + a.cr[3][3] * b.cr[3][0],
            a.cr[3][0] * b.cr[0][1] + a.cr[3][1] * b.cr[1][1] + a.cr[3][2] * b.cr[2][1] + a.cr[3][3] * b.cr[3][1],
            a.cr[3][0] * b.cr[0][2] + a.cr[3][1] * b.cr[1][2] + a.cr[3][2] * b.cr[2][2] + a.cr[3][3] * b.cr[3][2],
            a.cr[3][0] * b.cr[0][3] + a.cr[3][1] * b.cr[1][3] + a.cr[3][2] * b.cr[2][3] + a.cr[3][3] * b.cr[3][3],
        } };
    }
};

test "Mat4 mul" {
    const a = Mat4.new(1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6, 5, 4, 3, 2);

    const b = Mat4{ .a = .{
        -2, 1, 2, 3,
        3,  2, 1, -1,
        4,  3, 6, 5,
        1,  2, 7, 8,
    } };

    const expected = Mat4{ .a = .{
        20, 22, 50,  48,
        44, 54, 114, 108,
        40, 58, 110, 102,
        16, 26, 46,  42,
    } };

    const result = a.mul(b);

    try std.testing.expectEqual(expected.cr, result.cr);
    try std.testing.expect(expected.eq(result));
}
