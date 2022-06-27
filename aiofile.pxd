# cython: language_level=3

from libc cimport stdlib, stdio, string
from libc.stdio cimport printf

cdef int ABOVE_NORMAL_PRIORITY_CLASS = 32768

cdef int BELOW_NORMAL_PRIORITY_CLASS = 16384

cdef int CREATE_BREAKAWAY_FROM_JOB = 16777216

cdef int CREATE_DEFAULT_ERROR_MODE = 67108864

cdef int CREATE_NEW_CONSOLE = 16

cdef int CREATE_NEW_PROCESS_GROUP = 512

cdef int CREATE_NO_WINDOW = 134217728

cdef int DETACHED_PROCESS = 8

cdef int DUPLICATE_CLOSE_SOURCE = 1

cdef int DUPLICATE_SAME_ACCESS = 2

cdef int ERROR_ALREADY_EXISTS = 183

cdef int ERROR_BROKEN_PIPE = 109

cdef int ERROR_IO_PENDING = 997

cdef int ERROR_MORE_DATA = 234

cdef int ERROR_NETNAME_DELETED = 64

cdef int ERROR_NO_DATA = 232

cdef int ERROR_NO_SYSTEM_RESOURCES = 1450

cdef int ERROR_OPERATION_ABORTED = 995

cdef int ERROR_PIPE_BUSY = 231
cdef int ERROR_PIPE_CONNECTED = 535

cdef int ERROR_SEM_TIMEOUT = 121

cdef int FILE_FLAG_FIRST_PIPE_INSTANCE = 524288
cdef int FILE_ATTRIBUTE_NORMAL = 128
cdef int FILE_FLAG_OVERLAPPED = 1073741824

cdef int FILE_GENERIC_READ = 1179785
cdef int FILE_GENERIC_WRITE = 1179926

cdef int FILE_MAP_ALL_ACCESS = 983071

cdef int FILE_MAP_COPY = 1
cdef int FILE_MAP_EXECUTE = 32
cdef int FILE_MAP_READ = 4
cdef int FILE_MAP_WRITE = 2

cdef int FILE_TYPE_CHAR = 2
cdef int FILE_TYPE_DISK = 1
cdef int FILE_TYPE_PIPE = 3
cdef int FILE_TYPE_REMOTE = 32768
cdef int FILE_TYPE_UNKNOWN = 0

cdef int GENERIC_READ = 2147483648
cdef int GENERIC_WRITE = 1073741824

cdef int HIGH_PRIORITY_CLASS = 128

cdef int IDLE_PRIORITY_CLASS = 64

cdef int INFINITE = 4294967295

cdef int INVALID_HANDLE_VALUE = 18446744073709551615

cdef int MEM_COMMIT = 4096
cdef int MEM_FREE = 65536
cdef int MEM_IMAGE = 16777216
cdef int MEM_MAPPED = 262144
cdef int MEM_PRIVATE = 131072
cdef int MEM_RESERVE = 8192

cdef int NMPWAIT_WAIT_FOREVER = 4294967295

cdef int NORMAL_PRIORITY_CLASS = 32

cdef int OPEN_EXISTING = 3

cdef int PAGE_EXECUTE = 16

cdef int PAGE_EXECUTE_READ = 32
cdef int PAGE_EXECUTE_READWRITE = 64
cdef int PAGE_EXECUTE_WRITECOPY = 128

cdef int PAGE_GUARD = 256
cdef int PAGE_NOACCESS = 1
cdef int PAGE_NOCACHE = 512
cdef int PAGE_READONLY = 2
cdef int PAGE_READWRITE = 4
cdef int PAGE_WRITECOMBINE = 1024
cdef int PAGE_WRITECOPY = 8

cdef int PIPE_ACCESS_DUPLEX = 3
cdef int PIPE_ACCESS_INBOUND = 1

cdef int PIPE_READMODE_MESSAGE = 2

cdef int PIPE_TYPE_MESSAGE = 4

