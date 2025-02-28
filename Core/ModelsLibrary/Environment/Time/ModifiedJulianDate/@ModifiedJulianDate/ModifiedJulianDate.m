classdef ModifiedJulianDate < ModelBase
    methods (Static)
        
        current_time__mjd = execute(simulation_time__s, ParametersModifiedJulianDate)
        
    end

    methods (Access = public)

        function obj = ModifiedJulianDate(simulation_start_time__mjd)
        % ModifiedJulianDate
        %
        %   Inputs:
        %   simulation_start_time__mjd: Initial modified julian date
        %

        arguments
            simulation_start_time__mjd (1,1) {mustBePositive}
        end

            Parameters.simulation_start_time__mjd = simulation_start_time__mjd;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);
            
        end

    end
end