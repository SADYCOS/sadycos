classdef SimplifiedVleoAerodynamics < ModelBase
    methods (Static)
                        
        [aerodynamic_force_B__N, aerodynamic_torque_B__Nm] ...
            = execute(attitude_quaternion_BI, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        velocity_I_I__m_per_s, ...
                        wind_velocity_I_I__m_per_s, ...
                        atmosphere_mass_density__kg_per_m3, ...
                        atmosphere_number_density__1_per_m3, ...
                        atmosphere_temperature__K, ...
                        bodies_rotation_angles__rad, ...
                        ParametersSimplifiedVleoAerodynamics)

    end

    methods (Access = public)

        function obj = SimplifiedVleoAerodynamics(obj_files, ...
                                                    rotation_hinge_points_CAD, ...
                                                    rotation_directions_CAD, ...
                                                    surface_temperatures__K, ...
                                                    surface_energy_accommodation_coefficients, ...
                                                    DCM_B_from_CAD, ...
                                                    center_of_mass_CAD, ...
                                                    show_body_flag, ...
                                                    temperature_ratio_method)
        % SimplifiedVleoAerodynamics
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

            bodies = vleo_aerodynamics_core.importMultipleBodies(obj_files, ...
                                rotation_hinge_points_CAD, ...
                                rotation_directions_CAD, ...
                                surface_temperatures__K, ...
                                surface_energy_accommodation_coefficients, ...
                                DCM_B_from_CAD, ...
                                center_of_mass_CAD);
            Parameters.bodies = bodies;

            Parameters.temperature_ratio_method = temperature_ratio_method;

            if show_body_flag
                vleo_aerodynamics_core.showBodies(bodies, zeros(size(obj_files)));
            end

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end