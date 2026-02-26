function build_hwm14_mex

% This function builds the HWM14 Fortran MEX file into the wrapper folder.

cd Core\ModelsLibrary\Environment\EarthAtmosphere\hwm14\wrapper
mex -R2018a -output hwm14_mex ...
hwm14_gateway.F90 ...
..\hwm14_gemini3d\src\hwm14.f90

end