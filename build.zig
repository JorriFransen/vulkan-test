const std = @import("std");
const assert = std.debug.assert;
const elog = std.log.err;

const builtin = @import("builtin");

var target: std.Build.ResolvedTarget = undefined;
var optimize: std.builtin.OptimizeMode = undefined;

const sep = std.fs.path.sep_str;
const shader_dirs = [_]Shaders.Dir{
    .{ .path = "comptime_res", .recurse = false, .optional = false },
    .{ .path = "comptime_res" ++ sep ++ "shaders", .recurse = true, .optional = true },
};

pub fn build(b: *std.Build) !void {
    target = b.standardTargetOptions(.{});
    optimize = b.standardOptimizeOption(.{});

    const log_level = b.option(std.log.Level, "log", "Set global log level") orelse .info;
    const window_verbose = b.option(std.log.Level, "window-log", "Set window log level") orelse .info;
    const vulkan_verbose = b.option(std.log.Level, "vulkan-log", "Set vulkan log level") orelse .info;
    const timing = b.option(bool, "timing", "Enable timing reports") orelse false;
    const glfw_system = target.result.os.tag != .windows;
    const glfw_support = b.option(bool, "glfw-support", "Build with glfw suport") orelse glfw_system;

    const options = b.addOptions();
    options.addOption(std.log.Level, "log_level", log_level);
    options.addOption(std.log.Level, "window_log_level", window_verbose);
    options.addOption(std.log.Level, "vulkan_log_level", vulkan_verbose);
    options.addOption(bool, "timing", timing);
    options.addOption(bool, "glfw_support", glfw_support);
    const options_mod = options.createModule();

    // const flags_dep = b.dependency("flags", .{ .target = target, .optimize = optimize });
    // const flags_mod = flags_dep.module("flags");
    const clap_dep = b.dependency("clap", .{ .target = target, .optimize = optimize });
    const clap_mod = clap_dep.module("clap");

    const root_source_file = b.path("src/main.zig");

    const exe = b.addExecutable(.{
        .name = "vulkan-test",
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const exe_install_artifact = b.addInstallArtifact(exe, .{});
    b.getInstallStep().dependOn(&exe_install_artifact.step);

    exe.addCSourceFile(.{ .file = b.path("src/stb_image.c") });
    exe.addIncludePath(b.path("src/"));

    // Can't get wayland to work on nixos when building ourselves
    if (glfw_support) {
        if (glfw_system) {
            exe.linkSystemLibrary2("glfw", .{ .preferred_link_mode = .static });
        } else {
            const glfw_dep = b.dependency("glfw", .{ .target = target, .optimize = optimize });
            const glfw_lib = glfw_dep.artifact("glfw");
            exe.linkLibrary(glfw_lib);
        }
    }

    if (target.result.os.tag == .linux) {
        exe.linkSystemLibrary("X11");
        exe.linkSystemLibrary("X11-xcb");
    }

    try useVulkan(b, exe);

    const shaders = try Shaders.init(b, &exe.step, &shader_dirs);
    const shaders_mod = try shaders.emitShadersModule();

    exe.root_module.addImport("clap", clap_mod);
    exe.root_module.addImport("options", options_mod);
    exe.root_module.addImport("shaders", shaders_mod);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("src/tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);

    const clean_step = b.step("clean", "Clean zig-out and .zig-cache");
    clean_step.dependOn(&b.addRemoveDirTree(std.Build.LazyPath{ .cwd_relative = b.install_path }).step);
    if (builtin.os.tag != .windows)
        clean_step.dependOn(&b.addRemoveDirTree(std.Build.LazyPath{ .cwd_relative = b.cache_root.path.? }).step);
}

fn addPrivateModule(b: *std.Build, path: []const u8, name: []const u8) *std.Build.Module {
    const mod = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
    mod.addImport(name, mod);

    return mod;
}

fn useVulkan(b: *std.Build, c: *std.Build.Step.Compile) !void {
    const windows = target.result.os.tag == .windows;
    const vk_lib_name = if (windows) "vulkan-1" else "vulkan";
    c.linkSystemLibrary(vk_lib_name);

    if (windows) {
        var env = std.process.getEnvMap(b.allocator) catch unreachable;
        defer env.deinit();

        if (env.get("VULKAN_SDK")) |sdk_path| {
            const lib_path = b.pathJoin(&.{ sdk_path, "lib" });
            c.addLibraryPath(.{ .cwd_relative = lib_path });
        } else {
            return error.VulkanSDKNotFound;
        }
    }
}

const Shaders = struct {
    const source_exts: []const []const u8 = &.{ ".vert", ".frag" };
    const ext = ".spv";

    owner: *std.Build,
    compile: *std.Build.Step,
    module_step: *std.Build.Step,
    wf: *std.Build.Step.WriteFile,

    shaders: std.ArrayList(Shader),

    const Dir = struct {
        path: []const u8,
        recurse: bool,
        optional: bool,
        pub fn format(sdir: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            try writer.writeAll("Shader_Dir{");
            try writer.print(".path = \"{s}\", .recurse = {}, .optional = {}", .{ sdir.path, sdir.recurse, sdir.optional });
            try writer.writeAll("}");
        }
    };

    const Shader = struct {
        name: []const u8,
        path: []const u8,
    };

    pub fn init(b: *std.Build, dependency_of: *std.Build.Step, dirs: ?[]const Dir) !Shaders {
        const cstep = b.step("shaders", "compile shaders");
        const mstep = b.step("shadermodule", "create a zig module with embedded shaders");

        const wf = b.addWriteFiles();
        wf.step.name = "WriteFile shaders";

        wf.step.dependOn(cstep);
        mstep.dependOn(&wf.step);
        dependency_of.dependOn(mstep);

        var result = Shaders{
            .owner = b,
            .compile = cstep,
            .module_step = mstep,
            .wf = wf,
            .shaders = std.ArrayList(Shader).init(b.allocator),
        };

        if (dirs) |d| {
            try result.addShaderDirs(d);
        }

        return result;
    }

    fn addShaderDirs(this: *@This(), sdirs: []const Shaders.Dir) !void {
        const b = this.owner;

        const cwd = std.fs.cwd();

        const filterExtension = struct {
            pub inline fn f(path: []const u8, extensions: []const []const u8) bool {
                for (extensions) |sext| if (std.mem.endsWith(u8, std.fs.path.extension(path), sext)) {
                    return true;
                };
                return false;
            }
        }.f;

        for (sdirs) |sdir| {
            var root_dir = cwd.openDir(sdir.path, .{ .iterate = true }) catch |err| switch (err) {
                error.FileNotFound => {
                    if (sdir.optional) {
                        continue;
                    } else {
                        elog("Unable to open directory '{s}': FileNotFound", .{sdir.path});
                        return error.File_Not_Found;
                    }
                },
                else => return error.Unhandled_File_Error,
            };
            defer root_dir.close();

            if (sdir.recurse) {
                var walker = try root_dir.walk(b.allocator);
                defer walker.deinit();

                while (try walker.next()) |entry|
                    if (entry.kind == .file and filterExtension(entry.path, source_exts)) {
                        _ = try this.add(sdir.path, entry.path);
                    };
            } else {
                var it = root_dir.iterate();

                while (try it.next()) |entry|
                    if (entry.kind == .file and filterExtension(entry.name, source_exts)) {
                        _ = try this.add(sdir.path, entry.name);
                    };
            }
        }
    }

    fn add(this: *@This(), sdir_path: []const u8, s_path: []const u8) !Shader {
        const b = this.owner;

        // Remove the first directory from the prefix
        var out_prefix: []const u8 = "";
        if (std.mem.indexOfScalar(u8, sdir_path, std.fs.path.sep)) |i| if (i > 0) {
            assert(sdir_path.len > i);
            out_prefix = sdir_path[i + 1 ..];
        };

        const name = b.pathJoin(&.{ out_prefix, b.fmt("{s}", .{s_path}) });
        const output_path = b.fmt("{s}{s}", .{ name, ext });
        const input_path = this.owner.pathJoin(&.{ sdir_path, s_path });

        const compile_step = b.addSystemCommand(&.{"glslc"});
        compile_step.setName(b.fmt("compile ({s})", .{input_path}));
        compile_step.rename_step_with_output_arg = false;
        this.compile.dependOn(&compile_step.step);

        compile_step.addFileArg(b.path(input_path));
        const spv = compile_step.addPrefixedOutputFileArg("-o", output_path);

        const lazy_path = this.wf.addCopyFile(spv, output_path);
        try this.module_step.addWatchInput(lazy_path);

        try this.shaders.append(.{
            .name = name,
            .path = output_path,
        });

        return this.shaders.getLast();
    }

    pub fn emitShadersModule(this: *const @This()) !*std.Build.Module {
        const b = this.owner;

        var file_content = std.ArrayList(u8).init(b.allocator);
        defer file_content.deinit();

        const out_file_name = "shaders.zig";
        const result = b.createModule(.{ .root_source_file = this.wf.getDirectory().path(b, out_file_name) });

        for (this.shaders.items) |s| {
            try file_content.appendSlice("pub const @\"");
            try file_content.appendSlice(s.name);
            try file_content.appendSlice("\" align(4) = @embedFile(\"");
            try file_content.appendSlice(s.path);
            try file_content.appendSlice("\").*;\n");
        }

        _ = this.wf.add(out_file_name, file_content.items);

        return result;
    }
};

const CheckPathError = error{ File_Not_Found, Unhandled_File_Error };

fn checkPath(p: []const u8) CheckPathError!void {
    var myerr: ?CheckPathError = null;

    std.fs.accessAbsolute(p, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            elog("unable to open path '{s}': FileNotFound", .{p});
            myerr = error.File_Not_Found;
        },
        else => {
            myerr = error.Unhandled_File_Error;
        },
    };

    if (myerr) |e| return e;
}
