function saveSimulation(obj, userChoosePath)

% Save the entire SimulationConfiguration object
% to a .mat file in the current working directory

arguments
    obj (1,1) SimulationConfiguration  % Ensure the input is of type SimulationConfiguration
    userChoosePath (1,1) logical = false % Optional argument to let user choose path
end

% Define default save path
save_path = fullfile(pwd, 'saved_simulations');

if userChoosePath
    % Open a dialog for the user to select a directory
    selected_path = uigetdir(pwd, 'Select Directory to Save Simulation Data');
    if selected_path ~= 0  % Check if the user did not cancel
        save_path = selected_path;

        % Create timestamp string and filename
        timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));
        filename = fullfile(save_path, ['sadycos_' timestamp '.mat']);

        % Save file to selected path
        try
            save(filename, 'obj');
            fprintf('Simulation data successfully saved to %s\n', filename);
        catch ME
            warning(ME.identifier, 'Failed to save simulation data: %s', ME.message);
        end

    else
        warning('Save operation cancelled by user.');
    end

else
    % Create directory if it doesn't exist
    if ~exist(save_path, 'dir')
        mkdir(save_path);
    end

    % Create timestamp string and filename
    timestamp = char(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));
    filename = fullfile(save_path, ['sadycos_' timestamp '.mat']);

    % Save file to  default path
    try
        save(filename, 'obj');
        fprintf('Simulation data successfully saved to %s\n', filename);
    catch ME
        warning(ME.identifier, 'Failed to save simulation data: %s', ME.message);
    end

end
end

