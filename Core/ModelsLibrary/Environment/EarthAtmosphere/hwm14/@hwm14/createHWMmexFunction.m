function createHWMmexFunction()
% Function to create the MEX function for the AtmosphericVelocity class
% by first buildung the hwm14_patch library and then creating the MEX function

%% Build the hwm14_patch library

% Get the full path of the current file for independent path building
[this_folder,~,~] = fileparts(mfilename('fullpath'));

% Go one folder up (to hwm14)
[hwm14_dir,~,~] = fileparts(this_folder);

% Build relevant paths for easier access later on
% Current working directory is saved to be able to switch back to it at the end of the function
old_dir = pwd;

% Build the path to the hwm14_patch submodule directory
hwm14submodule_dir = fullfile(hwm14_dir, 'fortran_code', 'hwm14_patch');

% Build the path to the hwm14 class directory
% hwm14class_dir = fullfile(hwm14_dir, '@hwm14');

% Build the path to the AtmosphericVelocity class directory
% atmospheric_velocity_dir = fullfile(hwm14_dir, '@AtmosphericVelocity');

% Build the path to the wrapper directory
wrapper_dir = fullfile(hwm14_dir, 'fortran_code', 'wrapper');

% Build the path to the desired build directory for the hwm14 library
build_dir = fullfile(hwm14_dir, 'bin', 'build');

% Build the path to the desired installation directory for the hwm14 library
install_dir = fullfile(hwm14_dir, 'bin', 'install');

% Check if the build folder exists, if so, delete it
if exist(build_dir,'dir')
    rmdir(build_dir,'s')
end 

% Check if the install folder exists, if so, delete it
if exist(install_dir,'dir')
    rmdir(install_dir,'s')
end

% Reset the working directory to the original one at the end of the function, even if an error occurs
cleanupObj = onCleanup(@() cd(old_dir));
% switch to the hwm14_patch directory
cd(hwm14submodule_dir);

% locate the installation directory of MATLAB and safe it in a variable
% matlab_root = matlabroot;

% build the path to the mingw_w64.instrset directory
sp_root = fullfile(getenv('PROGRAMDATA'),'MATLAB','SupportPackages');
release_name =  ['R' version('-release')];
mingw_dir = fullfile(sp_root, release_name, '3P.instrset', 'mingw_w64.instrset');
%mingw_dir = fullfile(matlab_root,...
    %'SupportPackages','R2024b','3P.instrset','mingw_w64.instrset');

% Check if the mingw directory exists, if not, throw an error
if ~exist(mingw_dir,'dir')
    error('MinGW directory not found: %s', mingw_dir)
end

% Set the environment variable MW_MINGW64_LOC to the path of the mingw_w64.instrset directory
setenv('MW_MINGW64_LOC', mingw_dir);

% Add mingw bin directory temporarily to PATH environment variable 
% otherwise cmake will not be able to find the mingw (fortran) compiler 
% and Error "CMake Error: CMAKE_Fortran_COMPILER not set" would occur
setenv('PATH',[fullfile(mingw_dir,'bin') pathsep getenv('PATH')]);


% configure the build using cmake
% -S specifies the source directory (current directory), 
% -B specifies the build directory (build_dir),
% -G specifies the generator (MinGW Makefiles)
% set the Fortran compiler to gfortran to ensure that the same compiler 
% is used for both the library build and the MEX function build
% add the flag -fdefault-integer-8 to use 64 bit integers by default
cmd_build = sprintf(['cmake -S . -B "%s" -G "MinGW Makefiles" ' ...
               '-DCMAKE_Fortran_COMPILER=gfortran ' ... 
               '-DCMAKE_Fortran_FLAGS="-fdefault-integer-8"'], ...
               build_dir);
status = system(cmd_build);

% Check if the command was successful
if status ~= 0
    error('CMake configuration failed')
end

% Build the library using cmake
status = system(sprintf('cmake --build "%s"', build_dir));
if status ~= 0
    error('CMake build failed')
end

fprintf('CMake configuration successful.\n')


% install the library to a specific directory (install_dir) using cmake, 
% this will copy the relevant library files and mod files to the install_dir
cmd_install = sprintf('cmake --install "%s" --prefix "%s"', build_dir, install_dir);
status = system(cmd_install);

% Check if the command was successful
if status ~= 0
    error('Hwm14 installation failed')
end

fprintf('Hwm14 installation successful.\n')


%% Create the MEX function

% Build the MEX function using the gateway, the libraries and the mod files

% Build the path to the mod files directory 
% (the mod files are needed for the compilation of the gateway)
mod_dir = fullfile(install_dir,'include');

% Build the path to the gateway source file
gateway_path = fullfile(wrapper_dir,'hwm14_ifc_gateway.F90');

% Build the paths to the relevant hwm interface library file "libhwm_ifc.a"
libhwmifc_path = fullfile(install_dir, 'lib', 'libhwm_ifc.a');

% Build the paths to the hwm14 library file "libhwm14.a"
% Note that the hwm14 library also needs to be linked to ensure that all
% symbols that are used in the hwm interface library are defined
libhwm14_path = fullfile(install_dir, 'lib', 'libhwm14.a');

% Build the path to the output directory for the hwm14 MEX function
out_path = fullfile(hwm14_dir,'hwm14ifc_mex');

% Determine the extension of the MEX function for the current platform
mex_ext = ['.' mexext];
% Build the full path to the MEX function
mex_file = [out_path mex_ext];

% Check if all relevant files and directories exist, if not, throw an error
assert(exist(mod_dir,'dir') == 7, 'mod_dir not found')
assert(exist(gateway_path,'file') == 2, 'gateway source not found')
assert(exist(libhwmifc_path,'file') == 2, 'libhwm_ifc.a not found')
assert(exist(libhwm14_path,'file') == 2, 'libhwm14.a not found')

% Set the environment variable HWMPATH to the path of the hwm14 data directory,
% this is needed for the hwm14 library to be able to find the data files that it needs on runtime 
% data_dir = fullfile(hwm14_dir,'bin','install','share','data','hwm14');
% assert(exist(data_dir,'dir') == 7, 'HWM14 data directory not found: %s', data_dir);
% setenv('HWMPATH', data_dir);
% check if the environment variable is correctly set
% disp(['Path for data folder set to: ' getenv('HWMPATH')])
% exist(fullfile(getenv('HWMPATH'),'dwm07b104i.dat'),'file')
% exist(fullfile(getenv('HWMPATH'),'gd2qd.dat'),'file')
% exist(fullfile(getenv('HWMPATH'),'hwm123114.bin'),'file')

% Check if the MEX function already exists, if so, delete it
if exist(mex_file,'file')
    delete(mex_file)
end

% Call the MATLAB mex function to build the hwm14 MEX function
mex('-R2018a', ... 
['-I' mod_dir], ...
gateway_path, ...
libhwmifc_path, ...
libhwm14_path, ...
'-output', out_path);

end



