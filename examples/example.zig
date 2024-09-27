const std = @import("std");

const uv = @cImport({
    @cInclude("uv.h");
});

const CustomTimer = struct {
    timer: uv.uv_timer_t,
    data: *bool,
};

fn timer_callback(handle: ?*uv.uv_timer_t) callconv(.C) void {
    const custom_timer = @as(*CustomTimer, @ptrCast(@alignCast(handle)));
    custom_timer.data.* = true;
    _ = uv.uv_timer_stop(handle);
    uv.uv_close(@as(*uv.uv_handle_t, @ptrCast(handle)), null);
}

pub fn main() !void {
    var loop: uv.uv_loop_t = undefined;
    if (uv.uv_loop_init(&loop) != 0) {
        std.debug.print("Error initializing loop\n", .{});
        return error.LoopInitFailed;
    }

    var custom_timer = try std.heap.c_allocator.create(CustomTimer);
    if (uv.uv_timer_init(&loop, &custom_timer.timer) != 0) {
        std.debug.print("Error initializing timer\n", .{});
        return error.TimerInitFailed;
    }

    var called = false;
    custom_timer.data = &called;

    if (uv.uv_timer_start(&custom_timer.timer, timer_callback, 10, 1000) != 0) {
        std.debug.print("Error starting timer\n", .{});
        return error.TimerStartFailed;
    }

    _ = uv.uv_run(&loop, uv.UV_RUN_DEFAULT);

    if (called) {
        std.debug.print("Timer callback was called\n", .{});
    } else {
        std.debug.print("Timer callback was not called\n", .{});
    }

    _ = uv.uv_loop_close(&loop);
    std.heap.c_allocator.destroy(custom_timer);
}
