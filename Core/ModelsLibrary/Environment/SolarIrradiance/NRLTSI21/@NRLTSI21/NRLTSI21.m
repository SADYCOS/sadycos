classdef NRLTSI21 < ModelBase

    methods (Static)

        [total_solar_irradiance_at_1AU_W_per_m2] ...
            = execute(current_modified_julian_date, ...
                       ParametersNrltsi21)

        processNrltsiProjectionData(saveFileFlag)

        Nrltsi21Data = loadNrltsiProjectionData()

    end

    methods (Access = public)

        function obj = NRLTSI21(mjd0,simulation_duration__s)
        % NRLTSI21
        %
        %   Inputs:
        %   mjd0: Initial modified julian date
        %   simulation_duration__s: Duration of simulation in seconds

        arguments
            mjd0 (1,1) {mustBePositive}
            simulation_duration__s (1,1) {mustBePositive}            
        end

            %% Load data for NRLTSI21
            Nrltsi21Data = NRLTSI21.loadNrltsiProjectionData();

            % Calculate final modified julian date
            mjd_fin = mjd0 + simulation_duration__s/86400;

            % Display error if no atmospheric data is available
            if (mjd0 < min([Nrltsi21Data.mjd])) || (mjd_fin > max([Nrltsi21Data.mjd]))
                error('Solar irradiance data not available for entire duration of simulation!');
            end

            % Find indices of relevant mjds for simulation

            % Find all mjds smaller than mjd0
            smaller_logIdxs = ([Nrltsi21Data.mjd] < mjd0);

            idx1 = find(smaller_logIdxs, 1, 'last');
            idx1 = min([idx1, length(Nrltsi21Data) - 1]);

            % Find all mjds greater than mjd_fin
            greater_logIdxs = ([Nrltsi21Data.mjd] > mjd_fin);

            idx2 = find(greater_logIdxs, 1, 'first');
            idx2 = max([idx2, 2]);

            Parameters.Nrltsi21Data = Nrltsi21Data(idx1:idx2);

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);
        end
        
    end

end