const std = @import("std");

comptime {
    _ = @import("math.zig");
}

test {
    std.testing.refAllDeclsRecursive(@This());
}
