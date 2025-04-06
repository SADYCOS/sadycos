function GeopotentialData = processGeopotentialData(file_name, num_header_lines, variable_names_line, saveFileFlag)

arguments
    file_name (1,1) string {mustBeFile}
    num_header_lines (1,1) {mustBePositive, mustBeInteger}
    variable_names_line (1,1) {mustBePositive, mustBeInteger}
    saveFileFlag (1,1) logical = false
end

%% Read model coefficients
% Read table from xls file
T = readtable(file_name, ...
                FileType = "text", ...
                NumHeaderLines = num_header_lines, ...
                VariableNamesLine = variable_names_line);
[numRows, ~] = size(T);

% Prepare struct arrays for Schmidt-normalized and Gauss-normalized
% coefficients of DGRF and IGRF models plus one predicted model
n_max = max(T.L); % GFC data uses L instead of n
m_max = max(T.M);

normCoeffs.C = zeros(n_max + 1, m_max + 1);
normCoeffs.S = normCoeffs.C;

% Read normalized coefficients
for i = 1:numRows
    coeffsRow = T.L(i) + 1;
    coeffsCol = T.M(i) + 1;
    normCoeffs.C(coeffsRow, coeffsCol) = T.C(i);
    normCoeffs.S(coeffsRow, coeffsCol) = T.S(i);
end

%% Denormalize normalized coefficients
DenormCoeffs.C = SphericalHarmonicsGeopotential.denormalizeCoefficients(normCoeffs.C);
DenormCoeffs.S = SphericalHarmonicsGeopotential.denormalizeCoefficients(normCoeffs.S);

%% Parse file to get reference values
% Open the file
fileID = fopen(file_name,'r');

% Initialize the values
reference_earth_gravity_constant__m3_per_s2 = nan;
reference_radius__m = nan;

% Read the file line by line
while ~feof(fileID)
    line = fgetl(fileID);
    % Split the line into keyword and value
    parts = strsplit(line);
    if numel(parts) == 2
        keyword = parts{1};
        value = parts{2};
        
        % Check if the keyword matches and store the value
        if strcmp(keyword, 'earth_gravity_constant')
            reference_earth_gravity_constant__m3_per_s2 = str2double(value);
        elseif strcmp(keyword, 'radius')
            reference_radius__m = str2double(value);
        end
    end

    if ~isnan(reference_earth_gravity_constant__m3_per_s2) ...
        && ~isnan(reference_radius__m)
        break;
    end
end

% Close the file
fclose(fileID);

%% Store in struct
GeopotentialData.DenormCoeffs = DenormCoeffs;
GeopotentialData.reference_earth_gravity_constant__m3_per_s2 = reference_earth_gravity_constant__m3_per_s2;
GeopotentialData.reference_radius__m = reference_radius__m;

%% Save in file
if(saveFileFlag)
    [current_folder, ~, ~] = fileparts(mfilename('fullpath'));
    processed_data_file_name = fullfile(current_folder, "ProcessedGeopotentialData", "SphericalHarmonicsGeopotentialCoefficients.mat");
    fprintf("Saving processed geopotential data in file %s...\n", processed_data_file_name);
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

    save(processed_data_file_name, "-struct", "GeopotentialData");

end

end