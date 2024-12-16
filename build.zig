const std = @import("std");
const assert = std.debug.assert;
const elog = std.log.err;

const builtin = @import("builtin");

var target: std.Build.ResolvedTarget = undefined;
var optimize: std.builtin.OptimizeMode = undefined;

var shaders_compile_step: *std.Build.Step = undefined;
var shaders_module_step: *std.Build.Step = undefined;

const shader_extensions: []const []const u8 = &.{ ".vert", ".frag" };

const sep = std.fs.path.sep_str;
const shader_dirs = [_]Shader_Dir{
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

    setup_shader_steps(b, exe);
    const shaders = try add_shader_dirs(b, &shader_dirs);
    const shaders_mod = try emit_shaders_module(b, shaders);

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

fn setup_shader_steps(b: *std.Build, cstep: *std.Build.Step.Compile) void {
    shaders_compile_step = b.step("shaders", "compile shaders");
    shaders_module_step = b.step("shadermodule", "create a zig module with embedded shaders");

    shaders_module_step.dependOn(shaders_compile_step);
    cstep.step.dependOn(shaders_module_step);
}

const Shader_Dir = struct {
    path: []const u8,
    recurse: bool,
    optional: bool,
    pub fn format(sdir: @This(), comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try writer.writeAll("Shader_Dir{");
        try writer.print(".path = \"{s}\", .recurse = {}, .optional = {}", .{ sdir.path, sdir.recurse, sdir.optional });
        try writer.writeAll("}");
    }
};

const Shader_Import_Info = struct {
    name: []const u8,
    root_source_file: std.Build.LazyPath,
};

fn add_shader_dirs(b: *std.Build, sdirs: []const Shader_Dir) ![]Shader_Import_Info {
    const cwd = std.fs.cwd();

    var result = std.ArrayList(Shader_Import_Info).init(b.allocator);

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

        const filter_extension = struct {
            pub inline fn f(path: []const u8, extensions: []const []const u8) bool {
                for (extensions) |ext| if (std.mem.endsWith(u8, std.fs.path.extension(path), ext)) {
                    return true;
                };
                return false;
            }
        }.f;

        if (sdir.recurse) {
            var walker = try root_dir.walk(b.allocator);
            defer walker.deinit();

            while (try walker.next()) |entry|
                if (entry.kind == .file and filter_extension(entry.path, shader_extensions)) {
                    try result.append(add_shader(b, .{ .path = entry.path, .path_prefix = sdir.path }));
                };
        } else {
            var it = root_dir.iterate();

            while (try it.next()) |entry|
                if (entry.kind == .file and filter_extension(entry.name, shader_extensions)) {
                    try result.append(add_shader(b, .{ .path = entry.name, .path_prefix = sdir.path }));
                };
        }
    }

    return result.toOwnedSlice();
}

const Add_Shader_Options = struct {
    path: []const u8,
    path_prefix: ?[]const u8 = null,
};

fn add_shader(b: *std.Build, options: Add_Shader_Options) Shader_Import_Info {
    const prefixed_path = if (options.path_prefix) |p| b.pathJoin(&.{ p, options.path }) else options.path;

    const compile_step = b.addSystemCommand(&.{"glslc"});
    compile_step.setName(b.fmt("compile ({s})", .{prefixed_path}));
    compile_step.rename_step_with_output_arg = false;
    shaders_compile_step.dependOn(&compile_step.step);

    // Remove the first directory from the prefix
    const in_file_lpath = b.path(prefixed_path);
    var out_prefix: []const u8 = "";
    if (options.path_prefix) |p| if (std.mem.indexOfScalar(u8, p, std.fs.path.sep)) |i| if (i > 0) {
        assert(p.len > i);
        out_prefix = p[i + 1 ..];
    };

    const out_file_path = b.pathJoin(&.{ out_prefix, b.fmt("shaders/{s}.spv", .{options.path}) });

    compile_step.addFileArg(in_file_lpath);
    compile_step.addArg("-o");
    const spv = compile_step.addOutputFileArg(out_file_path);

    return .{
        .name = out_file_path,
        .root_source_file = spv,
    };
}

fn emit_shaders_module(b: *std.Build, shaders: []const Shader_Import_Info) !*std.Build.Module {
    var file_content = std.ArrayList(u8).init(b.allocator);
    defer file_content.deinit();

    const out_file_name = "shaders.zig";
    const wf = b.addWriteFiles();
    var result = b.createModule(.{ .root_source_file = wf.getDirectory().path(b, out_file_name) });

    for (shaders) |s| {
        try file_content.appendSlice("pub const @\"");
        try file_content.appendSlice(s.name);
        try file_content.appendSlice("\" = @embedFile(\"");
        try file_content.appendSlice(s.name);
        try file_content.appendSlice("\");\n");

        result.addAnonymousImport(s.name, .{ .root_source_file = s.root_source_file });
    }

    _ = wf.add(out_file_name, file_content.items);

    shaders_module_step.dependOn(&wf.step);

    return result;
}

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
