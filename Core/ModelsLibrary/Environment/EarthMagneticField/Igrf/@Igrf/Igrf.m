classdef Igrf < ModelBase
    methods (Static)
        
        magnetic_field_I__T = execute(position_BI_I__m, attitude_quaternion_EI, current_year, ParametersIgrf)
        IgrfData = processIgrfData(file_name, saveFileFlag)
        gaussCoeffs = gaussFromSchmidt(schmidtCoeffs)
        
    end

    methods (Access = public)

        function obj = Igrf(mjd0, simulation_duration__s, max_degree)
        % Igrf
        %
        %   Inputs:
        %   mjd0: Initial modified julian date
        %   simulation_duration__s: Duration of simulation in seconds
        %   max_degree: Maximum degree of IGRF coefficients to load
        %

        arguments
            mjd0 (1,1) {mustBePositive}
            simulation_duration__s (1,1) {mustBePositive}
            max_degree (1,1) {mustBeInteger, mustBePositive}
        end

            % Load data for IGRF
            [current_folder, ~, ~] = fileparts(mfilename('fullpath'));
            data = load(fullfile(current_folder, "ProcessedIgrfData", "IgrfCoeffs.mat"));
            
            % Copy reference radius of coefficients into parameter structure
            Parameters.reference_radius__m = data.reference_radius__m;
            
            % Calculate initial year and final year from from initial modified julian
            % date and simulation duration
            [year_ini, ~, ~] = smu.time.calDatFromModifiedJulianDate(mjd0);
            [year_fin, ~, ~] = smu.time.calDatFromModifiedJulianDate(mjd0 + simulation_duration__s/86400);
            
            % Find indices of relevant epochs for simulation
            % The igrf function always linearly interpolates/extrapolates between two
            % epochs. Therefore, always two epochs need to be kept. If initial and
            % final year are before the first epoch, keep the first two epochs. If
            % initial and final year are after the last epoch, keep the last two epoch.
            % Otherwise, keep all epochs relevant for the all times between the initial
            % and final year.
            
            % Find all epochs smaller than the initial year.
            smaller_logIdxs = ([data.gaussNormCoeffs.epoch] < year_ini);
            
            idx1 = find(smaller_logIdxs, 1, 'last');
            if isempty(idx1)
                idx1 = 1;
            else
                idx1 = min([idx1, length(data.gaussNormCoeffs) - 1]);
            end
            % Find all epochs greater than the final year.
            greater_logIdxs = ([data.gaussNormCoeffs.epoch] > year_fin);
            
            idx2 = find(greater_logIdxs, 1, 'first');
            if isempty(idx2)
                idx2 = length(data.gaussNormCoeffs);
            else
                idx2 = max([idx2, 2]);
            end
            
            num_relevant_epochs = sum(idx2 - idx1 + 1);
            
            % Prepare structure
            Parameters.gaussNormCoeffs(num_relevant_epochs) = struct();
            
            % Get a vector of all indices
            idxs = idx1:idx2;
            
            % Copy data into parameter structure
            for i = 1:num_relevant_epochs
                theData = data.gaussNormCoeffs(idxs(i));
                
                % Copy epoch into parameter structure
                Parameters.gaussNormCoeffs(i).epoch ...
                    = theData.epoch;
                % Copy coefficients only up to desired maximum degree into parameter structure
                Parameters.gaussNormCoeffs(i).g__nT ...
                    = theData.g__nT(1:max_degree, 1:max_degree+1);
                % Copy coefficients only up to desired maximum degree into parameter structure
                    Parameters.gaussNormCoeffs(i).h__nT ...
                        = theData.h__nT(1:max_degree, 1:max_degree+1);
            end
            
            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);
            
            end

    end
end