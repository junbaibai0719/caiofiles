import pathlib

from setuptools import Extension, setup, find_packages
from Cython.Build import cythonize

print(find_packages("src"))
setup(
    name="caiofiles",
    version="1.0.0",
    packages=find_packages("src"),
    package_dir={"": "src"},
    ext_modules=cythonize(["src/caiofiles/aiofile.pyx", "src/caiofiles/overlapped.pyx"], language="c++", annotate=True, language_level='3'),
    zip_safe=False,
    # data_files=[
    #     ("", ["src/__init__.py"])
    # ],
)
