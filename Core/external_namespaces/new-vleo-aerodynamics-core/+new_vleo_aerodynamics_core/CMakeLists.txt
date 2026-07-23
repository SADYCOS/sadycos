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

    message(STATUS "Mex file can be found in ${PROJECT_SOURCE_DIR}/bin")
else ()
    message(FATAL_ERROR "MATLAB root directory not found. Failed to build MATLAB bindings.")
    set(BUILD_MATLAB_BINDINGS OFF)
endif ()