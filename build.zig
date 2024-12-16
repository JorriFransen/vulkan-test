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

    const window_verbose = b.option(bool, "window-verbose", "Enable verbose window logging") orelse false;
    const vulkan_verbose = b.option(bool, "vulkan-verbose", "Enable verbose vulkan logging") orelse false;

    const options = b.addOptions();
    options.addOption(bool, "window_verbose", window_verbose);
    options.addOption(bool, "vulkan_verbose", vulkan_verbose);
    const options_mod = options.createModule();

    const flags_dep = b.dependency("flags", .{ .target = target, .optimize = optimize });
    const flags_mod = flags_dep.module("flags");

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

    if (target.result.os.tag == .linux) {
        exe.linkSystemLibrary2("glfw", .{ .preferred_link_mode = .static });
        exe.linkSystemLibrary("X11");
        exe.linkSystemLibrary("X11-xcb");
    }

    const alloc_mod = add_private_module(b, "src/alloc.zig", "alloc");
    const util_mod = add_private_module(b, "src/util.zig", "util");
    const platform_mod = add_private_module(b, "src/platform.zig", "platform");
    const vulkan_info = try use_vulkan(b);
    const vulkan_mod = vulkan_info.module;

    const shaders = try Shaders.init(b, &exe.step, &shader_dirs);
    const shaders_mod = try shaders.emit_shaders_module();

    exe.root_module.addImport("alloc", alloc_mod);
    exe.root_module.addImport("platform", platform_mod);
    exe.root_module.addImport("vulkan", vulkan_mod);
    exe.root_module.addImport("flags", flags_mod);
    exe.root_module.addImport("options", options_mod);

    vulkan_mod.addImport("alloc", alloc_mod);
    vulkan_mod.addImport("util", util_mod);
    vulkan_mod.addImport("platform", platform_mod);
    vulkan_mod.addImport("options", options_mod);
    vulkan_mod.addImport("shaders", shaders_mod);

    platform_mod.addIncludePath(vulkan_info.include_path);
    platform_mod.addImport("util", util_mod);
    platform_mod.addImport("vulkan", vulkan_mod);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const clean_step = b.step("clean", "Clean zig-out and .zig-cache");
    clean_step.dependOn(&b.addRemoveDirTree(std.Build.LazyPath{ .cwd_relative = b.install_path }).step);
    if (builtin.os.tag != .windows)
        clean_step.dependOn(&b.addRemoveDirTree(std.Build.LazyPath{ .cwd_relative = b.cache_root.path.? }).step);
}

fn add_private_module(b: *std.Build, path: []const u8, name: []const u8) *std.Build.Module {
    const mod = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
    mod.addImport(name, mod);

    return mod;
}

const Vulkan_Info = struct {
    module: *std.Build.Module,
    include_path: std.Build.LazyPath,
    lib_path: std.Build.LazyPath,
};

fn use_vulkan(b: *std.Build) !Vulkan_Info {
    const vk_lib_name = if (target.result.os.tag == .windows) "vulkan-1" else "vulkan";
    var lib_path: []const u8 = undefined;
    var include_path: []const u8 = undefined;

    const env_var_map = try std.process.getEnvMap(b.allocator);
    if (env_var_map.get("VK_SDK_PATH")) |path| {
        lib_path = try std.fmt.allocPrint(b.allocator, "{s}/lib", .{path});
        include_path = try std.fmt.allocPrint(b.allocator, "{s}/include", .{path});
    } else {

        // Nix
        if (env_var_map.get("VK_LIB_PATH")) |path| {
            lib_path = path;
        } else {
            return error.VK_LIB_PATH_Not_Set;
        }

        if (env_var_map.get("VK_INCLUDE_PATH")) |path| {
            include_path = path;
        } else {
            return error.VK_INCLUDE_PATH_Not_Set;
        }
    }

    try check_path(lib_path);
    try check_path(include_path);

    const lazy_lib_path = std.Build.LazyPath{ .cwd_relative = lib_path };
    const lazy_include_path = std.Build.LazyPath{ .cwd_relative = include_path };

    const vk_mod = add_private_module(b, "src/vulkan.zig", "vulkan");
    vk_mod.addLibraryPath(lazy_lib_path);
    vk_mod.addIncludePath(lazy_include_path);
    vk_mod.linkSystemLibrary(vk_lib_name, .{});

    return .{
        .module = vk_mod,
        .include_path = lazy_include_path,
        .lib_path = lazy_lib_path,
    };
}

const Shaders = struct {
    const source_exts: []const []const u8 = &.{ ".vert", ".frag" };
    const ext = ".spv";

    owner: *std.Build,
    compile: *std.Build.Step,
    module_step: *std.Build.Step,
    // wf: *std.Build.Step.WriteFile,

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
        root_source_file: std.Build.LazyPath,
    };

    pub fn init(b: *std.Build, dependency_of: *std.Build.Step, dirs: ?[]const Dir) !Shaders {
        const cstep = b.step("shaders", "compile shaders");
        const mstep = b.step("shadermodule", "create a zig module with embedded shaders");

        mstep.dependOn(cstep);
        dependency_of.dependOn(mstep);

        var result = Shaders{
            .owner = b,
            .compile = cstep,
            .module_step = mstep,
            // .wf = b.addWriteFiles(),
            .shaders = std.ArrayList(Shader).init(b.allocator),
        };

        if (dirs) |d| {
            try result.add_shader_dirs(d);
        }

        return result;
    }

    fn add_shader_dirs(this: *@This(), sdirs: []const Shaders.Dir) !void {
        const b = this.owner;

        const cwd = std.fs.cwd();

        const filter_extension = struct {
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
                    if (entry.kind == .file and filter_extension(entry.path, source_exts)) {
                        _ = try this.add(sdir.path, entry.path);
                    };
            } else {
                var it = root_dir.iterate();

                while (try it.next()) |entry|
                    if (entry.kind == .file and filter_extension(entry.name, source_exts)) {
                        _ = try this.add(sdir.path, entry.name);
                    };
            }
        }
    }

    fn add(this: *@This(), sdir_path: []const u8, s_path: []const u8) !Shader {
        const b = this.owner;
        //
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
        compile_step.addArg("-o");
        const spv = compile_step.addOutputFileArg(output_path);

        try this.shaders.append(.{
            .name = name,
            .path = output_path,
            .root_source_file = spv,
        });

        return this.shaders.getLast();
    }

    pub fn emit_shaders_module(this: *const @This()) !*std.Build.Module {
        const b = this.owner;

        var file_content = std.ArrayList(u8).init(b.allocator);
        defer file_content.deinit();

        const out_file_name = "shaders.zig";
        const wf = b.addWriteFiles();
        var result = b.createModule(.{ .root_source_file = wf.getDirectory().path(b, out_file_name) });

        for (this.shaders.items) |s| {
            try file_content.appendSlice("pub const @\"");
            try file_content.appendSlice(s.name);
            try file_content.appendSlice("\" = @embedFile(\"");
            try file_content.appendSlice(s.path);
            try file_content.appendSlice("\");\n");

            result.addAnonymousImport(s.path, .{ .root_source_file = s.root_source_file });
        }

        _ = wf.add(out_file_name, file_content.items);

        this.module_step.dependOn(&wf.step);

        return result;
    }
};

const Check_Path_Error = error{ File_Not_Found, Unhandled_File_Error };

fn check_path(p: []const u8) Check_Path_Error!void {
    var myerr: ?Check_Path_Error = null;

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
