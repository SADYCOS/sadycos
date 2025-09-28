function save(obj, o)

% SAVE SIMULATION RESULTS with tree-based selection

arguments
    obj (1,1) SimulationConfiguration  % Must be single SimulationConfiguration object
    o (1,1)                           % Must be single element (struct or object)
end

simOut = o.simulation_outputs;

% Ask user whether to save all or selected
choice = questdlg('Do you want to save all results or only selected fields?', ...
    'Save Options', ...
    'All','Selected', 'Cancel','All');
if isempty(choice) || strcmp(choice, 'Cancel')
    disp('User canceled saving.');
    return;
end

% If selected --> open tree UI
if strcmp(choice, 'Selected')
    simOut = treeSelectionUI(simOut);
    if isempty(simOut)
        disp('No fields selected or operation canceled. Aborting save.');
        return;
    end
end

% Ask user for folder
folder = uigetdir(pwd, 'Select folder to save simulation results');
if isequal(folder, 0)
    disp('User canceled saving.');
    return;
end

% Create timestamp string
timestamp = datestr(now, 'yyyymmdd_HHMMSS');
filename = fullfile(folder, ['simOut_' timestamp '.mat']);

% Save
try
    save(filename, 'simOut');
    fprintf('Simulation results successfully saved to %s\n', filename);
catch ME
    warning('Failed to save simulation results: %s', ME.message);
end


%% ================= TREE SELECTION UI =================
    function selectedStruct = treeSelectionUI(data)
        
        selectedStruct = []; % Initialize return value
        userCanceled = false; % Flag to track if user canceled
        selectedNodes = [];  % Store selected nodes
        checkedNodeTexts = {};  % Store text of checked nodes manually

        % Create UI figure
        fig = uifigure('Name','Select Fields to Save','Position',[100 100 500 500]);

        % Create tree with checkboxes
        t = uitree(fig,'checkbox','Position',[20 50 460 440]);

        % Set up tree event listener for checkbox changes
        t.CheckedNodesChangedFcn = @(src,event) treeCheckCallback(src,event);

        buildTree(t, data, 'simOut');

        % Add Save button
        confirmbtn = uibutton(fig,'Text','Confirm Selection','Position',[200 10 120 30], ...
            'ButtonPushedFcn', {@confirmCallback});

        % Add Cancel button
        cancelBtn = uibutton(fig,'Text','Cancel','Position',[350 10 100 30], ...
            'ButtonPushedFcn', {@cancelCallback});

        % Add close request function to handle X button
        fig.CloseRequestFcn = {@cancelCallback};

        % Wait for user input
        uiwait(fig);

        % Check if user canceled
        if userCanceled
            selectedStruct = [];
            if isvalid(fig)
                delete(fig);
            end
            return;
        end

        % Convert tree selection back into structure using stored node texts
        selectedStruct = buildStructFromNodeTexts(data, checkedNodeTexts);

        % Close figure after successful operation
        if isvalid(fig)
            delete(fig);
        end

        % Tree checkbox callback function
        function treeCheckCallback(src, event)
            % Update our manual tracking of checked nodes
            checkedNodeTexts = {};
            if ~isempty(src.CheckedNodes)
                for i = 1:length(src.CheckedNodes)
                    checkedNodeTexts{end+1} = src.CheckedNodes(i).Text;
                end
            end
        end

        % Nested callback functions
        function confirmCallback(src, event)
            % Use MATLAB's built-in CheckedNodes property
            if ~isempty(t.CheckedNodes)
                selectedNodes = t.CheckedNodes;
            else
                selectedNodes = [];
            end

            userCanceled = false;
            uiresume(fig);
        end

        function cancelCallback(src, event)
            selectedNodes = [];
            checkedNodeTexts = {};
            userCanceled = true;
            uiresume(fig);
        end
    end

%% Build tree nodes recursively
    function buildTree(parentNode, data, name)
        node = uitreenode(parentNode,'Text',name);

        % Handle different data types
        if isstruct(data)
            % Struct: use fieldnames
            fields = fieldnames(data);
            for k = 1:numel(fields)
                fname = fields{k};
                try
                    value = data.(fname);
                    buildTree(node, value, fname);
                catch
                    continue; % skip inaccessible properties
                end
            end

        elseif isobject(data)
            % Object: use properties
            fields = properties(data);
            for k = 1:numel(fields)
                fname = fields{k};
                try
                    value = data.(fname);
                    buildTree(node, value, fname);
                catch
                    continue; % skip inaccessible properties
                end
            end

        elseif iscell(data)
            % Cell Array: iterate through elements
            for k = 1:numel(data)
                try
                    cellValue = data{k};
                    % Create name like "logsout{1}", "logsout{2}", etc.
                    cellName = sprintf('%s{%d}', name, k);
                    buildTree(node, cellValue, cellName);
                catch
                    continue; % skip inaccessible cell elements
                end
            end

        else
            % Leaf node (numeric, string, etc.) - no further expansion
            return;
        end
    end

