from setuptools import Extension, setup
from Cython.Build import cythonize

extensions = [
    Extension("aiofile", ["src/aiofile.pyx", "./source/futuremap.cpp"], define_macros=[("_AMD64_", None)],
              include_dirs=["./include"]),
    Extension("overlapped", ["src/overlapped.pyx"],
              define_macros=[("_AMD64_", None)],
              include_dirs=["./include"]),
    Extension("io_callback", ["src/io_callback.pyx"],
              define_macros=[("_AMD64_", None)],
              include_dirs=["./include"]),
]

setup(
    name="aiofile",
    version="1.0.0",
    ext_modules=cythonize(extensions, language="c++", annotate=True, language_level='3'),
    zip_safe=False,
)
