const std = @import("std");

pub const FLOAT_EPSILON = 0.00001;

pub const f32x4 = @Vector(4, f32);

pub const degrees = std.math.radiansToDegrees;
pub const radians = std.math.degreesToRadians;

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub fn new(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }
};

pub const Vec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,

    pub const zero = Vec3{ .x = 0, .y = 0, .z = 0 };

    pub fn new(x: f32, y: f32, z: f32) Vec3 {
        return .{ .x = x, .y = y, .z = z };
    }

    pub fn add(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z };
    }

    pub fn sub(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z };
    }

    pub fn mul(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.x * b.x, .y = a.y * b.y, .z = a.z * b.z };
    }

    pub fn mul_scalar(v: Vec3, s: f32) Vec3 {
        return .{ .x = v.x * s, .y = v.y * s, .z = v.z * s };
    }

    pub fn div_scalar(v: Vec3, s: f32) Vec3 {
        return .{ .x = v.x / s, .y = v.y / s, .z = v.z / s };
    }

    pub fn normalized(v: Vec3) Vec3 {
        return v.div_scalar(v.length());
    }

    pub fn length(v: Vec3) f32 {
        return std.math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    }

    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        const v1 = Vec3.new(a.y, a.z, a.x);
        const v2 = Vec3.new(b.z, b.x, b.y);
        const v3 = Vec3.new(a.z, a.x, a.y);
        const v4 = Vec3.new(b.y, b.z, b.x);

        return v1.mul(v2).sub(v3.mul(v4));
    }

    pub fn dot(a: Vec3, b: Vec3) f32 {
        const m = a.mul(b);
        return m.x + m.y + m.z;
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
        const V = @Vector(4 * 4, f32);

        const va: V = @bitCast(a);
        const vb: V = @bitCast(b);

        const diff = va - vb;
        for (0..@typeInfo(V).vector.len) |i| {
            if (@abs(diff[i]) >= FLOAT_EPSILON) return false;
        }
        return true;
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

    pub fn scaling(x: f32, y: f32, z: f32) Mat4 {
        return .{ .a = .{
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1,
        } };
    }

    pub fn perspective(fovy: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const f = 1 / @tan(fovy * 0.5);

        return .{ .a = .{
            f / aspect, 0, 0,                             0,
            0,          f, 0,                             0,
            0,          0, (near + far) / (near - far),   -1,
            0,          0, 2 * far * near / (near - far), 0,
        } };
    }

    pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4 {
        const result = Mat4{ .a = .{
            2 / (right - left),              0,                               0,                           0,
            0,                               2 / (top - bottom),              0,                           0,
            0,                               0,                               2 / (near - far),            0,
            (left + right) / (left - right), (bottom + top) / (bottom - top), (far + near) / (near - far), 1,
        } };
        return result;
    }

    pub fn lookAt(eye: Vec3, to: Vec3, up: Vec3) Mat4 {
        const forward = to.sub(eye).normalized();
        const left = forward.cross(up).normalized();
        const true_up = left.cross(forward);

        return .{ .a = .{
            left.x,        true_up.x,         -forward.x,       0,
            left.y,        true_up.y,         -forward.y,       0,
            left.z,        true_up.z,         -forward.z,       0,
            left.dot(eye), -true_up.dot(eye), forward.dot(eye), 1,
        } };
    }

    pub fn transposed(m: *const Mat4) Mat4 {
        return .{ .a = .{
            m.a[0], m.a[4], m.a[8],  m.a[12],
            m.a[1], m.a[5], m.a[9],  m.a[13],
            m.a[2], m.a[6], m.a[10], m.a[14],
            m.a[3], m.a[7], m.a[11], m.a[15],
        } };
    }

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

test "Vec3 cross" {
    const a = Vec3.new(1, 2, 3);
    const b = Vec3.new(2, 3, 4);

    const expected_ab = Vec3.new(-1, 2, -1);
    const expected_ba = Vec3.new(1, -2, 1);

    const result_ab = a.cross(b);
    const result_ba = b.cross(a);

    try std.testing.expectEqual(expected_ab, result_ab);
    try std.testing.expectEqual(expected_ba, result_ba);
}

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
}

