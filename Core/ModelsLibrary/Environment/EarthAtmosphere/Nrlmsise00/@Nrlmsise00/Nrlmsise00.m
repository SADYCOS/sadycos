classdef Nrlmsise00 < ModelBase
    methods (Static)

        [atmosphere_mass_density__kg_per_m3, ...
            atmosphere_number_density__1_per_m3, ...
            atmosphere_temperature__K] ...
            = execute(position_BI_I__m, ...
                            attitude_quaternion_EI, ...
                            current_modified_julian_date, ...
                            ParametersNrlmsise00)

        Nrlmsise00Data = processSpaceWeatherData(saveFileFlag)

        Nrlmsise00Data = loadProcessedSpaceWeatherData()

    end

    methods (Access = public)

        function obj = Nrlmsise00(mjd0, simulation_duration__s, switches, position_precision__m)
        % Nrlmsise00
        %
        %   Inputs:
        %   mjd0: Initial modified julian date
        %   simulation_duration__s: Duration of simulation in seconds
        %   switches: 24x1 vector of switches for NRLMSISE00
        %   position_precision__m: Position precision in meters

        arguments
            mjd0 (1,1) {mustBePositive}
            simulation_duration__s (1,1) {mustBePositive}
            switches (24,1) logical
            position_precision__m (1,1) {mustBePositive}
        end

            %% Load data for NRLMSISE00
            Nrlmsise00Data = Nrlmsise00.loadProcessedSpaceWeatherData();

            % Calculate final modified julian date
            mjd_fin = mjd0 + simulation_duration__s/86400;

            % Display error if no atmospheric data is available
            if (mjd0 < min([Nrlmsise00Data.mjd])) || (mjd_fin > max([Nrlmsise00Data.mjd]))
                error('Atmospheric data not available for entire duration of simulation!');
            end

            % Find indices of relevant mjds for simulation

            % Find all mjds smaller than mjd0
            smaller_logIdxs = ([Nrlmsise00Data.mjd] < mjd0);

            idx1 = find(smaller_logIdxs, 1, 'last');
            idx1 = min([idx1, length(Nrlmsise00Data) - 1]);

            % Find all mjds greater than mjd_fin
            greater_logIdxs = ([Nrlmsise00Data.mjd] > mjd_fin);

            idx2 = find(greater_logIdxs, 1, 'first');
            idx2 = max([idx2, 2]);

            Parameters.Nrlmsise00Data = Nrlmsise00Data(idx1:idx2);

            %% Copy switches into Parameters

            Parameters.switches = switches;

            %% Copy position precision into Parameters

            Parameters.position_precision__m = position_precision__m;

            %% Add header files, include directories and source files of nrlmsise00 model to Settings Parameters

            [this_folder,~,~] = fileparts(mfilename("fullpath"));
            c_code_folder = fullfile(this_folder, "..", "c_code");
            wrapper_folder = fullfile(c_code_folder, "wrapper");
            wrapper_header_file = fullfile(wrapper_folder, "nrlmsise00Wrapper.h");
            submodule_folder = fullfile(c_code_folder, "nrlmsise-00");

            include_headers = """" + wrapper_header_file + """" + newline;
            include_directories = """" + wrapper_folder + """" + newline ...
                                    + """" + submodule_folder + """" + newline;
            source_files = "nrlmsise00Wrapper.c" + newline ...
                            + "nrlmsise-00.c" + newline ...
                            + "nrlmsise-00_data.c" + newline;

            Settings = [SimulinkModelSetting("SimCustomHeaderCode", include_headers), ...
                        SimulinkModelSetting("SimUserIncludeDirs", include_directories), ...
                        SimulinkModelSetting("SimUserSources", source_files)];

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters,"Settings", Settings);
        end
        
    end

end