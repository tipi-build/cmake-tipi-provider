# SBOM guided auto-generation feature
SBOM generation can be automated for all dependencies added to a CMake project thanks to the cmake-tipi-provider.

Furthermore this can be enabled too for tipi CMakeLists autogeneration, providing SBOM for automatically detected dependencies.

## Running the demo
With tipi v0.0.55 there is still a small issue when given just `tipi` on the command line, it's important to use an absolute path for the SBOM generation to work properly.

`/usr/local/bin/tipi . -t clang-cxx17 -uv --install`

### Setup
For the SBOM generation to work, you need to provide information on your package and where you want the sbom to land.

```cmake
# Setup the SBOM to be generated during install.
sbom_generate(
  OUTPUT
    ${CMAKE_INSTALL_PREFIX}/sbom-${GIT_VERSION_PATH}.spdx
  LICENSE MIT
  SUPPLIER tipi
  SUPPLIER_URL https://tipi.build
)
````

#### Enable the compliances checks you want
```cmake
# If you want to check REUSE compliance.
#reuse_lint()

# If you want to generate a SPDX file with the license information of the source code.
reuse_spdx()
```

#### Enable the installed targets you want SBOM dependency information to be generated for 

```cmake
sbom_add(TARGET app)
```
#### Trigger SBOM finalization and verification.
```cmake
sbom_finalize()
```