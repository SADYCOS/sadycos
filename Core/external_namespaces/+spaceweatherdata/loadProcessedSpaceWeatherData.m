function Parameters = loadProcessedSpaceWeatherData(mjd0, simulation_duration__s)

  %% Load space weather data
  [folder_name, ~, ~] = fileparts(mfilename('fullpath'));
  data = load(fullfile(folder_name, "ProcessedSpaceWeatherData", "ProcessedSpaceWeatherData.mat"));
  
  SpaceWeatherData = data.SpaceWeatherData;

  % Calculate final modified julian date
  mjd_fin = mjd0 + simulation_duration__s/86400;

  % Display error if no atmospheric data is available
  if (mjd0 < min([SpaceWeatherData.mjd])) || (mjd_fin > max([SpaceWeatherData.mjd]))
      error('Atmospheric data not available for entire duration of simulation!');
  end

  % Find indices of relevant mjds for simulation

  % Find all mjds smaller than mjd0
  smaller_logIdxs = ([SpaceWeatherData.mjd] < mjd0);

  idx1 = find(smaller_logIdxs, 1, 'last');
  idx1 = min([idx1, length(SpaceWeatherData) - 1]);

  % Find all mjds greater than mjd_fin
  greater_logIdxs = ([SpaceWeatherData.mjd] > mjd_fin);

  idx2 = find(greater_logIdxs, 1, 'first');
  idx2 = max([idx2, 2]);

  Parameters = SpaceWeatherData(idx1:idx2);

end