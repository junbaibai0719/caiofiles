import pathlib

from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize

libuv_ext = Extension(
    name="py_libuv.pyuv",
    sources=["src/py_libuv/pyuv.pyx"],
    include_dirs=["/home/pi/Programs/libuv/include/"],
    # library_dirs=["/home/pi/Programs/libuv/lib/"],
    libraries=["uv"]
)

print(find_packages("src"))
setup(
    name="caiofiles",
    version="1.0.0",
    packages=find_packages("src"),
    package_dir={"": "src"},
    ext_modules=cythonize(
        # ["src/caiofiles/aiofile.pyx", "src/caiofiles/overlapped.pyx"],
        [libuv_ext],
        annotate=True, language_level='3'
    ),
    zip_safe=False,
    # data_files=[
    #     ("", ["src/__init__.py"])
    # ],
)
