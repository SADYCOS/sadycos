classdef PanelMethodSRP < ModelBase
    methods (Static)
                            
        [srp_force_B__N, srp_torque_B__Nm] ...
                = execute(attitude_quaternion_BI, ...
                            irradiance_at_sat_I_I__W_per_m2, ...
                            bodies_rotation_angles__rad, ...
                            ParametersPanelMethodSRP)

    end

    methods (Access = public)

        function obj = PanelMethodSRP(obj_files, ...
                                        rotation_hinge_points_CAD, ...
                                        rotation_directions_CAD, ...
                                        reflectivities, ...
                                        DCM_B_from_CAD, ...
                                        center_of_mass_CAD, ...
                                        show_body_flag)
        % PanelMethodSRP
        %
        %   Inputs:
        %   obj_files: Cell array of file paths to .obj files
        %   rotation_hinge_points_CAD: 3xN matrix of hinge points in CAD frame
        %   rotation_directions_CAD: 3xN matrix of rotation directions in CAD frame
        %   reflectivities: 1xN vector of reflectivities of the surfaces
        %   DCM_B_from_CAD: 3x3xN matrix of DCMs from CAD to body frame
        %   center_of_mass_CAD: 3x1 vector of center of mass in CAD frame
        %   show_body_flag: Flag to show body in 3D viewer
        %
            arguments
                obj_files % will be validated in importMultipleBodies
                rotation_hinge_points_CAD % will be validated in importMultipleBodies
                rotation_directions_CAD % will be validated in importMultipleBodies
                reflectivities % will be validated in importMultipleBodies
                DCM_B_from_CAD % will be validated in importMultipleBodies
                center_of_mass_CAD % will be validated in importMultipleBodies
                show_body_flag (1,1) logical = false
            end

            bodies = panel_based_pressure_response.importMultipleBodies(obj_files, ...
                                rotation_hinge_points_CAD, ...
                                rotation_directions_CAD, ...
                                reflectivities, ...
                                DCM_B_from_CAD, ...
                                center_of_mass_CAD);
            Parameters.bodies = bodies;

            if show_body_flag
                vleo_aerodynamics_core.showBodies(bodies, zeros(size(obj_files)));
            end

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end