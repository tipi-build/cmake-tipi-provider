set(FETCHCONTENT_QUIET OFF CACHE BOOL "" FORCE)
cmake_minimum_required(VERSION 3.24)
project(BoostDependent)

Include(FetchContent)
FetchContent_Declare(
    Boost
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    GIT_TAG        32da69a36f84c5255af8a994951918c258bac601
    )
FetchContent_MakeAvailable(Boost)
find_package(boost_filesystem CONFIG REQUIRED)

add_executable(app boost.cpp)
target_link_libraries(app Boost::filesystem)