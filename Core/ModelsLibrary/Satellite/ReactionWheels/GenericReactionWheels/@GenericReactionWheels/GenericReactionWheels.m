classdef GenericReactionWheels < ModelBase
    methods (Static)
                                
        [rw_angular_velocities_derivative__rad_per_s2, ...
            torque_on_body__N_m] ...
            = execute(torque_commands__Nm, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        rw_angular_velocities__rad_per_s, ...
                        ParametersGenericReactionWheels)

    end

    methods (Access = public)

        function obj = GenericReactionWheels(inertias__kg_m2, ...
                                                spin_directions_B, ...
                                                friction_coefficients__N_m_s_per_rad)
        % GenericReactionWheels
        %
        %   Inputs:
        %   inertias__kg_m2: Inertias of the reaction wheels in kg m^2
        %   spin_directions_B: Spin directions of the reaction wheels in the body frame
        %   friction_coefficients__N_m_s_per_rad: Friction coefficients in N m s per rad
        %

            arguments
                inertias__kg_m2 (:,1) {mustBePositive}
                spin_directions_B (3,:) {mustBeNumeric, mustBeReal, smu.argumentValidation.mustBeEqualLength(spin_directions_B, inertias__kg_m2, 2, 1), mustBeUnitColumns}
                friction_coefficients__N_m_s_per_rad (:,1) {mustBeNonnegative, smu.argumentValidation.mustBeEqualLength(friction_coefficients__N_m_s_per_rad, inertias__kg_m2, 1, 1)}
            end

            Parameters.inertias__kg_m2 = inertias__kg_m2;
            Parameters.spin_directions_B = spin_directions_B;
            Parameters.friction_coefficients__N_m_s_per_rad = friction_coefficients__N_m_s_per_rad;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end

end