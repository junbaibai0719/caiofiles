from libc.stdint cimport uint64_t, int64_t, int32_t, uint16_t

cdef extern from "uv.h" nogil:
    ctypedef struct sockaddr:
        pass
    ctypedef struct sockaddr_in:
        pass
    ctypedef struct sockaddr_in6:
        pass
    ctypedef struct sockaddr_storage:
        pass
    ctypedef struct addrinfo:
        pass
    ctypedef struct termios:
        pass
    ctypedef struct DIR:
        pass

    cdef struct uv__queue:
        uv__queue* next
        uv__queue* prev

    ctypedef void (*_uv__work_work_ft)(uv__work* w)

    ctypedef void (*_uv__work_done_ft)(uv__work* w, int status)

    cdef struct uv__work:
        _uv__work_work_ft work
        _uv__work_done_ft done
        uv_loop_s* loop
        void* wq[2]

    cdef struct uv__io_s

    cdef struct uv_loop_s

    ctypedef void (*uv__io_cb)(uv_loop_s* loop, uv__io_s* w, unsigned int events)

    ctypedef uv__io_s uv__io_t

    cdef struct uv__io_s:
        uv__io_cb cb
        void* pending_queue[2]
        void* watcher_queue[2]
        unsigned int pevents
        unsigned int events
        int fd

    cdef struct uv_buf_t:
        char* base
        size_t len

    ctypedef int uv_file

    ctypedef int uv_os_sock_t

    ctypedef int uv_os_fd_t

    ctypedef int pid_t
    ctypedef int pthread_once_t
    ctypedef int pthread_t
    ctypedef int pthread_mutex_t
    ctypedef int pthread_rwlock_t
    ctypedef int sem_t
    ctypedef int pthread_cond_t 
    ctypedef int pthread_key_t 

    ctypedef pid_t uv_pid_t

    ctypedef pthread_once_t uv_once_t

    ctypedef pthread_t uv_thread_t

    ctypedef pthread_mutex_t uv_mutex_t

    ctypedef pthread_rwlock_t uv_rwlock_t

    ctypedef sem_t uv_sem_t

    ctypedef pthread_cond_t uv_cond_t

    ctypedef pthread_key_t uv_key_t

    cdef struct _uv_barrier:
        uv_mutex_t mutex
        uv_cond_t cond
        unsigned threshold
        unsigned in_ "in"
        unsigned out

    ctypedef struct uv_barrier_t:
        _uv_barrier* b
    
    ctypedef int gid_t
    ctypedef int uid_t
    ctypedef int dirent

    ctypedef struct FILE:
        pass

    ctypedef gid_t uv_gid_t

    ctypedef uid_t uv_uid_t

    ctypedef dirent uv__dirent_t

    ctypedef struct uv_lib_t:
        void* handle
        char* errmsg

    ctypedef enum uv_errno_t:
        UV_E2BIG
        UV_EACCES
        UV_EADDRINUSE
        UV_EADDRNOTAVAIL
        UV_EAFNOSUPPORT
        UV_EAGAIN
        UV_EAI_ADDRFAMILY
        UV_EAI_AGAIN
        UV_EAI_BADFLAGS
        UV_EAI_BADHINTS
        UV_EAI_CANCELED
        UV_EAI_FAIL
        UV_EAI_FAMILY
        UV_EAI_MEMORY
        UV_EAI_NODATA
        UV_EAI_NONAME
        UV_EAI_OVERFLOW
        UV_EAI_PROTOCOL
        UV_EAI_SERVICE
        UV_EAI_SOCKTYPE
        UV_EALREADY
        UV_EBADF
        UV_EBUSY
        UV_ECANCELED
        UV_ECHARSET
        UV_ECONNABORTED
        UV_ECONNREFUSED
        UV_ECONNRESET
        UV_EDESTADDRREQ
        UV_EEXIST
        UV_EFAULT
        UV_EFBIG
        UV_EHOSTUNREACH
        UV_EINTR
        UV_EINVAL
        UV_EIO
        UV_EISCONN
        UV_EISDIR
        UV_ELOOP
        UV_EMFILE
        UV_EMSGSIZE
        UV_ENAMETOOLONG
        UV_ENETDOWN
        UV_ENETUNREACH
        UV_ENFILE
        UV_ENOBUFS
        UV_ENODEV
        UV_ENOENT
        UV_ENOMEM
        UV_ENONET
        UV_ENOPROTOOPT
        UV_ENOSPC
        UV_ENOSYS
        UV_ENOTCONN
        UV_ENOTDIR
        UV_ENOTEMPTY
        UV_ENOTSOCK
        UV_ENOTSUP
        UV_EOVERFLOW
        UV_EPERM
        UV_EPIPE
        UV_EPROTO
        UV_EPROTONOSUPPORT
        UV_EPROTOTYPE
        UV_ERANGE
        UV_EROFS
        UV_ESHUTDOWN
        UV_ESPIPE
        UV_ESRCH
        UV_ETIMEDOUT
        UV_ETXTBSY
        UV_EXDEV
        UV_UNKNOWN
        UV_EOF
        UV_ENXIO
        UV_EMLINK
        UV_EHOSTDOWN
        UV_EREMOTEIO
        UV_ENOTTY
        UV_EFTYPE
        UV_EILSEQ
        UV_ESOCKTNOSUPPORT
        UV_ENODATA
        UV_EUNATCH
        UV_ERRNO_MAX

    ctypedef enum uv_handle_type:
        UV_UNKNOWN_HANDLE
        UV_ASYNC
        UV_CHECK
        UV_FS_EVENT
        UV_FS_POLL
        UV_HANDLE
        UV_IDLE
        UV_NAMED_PIPE
        UV_POLL
        UV_PREPARE
        UV_PROCESS
        UV_STREAM
        UV_TCP
        UV_TIMER
        UV_TTY
        UV_UDP
        UV_SIGNAL
        UV_FILE
        UV_HANDLE_TYPE_MAX

    ctypedef enum uv_req_type:
        UV_UNKNOWN_REQ
        UV_REQ
        UV_CONNECT
        UV_WRITE
        UV_SHUTDOWN
        UV_UDP_SEND
        UV_FS
        UV_WORK
        UV_GETADDRINFO
        UV_GETNAMEINFO
        UV_RANDOM
        UV_REQ_TYPE_MAX

    ctypedef uv_loop_s uv_loop_t

    ctypedef uv_handle_s uv_handle_t

    ctypedef uv_dir_s uv_dir_t

    ctypedef uv_stream_s uv_stream_t

    ctypedef uv_tcp_s uv_tcp_t

    ctypedef uv_udp_s uv_udp_t

    ctypedef uv_pipe_s uv_pipe_t

    ctypedef uv_tty_s uv_tty_t

    ctypedef uv_poll_s uv_poll_t

    ctypedef uv_timer_s uv_timer_t

    ctypedef uv_prepare_s uv_prepare_t

    ctypedef uv_check_s uv_check_t

    ctypedef uv_idle_s uv_idle_t

    ctypedef uv_async_s uv_async_t

    ctypedef uv_process_s uv_process_t

    ctypedef uv_fs_event_s uv_fs_event_t

    ctypedef uv_fs_poll_s uv_fs_poll_t

    ctypedef uv_signal_s uv_signal_t

    ctypedef uv_req_s uv_req_t

    ctypedef uv_getaddrinfo_s uv_getaddrinfo_t

    ctypedef uv_getnameinfo_s uv_getnameinfo_t

    ctypedef uv_shutdown_s uv_shutdown_t

    ctypedef uv_write_s uv_write_t

    ctypedef uv_connect_s uv_connect_t

    ctypedef uv_udp_send_s uv_udp_send_t

    ctypedef uv_fs_s uv_fs_t

    ctypedef uv_work_s uv_work_t

    ctypedef uv_random_s uv_random_t

    ctypedef uv_env_item_s uv_env_item_t

    ctypedef uv_cpu_info_s uv_cpu_info_t

    ctypedef uv_interface_address_s uv_interface_address_t

    ctypedef uv_dirent_s uv_dirent_t

    ctypedef uv_passwd_s uv_passwd_t

    ctypedef uv_group_s uv_group_t

    ctypedef uv_utsname_s uv_utsname_t

    ctypedef uv_statfs_s uv_statfs_t

    ctypedef uv_metrics_s uv_metrics_t

    ctypedef enum uv_loop_option:
        UV_LOOP_BLOCK_SIGNAL
        UV_METRICS_IDLE_TIME

    ctypedef enum uv_run_mode:
        UV_RUN_DEFAULT
        UV_RUN_ONCE
        UV_RUN_NOWAIT

    unsigned int uv_version()

    const char* uv_version_string()

    ctypedef void* (*uv_malloc_func)(size_t size)

    ctypedef void* (*uv_realloc_func)(void* ptr, size_t size)

    ctypedef void* (*uv_calloc_func)(size_t count, size_t size)

    ctypedef void (*uv_free_func)(void* ptr)

    void uv_library_shutdown()

    int uv_replace_allocator(uv_malloc_func malloc_func, uv_realloc_func realloc_func, uv_calloc_func calloc_func, uv_free_func free_func)

    uv_loop_t* uv_default_loop()

    int uv_loop_init(uv_loop_t* loop)

    int uv_loop_close(uv_loop_t* loop)

    uv_loop_t* uv_loop_new()

    void uv_loop_delete(uv_loop_t*)

    size_t uv_loop_size()

    int uv_loop_alive(const uv_loop_t* loop)

    int uv_loop_configure(uv_loop_t* loop, uv_loop_option option)

    int uv_loop_fork(uv_loop_t* loop)

    int uv_run(uv_loop_t*, uv_run_mode mode)

    void uv_stop(uv_loop_t*)

    void uv_ref(uv_handle_t*)

    void uv_unref(uv_handle_t*)

    int uv_has_ref(const uv_handle_t*)

    void uv_update_time(uv_loop_t*)

    uint64_t uv_now(const uv_loop_t*)

    int uv_backend_fd(const uv_loop_t*)

    int uv_backend_timeout(const uv_loop_t*)

    ctypedef void (*uv_alloc_cb)(uv_handle_t* handle, size_t suggested_size, uv_buf_t* buf)

    ctypedef void (*uv_read_cb)(uv_stream_t* stream, ssize_t nread, const uv_buf_t* buf)

    ctypedef void (*uv_write_cb)(uv_write_t* req, int status)

    ctypedef void (*uv_connect_cb)(uv_connect_t* req, int status)

    ctypedef void (*uv_shutdown_cb)(uv_shutdown_t* req, int status)

    ctypedef void (*uv_connection_cb)(uv_stream_t* server, int status)

    ctypedef void (*uv_close_cb)(uv_handle_t* handle)

    ctypedef void (*uv_poll_cb)(uv_poll_t* handle, int status, int events)

    ctypedef void (*uv_timer_cb)(uv_timer_t* handle)

    ctypedef void (*uv_async_cb)(uv_async_t* handle)

    ctypedef void (*uv_prepare_cb)(uv_prepare_t* handle)

    ctypedef void (*uv_check_cb)(uv_check_t* handle)

    ctypedef void (*uv_idle_cb)(uv_idle_t* handle)

    ctypedef void (*uv_exit_cb)(uv_process_t*, int64_t exit_status, int term_signal)

    ctypedef void (*uv_walk_cb)(uv_handle_t* handle, void* arg)

    ctypedef void (*uv_fs_cb)(uv_fs_t* req)

    ctypedef void (*uv_work_cb)(uv_work_t* req)

    ctypedef void (*uv_after_work_cb)(uv_work_t* req, int status)

    ctypedef void (*uv_getaddrinfo_cb)(uv_getaddrinfo_t* req, int status, addrinfo* res)

    ctypedef void (*uv_getnameinfo_cb)(uv_getnameinfo_t* req, int status, const char* hostname, const char* service)

    ctypedef void (*uv_random_cb)(uv_random_t* req, int status, void* buf, size_t buflen)

    ctypedef enum uv_clock_id:
        UV_CLOCK_MONOTONIC
        UV_CLOCK_REALTIME

    ctypedef struct uv_timespec_t:
        long tv_sec
        long tv_nsec

    ctypedef struct uv_timespec64_t:
        int64_t tv_sec
        int32_t tv_nsec

    ctypedef struct uv_timeval_t:
        long tv_sec
        long tv_usec

    ctypedef struct uv_timeval64_t:
        int64_t tv_sec
        int32_t tv_usec

    ctypedef struct uv_stat_t:
        uint64_t st_dev
        uint64_t st_mode
        uint64_t st_nlink
        uint64_t st_uid
        uint64_t st_gid
        uint64_t st_rdev
        uint64_t st_ino
        uint64_t st_size
        uint64_t st_blksize
        uint64_t st_blocks
        uint64_t st_flags
        uint64_t st_gen
        uv_timespec_t st_atim
        uv_timespec_t st_mtim
        uv_timespec_t st_ctim
        uv_timespec_t st_birthtim

    ctypedef void (*uv_fs_event_cb)(uv_fs_event_t* handle, const char* filename, int events, int status)

    ctypedef void (*uv_fs_poll_cb)(uv_fs_poll_t* handle, int status, const uv_stat_t* prev, const uv_stat_t* curr)

    ctypedef void (*uv_signal_cb)(uv_signal_t* handle, int signum)

    ctypedef enum uv_membership:
        UV_LEAVE_GROUP
        UV_JOIN_GROUP

    int uv_translate_sys_error(int sys_errno)

    const char* uv_strerror(int err)

    char* uv_strerror_r(int err, char* buf, size_t buflen)

    const char* uv_err_name(int err)

    char* uv_err_name_r(int err, char* buf, size_t buflen)

    cdef struct uv_req_s:
        void* data
        uv_req_type type
        void* reserved[6]

    int uv_shutdown(uv_shutdown_t* req, uv_stream_t* handle, uv_shutdown_cb cb)

    cdef struct uv_shutdown_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_stream_t* handle
        uv_shutdown_cb cb

    cdef union _uv_handle_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_handle_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_handle_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags

    size_t uv_handle_size(uv_handle_type type)

    uv_handle_type uv_handle_get_type(const uv_handle_t* handle)

    const char* uv_handle_type_name(uv_handle_type type)

    void* uv_handle_get_data(const uv_handle_t* handle)

    uv_loop_t* uv_handle_get_loop(const uv_handle_t* handle)

    void uv_handle_set_data(uv_handle_t* handle, void* data)

    size_t uv_req_size(uv_req_type type)

    void* uv_req_get_data(const uv_req_t* req)

    void uv_req_set_data(uv_req_t* req, void* data)

    uv_req_type uv_req_get_type(const uv_req_t* req)

    const char* uv_req_type_name(uv_req_type type)

    int uv_is_active(const uv_handle_t* handle)

    void uv_walk(uv_loop_t* loop, uv_walk_cb walk_cb, void* arg)

    void uv_print_all_handles(uv_loop_t* loop, FILE* stream)

    void uv_print_active_handles(uv_loop_t* loop, FILE* stream)

    void uv_close(uv_handle_t* handle, uv_close_cb close_cb)

    int uv_send_buffer_size(uv_handle_t* handle, int* value)

    int uv_recv_buffer_size(uv_handle_t* handle, int* value)

    int uv_fileno(const uv_handle_t* handle, uv_os_fd_t* fd)

    uv_buf_t uv_buf_init(char* base, unsigned int len)

    int uv_pipe(uv_file fds[2], int read_flags, int write_flags)

    int uv_socketpair(int type, int protocol, uv_os_sock_t socket_vector[2], int flags0, int flags1)

    cdef union _uv_stream_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_stream_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_stream_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        size_t write_queue_size
        uv_alloc_cb alloc_cb
        uv_read_cb read_cb
        uv_connect_t* connect_req
        uv_shutdown_t* shutdown_req
        uv__io_t io_watcher
        void* write_queue[2]
        void* write_completed_queue[2]
        uv_connection_cb connection_cb
        int delayed_error
        int accepted_fd
        void* queued_fds

    size_t uv_stream_get_write_queue_size(const uv_stream_t* stream)

    int uv_listen(uv_stream_t* stream, int backlog, uv_connection_cb cb)

    int uv_accept(uv_stream_t* server, uv_stream_t* client)

    int uv_read_start(uv_stream_t*, uv_alloc_cb alloc_cb, uv_read_cb read_cb)

    int uv_read_stop(uv_stream_t*)

    int uv_write(uv_write_t* req, uv_stream_t* handle, const uv_buf_t bufs[], unsigned int nbufs, uv_write_cb cb)

    int uv_write2(uv_write_t* req, uv_stream_t* handle, const uv_buf_t bufs[], unsigned int nbufs, uv_stream_t* send_handle, uv_write_cb cb)

    int uv_try_write(uv_stream_t* handle, const uv_buf_t bufs[], unsigned int nbufs)

    int uv_try_write2(uv_stream_t* handle, const uv_buf_t bufs[], unsigned int nbufs, uv_stream_t* send_handle)

    cdef struct uv_write_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_write_cb cb
        uv_stream_t* send_handle
        uv_stream_t* handle
        void* queue[2]
        unsigned int write_index
        uv_buf_t* bufs
        unsigned int nbufs
        int error
        uv_buf_t bufsml[4]

    int uv_is_readable(const uv_stream_t* handle)

    int uv_is_writable(const uv_stream_t* handle)

    int uv_stream_set_blocking(uv_stream_t* handle, int blocking)

    int uv_is_closing(const uv_handle_t* handle)

    cdef union _uv_tcp_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_tcp_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_tcp_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        size_t write_queue_size
        uv_alloc_cb alloc_cb
        uv_read_cb read_cb
        uv_connect_t* connect_req
        uv_shutdown_t* shutdown_req
        uv__io_t io_watcher
        void* write_queue[2]
        void* write_completed_queue[2]
        uv_connection_cb connection_cb
        int delayed_error
        int accepted_fd
        void* queued_fds

    int uv_tcp_init(uv_loop_t*, uv_tcp_t* handle)

    int uv_tcp_init_ex(uv_loop_t*, uv_tcp_t* handle, unsigned int flags)

    int uv_tcp_open(uv_tcp_t* handle, uv_os_sock_t sock)

    int uv_tcp_nodelay(uv_tcp_t* handle, int enable)

    int uv_tcp_keepalive(uv_tcp_t* handle, int enable, unsigned int delay)

    int uv_tcp_simultaneous_accepts(uv_tcp_t* handle, int enable)

    cpdef enum uv_tcp_flags:
        UV_TCP_IPV6ONLY
        UV_TCP_REUSEPORT

    int uv_tcp_bind(uv_tcp_t* handle, const sockaddr* addr, unsigned int flags)

    int uv_tcp_getsockname(const uv_tcp_t* handle, sockaddr* name, int* namelen)

    int uv_tcp_getpeername(const uv_tcp_t* handle, sockaddr* name, int* namelen)

    int uv_tcp_close_reset(uv_tcp_t* handle, uv_close_cb close_cb)

    int uv_tcp_connect(uv_connect_t* req, uv_tcp_t* handle, const sockaddr* addr, uv_connect_cb cb)

    cdef struct uv_connect_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_connect_cb cb
        uv_stream_t* handle
        void* queue[2]

    cpdef enum uv_udp_flags:
        UV_UDP_IPV6ONLY
        UV_UDP_PARTIAL
        UV_UDP_REUSEADDR
        UV_UDP_MMSG_CHUNK
        UV_UDP_MMSG_FREE
        UV_UDP_LINUX_RECVERR
        UV_UDP_RECVMMSG

    ctypedef void (*uv_udp_send_cb)(uv_udp_send_t* req, int status)

    ctypedef void (*uv_udp_recv_cb)(uv_udp_t* handle, ssize_t nread, const uv_buf_t* buf, const sockaddr* addr, unsigned flags)

    cdef union _uv_udp_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_udp_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_udp_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        size_t send_queue_size
        size_t send_queue_count
        uv_alloc_cb alloc_cb
        uv_udp_recv_cb recv_cb
        uv__io_t io_watcher
        void* write_queue[2]
        void* write_completed_queue[2]

    cdef struct uv_udp_send_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_udp_t* handle
        uv_udp_send_cb cb
        void* queue[2]
        sockaddr_storage addr
        unsigned int nbufs
        uv_buf_t* bufs
        ssize_t status
        uv_udp_send_cb send_cb
        uv_buf_t bufsml[4]

    int uv_udp_init(uv_loop_t*, uv_udp_t* handle)

    int uv_udp_init_ex(uv_loop_t*, uv_udp_t* handle, unsigned int flags)

    int uv_udp_open(uv_udp_t* handle, uv_os_sock_t sock)

    int uv_udp_bind(uv_udp_t* handle, const sockaddr* addr, unsigned int flags)

    int uv_udp_connect(uv_udp_t* handle, const sockaddr* addr)

    int uv_udp_getpeername(const uv_udp_t* handle, sockaddr* name, int* namelen)

    int uv_udp_getsockname(const uv_udp_t* handle, sockaddr* name, int* namelen)

    int uv_udp_set_membership(uv_udp_t* handle, const char* multicast_addr, const char* interface_addr, uv_membership membership)

    int uv_udp_set_source_membership(uv_udp_t* handle, const char* multicast_addr, const char* interface_addr, const char* source_addr, uv_membership membership)

    int uv_udp_set_multicast_loop(uv_udp_t* handle, int on)

    int uv_udp_set_multicast_ttl(uv_udp_t* handle, int ttl)

    int uv_udp_set_multicast_interface(uv_udp_t* handle, const char* interface_addr)

    int uv_udp_set_broadcast(uv_udp_t* handle, int on)

    int uv_udp_set_ttl(uv_udp_t* handle, int ttl)

    int uv_udp_send(uv_udp_send_t* req, uv_udp_t* handle, const uv_buf_t bufs[], unsigned int nbufs, const sockaddr* addr, uv_udp_send_cb send_cb)

    int uv_udp_try_send(uv_udp_t* handle, const uv_buf_t bufs[], unsigned int nbufs, const sockaddr* addr)

    int uv_udp_recv_start(uv_udp_t* handle, uv_alloc_cb alloc_cb, uv_udp_recv_cb recv_cb)

    int uv_udp_using_recvmmsg(const uv_udp_t* handle)

    int uv_udp_recv_stop(uv_udp_t* handle)

    size_t uv_udp_get_send_queue_size(const uv_udp_t* handle)

    size_t uv_udp_get_send_queue_count(const uv_udp_t* handle)

    cdef union _uv_tty_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_tty_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_tty_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        size_t write_queue_size
        uv_alloc_cb alloc_cb
        uv_read_cb read_cb
        uv_connect_t* connect_req
        uv_shutdown_t* shutdown_req
        uv__io_t io_watcher
        void* write_queue[2]
        void* write_completed_queue[2]
        uv_connection_cb connection_cb
        int delayed_error
        int accepted_fd
        void* queued_fds
        termios orig_termios
        int mode

    ctypedef enum uv_tty_mode_t:
        UV_TTY_MODE_NORMAL
        UV_TTY_MODE_RAW
        UV_TTY_MODE_IO

    ctypedef enum uv_tty_vtermstate_t:
        UV_TTY_SUPPORTED
        UV_TTY_UNSUPPORTED

    int uv_tty_init(uv_loop_t*, uv_tty_t*, uv_file fd, int readable)

    int uv_tty_set_mode(uv_tty_t*, uv_tty_mode_t mode)

    int uv_tty_reset_mode()

    int uv_tty_get_winsize(uv_tty_t*, int* width, int* height)

    void uv_tty_set_vterm_state(uv_tty_vtermstate_t state)

    int uv_tty_get_vterm_state(uv_tty_vtermstate_t* state)

    uv_handle_type uv_guess_handle(uv_file file)

    cpdef enum:
        UV_PIPE_NO_TRUNCATE

    cdef union _uv_pipe_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_pipe_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_pipe_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        size_t write_queue_size
        uv_alloc_cb alloc_cb
        uv_read_cb read_cb
        uv_connect_t* connect_req
        uv_shutdown_t* shutdown_req
        uv__io_t io_watcher
        void* write_queue[2]
        void* write_completed_queue[2]
        uv_connection_cb connection_cb
        int delayed_error
        int accepted_fd
        void* queued_fds
        int ipc
        const char* pipe_fname

    int uv_pipe_init(uv_loop_t*, uv_pipe_t* handle, int ipc)

    int uv_pipe_open(uv_pipe_t*, uv_file file)

    int uv_pipe_bind(uv_pipe_t* handle, const char* name)

    int uv_pipe_bind2(uv_pipe_t* handle, const char* name, size_t namelen, unsigned int flags)

    void uv_pipe_connect(uv_connect_t* req, uv_pipe_t* handle, const char* name, uv_connect_cb cb)

    int uv_pipe_connect2(uv_connect_t* req, uv_pipe_t* handle, const char* name, size_t namelen, unsigned int flags, uv_connect_cb cb)

    int uv_pipe_getsockname(const uv_pipe_t* handle, char* buffer, size_t* size)

    int uv_pipe_getpeername(const uv_pipe_t* handle, char* buffer, size_t* size)

    void uv_pipe_pending_instances(uv_pipe_t* handle, int count)

    int uv_pipe_pending_count(uv_pipe_t* handle)

    uv_handle_type uv_pipe_pending_type(uv_pipe_t* handle)

    int uv_pipe_chmod(uv_pipe_t* handle, int flags)

    cdef union _uv_poll_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_poll_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_poll_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_poll_cb poll_cb
        uv__io_t io_watcher

    cpdef enum uv_poll_event:
        UV_READABLE
        UV_WRITABLE
        UV_DISCONNECT
        UV_PRIORITIZED

    int uv_poll_init(uv_loop_t* loop, uv_poll_t* handle, int fd)

    int uv_poll_init_socket(uv_loop_t* loop, uv_poll_t* handle, uv_os_sock_t socket)

    int uv_poll_start(uv_poll_t* handle, int events, uv_poll_cb cb)

    int uv_poll_stop(uv_poll_t* handle)

    cdef union _uv_prepare_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_prepare_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_prepare_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_prepare_cb prepare_cb
        void* queue[2]

    int uv_prepare_init(uv_loop_t*, uv_prepare_t* prepare)

    int uv_prepare_start(uv_prepare_t* prepare, uv_prepare_cb cb)

    int uv_prepare_stop(uv_prepare_t* prepare)

    cdef union _uv_check_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_check_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_check_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_check_cb check_cb
        void* queue[2]

    int uv_check_init(uv_loop_t*, uv_check_t* check)

    int uv_check_start(uv_check_t* check, uv_check_cb cb)

    int uv_check_stop(uv_check_t* check)

    cdef union _uv_idle_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_idle_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_idle_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_idle_cb idle_cb
        void* queue[2]

    int uv_idle_init(uv_loop_t*, uv_idle_t* idle)

    int uv_idle_start(uv_idle_t* idle, uv_idle_cb cb)

    int uv_idle_stop(uv_idle_t* idle)

    cdef union _uv_async_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_async_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_async_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_async_cb async_cb
        void* queue[2]
        int pending

    int uv_async_init(uv_loop_t*, uv_async_t* async_, uv_async_cb async_cb)

    int uv_async_send(uv_async_t* async_)

    cdef union _uv_timer_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_timer_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_timer_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_timer_cb timer_cb
        void* heap_node[3]
        uint64_t timeout
        uint64_t repeat
        uint64_t start_id

    int uv_timer_init(uv_loop_t*, uv_timer_t* handle)

    int uv_timer_start(uv_timer_t* handle, uv_timer_cb cb, uint64_t timeout, uint64_t repeat)

    int uv_timer_stop(uv_timer_t* handle)

    int uv_timer_again(uv_timer_t* handle)

    void uv_timer_set_repeat(uv_timer_t* handle, uint64_t repeat)

    uint64_t uv_timer_get_repeat(const uv_timer_t* handle)

    uint64_t uv_timer_get_due_in(const uv_timer_t* handle)

    cdef struct uv_getaddrinfo_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_loop_t* loop
        uv__work work_req
        uv_getaddrinfo_cb cb
        addrinfo* hints
        char* hostname
        char* service
        addrinfo* addrinfo
        int retcode

    int uv_getaddrinfo(uv_loop_t* loop, uv_getaddrinfo_t* req, uv_getaddrinfo_cb getaddrinfo_cb, const char* node, const char* service, const addrinfo* hints)

    void uv_freeaddrinfo(addrinfo* ai)

    cdef struct uv_getnameinfo_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_loop_t* loop
        uv__work work_req
        uv_getnameinfo_cb getnameinfo_cb
        sockaddr_storage storage
        int flags
        char host[1025]
        char service[32]
        int retcode

    int uv_getnameinfo(uv_loop_t* loop, uv_getnameinfo_t* req, uv_getnameinfo_cb getnameinfo_cb, const sockaddr* addr, int flags)

    ctypedef enum uv_stdio_flags:
        UV_IGNORE
        UV_CREATE_PIPE
        UV_INHERIT_FD
        UV_INHERIT_STREAM
        UV_READABLE_PIPE
        UV_WRITABLE_PIPE
        UV_NONBLOCK_PIPE
        UV_OVERLAPPED_PIPE

    cdef union _uv_stdio_container_t_uv_stdio_container_t_uv_stdio_container_s_data_u:
        uv_stream_t* stream
        int fd

    cdef struct uv_stdio_container_s:
        uv_stdio_flags flags
        _uv_stdio_container_t_uv_stdio_container_t_uv_stdio_container_s_data_u data

    ctypedef uv_stdio_container_s uv_stdio_container_t

    cdef struct uv_process_options_s:
        uv_exit_cb exit_cb
        const char* file
        char** args
        char** env
        const char* cwd
        unsigned int flags
        int stdio_count
        uv_stdio_container_t* stdio
        uv_uid_t uid
        uv_gid_t gid

    ctypedef uv_process_options_s uv_process_options_t

    cpdef enum uv_process_flags:
        UV_PROCESS_SETUID
        UV_PROCESS_SETGID
        UV_PROCESS_WINDOWS_VERBATIM_ARGUMENTS
        UV_PROCESS_DETACHED
        UV_PROCESS_WINDOWS_HIDE
        UV_PROCESS_WINDOWS_HIDE_CONSOLE
        UV_PROCESS_WINDOWS_HIDE_GUI
        UV_PROCESS_WINDOWS_FILE_PATH_EXACT_NAME

    cdef union _uv_process_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_process_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_process_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_exit_cb exit_cb
        int pid
        void* queue[2]
        int status

    int uv_spawn(uv_loop_t* loop, uv_process_t* handle, const uv_process_options_t* options)

    int uv_process_kill(uv_process_t*, int signum)

    int uv_kill(int pid, int signum)

    uv_pid_t uv_process_get_pid(const uv_process_t*)

    cdef struct uv_work_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_loop_t* loop
        uv_work_cb work_cb
        uv_after_work_cb after_work_cb
        uv__work work_req

    int uv_queue_work(uv_loop_t* loop, uv_work_t* req, uv_work_cb work_cb, uv_after_work_cb after_work_cb)

    int uv_cancel(uv_req_t* req)

    cdef struct uv_cpu_times_s:
        uint64_t user
        uint64_t nice
        uint64_t sys
        uint64_t idle
        uint64_t irq

    cdef struct uv_cpu_info_s:
        char* model
        int speed
        uv_cpu_times_s cpu_times

    cdef union _uv_interface_address_s_address_u:
        sockaddr_in address4
        sockaddr_in6 address6

    cdef union _uv_interface_address_s_netmask_u:
        sockaddr_in netmask4
        sockaddr_in6 netmask6

    cdef struct uv_interface_address_s:
        char* name
        char phys_addr[6]
        int is_internal
        _uv_interface_address_s_address_u address
        _uv_interface_address_s_netmask_u netmask

    cdef struct uv_passwd_s:
        char* username
        unsigned long uid
        unsigned long gid
        char* shell
        char* homedir

    cdef struct uv_group_s:
        char* groupname
        unsigned long gid
        char** members

    cdef struct uv_utsname_s:
        char sysname[256]
        char release[256]
        char version[256]
        char machine[256]

    cdef struct uv_statfs_s:
        uint64_t f_type
        uint64_t f_bsize
        uint64_t f_blocks
        uint64_t f_bfree
        uint64_t f_bavail
        uint64_t f_files
        uint64_t f_ffree
        uint64_t f_spare[4]

    ctypedef enum uv_dirent_type_t:
        UV_DIRENT_UNKNOWN
        UV_DIRENT_FILE
        UV_DIRENT_DIR
        UV_DIRENT_LINK
        UV_DIRENT_FIFO
        UV_DIRENT_SOCKET
        UV_DIRENT_CHAR
        UV_DIRENT_BLOCK

    cdef struct uv_dirent_s:
        const char* name
        uv_dirent_type_t type

    char** uv_setup_args(int argc, char** argv)

    int uv_get_process_title(char* buffer, size_t size)

    int uv_set_process_title(const char* title)

    int uv_resident_set_memory(size_t* rss)

    int uv_uptime(double* uptime)

    uv_os_fd_t uv_get_osfhandle(int fd)

    int uv_open_osfhandle(uv_os_fd_t os_fd)

    ctypedef struct uv_rusage_t:
        uv_timeval_t ru_utime
        uv_timeval_t ru_stime
        uint64_t ru_maxrss
        uint64_t ru_ixrss
        uint64_t ru_idrss
        uint64_t ru_isrss
        uint64_t ru_minflt
        uint64_t ru_majflt
        uint64_t ru_nswap
        uint64_t ru_inblock
        uint64_t ru_oublock
        uint64_t ru_msgsnd
        uint64_t ru_msgrcv
        uint64_t ru_nsignals
        uint64_t ru_nvcsw
        uint64_t ru_nivcsw

    int uv_getrusage(uv_rusage_t* rusage)

    int uv_os_homedir(char* buffer, size_t* size)

    int uv_os_tmpdir(char* buffer, size_t* size)

    int uv_os_get_passwd(uv_passwd_t* pwd)

    void uv_os_free_passwd(uv_passwd_t* pwd)

    int uv_os_get_passwd2(uv_passwd_t* pwd, uv_uid_t uid)

    int uv_os_get_group(uv_group_t* grp, uv_uid_t gid)

    void uv_os_free_group(uv_group_t* grp)

    uv_pid_t uv_os_getpid()

    uv_pid_t uv_os_getppid()

    int uv_os_getpriority(uv_pid_t pid, int* priority)

    int uv_os_setpriority(uv_pid_t pid, int priority)

    cpdef enum:
        UV_THREAD_PRIORITY_HIGHEST
        UV_THREAD_PRIORITY_ABOVE_NORMAL
        UV_THREAD_PRIORITY_NORMAL
        UV_THREAD_PRIORITY_BELOW_NORMAL
        UV_THREAD_PRIORITY_LOWEST

    int uv_thread_getpriority(uv_thread_t tid, int* priority)

    int uv_thread_setpriority(uv_thread_t tid, int priority)

    unsigned int uv_available_parallelism()

    int uv_cpu_info(uv_cpu_info_t** cpu_infos, int* count)

    void uv_free_cpu_info(uv_cpu_info_t* cpu_infos, int count)

    int uv_cpumask_size()

    int uv_interface_addresses(uv_interface_address_t** addresses, int* count)

    void uv_free_interface_addresses(uv_interface_address_t* addresses, int count)

    cdef struct uv_env_item_s:
        char* name
        char* value

    int uv_os_environ(uv_env_item_t** envitems, int* count)

    void uv_os_free_environ(uv_env_item_t* envitems, int count)

    int uv_os_getenv(const char* name, char* buffer, size_t* size)

    int uv_os_setenv(const char* name, const char* value)

    int uv_os_unsetenv(const char* name)

    int uv_os_gethostname(char* buffer, size_t* size)

    int uv_os_uname(uv_utsname_t* buffer)

    cdef struct uv_metrics_s:
        uint64_t loop_count
        uint64_t events
        uint64_t events_waiting
        uint64_t* reserved[13]

    int uv_metrics_info(uv_loop_t* loop, uv_metrics_t* metrics)

    uint64_t uv_metrics_idle_time(uv_loop_t* loop)

    ctypedef enum uv_fs_type:
        UV_FS_UNKNOWN
        UV_FS_CUSTOM
        UV_FS_OPEN
        UV_FS_CLOSE
        UV_FS_READ
        UV_FS_WRITE
        UV_FS_SENDFILE
        UV_FS_STAT
        UV_FS_LSTAT
        UV_FS_FSTAT
        UV_FS_FTRUNCATE
        UV_FS_UTIME
        UV_FS_FUTIME
        UV_FS_ACCESS
        UV_FS_CHMOD
        UV_FS_FCHMOD
        UV_FS_FSYNC
        UV_FS_FDATASYNC
        UV_FS_UNLINK
        UV_FS_RMDIR
        UV_FS_MKDIR
        UV_FS_MKDTEMP
        UV_FS_RENAME
        UV_FS_SCANDIR
        UV_FS_LINK
        UV_FS_SYMLINK
        UV_FS_READLINK
        UV_FS_CHOWN
        UV_FS_FCHOWN
        UV_FS_REALPATH
        UV_FS_COPYFILE
        UV_FS_LCHOWN
        UV_FS_OPENDIR
        UV_FS_READDIR
        UV_FS_CLOSEDIR
        UV_FS_STATFS
        UV_FS_MKSTEMP
        UV_FS_LUTIME

    # ctypedef __dirstream DIR

    cdef struct uv_dir_s:
        uv_dirent_t* dirents
        size_t nentries
        void* reserved[4]
        DIR* dir

    ctypedef int mode_t
    ctypedef int off_t

    cdef struct uv_fs_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_fs_type fs_type
        uv_loop_t* loop
        uv_fs_cb cb
        ssize_t result
        void* ptr
        const char* path
        uv_stat_t statbuf
        const char* new_path
        uv_file file
        int flags
        mode_t mode
        unsigned int nbufs
        uv_buf_t* bufs
        off_t off
        uv_uid_t uid
        uv_gid_t gid
        double atime
        double mtime
        uv__work work_req
        uv_buf_t bufsml[4]

    uv_fs_type uv_fs_get_type(const uv_fs_t*)

    ssize_t uv_fs_get_result(const uv_fs_t*)

    int uv_fs_get_system_error(const uv_fs_t*)

    void* uv_fs_get_ptr(const uv_fs_t*)

    const char* uv_fs_get_path(const uv_fs_t*)

    uv_stat_t* uv_fs_get_statbuf(uv_fs_t*)

    void uv_fs_req_cleanup(uv_fs_t* req)

    int uv_fs_close(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb)

    int uv_fs_open(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, int mode, uv_fs_cb cb)

    int uv_fs_read(uv_loop_t* loop, uv_fs_t* req, uv_file file, const uv_buf_t bufs[], unsigned int nbufs, int64_t offset, uv_fs_cb cb)

    int uv_fs_unlink(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_write(uv_loop_t* loop, uv_fs_t* req, uv_file file, const uv_buf_t bufs[], unsigned int nbufs, int64_t offset, uv_fs_cb cb)

    int uv_fs_copyfile(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, int flags, uv_fs_cb cb)

    int uv_fs_mkdir(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, uv_fs_cb cb)

    int uv_fs_mkdtemp(uv_loop_t* loop, uv_fs_t* req, const char* tpl, uv_fs_cb cb)

    int uv_fs_mkstemp(uv_loop_t* loop, uv_fs_t* req, const char* tpl, uv_fs_cb cb)

    int uv_fs_rmdir(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_scandir(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, uv_fs_cb cb)

    int uv_fs_scandir_next(uv_fs_t* req, uv_dirent_t* ent)

    int uv_fs_opendir(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_readdir(uv_loop_t* loop, uv_fs_t* req, uv_dir_t* dir, uv_fs_cb cb)

    int uv_fs_closedir(uv_loop_t* loop, uv_fs_t* req, uv_dir_t* dir, uv_fs_cb cb)

    int uv_fs_stat(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_fstat(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb)

    int uv_fs_rename(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, uv_fs_cb cb)

    int uv_fs_fsync(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb)

    int uv_fs_fdatasync(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb)

    int uv_fs_ftruncate(uv_loop_t* loop, uv_fs_t* req, uv_file file, int64_t offset, uv_fs_cb cb)

    int uv_fs_sendfile(uv_loop_t* loop, uv_fs_t* req, uv_file out_fd, uv_file in_fd, int64_t in_offset, size_t length, uv_fs_cb cb)

    int uv_fs_access(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, uv_fs_cb cb)

    int uv_fs_chmod(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, uv_fs_cb cb)

    int uv_fs_utime(uv_loop_t* loop, uv_fs_t* req, const char* path, double atime, double mtime, uv_fs_cb cb)

    int uv_fs_futime(uv_loop_t* loop, uv_fs_t* req, uv_file file, double atime, double mtime, uv_fs_cb cb)

    int uv_fs_lutime(uv_loop_t* loop, uv_fs_t* req, const char* path, double atime, double mtime, uv_fs_cb cb)

    int uv_fs_lstat(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_link(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, uv_fs_cb cb)

    int uv_fs_symlink(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, int flags, uv_fs_cb cb)

    int uv_fs_readlink(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_realpath(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    int uv_fs_fchmod(uv_loop_t* loop, uv_fs_t* req, uv_file file, int mode, uv_fs_cb cb)

    int uv_fs_chown(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_uid_t uid, uv_gid_t gid, uv_fs_cb cb)

    int uv_fs_fchown(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_uid_t uid, uv_gid_t gid, uv_fs_cb cb)

    int uv_fs_lchown(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_uid_t uid, uv_gid_t gid, uv_fs_cb cb)

    int uv_fs_statfs(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb)

    cpdef enum uv_fs_event:
        UV_RENAME
        UV_CHANGE

    cdef union _uv_fs_event_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_fs_event_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_fs_event_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        char* path
        uv_fs_event_cb cb
        void* watchers[2]
        int wd

    cdef union _uv_fs_poll_s_u_u:
        int fd
        void* reserved[4]

    cdef struct uv_fs_poll_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_fs_poll_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        void* poll_ctx

    int uv_fs_poll_init(uv_loop_t* loop, uv_fs_poll_t* handle)

    int uv_fs_poll_start(uv_fs_poll_t* handle, uv_fs_poll_cb poll_cb, const char* path, unsigned int interval)

    int uv_fs_poll_stop(uv_fs_poll_t* handle)

    int uv_fs_poll_getpath(uv_fs_poll_t* handle, char* buffer, size_t* size)

    cdef union _uv_signal_s_u_u:
        int fd
        void* reserved[4]

    cdef struct _uv_signal_s_tree_entry_s:
        uv_signal_s* rbe_left
        uv_signal_s* rbe_right
        uv_signal_s* rbe_parent
        int rbe_color

    cdef struct uv_signal_s:
        void* data
        uv_loop_t* loop
        uv_handle_type type
        uv_close_cb close_cb
        uv__queue handle_queue
        _uv_signal_s_u_u u
        uv_handle_t* next_closing
        unsigned int flags
        uv_signal_cb signal_cb
        int signum
        _uv_signal_s_tree_entry_s tree_entry
        unsigned int caught_signals
        unsigned int dispatched_signals

    int uv_signal_init(uv_loop_t* loop, uv_signal_t* handle)

    int uv_signal_start(uv_signal_t* handle, uv_signal_cb signal_cb, int signum)

    int uv_signal_start_oneshot(uv_signal_t* handle, uv_signal_cb signal_cb, int signum)

    int uv_signal_stop(uv_signal_t* handle)

    void uv_loadavg(double avg[3])

    cpdef enum uv_fs_event_flags:
        UV_FS_EVENT_WATCH_ENTRY
        UV_FS_EVENT_STAT
        UV_FS_EVENT_RECURSIVE

    int uv_fs_event_init(uv_loop_t* loop, uv_fs_event_t* handle)

    int uv_fs_event_start(uv_fs_event_t* handle, uv_fs_event_cb cb, const char* path, unsigned int flags)

    int uv_fs_event_stop(uv_fs_event_t* handle)

    int uv_fs_event_getpath(uv_fs_event_t* handle, char* buffer, size_t* size)

    int uv_ip4_addr(const char* ip, int port, sockaddr_in* addr)

    int uv_ip6_addr(const char* ip, int port, sockaddr_in6* addr)

    int uv_ip4_name(const sockaddr_in* src, char* dst, size_t size)

    int uv_ip6_name(const sockaddr_in6* src, char* dst, size_t size)

    int uv_ip_name(const sockaddr* src, char* dst, size_t size)

    int uv_inet_ntop(int af, const void* src, char* dst, size_t size)

    int uv_inet_pton(int af, const char* src, void* dst)

    cdef struct uv_random_s:
        void* data
        uv_req_type type
        void* reserved[6]
        uv_loop_t* loop
        int status
        void* buf
        size_t buflen
        uv_random_cb cb
        uv__work work_req

    int uv_random(uv_loop_t* loop, uv_random_t* req, void* buf, size_t buflen, unsigned flags, uv_random_cb cb)

    int uv_if_indextoname(unsigned int ifindex, char* buffer, size_t* size)

    int uv_if_indextoiid(unsigned int ifindex, char* buffer, size_t* size)

    int uv_exepath(char* buffer, size_t* size)

    int uv_cwd(char* buffer, size_t* size)

    int uv_chdir(const char* dir)

    uint64_t uv_get_free_memory()

    uint64_t uv_get_total_memory()

    uint64_t uv_get_constrained_memory()

    uint64_t uv_get_available_memory()

    int uv_clock_gettime(uv_clock_id clock_id, uv_timespec64_t* ts)

    uint64_t uv_hrtime()

    void uv_sleep(unsigned int msec)

    void uv_disable_stdio_inheritance()

    int uv_dlopen(const char* filename, uv_lib_t* lib)

    void uv_dlclose(uv_lib_t* lib)

    int uv_dlsym(uv_lib_t* lib, const char* name, void** ptr)

    const char* uv_dlerror(const uv_lib_t* lib)

    int uv_mutex_init(uv_mutex_t* handle)

    int uv_mutex_init_recursive(uv_mutex_t* handle)

    void uv_mutex_destroy(uv_mutex_t* handle)

    void uv_mutex_lock(uv_mutex_t* handle)

    int uv_mutex_trylock(uv_mutex_t* handle)

    void uv_mutex_unlock(uv_mutex_t* handle)

    int uv_rwlock_init(uv_rwlock_t* rwlock)

    void uv_rwlock_destroy(uv_rwlock_t* rwlock)

    void uv_rwlock_rdlock(uv_rwlock_t* rwlock)

    int uv_rwlock_tryrdlock(uv_rwlock_t* rwlock)

    void uv_rwlock_rdunlock(uv_rwlock_t* rwlock)

    void uv_rwlock_wrlock(uv_rwlock_t* rwlock)

    int uv_rwlock_trywrlock(uv_rwlock_t* rwlock)

    void uv_rwlock_wrunlock(uv_rwlock_t* rwlock)

    int uv_sem_init(uv_sem_t* sem, unsigned int value)

    void uv_sem_destroy(uv_sem_t* sem)

    void uv_sem_post(uv_sem_t* sem)

    void uv_sem_wait(uv_sem_t* sem)

    int uv_sem_trywait(uv_sem_t* sem)

    int uv_cond_init(uv_cond_t* cond)

    void uv_cond_destroy(uv_cond_t* cond)

    void uv_cond_signal(uv_cond_t* cond)

    void uv_cond_broadcast(uv_cond_t* cond)

    int uv_barrier_init(uv_barrier_t* barrier, unsigned int count)

    void uv_barrier_destroy(uv_barrier_t* barrier)

    int uv_barrier_wait(uv_barrier_t* barrier)

    void uv_cond_wait(uv_cond_t* cond, uv_mutex_t* mutex)

    int uv_cond_timedwait(uv_cond_t* cond, uv_mutex_t* mutex, uint64_t timeout)

    ctypedef void (*_uv_once_callback_ft)()

    void uv_once(uv_once_t* guard, _uv_once_callback_ft callback)

    int uv_key_create(uv_key_t* key)

    void uv_key_delete(uv_key_t* key)

    void* uv_key_get(uv_key_t* key)

    void uv_key_set(uv_key_t* key, void* value)

    int uv_gettimeofday(uv_timeval64_t* tv)

    ctypedef void (*uv_thread_cb)(void* arg)

    int uv_thread_create(uv_thread_t* tid, uv_thread_cb entry, void* arg)

    ctypedef enum uv_thread_create_flags:
        UV_THREAD_NO_FLAGS
        UV_THREAD_HAS_STACK_SIZE

    cdef struct uv_thread_options_s:
        unsigned int flags
        size_t stack_size

    ctypedef uv_thread_options_s uv_thread_options_t

    int uv_thread_create_ex(uv_thread_t* tid, const uv_thread_options_t* params, uv_thread_cb entry, void* arg)

    int uv_thread_setaffinity(uv_thread_t* tid, char* cpumask, char* oldmask, size_t mask_size)

    int uv_thread_getaffinity(uv_thread_t* tid, char* cpumask, size_t mask_size)

    int uv_thread_getcpu()

    uv_thread_t uv_thread_self()

    int uv_thread_join(uv_thread_t* tid)

    int uv_thread_equal(const uv_thread_t* t1, const uv_thread_t* t2)

    cdef union uv_any_handle:
        uv_async_t async_ "async"
        uv_check_t check
        uv_fs_event_t fs_event
        uv_fs_poll_t fs_poll
        uv_handle_t handle
        uv_idle_t idle
        uv_pipe_t pipe
        uv_poll_t poll
        uv_prepare_t prepare
        uv_process_t process
        uv_stream_t stream
        uv_tcp_t tcp
        uv_timer_t timer
        uv_tty_t tty
        uv_udp_t udp
        uv_signal_t signal

    cdef union uv_any_req:
        uv_req_t req
        uv_connect_t connect
        uv_write_t write
        uv_shutdown_t shutdown
        uv_udp_send_t udp_send
        uv_fs_t fs
        uv_work_t work
        uv_getaddrinfo_t getaddrinfo
        uv_getnameinfo_t getnameinfo
        uv_random_t random

    cdef union _uv_loop_s_active_reqs_u:
        void* unused
        unsigned int count

    ctypedef void (*_uv_loop_s_async_unused_ft)()

    cdef struct _uv_loop_s_timer_heap_s:
        void* min
        unsigned int nelts

    cdef struct uv_loop_s:
        void* data
        unsigned int active_handles
        uv__queue handle_queue
        _uv_loop_s_active_reqs_u active_reqs
        void* internal_fields
        unsigned int stop_flag
        unsigned long flags
        int backend_fd
        void* pending_queue[2]
        void* watcher_queue[2]
        uv__io_t** watchers
        unsigned int nwatchers
        unsigned int nfds
        void* wq[2]
        uv_mutex_t wq_mutex
        uv_async_t wq_async
        uv_rwlock_t cloexec_lock
        uv_handle_t* closing_handles
        void* process_handles[2]
        void* prepare_handles[2]
        void* check_handles[2]
        void* idle_handles[2]
        void* async_handles[2]
        _uv_loop_s_async_unused_ft async_unused
        uv__io_t async_io_watcher
        int async_wfd
        _uv_loop_s_timer_heap_s timer_heap
        uint64_t timer_counter
        uint64_t time
        int signal_pipefd[2]
        uv__io_t signal_io_watcher
        uv_signal_t child_watcher
        int emfile_fd
        uv__io_t inotify_read_watcher
        void* inotify_watchers
        int inotify_fd

    void* uv_loop_get_data(const uv_loop_t*)

    void uv_loop_set_data(uv_loop_t*, void* data)

    size_t uv_utf16_length_as_wtf8(const uint16_t* utf16, ssize_t utf16_len)

    int uv_utf16_to_wtf8(const uint16_t* utf16, ssize_t utf16_len, char** wtf8_ptr, size_t* wtf8_len_ptr)

    ssize_t uv_wtf8_length_as_utf16(const char* wtf8)

    void uv_wtf8_to_utf16(const char* wtf8, uint16_t* utf16, size_t utf16_len)
