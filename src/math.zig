const std = @import("std");

pub const FLOAT_EPSILON = 0.00001;

pub const degrees = std.math.radiansToDegrees;
pub const radians = std.math.degreesToRadians;

pub const Vec2f32 = Vec(2, f32);
pub const Vec3f32 = Vec(3, f32);
pub const Vec4f32 = Vec(4, f32);

pub fn Vec(comptime N: usize, comptime T: type) type {
    if (N == 0 or N > 4) @compileError("N must be between 2 and 4");

    switch (N) {
        else => unreachable,

        2 => return extern struct {
            x: T,
            y: T,
            pub fn new(x: T, y: T) @This() {
                return .{ .x = x, .y = y };
            }
            pub usingnamespace VecFunctionsMixin(N, T, @This());
        },
        3 => return extern struct {
            x: T,
            y: T,
            z: T,
            pub fn new(x: T, y: T, z: T) @This() {
                return .{ .x = x, .y = y, .z = z };
            }
            pub usingnamespace VecFunctionsMixin(N, T, @This());
        },
        4 => return extern struct {
            x: T,
            y: T,
            z: T,
            w: T,
            pub fn new(x: T, y: T, z: T, w: T) @This() {
                return .{ .x = x, .y = y, .z = z, .w = w };
            }
            pub usingnamespace VecFunctionsMixin(N, T, @This());
        },
    }
}

pub fn VecFunctionsMixin(comptime N: usize, comptime T: type, comptime Base: type) type {
    const V = @Vector(N, T);
    return extern struct {
        pub inline fn initV(v: V) Base {
            return @bitCast(v);
        }
        pub inline fn vector(this: Base) V {
            return @bitCast(this);
        }
        pub inline fn add(a: Base, b: Base) Base {
            return initV(a.vector() + b.vector());
        }
        pub inline fn sub(a: Base, b: Base) Base {
            return initV(a.vector() - b.vector());
        }
        pub inline fn mul(a: Base, b: Base) Base {
            return initV(a.vector() * b.vector());
        }
        pub inline fn div(a: Base, b: Base) Base {
            return initV(a.vector() / b.vector());
        }
        pub inline fn div_scalar(v: Base, s: T) Base {
            return initV(v.vector() / @as(V, @splat(s)));
        }
        pub inline fn length(v: Base) T {
            const p = v.vector() * v.vector();
            return std.math.sqrt(@reduce(.Add, p));
        }
        pub inline fn normalized(v: Base) Base {
            return v.div_scalar(v.length());
        }
        pub inline fn dot(a: Base, b: Base) T {
            return @reduce(.Add, a.mul(b).vector());
        }
        pub inline fn cross(a: Base, b: Base) Base {
            comptime if (N == 2) @compileError("Cannot apply cross product to Vector2");

            const av = a.vector();
            const bv = b.vector();

            const M = @Vector(N, i32);
            const m1 = if (N == 3) M{ 1, 2, 0 } else M{ 1, 2, 0, 3 };
            const m2 = if (N == 3) M{ 2, 0, 1 } else M{ 2, 0, 1, 3 };

            const v1 = @shuffle(T, av, undefined, m1);
            const v2 = @shuffle(T, bv, undefined, m2);
            const v3 = @shuffle(T, av, undefined, m2);
            const v4 = @shuffle(T, bv, undefined, m1);

            return initV((v1 * v2) - (v3 * v4));
        }
    };
}

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

    pub fn perspective(fovy: f32, a: f32, n: f32, f: f32) Mat4 {
        const s = 1 / @tan(fovy * 0.5);

        return .{ .a = .{
            s / a, 0, 0,                   0,
            0,     s, 0,                   0,
            0,     0, (n + f) / (n - f),   -1,
            0,     0, 2 * f * n / (n - f), 0,
        } };
    }

    pub fn ortho(l: f32, r: f32, b: f32, t: f32, n: f32, f: f32) Mat4 {
        const result = Mat4{ .a = .{
            2 / (r - l),       0,                 0,                 0,
            0,                 2 / (t - b),       0,                 0,
            0,                 0,                 2 / (n - f),       0,
            (l + r) / (l - r), (b + t) / (b - t), (f + n) / (n - f), 1,
        } };
        return result;
    }

    pub fn lookAt(eye: Vec3f32, to: Vec3f32, up: Vec3f32) Mat4 {
        const f = to.sub(eye).normalized();
        const l = f.cross(up).normalized();
        const u = l.cross(f);

        return .{ .a = .{
            l.x,        u.x,         -f.x,       0,
            l.y,        u.y,         -f.y,       0,
            l.z,        u.z,         -f.z,       0,
            l.dot(eye), -u.dot(eye), f.dot(eye), 1,
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
    const a = Vec3f32.new(1, 2, 3);
    const b = Vec3f32.new(2, 3, 4);

    const expected_ab = Vec3f32.new(-1, 2, -1);
    const expected_ba = Vec3f32.new(1, -2, 1);

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
    const eye = Vec3f32.new(0, 0, 0);
    const to = Vec3f32.new(0, 0, -1);
    const up = Vec3f32.new(0, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    try std.testing.expectEqual(Mat4.identity.cr, tf.cr);
}

test "Mat4 look_at positive z" {
    const eye = Vec3f32.new(0, 0, 0);
    const to = Vec3f32.new(0, 0, 1);
    const up = Vec3f32.new(0, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    try std.testing.expectEqual(Mat4.scaling(-1, 1, -1).cr, tf.cr);
}

test "Mat4 look_at moves world" {
    const eye = Vec3f32.new(0, 0, 8);
    const to = Vec3f32.new(0, 0, 0);
    const up = Vec3f32.new(0, 1, 0);

    const tf = Mat4.lookAt(eye, to, up);

    try std.testing.expectEqual(Mat4.translation(0, 0, -8).cr, tf.cr);
}

test "Mat4 look_at arbitrary" {
    const eye = Vec3f32.new(1, 3, 2);
    const to = Vec3f32.new(4, -2, 8);
    const up = Vec3f32.new(1, 1, 0);

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
