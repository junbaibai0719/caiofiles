# cython: language_level=3

from winbase cimport *

cdef extern from "fileapi.h":
    cdef HANDLE CreateFileA(
            LPCSTR lpFileName,
            DWORD dwDesiredAccess,
            DWORD dwShareMode,
            LPSECURITY_ATTRIBUTES lpSecurityAttributes,
            DWORD dwCreationDisposition,
            DWORD dwFlagsAndAttributes,
            HANDLE hTemplateFile
    )

    cdef HANDLE CreateFileW(
            LPCSTR lpFileName,
            DWORD dwDesiredAccess,
            DWORD dwShareMode,
            LPSECURITY_ATTRIBUTES lpSecurityAttributes,
            DWORD dwCreationDisposition,
            DWORD dwFlagsAndAttributes,
            HANDLE hTemplateFile
    )

    cdef BOOL ReadFile(
            HANDLE hFile,
            LPVOID lpBuffer,
            DWORD nNumberOfBytesToRead,
            LPDWORD lpNumberOfBytesRead,
            LPOVERLAPPED lpOverlapped
    )
    cdef BOOL ReadFileEx(
            HANDLE hFile,
            LPVOID lpBuffer,
            DWORD nNumberOfBytesToRead,
            LPOVERLAPPED lpOverlapped,
            LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine
    )

    cdef BOOL GetFileSizeEx(HANDLE hFile,
                            PLARGE_INTEGER lpFileSize)

    cdef HANDLE  CreateIoCompletionPort(
            HANDLE    FileHandle,
            HANDLE    ExistingCompletionPort,
            ULONG_PTR CompletionKey,
            DWORD     NumberOfConcurrentThreads
    )

    cdef BOOL  CancelIo(HANDLE hFile)