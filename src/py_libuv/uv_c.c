
#include <uv.h>
#include <fcntl.h>
#include <stdlib.h>

uv_loop_t* loop;
uv_fs_t *open_req;
uv_buf_t iov;

void on_read(uv_fs_t *req)
{
    printf("iov :%d %d\n", &iov, iov.len);
    printf("onread req:%d\n", req->result);
    printf("read res: %s\n", iov.base);
    if (req->result < 0)
    {
        fprintf(stderr, "Read error: %s\n", uv_strerror(req->result));
    }
    else if (req->result == 0)
    {
        uv_fs_t close_req;
        // synchronous
        uv_fs_close(loop, &close_req, open_req->result, NULL);
    }
    else if (req->result > 0)
    {
        printf("111111111\n");
        // iov.len = req->result;
        printf("req : %d\n", req->result);
        // uv_fs_write(uv_default_loop(), &write_req, 1, &iov, 1, -1, on_write);
    }
}

void cb(uv_fs_t *req)
{
    char *buffer = malloc(1024 * 1024 * sizeof(char));
    printf("%d\n", req->result);
    uv_fs_t read_req;
    if (req->result >= 0)
    {
        iov = uv_buf_init(buffer, 10);
        printf("buf: %s, iov %d\n", iov.base, iov.len);
        int r = uv_fs_read(loop, &read_req, req->result,
                   &iov, 1, -1, on_read);
        printf("readr %d\n", r);
    }
    else
    {
        fprintf(stderr, "error opening file: %s\n", uv_strerror((int)req->result));
    }
}

int main()
{
    const char *path = "/home/pi/Documents/caiofiles/main.py";
    printf("%s\n", path);
    loop = malloc(sizeof(uv_loop_t));
    int init_r = uv_loop_init(loop);
    printf("init loop res: %s\n", uv_strerror(init_r));
    uv_fs_t *req = malloc(sizeof(uv_fs_t));
    open_req = req;
    int flags = O_RDONLY;
    int mode = S_IRWXU;
    printf("flags: %d, mode:%d\n", flags, mode);
    int r = uv_fs_open(loop, req, path, flags, mode, cb);
    printf("uv_fs_open %d\n", r);
    r = uv_run(loop, UV_RUN_DEFAULT);
    printf("run r :%d\n", r);
    uv_loop_close(loop);
    return 0;
}