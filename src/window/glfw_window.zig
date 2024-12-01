const std = @import("std");
const dlog = std.log.debug;
const elog = std.log.err;
const ilog = std.log.info;

pub fn init() !void {
    dlog("Initialized Window", .{});
}

title: []const u8,
counter: i32,

pub fn create(title: []const u8) !@This() {
    const result = @This(){
        .title = title,
        .counter = 0,
    };
    dlog("Created {}", .{result});

    return result;
}

pub fn should_close(this: *const @This()) bool {
    return this.counter >= 10;
}

pub fn update(this: *@This()) void {
    this.counter += 1;
    dlog("Updated {}", .{this});
}

pub fn close(this: *@This()) void {
    this.title = &.{};
    this.counter = -1;
    dlog("Closed {any}", .{this});
}
