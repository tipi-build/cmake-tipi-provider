set(FETCHCONTENT_QUIET OFF CACHE BOOL "" FORCE)
cmake_minimum_required(VERSION 3.24)
project(example_app)

include(${CMAKE_CURRENT_LIST_DIR}/.tipi/cmake/sbom.cmake)

# Setup the SBOM to be generated during install.
sbom_generate(
  OUTPUT
    ${CMAKE_INSTALL_PREFIX}/sbom-${GIT_VERSION_PATH}.spdx
  LICENSE MIT
  SUPPLIER tipi
  SUPPLIER_URL https://tipi.build
)

# If you want to check REUSE compliance.
#reuse_lint()

# If you want to generate a SPDX file with the license information of the source code.
reuse_spdx()

# Dependencies
Include(FetchContent)
FetchContent_Declare(
    Catch2
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG        766541d12d64845f5232a1ce4e34a85e83506b09
    )
FetchContent_MakeAvailable(Catch2)
find_package(Catch2 3 REQUIRED)



FetchContent_Declare(
    Boost
    GIT_REPOSITORY https://github.com/boostorg/boost.git
    GIT_TAG        32da69a36f84c5255af8a994951918c258bac601
    )
FetchContent_MakeAvailable(Boost)
find_package(boost_filesystem CONFIG REQUIRED)

add_executable(app app.cpp)
target_link_libraries(app Catch2::Catch2WithMain Boost::filesystem)

# Install the application.
install(
    TARGETS app
    EXPORT "${targets_export_name}"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
    RUNTIME DESTINATION "bin"
    INCLUDES DESTINATION "${include_install_dir}"
)
sbom_add(TARGET app)

# Trigger SBOM finalization and verification.
sbom_finalize()