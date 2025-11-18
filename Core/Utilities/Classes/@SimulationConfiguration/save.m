function save(obj, userChoosePath)

% Save the entire SimulationConfiguration object to a .mat file

arguments
    obj (1,1) SimulationConfiguration  % Ensure the input is of type SimulationConfiguration
    userChoosePath (1,1) logical = false % Optional argument to let user choose path
end

% Rename obj
simulationConfiguration = obj;

% Define default save path
save_path = fullfile(pwd, 'saved_simulations');

if userChoosePath
    % Open dialog for user to select directory
    selected_path = uigetdir(pwd, 'Select Directory to Save Simulation Data');

    if selected_path == 0  % User cancelled
        fprintf('Save operation cancelled by user.\n');
        return;
    end

    save_path = selected_path;
else
    % Create default directory if it doesn't exist
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end
end

% Create timestamp and filename
timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));
filename = fullfile(save_path, ['sadycos_' timestamp '.mat']);

% Save file
try
    save(filename, 'simulationConfiguration');
    fprintf('Simulation configuration successfully saved to:\n  %s\n', filename);
catch ME
    warning(ME.identifier, 'Failed to save simulation configuration: %s', ME.message);
end

end
