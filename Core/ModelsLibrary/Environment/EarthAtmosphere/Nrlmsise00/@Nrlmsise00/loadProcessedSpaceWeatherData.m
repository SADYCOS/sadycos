function Nrlmsise00Data = loadProcessedSpaceWeatherData()

[folder_name, ~, ~] = fileparts(mfilename('fullpath'));
data = load(fullfile(folder_name, "ProcessedSpaceWeatherData", "Nrlmsise00Data.mat"));

Nrlmsise00Data = data.Nrlmsise00Data;

end