cdef int PIPE_UNLIMITED_INSTANCES = 255

cdef int PIPE_WAIT = 0

cdef int PROCESS_ALL_ACCESS = 2097151

cdef int PROCESS_DUP_HANDLE = 64

cdef int REALTIME_PRIORITY_CLASS = 256

cdef int SEC_COMMIT = 134217728
cdef int SEC_IMAGE = 16777216

cdef int SEC_LARGE_PAGES = 2147483648

cdef int SEC_NOCACHE = 268435456
cdef int SEC_RESERVE = 67108864
cdef int SEC_WRITECOMBINE = 1073741824

cdef int STARTF_USESHOWWINDOW = 1
cdef int STARTF_USESTDHANDLES = 256

cdef int STD_ERROR_HANDLE = 4294967284

cdef int STD_INPUT_HANDLE = 4294967286

cdef int STD_OUTPUT_HANDLE = 4294967285

cdef int STILL_ACTIVE = 259

cdef int SW_HIDE = 0

cdef int SYNCHRONIZE = 1048576

cdef int WAIT_ABANDONED_0 = 128

cdef int WAIT_OBJECT_0 = 0

cdef int WAIT_TIMEOUT = 258

cdef int CREATE_NEW = 1
cdef int CREATE_ALWAYS = 2
cdef int OPEN_ALWAYS = 4
cdef int TRUNCATE_EXISTING = 5

ctypedef int BOOL
ctypedef void *LPVOID
ctypedef const char *LPCSTR
ctypedef unsigned long DWORD
ctypedef DWORD *LPDWORD

ctypedef void *HANDLE
ctypedef void *PVOID;
ctypedef  unsigned long ULONG_PTR

ctypedef struct DUMMYSTRUCTNAME:
    DWORD Offset
    DWORD OffsetHigh

ctypedef union DUMMYUNIONNAME:
    DUMMYSTRUCTNAME dummy_struct_name
    PVOID Pointer

cdef struct _OVERLAPPED:
    ULONG_PTR Internal
    ULONG_PTR InternalHigh
    DUMMYUNIONNAME dummy_union_name
    HANDLE hEvent

ctypedef _OVERLAPPED *LPOVERLAPPED

ctypedef void (__stdcall *LPOVERLAPPED_COMPLETION_ROUTINE)(
        DWORD dwErrorCode,
        DWORD dwNumberOfBytesTransfered,
        LPOVERLAPPED lpOverlapped
);

cdef struct _SECURITY_ATTRIBUTES:
    DWORD nLength
    LPVOID lpSecurityDescriptor
    BOOL bInheritHandle

ctypedef _SECURITY_ATTRIBUTES *LPSECURITY_ATTRIBUTES;

cdef extern from "fileapi.h":
    cdef HANDLE CreateFileA(
            LPCSTR lpFileName,
            DWORD dwDesiredAccess,
            DWORD dwShareMode,
            LPSECURITY_ATTRIBUTES lpSecurityAttributes,
            DWORD dwCreationDisposition,
            DWORD dwFlagsAndAttributes,
            HANDLE hTemplateFile
    );

    cdef HANDLE CreateFileW(
            LPCSTR lpFileName,
            DWORD dwDesiredAccess,
            DWORD dwShareMode,
            LPSECURITY_ATTRIBUTES lpSecurityAttributes,
            DWORD dwCreationDisposition,
            DWORD dwFlagsAndAttributes,
            HANDLE hTemplateFile
    );

    cdef int ReadFile(
            HANDLE hFile,
            LPVOID lpBuffer,
            DWORD nNumberOfBytesToRead,
            LPDWORD lpNumberOfBytesRead,
            LPOVERLAPPED lpOverlapped
    );
    cdef int ReadFileEx(
            HANDLE hFile,
            LPVOID lpBuffer,
            unsigned long nNumberOfBytesToRead,
            LPOVERLAPPED lpOverlapped,
            LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    );


cdef extern from "errhandlingapi.h":
    cdef DWORD GetLastError();
