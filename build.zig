const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "growsc-server",
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Add C library dependencies
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("enet");
    exe.linkSystemLibrary("z");

    // For now, let's not include the problematic C++ files
    // We'll implement the networking functionality in pure Zig later
    // exe.linkLibCpp(); // Add C++ standard library

    // Add include directories
    exe.addIncludePath(.{ .cwd_relative = "../enet/include" });
    exe.addIncludePath(.{ .cwd_relative = "../enet_new/include/enet" });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the GrowSC server");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = .{ .cwd_relative = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
} 