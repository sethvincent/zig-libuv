# zig-build-libuv

Build [libuv](https://github.com/libuv/libuv) with easy cross-compilation enabled by [Zig](https://github.com/ziglang/zig)!

## About

This continues the work from the archived [mitchellh/zig-libuv](https://github.com/mitchellh/zig-libuv) repository.

This repo's only responsibility is building libuv.

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

## Examples

Check out the two examples in the examples directory:

- [example.zig](./examples/example.zig)
- [example.c](./examples/example.c)

You can build them by running:

```sh
zig build examples
```

And run the resulting executables:

```sh
# zig example
./zig-out/bin/example_zig

# c example
./zig-out/bin/example.c
```

## See also
- [libxev](https://github.com/mitchellh/libxev) - an alternate event loop implemented in zig!

## License
[MIT](LICENSE)
