const alloc = @import("alloc.zig");
const clap = @import("clap");

const platform = @import("platform.zig");
const Window = platform.Window;

const std = @import("std");

const ParseResult = clap.Result(clap.Help, &cl_params, parsers);

const cl_params = clap.parseParamsComptime(
    \\-h, --help                Display this help and exit.
    \\--window-api  <WindowApi> Specify the window api to use.
    \\--glfw-api    <GLFWApi>   Hint glfw to use the specified api.
);

const parsers = .{
    .WindowApi = clap.parsers.enumeration(platform.WindowApi),
    .GLFWApi = clap.parsers.enumeration(platform.GlfwApi),
};

pub const CommandLineParseError = error{InvalidCommandLine,OutOfMemory};

pub fn usage(writer: anytype, exe_name: []const u8) void {
    // var args_it = std.process.args();

    writer.print("Usage: {s} ", .{exe_name}) catch {};
    clap.usage(writer, clap.Help, &cl_params) catch {};
    writer.print("\n", .{}) catch {};
}

pub fn help(writer: anytype, exe_name: []const u8) void {
    usage(writer, exe_name);
    clap.help(writer, clap.Help, &cl_params, .{}) catch {};
}

pub fn parse(comptime T: type) CommandLineParseError!T {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    var arg_it = try std.process.ArgIterator.initWithAllocator(arena.allocator());
    defer {
        arg_it.deinit();
        arena.deinit();
    }

    const exe_name = std.fs.path.basename(arg_it.next().?);

    var diag = clap.Diagnostic{};
    var result = clap.parseEx(clap.Help, &cl_params, parsers , &arg_it, .{
        .diagnostic = &diag,
        .allocator = alloc.gpa,
    }) catch |err| {
        const err_args = diag.name.longest();
        const prefix = switch (err_args.kind) {
            .positional => "",
            .short => "-",
            .long => "--",
        };
        const msg_args = .{ prefix, err_args.name };

        switch (err) {
            else => printErr("Error while parsing argument: {s}", .{@errorName(err)}),
            error.InvalidArgument => printErr("Invalid argument: '{s}{s}'", msg_args),
            error.MissingValue => printErr("Expected value for argument: '{s}{s}'", msg_args),
            error.DoesntTakeValue => printErr("Argument '{s}{s}' doesn't take a value", msg_args),
        }

        usage(std.io.getStdErr().writer(), exe_name);
        return error.InvalidCommandLine;
    };
    defer result.deinit();

    if (result.args.help != 0) {
        help(std.io.getStdOut().writer(), exe_name);
    }

    const default = T{};
    return .{
        .window_api = result.args.@"window-api" orelse default.window_api,
        .glfw_api = result.args.@"glfw-api" orelse default.glfw_api,
        .help = result.args.help != 0,
    };
}

fn printErr(comptime fmt: []const u8, args: anytype) void {
    const w = std.io.getStdErr().writer();
    w.print(fmt, args) catch {};
    w.print("\n", .{}) catch {};
}
