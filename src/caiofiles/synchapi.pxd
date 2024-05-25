# cython: language_level=3

from winbase cimport *

cdef extern from "synchapi.h":

    cdef DWORD __stdcall WaitForSingleObjectEx(
         HANDLE hHandle,
         DWORD dwMilliseconds,
         BOOL bAlertable
        )
