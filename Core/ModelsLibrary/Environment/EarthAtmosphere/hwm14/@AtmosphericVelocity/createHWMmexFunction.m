function createHWMmexFunction()
% Function to create the MEX function for the AtmosphericVelocity class
% by first buildung the hwm14_gemini3d library and then creating the MEX function

%% Build the hwm14_gemini3d library

% Get the full path of the current file and the project root directory
this_file = mfilename('fullpath');
project_root = fileparts(this_file);
hwm_dir = fullfile(project_root, 'Core','ModelsLibrary','Environment','EarthAtmosphere','hwm14','hwm14_gemini3d');


% Check if the build directory exists, if so, delete it
folder = 'Core\ModelsLibrary\Environment\EarthAtmosphere\hwm14\hwm14_gemini3d\build';

if exist(folder,'dir')
    rmdir(folder,'s')
end



