import pathlib

from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize

libuv_ext = Extension(
    name="py_libuv.pyuv",
    sources=["src/py_libuv/pyuv.pyx"],
    include_dirs=[r"E:\Lib\libuv_install\include", "/home/pi/Documents/uvloop/uvloop"],
    library_dirs=[r"E:\Lib\libuv_install\lib"],
    libraries=["uv"]
)

print(find_packages("src"))
setup(
    name="caiofiles",
    version="1.0.0",
    packages=find_packages("src"),
    package_dir={"": "src"},
    ext_modules=cythonize(
        # ["src/caiofiles/aiofile.pyx"],
        [libuv_ext],
        annotate=True, language_level='3'
    ),
    zip_safe=False,
    # data_files=[
    #     ("", ["src/__init__.py"])
    # ],
)
