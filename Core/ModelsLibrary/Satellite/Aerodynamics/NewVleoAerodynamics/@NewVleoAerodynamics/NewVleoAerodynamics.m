classdef NewVleoAerodynamics < ModelBase

    methods (Static)
                        
        [aerodynamic_force_B__N, aerodynamic_torque_B__Nm] ...
            = execute(attitude_quaternion_BI, ...
                        velocity_I_I__m_per_s, ...
                        wind_velocity_I_I__m_per_s, ...
                        surface_temperatures__K, ...
                        ParametersNewVleoAerodynamics,...
                        atmosphere_mass_density__kg_per_m3, ...
                        atmosphere_number_density__1_per_m3, ...
                        atmosphere_temperature__K,...
                        surface_energy_accommodation_coefficients)

        test                
                        

    end

    methods (Access = public)

        function obj = NewVleoAerodynamics(temperature_ratio_method)
                                                    
        % NewVleoAerodynamics
        %
        %   Inputs:
        %   atmosphere_mass_density__kg_per_m3: Atmospheric mass density in kg/m^3
        %   atmosphere_number_density__1_per_m3: Atmospheric number density in 1/m^3
        %   atmosphere_temperature__K: Atmospheric temperature in K
        %   surface_temperatures__K: 1xN vector of surface temperatures in K
        %   surface_energy_accommodation_coefficients: 1xN vector of surface energy accommodation coefficients
        %   temperature_ratio_method: Method to calculate temperature ratio
        %
            arguments
                temperature_ratio_method (1,1) {mustBeInteger, mustBePositive}
            end
            

            %% Create Sentman object
            sentman = new_vleo_aerodynamics_core.Sentman(temperature_ratio_method);

            % Save Sentman object in Parameters
            Parameters.sentman = sentman;


            %% Load Satellite Geometry
            %this_folder = fileparts(mfilename('fullpath'));
            %target_folder = fullfile('Core', 'external_namespaces', 'new-vleo-aerodynamics-core', '+new_vleo_aerodynamics_core');
            %mesh_file_path = fullfile(this_folder, target_folder, 'International Space Station.obj');
            
            sentman_file_path = which( ...
                "new_vleo_aerodynamics_core.Sentman");

            assert(~isempty(sentman_file_path), ...
                "The package new_vleo_aerodynamics_core is not on the MATLAB path.");

            package_folder = fileparts(sentman_file_path);

            mesh_file_path = fullfile( ...
                package_folder, ...
                "International Space Station.obj");

            assert(isfile(mesh_file_path), ...
                "Satellite geometry was not found: %s", ...
                mesh_file_path);

            % Check if the mesh file exists (debugging)
            % disp(mesh_file_path)
            % disp(isfile(mesh_file_path))
            % file_info = dir(mesh_file_path);
            % disp(file_info)

            satellite =  new_vleo_aerodynamics_core.RotatableMeshSatellite(mesh_file_path);

            % Debugging: Display the number of surfaces in the satellite
            num_triangles = satellite.get_num_triangles();
            fprintf("Loaded triangles: %d\n", num_triangles);

            % Rotate a specific surface/panel of the satellite 90 degrees around the Y-axis
            % rotation_angle_rad = pi / 2;
            % rotation_center = [0, 0, 0];
            % rotation_axis = [0, 1, 0];
            % iss_satellite.turn_surface_around_axis(1, rotation_angle_rad, rotation_center, rotation_axis);

            % Save ISS satellite object in Parameters
            Parameters.satellite = satellite;


            %% Create shading pipeline object with a resolution/grid size of 800
            shading_pipeline = new_vleo_aerodynamics_core.ShadingPipeline(...
                satellite, ...  % satellite object
                1, ...              % shading algorithm (0 = binary, 1 = CoP)
                800);               % number of pixels

            % Save shading pipeline object in Parameters
            Parameters.shading_pipeline = shading_pipeline;


            %% Create HybridAeroLoadCalculator object
            load_calculator = new_vleo_aerodynamics_core.HybridAeroLoadCalculator(...
            satellite, ...      % satellite object
            shading_pipeline, ...   % shading pipeline object
            sentman);               % sentman model object

            % Save load calculator object in Parameters
            Parameters.load_calculator = load_calculator;


            % Save other important parameters in Parameters
            Parameters.temperature_ratio_method = temperature_ratio_method;
            Parameters.mesh_file_path = mesh_file_path;
            

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end
    end
end