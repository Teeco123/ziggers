const std = @import("std");

const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .x86_64, .os_tag = .linux },
    .{ .cpu_arch = .x86_64, .os_tag = .windows },
};

pub fn build(b: *std.Build) !void {
    for (targets) |t| {
        const raylib_dep = b.dependency("raylib-zig", .{
            .target = b.host,
            .optimize = .ReleaseSafe,
        });

        const raylib = raylib_dep.module("raylib"); // main raylib module
        const raylib_artifact = raylib_dep.artifact("raylib"); // raylib C library

        const exe = b.addExecutable(.{
            .name = "Ziggers",
            .root_source_file = b.path("src/main.zig"),
            .target = b.host,
            .optimize = .ReleaseSafe,
        });

        exe.linkLibrary(raylib_artifact);
        exe.root_module.addImport("raylib", raylib);

        const target_output = b.addInstallArtifact(exe, .{
            .dest_dir = .{
                .override = .{
                    .custom = try t.zigTriple(b.allocator),
                },
            },
        });

        b.getInstallStep().dependOn(&target_output.step);
    }
}
