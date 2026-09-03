find_package(Matlab REQUIRED COMPONENTS MX_LIBRARY MEX_LIBRARY ENG_LIBRARY)
find_package(glm REQUIRED CONFIG)

if (Matlab_FOUND)
    message(STATUS "MATLAB root directory found: ${Matlab_ROOT_DIR}.")
    message(STATUS "MX_LIBRARY: ${Matlab_MX_LIBRARY}")
    message(STATUS "MEX_LIBRARY: ${Matlab_MEX_LIBRARY}")
    message(STATUS "ENG_LIBRARY: ${Matlab_ENG_LIBRARY}")

    matlab_add_mex(
        NAME MexGateway
        SRC mex_gateway.cpp
        LINK_TO ${Matlab_MX_LIBRARY} ${Matlab_MEX_LIBRARY} ${Matlab_ENG_LIBRARY}
                glm::glm gsi core satellite shading_pipeline aero_load_calculator visualization
    )

    set_target_properties(MexGateway
        PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/matlab/bin"
        LIBRARY_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/matlab/bin"
        RUNTIME_OUTPUT_DIRECTORY "${PROJECT_SOURCE_DIR}/matlab/bin"
    )

    # Windows-only (guarded by CONDA_PREFIX, i.e. a pixi-provided environment). MATLAB
    # loads MexGateway.mexw64 with no knowledge that the pixi environment exists, so
    # its runtime DLL dependencies (spdlog, VTK, assimp, GLEW, GLFW, ...) need to be
    # copied next to it -- see cmake/copy_runtime_deps.cmake.
    if (WIN32 AND DEFINED ENV{CONDA_PREFIX})
        add_custom_command(TARGET MexGateway POST_BUILD
            COMMAND ${CMAKE_COMMAND}
                "-DTARGET_FILE=$<TARGET_FILE:MexGateway>"
                "-DDEST_DIR=${PROJECT_SOURCE_DIR}/matlab/bin"
                "-DSEARCH_DIR=$ENV{CONDA_PREFIX}/Library/bin"
                -P "${PROJECT_SOURCE_DIR}/cmake/copy_runtime_deps.cmake"
            COMMENT "Copying MexGateway's runtime DLL dependencies into matlab/bin"
        )
    endif ()

    message(STATUS "Mex file can be found in ${PROJECT_SOURCE_DIR}/bin")
else ()
    message(FATAL_ERROR "MATLAB root directory not found. Failed to build MATLAB bindings.")
    set(BUILD_MATLAB_BINDINGS OFF)
endif ()