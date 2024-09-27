# zig-build-libuv

Build [libuv](https://github.com/libuv/libuv) with easy cross-compilation enabled by [Zig](https://github.com/ziglang/zig)!

## Usage

To **build libuv:**

Add the dependency:

```sh
zig fetch --save=zig_build_libuv "git ref url"
```

A gif ref url can be a commit, tag, release, etc.

```zig
pub fn build(b: *std.Build) !void {
    const build_libuv = b.dependency("zig_build_libuv", .{
        .target = target,
        .optimize = optimize,
    });

    const libuv = build_libuv.artifact("uv");

    // exe or lib setup

    exe.linkLibrary(libuv); // or lib.linkLibrary(libuv);
}
```

Import in your zig file:

```zig
const uv = @cImport({
    @cInclude("uv.h");
});
```
