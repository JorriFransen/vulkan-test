const alloc = @import("alloc.zig");
const clap = @import("clap");

const platform = @import("platform.zig");
const Window = platform.Window;

const std = @import("std");

pub const Options = struct {
    window_api: platform.WindowApi = .default,
    glfw_api: platform.GlfwApi = .default,

    fn fromParseResult(parsed: ParseResult) Options {
        var result = Options{};
        if (parsed.args.@"window-api") |api| result.window_api = api;
        if (parsed.args.@"glfw-api") |api| result.glfw_api = api;
        return result;
    }

    pub fn toInitOptions(this: *const Options) Window.InitSystemOptions {
        return .{ .window_api = this.window_api, .glfw_api = this.glfw_api };
    }
};

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
    const name = args_it.next().?;

    writer.print("Usage: {s}", .{name}) catch {};
    clap.usage(writer, clap.Help, &cl_params) catch {};
    writer.print("\n", .{}) catch {};
}

pub fn help(writer: anytype) void {
    usage(writer);
    clap.help(writer, clap.Help, &cl_params, .{}) catch {};
}

pub fn parse() CommandLineParseError!Options {
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
        std.process.exit(0);
    }

    return Options.fromParseResult(result);
}

fn printErr(comptime fmt: []const u8, args: anytype) void {
    const w = std.io.getStdErr().writer();
    w.print(fmt, args) catch {};
    w.print("\n", .{}) catch {};
}
