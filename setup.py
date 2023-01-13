from setuptools import Extension, setup
from Cython.Build import cythonize

extensions = [
    Extension("aiofile", ["aiofile.pyx", "./source/futuremap.cpp"], define_macros=[("_AMD64_", None)],
              include_dirs=["./include"]),
]

setup(
    ext_modules=cythonize(extensions, language="c++", language_level='3'),
    zip_safe=False,
)
