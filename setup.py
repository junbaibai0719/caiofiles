import pathlib

from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize


setup(
    name="aiofile",
    version="1.0.0",
    ext_modules=cythonize(["src/aiofile.pyx", "src/overlapped.pyx", "src/io_callback.pyx"], language="c++", annotate=True, language_level='3'),
    zip_safe=False,
    # data_files=[
    #     ("", ["src/__init__.py"])
    # ],
)
