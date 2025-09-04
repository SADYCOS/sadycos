function saveSimulationResults(o)

    % Extract simulation outputs
    simOut = o.simulation_outputs;
    props = properties(simOut);

    % Ask user if they want to save all results or only selected fields
    choice = questdlg('Do you want to save all results or only selected fields?', ...
        'Save Options', ...
        'All','Selected','All');

    if isempty(choice)
        disp('User canceled saving.');
        return;
    end

    if strcmp(choice, 'Selected')
        simOut = selectFieldsRecursive(simOut, 'Select fields/properties to save:');
        % Check if user canceled all selections
        if isempty(fieldnames(simOut))
            disp('No fields selected. Aborting save.');
            return;
        end
    end

    % Ask user for folder
    folder = uigetdir(pwd, 'Select folder to save simulation results');

    % Check if user canceled
    if isequal(folder, 0)
        disp('User canceled saving.');
        return;
    end

    % Create a timestamp string: YYYYMMDD_HHMMSS
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');

    % Define the full file path with timestamp
    filename = fullfile(folder, ['simOut_' timestamp '.mat']);

    % Save the simOut variable
    try
        save(filename, 'simOut');
        fprintf('Simulation results successfully saved to %s\n', filename);
    catch ME
        warning('Failed to save simulation results: %s', ME.message);
    end

end

%% RECURSIVE FIELD/PROPERTY SELECTION FUNCTION
function selected = selectFieldsRecursive(data, prompt)
    % RECURSIVE FIELD SELECTION
    % data: struct or object
    % prompt: text for dialog
    selected = struct();

    % Determine fields/properties
    if isstruct(data)
        fields = fieldnames(data);
    elseif isobject(data)
        fields = properties(data);
    else
        % Leaf variable, just return
        selected = data;
        return;
    end

    % Ask user to select fields/properties
    [selection, ok] = listdlg('PromptString', prompt, ...
                              'SelectionMode', 'multiple', ...
                              'ListString', fields);
    if ~ok
        return; % user canceled selection
    end

    % Loop over selected fields
    for k = 1:length(selection)
        fname = fields{selection(k)};
        value = data.(fname);

        % If value is struct or object, recurse
        if isstruct(value) || isobject(value)
            subPrompt = ['Select fields for ' fname ':'];
            subSelected = selectFieldsRecursive(value, subPrompt);
            % Only add if something was selected
            if ~isempty(fieldnames(subSelected)) || ~isempty(subSelected)
                selected.(fname) = subSelected;
            end
        else
            % Leaf variable, save directly
            selected.(fname) = value;
        end
    end
end