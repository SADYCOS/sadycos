function Nrlmsise00Data = processSpaceWeatherData(saveFileFlag)

arguments
    saveFileFlag (1,1) logical = false
end

%% Space Weather Data File
[folder_name, ~, ~] = fileparts(mfilename('fullpath'));
external_data_folder_name = fullfile(folder_name, "..", "ExternalData");
csv_filename = fullfile(external_data_folder_name, "SW-All.csv");

%% Read values from CSV file and save them in an intermediate MAT file
fprintf("Reading space weather data file %s...\n", csv_filename);
[intermediate_matfile, startdate, enddate] = aeroReadSpaceWeatherData(csv_filename);

%% Read relevant data for atmospheric model into structure

% Number of days with data
numdays = days(datetime(enddate(1), 1, enddate(2)) - datetime(startdate(1),1,startdate(2))) + 1;

disp("Calculating space weather data for every date in csv file.");
disp("This may take a few minutes...");
% Prepare struct array
Nrlmsise00Data(numdays * 8) = struct();
the_years = nan(size(Nrlmsise00Data));
the_days = the_years;
the_seconds = the_years;

for i = 1:numdays
    for j = 1:8
        ind = (i-1) * 8 + j;
        date = datetime(startdate(1),1,startdate(2)) + i-1 + (j-1)/8;
        
        y = year(date);
        m = month(date);
        d = day(day) + timeofday(date) / days(1);
        Nrlmsise00Data(ind).mjd = smu.time.modifiedJulianDateFromCalDat(y, m, d);

        the_years(ind) = year(date);
        the_days(ind) = day(date, 'dayofyear');
        the_seconds(ind) = seconds(timeofday(date));
    end
end

% Calculate space weather data in intervals of up to 1000 (to reduce memory load)
start_indices = 1:1000:length(Nrlmsise00Data);
end_indices = [start_indices(2:end)-1, length(Nrlmsise00Data)];
for i = 1:length(start_indices)
    start_index = start_indices(i);
    end_index = end_indices(i);
    indices = start_index:end_index;

    [f107average, f107daily, magneticindex] ...
        = fluxSolarAndGeomagnetic(the_years(indices), the_days(indices), the_seconds(indices) , intermediate_matfile);
    
    for ii = 1:length(indices)
        Nrlmsise00Data(indices(ii)).f107average = f107average(ii);
        Nrlmsise00Data(indices(ii)).f107daily = f107daily(ii);
        Nrlmsise00Data(indices(ii)).magneticindex = magneticindex(ii,:);
    end

end

disp("Space weather data calculated.");

%% Delete intermediate file
delete(intermediate_matfile)

%% Save in file
if(saveFileFlag)
    processed_data_file_name = fullfile(folder_name, "ProcessedSpaceWeatherData", "Nrlmsise00Data.mat");
    fprintf("Saving processed space weather data in file %s...\n", processed_data_file_name);
    % check if file already exists
    if isfile(processed_data_file_name)
        % ask user in while loop in command window if they want to overwrite
        while true
            prompt = "File already exists. Do you want to overwrite it? (y/n): ";
            overwrite = input(prompt, 's');
            if lower(overwrite) == "y"
                break;
            elseif lower(overwrite) == "n"
                disp("File not saved.");
                return;
            else
                disp("Invalid input. Please enter 'y' or 'n'.");
            end
        end
    end

    SaveData.Nrlmsise00Data = Nrlmsise00Data;
    save(processed_data_file_name, "-struct", "SaveData");

end

end