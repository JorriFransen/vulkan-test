const std = @import("std");
const time = std.time;

const log = std.log.scoped(.timing).info;

const options = @import("options");

pub const Timer = struct {
    name: []const u8 = undefined,
    timer: time.Timer = undefined,

    pub inline fn start(name: []const u8) Timer {
        return if (options.timing) .{
            .name = name,
            .timer = time.Timer.start() catch unreachable,
        } else .{};
    }

    pub inline fn lap(this: *@This()) void {
        if (options.timing) {
            log("{s}: {}", .{ this.name, this.timer.lap() });
        }
    }

    pub inline fn reset(this: *@This()) void {
        if (options.timing) this.timer.reset();
    }
};
