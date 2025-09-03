function saveSimulationResults(obj)

    % Ask user for folder
    folder = uigetdir(pwd, 'Select folder to save simulation results');
    
    % Check if user canceled
    if isequal(folder, 0)
        disp('User canceled saving.');
        return;
    end

      % Create a timestamp string: YYYYMMDD_HHMMSS
    timestamp = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
    
    % Define the full file path with timestamp
    filename = fullfile(folder, ['simOut_' timestamp '.mat']);
    
    % Save the simOut variable
    try
        simOut = obj.simulation_outputs;
        save(filename, 'simOut');
        fprintf('Simulation results successfully saved to %s\n', filename);
    catch ME
        warning('Failed to save simulation results: %s', ME.message);
    end

    end