function saveSimulation(obj)

% Save the entire SimulationConfiguration object 'o'
% to a .mat file in the current working directory

arguments
    obj (1,1) SimulationConfiguration  % Ensure the input is of type SimulationConfiguration
end

% Assign the object to variable 'o' for saving 
o = obj;

% Define the save path
save_path = fullfile(pwd, 'saved_simulations');

% Create directory if it doesn't exist
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% Create timestamp string and filename
timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));
filename = fullfile(save_path, ['o_' timestamp '.mat']);

% Save selected file to the specified location
try
    save(filename, 'o');
    fprintf('Simulation data successfully saved to %s\n', filename);
catch ME
    warning(ME.identifier, 'Failed to save simulation data: %s', ME.message);
end
