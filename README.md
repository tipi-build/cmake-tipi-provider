# cmake-tipi-provider: Automatic build caching and SBOM generation for CMake FetchContent 
**tipi.build ❤️ CMake**

<img src="./assets/tipi.build%20logo.svg" witdth="100px" height="100px"/>
<img src="./assets/CMake-Logo-and-Text.png" witdth="100px" height="100px"/>

## What is it ? Why ?
[tipi](https://tipi.build/documentation/0050-getting-started-cpp) is a Git connected automatic build cache for CMake which is configurable with a JSON file named [`.tipi/deps`](https://tipi.build/documentation/0700-dependencies) to define CMake build dependencies.

This way it can be used as a C++ package manager.

This JSON file is not a "standard CMake" way for CMake natives to express themselves, for this reason we have created **cmake-tipi-provider**, that allows to express any dependencies with the best CMake Package Manager out there **FetchContent**.

**Advantages :**
  - Without changes `FetchContent` is automatically cached.
  - `tipi . -t linux -u` injects automatically the cmake-tipi-provider. 
  - CMakeLists.txt stays fully compatible without tipi just with plain CMake


## How to use it ?
Exactly as the CMake FetchContent documentation requires, the build will just be cached and faster to restore.

It gets enabled in all CMake builds driven by tipi, 

1. 🚀 Install the pre-release by setting `export TIPI_INSTALL_VERSION=v0.0.55` with [`tipi` install scripts oneliner ](https://github.com/tipi-build/cli)
2. Set the environment variable : `export CMAKE_TIPI_PROVIDER_ENABLE=ON`
3. Run the CMake build via : `tipi . -t linux|macos|windows -u`
4. Add the FetchContent you need in your CMakeLists

```cmake
Include(FetchContent)
FetchContent_Declare(
    Boost
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    GIT_TAG        32da69a36f84c5255af8a994951918c258bac601 # Boost 1.80
    )
FetchContent_MakeAvailable(Boost)
find_package(boost_filesystem CONFIG REQUIRED)

add_executable(app boost.cpp)
target_link_libraries(app Boost::filesystem)
```

## How does it work ?
The speedup comes from the fact that instead of using `add_subdirectory` by default as plain FetchContent does, it runs the build of the dependency in a separate CMake context with tipi git mirroring based caching and installs the build artifacts in a dependency-specific sysroot.

When a cache entry is found, as it does not rely on CMake adding the subdirectory as part of the build, it doesn't need to fetch the sources but simply the build artifacts.

Fetching the sources in big project can be slow, but also having to provide the exact same environments for the build to happen to get the built artifacts can also be an issue, tipi's smart caching is based on an [ABI-hash](https://tipi.build/documentation/1000-build-cache) computation, that behaves as if the project was built from sources but without the cost of building if it was already done by a peer [in the same team](https://tipi.build/documentation/1100-shared-cache), or present on the curated [central tipi cache](https://tipi.build).

If compile flags changes in an incompatible way, the build will be performed fully from sources again.

tipi installs the FetchContent provider by defining: [`-DCMAKE_PROJECT_TOP_LEVEL_INCLUDES=tipi_provider.cmake`](./tipi_provider.cmake).

It leverages the standard CMake [DEPENDENCY_PROVIDER](https://cmake.org/cmake/help/latest/command/cmake_language.html#dependency-providers) feature dedicated to integrate with FetchContent and find_package.

## Help & Support
🧚 Get [community support](https://github.com/tipi-build/cmake-tipi-provider/issues)
<br/>📖 [Read tipi documentation](https://tipi.build/documentation)
<br/>📖 [Read CMake FetchContent documentation](https://cmake.org/cmake/help/latest/module/FetchContent.html)
