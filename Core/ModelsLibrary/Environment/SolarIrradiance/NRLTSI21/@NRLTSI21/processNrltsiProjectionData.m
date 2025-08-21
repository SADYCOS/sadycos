function processNrltsiProjectionData(fileName)
%% Reads data from source:
% [1] Odele Coddington, Judith L. Lean, Doug Lindholm, Peter Pilewskie, 
% Martin Snow, and NOAA CDR Program (2017): NOAA Climate Data Record (CDR) 
% of Total Solar Irradiance (TSI), NRLTSI Version 2.1. 
% data: "tsi-ssi-projection_v03r00_annual_s1610_e2100_c20250225.txt". 
% NOAA National Centers for Environmental Information. 
% https://doi.org/10.7289/V56W985W accessed 2025-04-08.

arguments
    fileName string
end

%% Space Weather Data File
[folder_name, ~, ~] = fileparts(mfilename('fullpath'));
external_data_folder_name = fullfile(folder_name, "..", "ExternalData");
txt_filename = fullfile(external_data_folder_name, fileName);

%% Read data from Txt file
fprintf("Reading Nrltsi21 data file %s...\n", txt_filename);

fid = fopen(txt_filename, 'r');

% Skip the 4 header lines
for i = 1:4
    fgetl(fid);
end

%% Extract relevant values for total solar irradiance
% Read only:
% %s      = date
% 13x %*f = skip first 13 float columns
% 3x %f  = read the last three irradiance values
% %d      = ID
formatSpec = '%s %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %*f %f %f %f %d';

data = textscan(fid, formatSpec, 'Delimiter', ',', 'CollectOutput', true);
fclose(fid);

% Extract
dates_raw = data{1};              % date strings
tsi_data = data{2};  % last 3 irradiance columns
tsi_data(tsi_data == -99) = NaN; % replace -99 values with NaN
ids = data{3};               % ID column

% Convert date strings to datetime
dates = mjuliandate(datetime(dates_raw, 'InputFormat', 'yyyy-MM-dd'));

% Initialize struct array
n = length(dates);
Nrltsi21Data(n) = struct('mjd', [], 'irradianceMean', [],'irradianceUpper', [],'irradianceLower', [], 'ids', []);

% Fill the struct array
for i = 1:n
    Nrltsi21Data(i).mjd              = dates(i);
    Nrltsi21Data(i).irradianceMean   = tsi_data(i,1);
    Nrltsi21Data(i).irradianceUpper  = tsi_data(i,2);
    Nrltsi21Data(i).irradianceLower  = tsi_data(i,3);    
    Nrltsi21Data(i).ids              = ids(i);
end

%% Save in file
processed_data_file_name = fullfile(folder_name, "ProcessedNrltsiData", "Nrltsi21Data.mat");
fprintf("Saving Nrltsi21 data in file %s...\n", processed_data_file_name);
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

SaveData.Nrltsi21Data = Nrltsi21Data;
save(processed_data_file_name, "-struct", "SaveData");


end