%% Convert selected nodes back into struct using node texts
    function selectedStruct = buildStructFromNodeTexts(data, checkedNodeTexts)
        % Initialize empty struct
        selectedStruct = struct();

        % Return empty if no selection
        if isempty(checkedNodeTexts)
            return;
        end

        % Determine if data is struct or object
        if isstruct(data)
            fields = fieldnames(data);
        elseif isobject(data)
            fields = properties(data);
        else
            return;
        end

        for k = 1:numel(fields)
            fname = fields{k};
            try
                value = data.(fname);
            catch
                continue; % skip inaccessible properties
            end

            % Check if field is selected by matching node texts
            isSelected = false;

            % Strategy 1: Exact name match
            if any(strcmp(checkedNodeTexts, fname))
                isSelected = true;
            end

            % Strategy 2: Check if any node text ends with this field name
            if ~isSelected
                for nodeIdx = 1:length(checkedNodeTexts)
                    nodeText = checkedNodeTexts{nodeIdx};
                    if endsWith(nodeText, fname) || endsWith(nodeText, ['.' fname])
                        isSelected = true;
                        break;
                    end
                end
            end

            % If field is struct or object, recurse
            if isstruct(value) || isobject(value)
                % recursive call
                subStruct = buildStructFromNodeTexts(value, checkedNodeTexts);
                if ~isempty(fieldnames(subStruct))
                    selectedStruct.(fname) = subStruct;
                elseif isSelected
                    % User selected the parent node, include entire sub-struct
                    selectedStruct.(fname) = value;
                end
            else % Leaf node
                if isSelected
                    selectedStruct.(fname) = value;
                end
            end
        end
    end


%% Convert selected nodes back into struct
    function selectedStruct = buildStructFromNodes(data, checkedNodes)
        % Initialize empty struct
        selectedStruct = struct();

        % DEBUG: Show what was selected
        fprintf('=== DEBUG buildStructFromNodes ===\n');
        if ~isempty(checkedNodes)
            fprintf('Selected nodes (%d total):\n', length(checkedNodes));
            for i = 1:length(checkedNodes)
                fprintf('  %d: "%s"\n', i, checkedNodes(i).Text);
            end
        else
            fprintf('No nodes selected!\n');
            return;
        end
        fprintf('==================================\n');

        % Determine if data is struct or object
        if isstruct(data)
            fields = fieldnames(data);
        elseif isobject(data)
            fields = properties(data);
        else
            fprintf('Data is neither struct nor object, returning empty\n');
            return;
        end

        fprintf('Processing %d fields from data\n', length(fields));

        for k = 1:numel(fields)
            fname = fields{k};
            try
                value = data.(fname);
            catch
                warning('Could not access field/property %s', fname);
                continue; % skip inaccessible properties
            end

            % Check if field is selected - try multiple matching strategies
            isSelected = false;

            % Strategy 1: Exact name match
            if any(strcmp({checkedNodes.Text}, fname))
                isSelected = true;
                fprintf('Field "%s" selected (exact match)\n', fname);
            end

            % Strategy 2: Check if any node text ends with this field name
            if ~isSelected
                for nodeIdx = 1:length(checkedNodes)
                    nodeText = checkedNodes(nodeIdx).Text;
                    if endsWith(nodeText, fname) || endsWith(nodeText, ['.' fname])
                        isSelected = true;
                        fprintf('Field "%s" selected (partial match with "%s")\n', fname, nodeText);
                        break;
                    end
                end
            end

            % If field is struct or object, recurse
            if isstruct(value) || isobject(value)
                fprintf('Recursing into field "%s"\n', fname);
                % recursive call
                subStruct = buildStructFromNodes(value, checkedNodes);
                if ~isempty(fieldnames(subStruct))
                    selectedStruct.(fname) = subStruct;
                    fprintf('Added subStruct for field "%s"\n', fname);
                elseif isSelected
                    % User selected the parent node, include entire sub-struct
                    selectedStruct.(fname) = value;
                    fprintf('Added entire substruct for selected parent "%s"\n', fname);
                end
            else % Leaf node
                if isSelected
                    selectedStruct.(fname) = value;
                    fprintf('Added leaf field "%s"\n', fname);
                end
            end
        end

        fprintf('Final selectedStruct has %d fields\n', length(fieldnames(selectedStruct)));
    end

end