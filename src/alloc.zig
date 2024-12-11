const heap = @import("std").heap;

var gpa_data = heap.GeneralPurposeAllocator(.{}).init;
pub const gpa = gpa_data.allocator();

pub fn detectLeaks() bool {
    return gpa_data.detectLeaks();
}
