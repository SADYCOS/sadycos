classdef atmospheric_velocity < ModelBase
    methods (Static)

        [atmosphere_wind_I__m_per_s] ...
            = execute(position_BI_I__m, ...
                            attitude_quaternion_EI, ...
                            current_modified_julian_date, ...
                            ParametersHwm14)

        createHWMmexFunction()

    end

    methods (Access = public)

        function obj = atmospheric_velocity(mjd0, simulation_duration__s, position_precision__m)
        % atmospheric_velocity
        %
        %   Inputs:
        %   mjd0: Initial modified julian date
        %   simulation_duration__s: Duration of simulation in seconds
        %   position_precision__m: Position precision in meters


        arguments
            mjd0 (1,1) {mustBePositive}
            simulation_duration__s (1,1) {mustBePositive}
            position_precision__m (1,1) {mustBePositive}
        end

        %% Determine the path to the hwm14ifc_mex function
        
        dataPath = fullfile('Core', 'ModelsLibrary', 'Environment', 'EarthAtmosphere',...
                            'hwm14', 'bin', 'install', 'share', 'data', 'hwm14');
        % Check if the data folder exists, if not, throw an error
        if ~isfolder(dataPath)
            error('hwm14:dataNotFound', ...
                  'HWM14 data folder not found at:\n%s', dataPath);
        end

        % Copy the data path into Parameters
        Parameters.dataPath = dataPath;

        %% Load data for hwm14

            Parameters.Hwm14Data = spaceweatherdata.loadProcessedSpaceWeatherData(mjd0, simulation_duration__s);

            %% Copy position precision into Parameters

            Parameters.position_precision__m = position_precision__m;
        
            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);
        end

    end

end