const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const root_source_file = b.path("src/main.zig");
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

    const exe = b.addExecutable(.{
        .name = "vulkan-test",
        .root_source_file = root_source_file,
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("glfw", zglfw_module);
    exe.linkLibrary(zglfw_lib);

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const clean_step = b.step("clean", "Clean zig-out and .zig-cache");
    clean_step.dependOn(&b.addRemoveDirTree(std.Build.LazyPath{ .cwd_relative = b.install_path }).step);
    clean_step.dependOn(&b.addRemoveDirTree(b.path(".zig-cache")).step);
}
