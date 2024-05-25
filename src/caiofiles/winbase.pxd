# cython: language_level=3

from libc.stddef cimport wchar_t

ctypedef  unsigned char uchar


cdef extern from *:
    ctypedef char * va_list

    ctypedef unsigned long DWORD
    ctypedef int BOOL
    ctypedef void *LPVOID
    ctypedef const char *LPCSTR
    ctypedef DWORD *LPDWORD

    ctypedef void *HANDLE
    ctypedef void *PVOID
    ctypedef unsigned long ULONG_PTR
    ctypedef ULONG_PTR *PULONG_PTR

    ctypedef ULONG_PTR SIZE_T

    cdef struct _OVERLAPPED:
        ULONG_PTR Internal
        ULONG_PTR InternalHigh
        DWORD Offset
        DWORD OffsetHigh
        PVOID Pointer
        HANDLE hEvent

    ctypedef _OVERLAPPED OVERLAPPED
    ctypedef OVERLAPPED *LPOVERLAPPED

    cdef struct _SECURITY_ATTRIBUTES:
        DWORD nLength
        LPVOID lpSecurityDescriptor
        BOOL bInheritHandle

    ctypedef _SECURITY_ATTRIBUTES *LPSECURITY_ATTRIBUTES

    ctypedef void (__stdcall *LPOVERLAPPED_COMPLETION_ROUTINE)(
            DWORD dwErrorCode,
            DWORD dwNumberOfBytesTransfered,
            LPOVERLAPPED lpOverlapped
    )


cdef extern from "windows.h":
    ctypedef const void *LPCVOID
    ctypedef unsigned int UINT
    ctypedef HANDLE HGLOBAL

    ctypedef char *LPSTR
    ctypedef LPSTR LPTSTR
    ctypedef long LONG
    ctypedef long long LONGLONG

    ctypedef struct LowPart_HighPart:
        DWORD LowPart
        LONG HighPart
    ctypedef union LARGE_INTEGER:
        DWORD LowPart
        LONG HighPart
        LowPart_HighPart u
        LONGLONG QuadPart
    ctypedef LARGE_INTEGER *PLARGE_INTEGER

    cdef int SUBLANG_NEUTRAL = 0x00
    cdef int SUBLANG_DEFAULT = 0x01
    cdef int SUBLANG_SYS_DEFAULT = 0X02

    cdef int FORMAT_MESSAGE_ALLOCATE_BUFFER = 0x00000100
    cdef int FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200
    cdef int FORMAT_MESSAGE_FROM_STRING = 0x00000400
    cdef int FORMAT_MESSAGE_FROM_HMODULE = 0x00000800
    cdef int FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
    cdef int FORMAT_MESSAGE_ARGUMENT_ARRAY = 0x00002000
    cdef int FORMAT_MESSAGE_MAX_WIDTH_MASK = 0x000000FF

    cdef long STATUS_WAIT_0 = 0x00000000
    cdef long STATUS_ABANDONED_WAIT_0 = 0x00000080
    cdef long STATUS_USER_APC = 0x000000C0
    cdef long STATUS_TIMEOUT = 0x00000102
    cdef long STATUS_PENDING = 0x00000103

    ctypedef wchar_t WCHAR
    ctypedef WCHAR *LPWSTR
    DWORD FormatMessage(
            DWORD dwFlags,
            LPCVOID lpSource,
            DWORD dwMessageId,
            DWORD dwLanguageId,
            LPTSTR   lpBuffer,
            DWORD nSize,
            va_list *Arguments)
    DWORD FormatMessageW(
            DWORD dwFlags,
            LPCVOID lpSource,
            DWORD dwMessageId,
            DWORD dwLanguageId,
            LPWSTR   lpBuffer,
            DWORD nSize,
            va_list *Arguments)
    cdef int GMEM_FIXED = 0x0000
    cdef int GMEM_MOVEABLE = 0x0002
    cdef int GMEM_NOCOMPACT = 0x0010
    cdef int GMEM_NODISCARD = 0x0020
    cdef int GMEM_ZEROINIT = 0x0040
    cdef int GMEM_MODIFY = 0x0080
    cdef int GMEM_DISCARDABLE = 0x0100
    cdef int GMEM_NOT_BANKED = 0x1000
    cdef int GMEM_SHARE = 0x2000
    cdef int GMEM_DDESHARE = 0x2000
    cdef int GMEM_NOTIFY = 0x4000
    cdef int GMEM_LOWER = GMEM_NOT_BANKED
    cdef int GMEM_VALID_FLAGS = 0x7F72
    cdef int GMEM_INVALID_HANDLE = 0x8000
    cdef int GPTR
    HGLOBAL GlobalAlloc(
            UINT    uFlags,
            SIZE_T dwBytes
    )

