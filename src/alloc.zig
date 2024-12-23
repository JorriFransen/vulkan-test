const heap = @import("std").heap;
const builtin = @import("builtin");

var gpa_data = heap.GeneralPurposeAllocator(.{}).init;
pub const gpa = gpa_data.allocator();

pub fn deinit() !void {
    if (gpa_data.deinit() == .leak) {
        return error.GPALeak;
    }
}
