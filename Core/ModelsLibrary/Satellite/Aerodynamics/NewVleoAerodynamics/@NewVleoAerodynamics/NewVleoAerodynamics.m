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

        function obj = NewVleoAerodynamics(obj_files, ...
                                                    rotation_hinge_points_CAD, ...
                                                    rotation_directions_CAD, ...
                                                    surface_temperatures__K, ...
                                                    surface_energy_accommodation_coefficients, ...
                                                    DCM_B_from_CAD, ...
                                                    center_of_mass_CAD, ...
                                                    show_body_flag, ...
                                                    temperature_ratio_method)
                                                    
        % NewVleoAerodynamics
        %
        %   Inputs:
        %   obj_files: Cell array of file paths to .obj files
        %   rotation_hinge_points_CAD: 3xN matrix of hinge points in CAD frame
        %   rotation_directions_CAD: 3xN matrix of rotation directions in CAD frame
        %   surface_temperatures__K: 1xN vector of surface temperatures in K
        %   surface_energy_accommodation_coefficients: 1xN vector of surface energy accommodation coefficients
        %   DCM_B_from_CAD: 3x3xN matrix of DCMs from CAD to body frame
        %   center_of_mass_CAD: 3x1 vector of center of mass in CAD frame
        %   show_body_flag: Flag to show body in 3D viewer
        %   temperature_ratio_method: Method to calculate temperature ratio
        %
            arguments
                obj_files % will be validated in importMultipleBodies
                rotation_hinge_points_CAD % will be validated in importMultipleBodies
                rotation_directions_CAD % will be validated in importMultipleBodies
                surface_temperatures__K % will be validated in importMultipleBodies
                surface_energy_accommodation_coefficients % will be validated in importMultipleBodies
                DCM_B_from_CAD % will be validated in importMultipleBodies
                center_of_mass_CAD % will be validated in importMultipleBodies
                show_body_flag (1,1) logical = false
                temperature_ratio_method (1,1) {mustBeInteger, mustBePositive} = 1
            end
            

            %% Save bodie, temperature ratio method and body flag in Parameters
            bodies = vleo_aerodynamics_core.importMultipleBodies(obj_files, ...
                                rotation_hinge_points_CAD, ...
                                rotation_directions_CAD, ...
                                surface_temperatures__K, ...
                                surface_energy_accommodation_coefficients, ...
                                DCM_B_from_CAD, ...
                                center_of_mass_CAD);

            Parameters.bodies = bodies;

            Parameters.temperature_ratio_method = temperature_ratio_method;

            satelliteObj = new_vleo_aerodynamics_core.RotatableMeshSatellite(obj_files);

            if show_body_flag
                vleo_aerodynamics_core.showBodies(bodies, zeros(size(obj_files)));
            end


            %% Create sentman object
            sentman = new_vleo_aerodynamics_core.Sentman(temperature_ratio_method);

            % Save sentman object in Parameters
            Parameters.sentman = sentman;


            %% Create shading pipeline object with a resolution/grid size of 800
            shading_pipeline = new_vleo_aerodynamics_core.ShadingPipeline(...
                satelliteObj, ...  % satellite .obj file
                1, ...              % shading algorithm (0 = binary, 1 = CoP)
                800);               % number of pixels

            % Save shading pipeline object in Parameters
            Parameters.shading_pipeline = shading_pipeline;


            %% Create HybridAeroLoadCalculator object
            load_calculator = new_vleo_aerodynamics_core.HybridAeroLoadCalculator(...
            satelliteObj, ...      % satellite .obj file
            shading_pipeline, ...   % shading pipeline object
            sentman);               % sentman model object

            % Save load calculator object in Parameters
            Parameters.load_calculator = load_calculator;


            % Save other important parameters in Parameters
            % Parameters.temperature_ratio_method = temperature_ratio_method;
            % Parameters.mesh_file_path = obj_files;
            

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end
    end
end