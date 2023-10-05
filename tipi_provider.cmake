# Always ensure we have the policy settings this provider expects
cmake_minimum_required(VERSION 3.24)

set(FETCHCONTENT_QUIET OFF CACHE BOOL "" FORCE)

macro(tipi_provide_dependency method package_name)
  message("***************** CALLING tipi_provide_dependency with ${method} and ${package_name}")
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
    message("***************** RETRIEVING revision: ${ARG_GIT_TAG} for ${ARG_GIT_REPOSITORY} ")


    #FetchContent_GetProperties(${package_name})
   # ${${package_name}_SOURCE_DIR}

    message("***************** RETRIEVING IN ${ARG_SOURCE_DIR} ")

    file(MAKE_DIRECTORY ${ARG_SOURCE_DIR})
    execute_process(
      COMMAND $ENV{CURRENT_TIPI_BINARY} -t ${POLLY_TOOLCHAIN_TAG} -vu  --install restore "${ARG_GIT_REPOSITORY}" "${ARG_GIT_TAG}"  
      #${package_name} --installdir ${TIPI_PROVIDER_INSTALL_DIR}
      WORKING_DIRECTORY ${ARG_SOURCE_DIR}
      RESULT_VARIABLE error_restoring_cache
      ECHO_OUTPUT_VARIABLE
      ECHO_ERROR_VARIABLE
    )
    message("Getting cache entry for ${package_name} : ${error_restoring_cache}")

    if(error_restoring_cache)

      # Save our current command arguments in case we are called recursively
      list(APPEND tipi_provider_args ${method} ${package_name})

      # This will forward to the built-in FetchContent implementation,
      # which detects a recursive call for the same thing and avoids calling
      # the provider again if dep_name is the same as the current call.
      if(NOT ${package_name}_POPULATED)
        # Fetch the content using previously declared details
        FetchContent_Populate(${package_name})
        execute_process(
          COMMAND $ENV{CURRENT_TIPI_BINARY} -t ${POLLY_TOOLCHAIN_TAG} -vu  --install .
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

    endif()
    
    list(INSERT CMAKE_FIND_ROOT_PATH 0 "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
    list(APPEND CMAKE_PREFIX_PATH "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
    list(APPEND CMAKE_PREFIX_PATH "${ARG_SOURCE_DIR}/build/${POLLY_TOOLCHAIN_TAG}/installed/lib/cmake" )
    FetchContent_SetPopulated( ${package_name} )

  elseif("${method}" STREQUAL "FIND_PACKAGE")
    #file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name})
    #execute_process(
    #  COMMAND $ENV{CURRENT_TIPI_BINARY} -t ${POLLY_TOOLCHAIN_TAG} -vu  --install restore "https://github.com/catchorg/Catch2.git" "766541d12d64845f5232a1ce4e34a85e83506b09"  
    #  #${package_name} --installdir ${TIPI_PROVIDER_INSTALL_DIR}
    #  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name}
    #  RESULT_VARIABLE error_code
    #)

    #if(error_code)
    #  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name}/CMakeLists.txt "
    #    cmake_minimum_required(VERSION 3.21)
    #    project(${package_name}Fetcher)
    #    include(${CMAKE_SOURCE_DIR}/deps/Catch2.cmake)
    #    "
    #  )
    #  execute_process(
    #    COMMAND $ENV{CURRENT_TIPI_BINARY} -t ${POLLY_TOOLCHAIN_TAG} -vu  --install .
    #    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name}
    #    RESULT_VARIABLE error_code
    #  )
    #endif()

    #list(INSERT CMAKE_FIND_ROOT_PATH 0 "${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
    #list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name}/build/${POLLY_TOOLCHAIN_TAG}/installed" )
    #list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_BINARY_DIR}/deps/${package_name}/build/${POLLY_TOOLCHAIN_TAG}/installed/lib/cmake" )
  endif()
endmacro()

cmake_language(
  SET_DEPENDENCY_PROVIDER tipi_provide_dependency
  SUPPORTED_METHODS 
    #FIND_PACKAGE 
    FETCHCONTENT_MAKEAVAILABLE_SERIAL
)



## Both FIND_PACKAGE and FETCHCONTENT_MAKEAVAILABLE_SERIAL methods provide
## the package or dependency name as the first method-specific argument.
#macro(tipi_provide_dependency method dep_name)
  #if("${dep_name}" MATCHES "^(gtest|googletest)$")
    ## Save our current command arguments in case we are called recursively
    #list(APPEND tipi_provider_args ${method} ${dep_name})

    ## This will forward to the built-in FetchContent implementation,
    ## which detects a recursive call for the same thing and avoids calling
    ## the provider again if dep_name is the same as the current call.
    #FetchContent_MakeAvailable(googletest)

    ## Restore our command arguments
    #list(POP_BACK tipi_provider_args dep_name method)

    ## Tell the caller we fulfilled the request
    #if("${method}" STREQUAL "FIND_PACKAGE")
      ## We need to set this if we got here from a find_package() call
      ## since we used a different method to fulfill the request.
      ## This example assumes projects only use the gtest targets,
      ## not any of the variables the FindGTest module may define.
      #set(${dep_name}_FOUND TRUE)
    #elseif(NOT "${dep_name}" STREQUAL "googletest")
      ## We used the same method, but were given a different name to the
      ## one we populated with. Tell the caller about the name it used.
      #FetchContent_SetPopulated(${dep_name}
        #SOURCE_DIR "${googletest_SOURCE_DIR}"
        #BINARY_DIR "${googletest_BINARY_DIR}"
      #)
    #endif()
  #endif()
#endmacro()
