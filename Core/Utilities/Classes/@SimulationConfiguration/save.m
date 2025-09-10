function save(o)

% SAVE SIMULATION RESULTS with tree-based selection

% Ask user whether to save all or selected
choice = questdlg('Do you want to save all results or only selected fields?', ...
    'Save Options', ...
    'All','Selected','All');
if isempty(choice)
    disp('User canceled saving.');
    return;
end