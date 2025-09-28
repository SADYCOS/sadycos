function save(obj, o)

% SAVE SIMULATION RESULTS with tree-based selection

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
         % Initialize return value
        selectedStruct = [];

        % Initialize flag for user cancellation 
        userCanceled = false;

        % Create UI figure
        fig = uifigure('Name','Select Fields to Save','Position',[100 100 500 500]);

        % Create tree with checkboxes
        t = uitree(fig,'checkbox','Position',[20 50 460 440]);
        buildTree(t, data, 'simOut');

        % Add Save button
        confirmbtn = uibutton(fig,'Text','Confirm Selection','Position',[200 10 120 30], ...
            'ButtonPushedFcn', @confirmCallback);

        % Add Cancel button
        cancelBtn = uibutton(fig,'Text','Cancel','Position',[350 10 100 30], ...
            'ButtonPushedFcn', @cancelCallback);
        
        % Add close request function to handle X button
        fig.CloseRequestFcn = @cancelCallback;

        % Wait for user input
        uiwait(fig);

        % Check if user canceled
        if userCanceled
            selectedStruct = [];
            delete(fig);
            return;
        end

        % Collect selected nodes
        checkedNodes = findobj(t,'Checked','on');

        % Convert tree selection back into structure
        selectedStruct = buildStructFromNodes(data, checkedNodes);

        % Nested callback functions
        function confirmCallback(~,~)
            userCanceled = false;
            uiresume(fig);
        end
        
        function cancelCallback(~,~)
            userCanceled = true;
            uiresume(fig);
        end
        % Close figure
        delete(fig);
end

%% Build tree nodes recursively
function buildTree(parentNode, data, name)
node = uitreenode(parentNode,'Text',name);

% Determine if data is struct or object
if isstruct(data)
    fields = fieldnames(data);
elseif isobject(data)
    fields = properties(data);
else
    return; % leaf node
end


for k = 1:numel(fields)
    fname = fields{k};
    try
        value = data.(fname);
    catch
        continue; % skip inaccessible properties
    end
    % recursive call
    buildTree(node, value, fname);
end
end

%% Convert selected nodes back into struct
function selectedStruct = buildStructFromNodes(data, checkedNodes)
% Initialize empty struct
selectedStruct = struct();

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
        warning('Could not access field/property %s', fname);
        continue; % skip inaccessible properties
    end

    % Check if field is empty
    if isempty(checkedNodes) || isa(checkedNodes,'matlab.graphics.GraphicsPlaceholder')
        isSelected = false;
    else
        isSelected = any(strcmp({checkedNodes.Text}, fname));
    end

    % If field is struct or object, recurse
    if isstruct(value) || isobject(value)
        % recursive call
        subStruct = buildStructFromNodes(value, checkedNodes);
        if ~isempty(fieldnames(subStruct))
            selectedStruct.(fname) = subStruct;
        elseif isSelected
            % User only selected the parent node, include entire sub-struct
            selectedStruct.(fname) = value;
        end
    else % Leaf node
        if isSelected
            selectedStruct.(fname) = value;
        end
    end
end
end
end