# SPDX-FileCopyrightText: 2023 tipi.build, tipi technologies Ltd.
#
# SPDX-License-Identifier: MIT

# Always ensure we have the policy settings this provider expects
cmake_minimum_required(VERSION 3.24)

set(FETCHCONTENT_QUIET OFF CACHE BOOL "" FORCE)

include(${CMAKE_CURRENT_LIST_DIR}/sbom/cmake/sbom.cmake)

macro(tipi_provide_dependency method package_name)
  message("[tipi.build] provide_dependency for ${package_name}")
  if("${method}" STREQUAL "FETCHCONTENT_MAKEAVAILABLE_SERIAL")

    # Because we are only looking for a subset of the supported keywords, we
    # cannot check for multi-value arguments with this method. We will have to
    # handle the URL keyword differently.
    set(oneValueArgs
      GIT_REPOSITORY
      GIT_TAG
      BINARY_DIR
      SOURCE_DIR
    )

    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}"
                          "${multiValueArgs}" ${ARGN} )
    message("[tipi.build] retrieving ${ARG_GIT_REPOSITORY}, rev: ${ARG_GIT_TAG} ")


    #FetchContent_GetProperties(${package_name})
   # ${${package_name}_SOURCE_DIR}

    message("[tipi.build] attempting restore in ${ARG_SOURCE_DIR} ")

    file(MAKE_DIRECTORY ${ARG_SOURCE_DIR})
    execute_process(
      COMMAND $ENV{CURRENT_TIPI_BINARY} -t ${POLLY_TOOLCHAIN_TAG} -u  --install restore "${ARG_GIT_REPOSITORY}" "${ARG_GIT_TAG}"  
      #${package_name} --installdir ${TIPI_PROVIDER_INSTALL_DIR}
      WORKING_DIRECTORY ${ARG_SOURCE_DIR}
      RESULT_VARIABLE error_restoring_cache
      ECHO_OUTPUT_VARIABLE
      ECHO_ERROR_VARIABLE
    )

    if(error_restoring_cache)

      message("[tipi.build] no cache entry for ${ARG_GIT_REPOSITORY}, rev: ${ARG_GIT_TAG}, building ")
      # Save our current command arguments in case we are called recursively
      list(APPEND tipi_provider_args ${method} ${package_name})

      # This will forward to the built-in FetchContent implementation,
      # which detects a recursive call for the same thing and avoids calling
      # the provider again if dep_name is the same as the current call.
      if(NOT ${package_name}_POPULATED)
        # Fetch the content using previously declared details
        FetchContent_Populate(${package_name})
        execute_process(
          COMMAND $ENV{CURRENT_TIPI_BINARY} -t ${POLLY_TOOLCHAIN_TAG} -u  --install .
          WORKING_DIRECTORY ${ARG_SOURCE_DIR}
          RESULT_VARIABLE error_building
          ECHO_OUTPUT_VARIABLE
          ECHO_ERROR_VARIABLE
          )
      
        if (NOT error_building)
          list(INSERT CMAKE_FIND_ROOT_PATH 0 "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
          list(APPEND CMAKE_PREFIX_PATH "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
          list(APPEND CMAKE_PREFIX_PATH "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed/lib/cmake" )

          FetchContent_SetPopulated( ${package_name} )
        endif()
      endif()

      # Restore our command arguments
      list(POP_BACK tipi_provider_args package_name method)
    else()
      message("[tipi.build] cache entry for ${ARG_GIT_REPOSITORY}, rev: ${ARG_GIT_TAG}, restored !")

    endif()
    
    sbom_add(
      PACKAGE ${package_name}
      DOWNLOAD_LOCATION ${ARG_GIT_REPOSITORY}
      VERSION ${ARG_GIT_TAG}
      #[EXTREF <ref>...]
      #[LICENSE <string>]
      #[RELATIONSHIP <string>]
      #[SPDXID <id>]
      #SUPPLIER Boost
    )

    list(INSERT CMAKE_FIND_ROOT_PATH 0 "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
    list(APPEND CMAKE_PREFIX_PATH "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
    list(APPEND CMAKE_PREFIX_PATH "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed/lib/cmake" )
    FetchContent_SetPopulated( ${package_name} )

  elseif("${method}" STREQUAL "FIND_PACKAGE")
    # Not implemented
  endif()
endmacro()

cmake_language(
  SET_DEPENDENCY_PROVIDER tipi_provide_dependency
  SUPPORTED_METHODS 
    #FIND_PACKAGE 
    FETCHCONTENT_MAKEAVAILABLE_SERIAL
)