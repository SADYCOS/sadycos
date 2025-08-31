function Nrltsi21Data = loadNrltsiProjectionData()

[folder_name, ~, ~] = fileparts(mfilename('fullpath'));
data = load(fullfile(folder_name, "ProcessedNrltsiData", "Nrltsi21Data.mat"));

Nrltsi21Data = data.Nrltsi21Data;

end