function saveSimulation(o)

% Save the entire SimulationConfiguration object 'o'
% to a .mat file in the current working directory

arguments
    o SimulationConfiguration  % Ensure the input is of type SimulationConfiguration
end

% Define the save path
save_path = fullfile(pwd, 'saved_simulations');

% Create directory if it doesn't exist
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% Create timestamp string and filename
timestamp = datestr(now, 'ddmmyyyy_HHMMSS');
filename = fullfile(save_path, ['o_' timestamp '.mat']);

% Save selected file to the specified location
try
    save(filename, 'o');
    fprintf('Simulation data successfully saved to %s\n', filename);
catch ME
    warning(ME.identifier, 'Failed to save simulation data: %s', ME.message);
end
