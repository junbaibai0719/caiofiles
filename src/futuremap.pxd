# cython: language_level=3
# distutils: language = c++

from libcpp.map cimport map



cdef extern from "futuremap.h":
    cdef cppclass FutureMap:
        FutureMap()
        void * get(int key)
        void set(int key, void * p)

# cdef extern from "futuremap.cpp":
#     pass