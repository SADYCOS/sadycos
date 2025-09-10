function save(o)

% SAVE SIMULATION RESULTS with tree-based selection

simOut = o.simulation_outputs;

% Ask user whether to save all or selected
choice = questdlg('Do you want to save all results or only selected fields?', ...
    'Save Options', ...
    'All','Selected','All');
if isempty(choice)
    disp('User canceled saving.');
    return;
end

% If selected --> open tree UI
if strcmp(choice, 'Selected')
    simOut = treeSelectionUI(simOut);
    if isempty(simOut)
        disp('No fields selected. Aborting save.');
        return;
    end
end


%% ================= TREE SELECTION UI =================
function selectedStruct = treeSelectionUI(data)
% Create UI figure
fig = uifigure('Name','Select Fields to Save','Position',[100 100 500 500]);