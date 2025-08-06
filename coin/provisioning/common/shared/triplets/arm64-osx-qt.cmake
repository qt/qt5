set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(VCPKG_OSX_ARCHITECTURES arm64)
set(VCPKG_TARGET_ARCHITECTURE arm64)

# Default settings of the triplet from the official vcpkg registry
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)

# Qt custom per-port customizations
if(PORT MATCHES "openssl")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
    set(VCPKG_FIXUP_ELF_RPATH ON)
endif()
