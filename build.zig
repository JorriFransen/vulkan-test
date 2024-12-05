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

    const alloc_mod = add_private_module(b, exe, "src/alloc.zig", "alloc", null);
    const window_mod = add_private_module(b, exe, "src/window.zig", "window", null);

    if (target.result.os.tag == .linux) {
        const glfw_mod = use_glfw(b, exe);
        window_mod.addImport("glfw", glfw_mod);
    }
    const vulkan_mod = try use_vulkan(b, exe);
    vulkan_mod.addImport("alloc", alloc_mod);
    vulkan_mod.addImport("window", window_mod);

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

fn add_private_module(b: *std.Build, cstep: *std.Build.Step.Compile, path: []const u8, name: []const u8, internal_name: ?[]const u8) *std.Build.Module {
    const mod = b.createModule(.{
        .root_source_file = b.path(path),
        .target = target,
        .optimize = optimize,
    });
    cstep.root_module.addImport(name, mod);
    if (internal_name) |n| mod.addImport(n, mod);

    return mod;
}

fn use_glfw(b: *std.Build, cstep: *std.Build.Step.Compile) *std.Build.Module {
    const zglfw_root_source_file = b.path("src/platform/glfw.zig");

    const zglfw_lib = b.addStaticLibrary(.{
        .name = "zglfw",
        .root_source_file = zglfw_root_source_file,
        .target = target,
        .optimize = optimize,
    });

    cstep.linkLibC();
    cstep.linkSystemLibrary2("glfw", .{ .preferred_link_mode = .static });

    b.installArtifact(zglfw_lib);

    const zglfw_module = b.createModule(.{
        .root_source_file = zglfw_root_source_file,
        .target = target,
        .optimize = optimize,
    });

    cstep.root_module.addImport("glfw", zglfw_module);
    cstep.linkLibrary(zglfw_lib);

    return zglfw_module;
}

fn use_vulkan(b: *std.Build, cstep: *std.Build.Step.Compile) !*std.Build.Module {
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

    const vk_mod = add_private_module(b, cstep, "src/vulkan.zig", "vulkan", "vk");
    vk_mod.addLibraryPath(.{ .cwd_relative = lib_path });
    vk_mod.addIncludePath(.{ .cwd_relative = include_path });
    vk_mod.linkSystemLibrary(vk_lib_name, .{});
    vk_mod.link_libc = true;

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
