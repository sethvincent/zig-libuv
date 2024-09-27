#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <uv.h>

typedef struct {
    uv_timer_t timer;
    bool *data;
} CustomTimer;

void timer_callback(uv_timer_t *handle) {
    CustomTimer *custom_timer = (CustomTimer *)handle;
    *(custom_timer->data) = true;
    uv_timer_stop(handle);
    uv_close((uv_handle_t *)handle, NULL);
}

int main() {
    uv_loop_t *loop = malloc(sizeof(uv_loop_t));
    if (uv_loop_init(loop) != 0) {
        fprintf(stderr, "Error initializing loop\n");
        return 1;
    }

    CustomTimer *custom_timer = malloc(sizeof(CustomTimer));
    if (uv_timer_init(loop, &custom_timer->timer) != 0) {
        fprintf(stderr, "Error initializing timer\n");
        return 1;
    }

    bool called = false;
    custom_timer->data = &called;

    if (uv_timer_start(&custom_timer->timer, timer_callback, 10, 1000) != 0) {
        fprintf(stderr, "Error starting timer\n");
        return 1;
    }

    uv_run(loop, UV_RUN_DEFAULT);

    if (called) {
        printf("Timer callback was called\n");
    } else {
        printf("Timer callback was not called\n");
    }

    uv_loop_close(loop);
    free(loop);
    free(custom_timer);

    return 0;
}
