set(FETCHCONTENT_QUIET OFF CACHE BOOL "" FORCE)
cmake_minimum_required(VERSION 3.24)
project(Catch2Dependent)

Include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        766541d12d64845f5232a1ce4e34a85e83506b09
    )
FetchContent_MakeAvailable(Catch2)
find_package(Catch2 3 REQUIRED)

add_executable(app catch2.cpp)
target_link_libraries(app Catch2::Catch2WithMain)