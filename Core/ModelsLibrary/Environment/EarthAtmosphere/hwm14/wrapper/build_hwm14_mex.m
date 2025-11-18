function build_hwm14_mex

% This function builds the HWM14 Fortran MEX file into the wrapper folder.


% Source directory of the HWM14 Fortran code and the wrapper folder
srcDir = fullfile('Core', 'ModelsLibrary', 'Environment' ,'EarthAtmosphere', 'hwm14', 'hwm14_gemini3d', 'src');
wrapperDir = fullfile('Core', 'ModelsLibrary', 'Environment' ,'EarthAtmosphere', 'hwm14', 'wrapper');

% Paths to source files
ifaceSrc   = fullfile(srcDir,    'hwm14_interface.f90');
hwmSrc     = fullfile(srcDir,    'hwm14.f90');
wrapperSrc = fullfile(wrapperDir, 'hwm14_mex.F90');


%----------------------------------------------------------------------
% Compile hwm_interface.f90 to object + .mod in the wrapper folder
%----------------------------------------------------------------------
fprintf('Compiling hwm_interface.f90 ...\n');
mex('-R2018a', ...
    '-c', ...
    ['-I' srcDir], ...
    '-outdir', wrapperDir, ...
    ifaceSrc);


%----------------------------------------------------------------------
% Build the actual MEX (hwm14_mex)
%----------------------------------------------------------------------
fprintf('Building hwm14_mex MEX file ...\n');
mex('-R2018a', ...
    ['-I' wrapperDir], ...      % for hwm_interface.mod
    '-outdir', wrapperDir, ...  % write .mexw64 here
    wrapperSrc, ...
    hwmSrc, ...
    fullfile(wrapperDir, 'hwm_interface.obj'));

end