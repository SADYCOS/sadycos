function IgrfData = processIgrfData(file_name, saveFileFlag)

%% References
% [1] P. Alken et al., “International Geomagnetic Reference Field: the thirteenth generation,” Earth Planets Space, vol. 73, no. 1, p. 49, Dec. 2021, doi: 10.1186/s40623-020-01288-x.

arguments
    file_name (1,1) string {mustBeFile}
    saveFileFlag (1,1) logical = false
end

%% Find models within xls file
% Get column headers
C = readcell(file_name, NumHeaderLines = 3);
headers = C(1,:);

% Columns with DGRF or IGRF data for the coefficients have a header that
% features the model's epoch as a number
% --> find all headers with a number in them
modelCols = [];
for i = 1:length(headers)
    if isnumeric(headers{1,i})
        modelCols(end+1) = i;
    end
end

%% Read DGRF and IGRF model coefficients
% Read table from xls file
T = readtable(file_name, NumHeaderLines = 3, ReadVariableNames = true);
[numRows, ~] = size(T);

% Prepare struct arrays for Schmidt-normalized and Gauss-normalized
% coefficients of DGRF and IGRF models plus one predicted model
n_max = max(T.n);
m_max = max(T.m);
schmidtNormCoeffs(length(modelCols) + 1) = struct();
gaussNormCoeffs = schmidtNormCoeffs;

% Read Schmidt-normalized coefficients
for i = 1:length(modelCols)    
    modelColumn = modelCols(i);
    schmidtNormCoeffs(i).epoch = C{1,modelColumn};
    % initialize coefficients to zero
    schmidtNormCoeffs(i).g__nT = zeros(n_max, m_max + 1);
    schmidtNormCoeffs(i).h__nT = schmidtNormCoeffs(i).g__nT;
    % Read Schmidt-normalized coefficients
    for ii = 1:numRows    
        if T.g_h{ii} == 'g'
            schmidtNormCoeffs(i).g__nT(T.n(ii), T.m(ii) + 1) = T{ii, modelColumn};
        else
            schmidtNormCoeffs(i).h__nT(T.n(ii), T.m(ii) + 1) = T{ii, modelColumn};
        end    
    end
end

%% Read predictive secular variation coefficients
% (predicted time-dependency of latest set of of coefficients)

% Prepare arrays for Schmidt-normalized coefficients of predictive
% secular variantions
schmidt_gSv__nT_per_year = zeros(n_max, m_max + 1);
schmidt_hSv__nT_per_year = schmidt_gSv__nT_per_year;

% Secular variation coefficients are located in last column of the table
for ii = 1:numRows
    if T.g_h{ii} == 'g'
            schmidt_gSv__nT_per_year(T.n(ii), T.m(ii) + 1) = T{ii, modelCols(end)+1};
        else
            schmidt_hSv__nT_per_year(T.n(ii), T.m(ii) + 1) = T{ii, modelCols(end)+1};
    end 
end

%% Use predictive secular variation coefficients to predict coefficients for next epoch
% (used for interpolation)
schmidtNormCoeffs(end).epoch = schmidtNormCoeffs(end-1).epoch + 5;
schmidtNormCoeffs(end).g__nT = schmidtNormCoeffs(end-1).g__nT + 5 * schmidt_gSv__nT_per_year;
schmidtNormCoeffs(end).h__nT = schmidtNormCoeffs(end-1).h__nT + 5 * schmidt_hSv__nT_per_year;

%% Convert Schmidt-normalized coeffients to Gauss-normalized coefficients
for i = 1:length(schmidtNormCoeffs)
    gaussNormCoeffs(i).epoch = schmidtNormCoeffs(i).epoch;
    gaussNormCoeffs(i).g__nT = Igrf.gaussFromSchmidt(schmidtNormCoeffs(i).g__nT);
    gaussNormCoeffs(i).h__nT = Igrf.gaussFromSchmidt(schmidtNormCoeffs(i).h__nT);
end

%% Reference radius
% according to [1]
reference_radius__m = 6371200;

%% Store in struct
IgrfData.gaussNormCoeffs = gaussNormCoeffs;
IgrfData.reference_radius__m = reference_radius__m;


%% Save in file
if(saveFileFlag)
    [current_folder, ~, ~] = fileparts(mfilename('fullpath'));
    processed_data_file_name = fullfile(current_folder, "ProcessedIgrfData", "IgrfCoeffs.mat");
    fprintf("Saving processed IGRF data in file %s...\n", processed_data_file_name);
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

    save(processed_data_file_name, "-struct", "IgrfData");

end