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
        .link_libc = true,
    });

    b.installArtifact(exe);

    const alloc_mod = add_private_module(b, "src/alloc.zig", "alloc");
    const util_mod = add_private_module(b, "src/util.zig", "util");
    const platform_mod = add_private_module(b, "src/platform.zig", "platform");
    const vulkan_mod = try use_vulkan(b);

    exe.root_module.addImport("alloc", alloc_mod);
    exe.root_module.addImport("util", util_mod);
    exe.root_module.addImport("platform", platform_mod);
    exe.root_module.addImport("vulkan", vulkan_mod);

    if (target.result.os.tag == .linux) {
        exe.linkSystemLibrary2("glfw", .{ .preferred_link_mode = .static });
        exe.linkSystemLibrary("X11");
        exe.linkSystemLibrary("X11-xcb");
    }

    vulkan_mod.addImport("alloc", alloc_mod);
    vulkan_mod.addImport("util", util_mod);
    vulkan_mod.addImport("platform", platform_mod);

    platform_mod.addImport("vulkan", vulkan_mod);
    platform_mod.addImport("util", util_mod);

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

fn use_vulkan(b: *std.Build) !*std.Build.Module {
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

    const vk_mod = add_private_module(b, "src/vulkan.zig", "vulkan");
    vk_mod.addLibraryPath(.{ .cwd_relative = lib_path });
    vk_mod.addIncludePath(.{ .cwd_relative = include_path });
    vk_mod.linkSystemLibrary(vk_lib_name, .{});

    return vk_mod;
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
