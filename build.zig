const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{
        .default_target = .{ .cpu_arch = .x86_64, .os_tag = .windows, .abi = .gnu },
    });

    if (target.result.os.tag != .windows) {
        return error.UnsupportedTargetPlatform;
    }

    const fbgen = b.addSharedLibrary(.{
        .name = "FrostbiteGen",
        .target = target,
        .optimize = optimize,
    });

    fbgen.installHeader(b.path("required.h"), "required.h");
    fbgen.installHeader(b.path("classinfo.h"), "classinfo.h");
    fbgen.installHeader(b.path("structs.h"), "structs.h");

    fbgen.linkLibCpp();

    fbgen.addCSourceFiles(.{
        .root = b.path("."),
        .files = &.{
            "main.cpp",
            "classinfo.cpp",
        },
        .flags = &.{
            "-std=c++17",
            "-Wall",
            "-Wextra",
            "-D_CRT_SECURE_NO_WARNINGS",
            "-DWIN32_LEAN_AND_MEAN",
        },
    });

    b.installArtifact(fbgen);
}
