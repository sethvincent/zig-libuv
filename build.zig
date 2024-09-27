const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const target_os = target.result.os.tag;

    const upstream = b.dependency("upstream", .{
        .target = target,
        .optimize = optimize,
    });

    const libuv = b.addStaticLibrary(.{
        .name = "uv",
        .target = target,
        .optimize = optimize,
    });

    if (target_os == .windows) {
        libuv.linkSystemLibrary("psapi");
        libuv.linkSystemLibrary("user32");
        libuv.linkSystemLibrary("advapi32");
        libuv.linkSystemLibrary("iphlpapi");
        libuv.linkSystemLibrary("userenv");
        libuv.linkSystemLibrary("ws2_32");
    }

    if (target_os == .linux) {
        libuv.linkSystemLibrary("pthread");
    }

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    if (target_os != .windows) {
        try flags.appendSlice(&.{
            "-D_FILE_OFFSET_BITS=64",
            "-D_LARGEFILE_SOURCE",
        });
    }

    if (target_os == .linux) {
        try flags.appendSlice(&.{
            "-D_GNU_SOURCE",
            "-D_POSIX_C_SOURCE=200112",
        });
    }

    if (target_os.isDarwin()) {
        try flags.appendSlice(&.{
            "-D_DARWIN_UNLIMITED_SELECT=1",
            "-D_DARWIN_USE_64_BIT_INODE=1",
        });
    }

    libuv.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = common_sources,
        .flags = flags.items,
    });

    if (target_os != .windows) {
        libuv.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = non_windows_sources,
            .flags = flags.items,
        });
    }

    if (target_os == .linux or target_os.isDarwin()) {
        libuv.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &.{
                "unix/proctitle.c",
            },
            .flags = flags.items,
        });
    }

    if (target_os == .linux) {
        libuv.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &.{
                "unix/linux.c",
                "unix/procfs-exepath.c",
                "unix/random-getrandom.c",
                "unix/random-sysctl-linux.c",
            },
            .flags = flags.items,
        });
    }


    if (target_os.isBSD()) { // includes darwin
        libuv.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &.{
                "unix/bsd-ifaddrs.c",
                "unix/kqueue.c",
            },
            .flags = flags.items,
        });
    }

    if (target_os.isDarwin() or target_os == .openbsd) {
        libuv.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &.{
                "unix/random-getentropy.c"
            },
            .flags = flags.items,
        });
    }

    if (target_os.isDarwin()) {
        libuv.addCSourceFiles(.{
            .root = upstream.path("src"),
            .files = &.{
                "unix/darwin-proctitle.c",
                "unix/darwin.c",
                "unix/fsevents.c",
            },
            .flags = flags.items,
        });
    }

    libuv.addIncludePath(upstream.path("include"));
    libuv.addIncludePath(upstream.path("src"));
    libuv.linkLibC();
    b.installArtifact(libuv);

    libuv.installHeadersDirectory(upstream.path("include"), "", .{});
    libuv.installHeadersDirectory(upstream.path("include"), "uv", .{});
    libuv.installHeadersDirectory(upstream.path("src"), "uv", .{});

    const example_step = b.step("examples", "Build example programs");
    const c_example = b.addExecutable(.{
        .name = "example_c",
        .target = target,
        .optimize = optimize,
    });

    c_example.addIncludePath(b.path("include"));
    c_example.linkLibrary(libuv);
    c_example.addCSourceFiles(.{
        .root = b.path("examples"),
        .files = &.{"example.c"}
    });

    const zig_example = b.addExecutable(.{
        .name = "example_zig",
        .root_source_file = b.path("examples/example.zig"),
        .target = target,
        .optimize = optimize,
    });

    zig_example.addIncludePath(b.path("include"));
    zig_example.linkLibrary(libuv);

    const install_c_example = b.addInstallArtifact(c_example, .{});
    const install_zig_example = b.addInstallArtifact(zig_example, .{});
    example_step.dependOn(&install_c_example.step);
    example_step.dependOn(&install_zig_example.step);
}

const common_sources: []const []const u8 = &.{
    "fs-poll.c",
    "idna.c",
    "inet.c",
    "random.c",
    "strscpy.c",
    "strtok.c",
    "threadpool.c",
    "timer.c",
    "uv-common.c",
    "uv-data-getter-setters.c",
    "version.c",
};

const non_windows_sources: []const []const u8 = &.{
    "unix/async.c",
    "unix/core.c",
    "unix/dl.c",
    "unix/fs.c",
    "unix/getaddrinfo.c",
    "unix/getnameinfo.c",
    "unix/loop-watcher.c",
    "unix/loop.c",
    "unix/pipe.c",
    "unix/poll.c",
    "unix/process.c",
    "unix/random-devurandom.c",
    "unix/signal.c",
    "unix/stream.c",
    "unix/tcp.c",
    "unix/thread.c",
    "unix/tty.c",
    "unix/udp.c",
};
