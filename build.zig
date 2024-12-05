const std = @import("std");
const elog = std.log.err;

const builtin = @import("builtin");

var target: std.Build.ResolvedTarget = undefined;
var optimize: std.builtin.OptimizeMode = undefined;

pub fn build(b: *std.Build) !void {
    target = b.standardTargetOptions(.{});
    optimize = b.standardOptimizeOption(.{});

    const root_source_file = b.path("src/main.zig");

    const exe = b.addExecutable(.{
        .name = "vulkan-test",
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    add_private_module(b, exe, "src/alloc.zig", "alloc", null);
    add_private_module(b, exe, "src/vulkan.zig", "vulkan", "vk");

    if (target.result.os.tag == .linux) use_glfw(b, exe);
    try use_vulkan(b, exe);

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

fn add_private_module(b: *std.Build, cstep: *std.Build.Step.Compile, path: []const u8, name: []const u8, internal_name: ?[]const u8) void {
    const mod = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
    cstep.root_module.addImport(name, mod);
    if (internal_name) |n| mod.addImport(n, mod);
}

fn use_glfw(b: *std.Build, cstep: *std.Build.Step.Compile) void {
    const zglfw_root_source_file = b.path("src/platform/glfw.zig");

    const zglfw_lib = b.addStaticLibrary(.{
        .name = "zglfw",
        .root_source_file = zglfw_root_source_file,
        .target = target,
        .optimize = optimize,
    });

    zglfw_lib.linkLibC();
    zglfw_lib.linkSystemLibrary("glfw");

    b.installArtifact(zglfw_lib);

    const zglfw_module = b.createModule(.{
        .root_source_file = zglfw_root_source_file,
        .target = target,
        .optimize = optimize,
    });

    cstep.root_module.addImport("glfw", zglfw_module);
    cstep.linkLibrary(zglfw_lib);
}

fn use_vulkan(b: *std.Build, cstep: *std.Build.Step.Compile) !void {
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

    cstep.linkSystemLibrary(vk_lib_name);
    cstep.addLibraryPath(.{ .cwd_relative = lib_path });
    cstep.addLibraryPath(.{ .cwd_relative = include_path });
}

pub const Check_Path_Error = error{ File_Not_Found, Unhandled_File_Error };

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
