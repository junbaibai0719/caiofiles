# cython: language_level=3

from winbase cimport *
from fileapi cimport ReadFileEx, CreateFileA
from errhandlingapi cimport GetLastError
from synchapi cimport WaitForSingleObjectEx