test "Mat4 look_at default" {
    const eye = Vec3.new(0, 0, 0);
    const to = Vec3.new(0, 0, -1);
    const up = Vec3.new(0, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    try std.testing.expectEqual(Mat4.identity.cr, tf.cr);
}

test "Mat4 look_at positive z" {
    const eye = Vec3.new(0, 0, 0);
    const to = Vec3.new(0, 0, 1);
    const up = Vec3.new(0, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    try std.testing.expectEqual(Mat4.scaling(-1, 1, -1).cr, tf.cr);
}

test "Mat4 look_at moves world" {
    const eye = Vec3.new(0, 0, 8);
    const to = Vec3.new(0, 0, 0);
    const up = Vec3.new(0, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    try std.testing.expectEqual(Mat4.translation(0, 0, -8).cr, tf.cr);
}

test "Mat4 look_at arbitrary" {
    const eye = Vec3.new(1, 3, 2);
    const to = Vec3.new(4, -2, 8);
    const up = Vec3.new(1, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    const expected = Mat4{ .a = .{
        -0.51449, 0.77892,  -0.35856, 0.00000,
        0.51449,  0.61494,  0.59761,  0.00000,
        0.68599,  0.12298,  -0.71713, 0.00000,
        2.40098,  -2.86972, -0.00000, 1.00000,
    } };

    try expectApproxEqualMatrix(expected, tf);
}

fn expectApproxEqualMatrix(expected: Mat4, actual: Mat4) !void {
    const V = @Vector(4 * 4, f32);

    const ve: V = @bitCast(expected);
    const va: V = @bitCast(actual);

    var match = true;
    var diff_index: usize = 0;

    const diff = ve - va;
    for (0..@typeInfo(V).vector.len) |i| {
        if (@abs(diff[i]) >= FLOAT_EPSILON) {
            match = false;
            diff_index = i;
            break;
        }
    }

    if (match) return;

    testprint("matrices differ. first difference occurs at index {d}\n", .{diff_index});

    const stderr = std.io.getStdErr();
    const ttyconf = std.io.tty.detectConfig(stderr);

    var differ = MatrixDiffer{
        .expected = expected,
        .actual = actual,
        .ttyconf = ttyconf,
    };

    testprint("\n============ expected this output: ============= \n", .{});
    differ.write(stderr.writer()) catch {};

    differ.expected = actual;
    differ.actual = expected;

    testprint("\n============= instead found this: ============== \n", .{});
    differ.write(stderr.writer()) catch {};

    return error.TestExpectedApproxEqAbs;
}

const MatrixDiffer = struct {
    expected: Mat4,
    actual: Mat4,
    ttyconf: std.io.tty.Config,

    pub fn write(self: MatrixDiffer, writer: anytype) !void {
        try writer.print("\n", .{});
        for (self.expected.cr, self.actual.cr) |er, ar| {
            try writer.print("[ ", .{});
            for (er, ar, 0..) |evalue, avalue, i| {
                const diff = @abs(evalue - avalue) >= FLOAT_EPSILON;
                if (diff) try self.ttyconf.setColor(writer, .red);
                try writer.print("{d: >14.6}", .{evalue});
                if (diff) try self.ttyconf.setColor(writer, .reset);

                if (i < 3) try writer.print(", ", .{});
            }
            try writer.print(" ]\n", .{});
        }
        try writer.print("\n", .{});
    }
};

fn testprint(comptime fmt: []const u8, args: anytype) void {
    if (@inComptime()) {
        @compileError(std.fmt.comptimePrint(fmt, args));
    } else if (std.testing.backend_can_print) {
        std.debug.print(fmt, args);
    }
}
