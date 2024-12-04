const std = @import("std");
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

    if (target.result.os.tag == .linux) use_glfw(b, exe);

    const vk_lib_name = if (target.result.os.tag == .windows) "vulkan-1" else "vulkan";
    exe.linkSystemLibrary(vk_lib_name);
    const env_var_map = try std.process.getEnvMap(b.allocator);
    if (env_var_map.get("VK_SDK_PATH")) |path| {
        exe.addLibraryPath(.{ .cwd_relative = try std.fmt.allocPrint(b.allocator, "{s}/lib", .{path}) });
        exe.addLibraryPath(.{ .cwd_relative = try std.fmt.allocPrint(b.allocator, "{s}/include", .{path}) });
    } else {
        std.log.err("Unable to find vulkan library", .{});
        return error.Vulkan_Lib_Not_Found;
    }

    const alloc_mod = b.createModule(.{
        .root_source_file = b.path("src/alloc.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("alloc", alloc_mod);

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