cdef enum:
    FILE_LOCK = 0
    FILE_SHARE_DELETE = 0x00000004
    FILE_SHARE_READ = 0x00000001
    FILE_SHARE_WRITE = 0x00000001

    ABOVE_NORMAL_PRIORITY_CLASS = 32768

    CREATE_BREAKAWAY_FROM_JOB = 16777216

    CREATE_DEFAULT_ERROR_MODE = 67108864

    CREATE_NEW_CONSOLE = 16

    CREATE_NEW_PROCESS_GROUP = 512

    CREATE_NO_WINDOW = 134217728

    DETACHED_PROCESS = 8

    DUPLICATE_CLOSE_SOURCE = 1

    DUPLICATE_SAME_ACCESS = 2

    ERROR_ALREADY_EXISTS = 183

    ERROR_BROKEN_PIPE = 109

    ERROR_IO_PENDING = 997

    ERROR_MORE_DATA = 234

    ERROR_NETNAME_DELETED = 64

    ERROR_NO_DATA = 232

    ERROR_NO_SYSTEM_RESOURCES = 1450

    ERROR_OPERATION_ABORTED = 995

    ERROR_PIPE_BUSY = 231
    ERROR_PIPE_CONNECTED = 535

    ERROR_SEM_TIMEOUT = 121

    FILE_FLAG_FIRST_PIPE_INSTANCE = 524288
    FILE_ATTRIBUTE_NORMAL = 128
    FILE_FLAG_OVERLAPPED = 1073741824

    FILE_GENERIC_READ = 1179785
    FILE_GENERIC_WRITE = 1179926

    FILE_MAP_ALL_ACCESS = 983071

    FILE_MAP_COPY = 1
    FILE_MAP_EXECUTE = 32
    FILE_MAP_READ = 4
    FILE_MAP_WRITE = 2

    FILE_TYPE_CHAR = 2
    FILE_TYPE_DISK = 1
    FILE_TYPE_PIPE = 3
    FILE_TYPE_REMOTE = 32768
    FILE_TYPE_UNKNOWN = 0

    GENERIC_READ = 2147483649
    GENERIC_WRITE = 1073741824

    HIGH_PRIORITY_CLASS = 128

    IDLE_PRIORITY_CLASS = 64

    INFINITE = 4294967295

    INVALID_HANDLE_VALUE = 18446744073709551615

    MEM_COMMIT = 4096
    MEM_FREE = 65536
    MEM_IMAGE = 16777216
    MEM_MAPPED = 262144
    MEM_PRIVATE = 131072
    MEM_RESERVE = 8192

    NMPWAIT_WAIT_FOREVER = 4294967295

    NORMAL_PRIORITY_CLASS = 32

    OPEN_EXISTING = 3

    PAGE_EXECUTE = 16

    PAGE_EXECUTE_READ = 32
    PAGE_EXECUTE_READWRITE = 64
    PAGE_EXECUTE_WRITECOPY = 128

    PAGE_GUARD = 256
    PAGE_NOACCESS = 1
    PAGE_NOCACHE = 512
    PAGE_READONLY = 2
    PAGE_READWRITE = 4
    PAGE_WRITECOMBINE = 1024
    PAGE_WRITECOPY = 8

    PIPE_ACCESS_DUPLEX = 3
    PIPE_ACCESS_INBOUND = 1

    PIPE_READMODE_MESSAGE = 2

    PIPE_TYPE_MESSAGE = 4

    PIPE_UNLIMITED_INSTANCES = 255

    PIPE_WAIT = 0

    PROCESS_ALL_ACCESS = 2097151

    PROCESS_DUP_HANDLE = 64

    REALTIME_PRIORITY_CLASS = 256

    SEC_COMMIT = 134217728
    SEC_IMAGE = 16777216

    SEC_LARGE_PAGES = 2147483648

    SEC_NOCACHE = 268435456
    SEC_RESERVE = 67108864
    SEC_WRITECOMBINE = 1073741824

    STARTF_USESHOWWINDOW = 1
    STARTF_USESTDHANDLES = 256

    STD_ERROR_HANDLE = 4294967284

    STD_INPUT_HANDLE = 4294967286

    STD_OUTPUT_HANDLE = 4294967285

    STILL_ACTIVE = 259

    SW_HIDE = 0

    SYNCHRONIZE = 1048576

    WAIT_ABANDONED_0 = 128

    WAIT_OBJECT_0 = 0

    WAIT_TIMEOUT = 258

    CREATE_NEW = 1
    CREATE_ALWAYS = 2
    OPEN_ALWAYS = 4
    TRUNCATE_EXISTING = 5

    WAIT_IO_COMPLETION = 0x000000C0L
    WAIT_ABANDONED = 0x00000080L
