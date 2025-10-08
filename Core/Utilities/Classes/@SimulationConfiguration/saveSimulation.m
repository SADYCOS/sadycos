function saveSimulation(o)

arguments
    o SimulationConfiguration  % Ensure the input is of type SimulationConfiguration
end

struct_o = struct(o);

% Ask for saving directory
save_path = uigetdir;

% Create timestamp string and filename
timestamp = datestr(now, 'ddmmyyyy_HHMMSS');
filename = fullfile(save_path, ['o_' timestamp '.mat']);

% Save selected file to the specified location
try
        save(filename, 'struct_o');
        fprintf('Simulation data successfully saved to %s\n', filename);
catch ME
    warning('Failed to save simulation data: %s', ME.message);
end
