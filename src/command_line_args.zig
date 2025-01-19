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

pub const CommandLineParseError = error{InvalidCommandLine};

pub fn usage(writer: anytype) void {
    var args_it = std.process.args();
    const name = std.fs.path.basename(args_it.next().?);

    writer.print("Usage: {s} ", .{name}) catch {};
    clap.usage(writer, clap.Help, &cl_params) catch {};
    writer.print("\n", .{}) catch {};
}

pub fn help(writer: anytype) void {
    usage(writer);
    clap.help(writer, clap.Help, &cl_params, .{}) catch {};
}

pub fn parse(comptime T: type) CommandLineParseError!T {
    var diag = clap.Diagnostic{};
    const result = clap.parse(clap.Help, &cl_params, parsers, .{
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

        usage(std.io.getStdErr().writer());
        return error.InvalidCommandLine;
    };
    defer result.deinit();

    if (result.args.help != 0) {
        help(std.io.getStdOut().writer());
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
