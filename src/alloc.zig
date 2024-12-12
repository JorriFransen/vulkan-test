const heap = @import("std").heap;
const builtin = @import("builtin");

var gpa_data = heap.GeneralPurposeAllocator(.{}).init;
pub const gpa = gpa_data.allocator();

pub fn detectLeaks() bool {
    return gpa_data.detectLeaks();
}

pub fn deinit() void {
    if (builtin.mode == .Debug and gpa_data.detectLeaks()) unreachable;
    _ = gpa_data.deinit();
}
