from setuptools import Extension, setup
from Cython.Build import cythonize

extensions = [
    Extension("aiofile", ["aiofile.pyx"], define_macros=[("_AMD64_",None)])
]

setup(
    ext_modules=cythonize(extensions),
    zip_safe=False,
)
