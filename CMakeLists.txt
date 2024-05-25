cmake_minimum_required(VERSION 3.25)
project(uv_c)

link_directories("/home/pi/Programs/libuv/lib")

add_executable(uv_c src/py_libuv/uv_c.c)

target_link_libraries(uv_c PRIVATE uv)