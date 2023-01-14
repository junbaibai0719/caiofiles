cmake_minimum_required(VERSION 3.0.0)
project(caiofiles VERSION 0.1.0)

include(CTest)
enable_testing()

include_directories("C:\\Users\\lin\\AppData\\Local\\Programs\\Python\\Python311\\include")
include_directories(./include)




add_library(caiofiles src/aiofile.cpp source/futuremap.cpp include/futuremap.h)


set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)
