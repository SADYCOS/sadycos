classdef RateLimitedReactionWheels < GenericReactionWheels
    methods (Static)
                                
        [rw_angular_velocities_derivative__rad_per_s2, ...
            torque_on_body__N_m] ...
            = execute(torque_commands__Nm, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        rw_angular_velocities__rad_per_s, ...
                        ParametersRateLimitedReactionWheels)

    end

    methods (Access = public)

        function obj = RateLimitedReactionWheels(inertias__kg_m2, ...
                                                    spin_directions_B, ...
                                                    friction_coefficients__N_m_s_per_rad, ...
                                                    maximum_frequencies__rad_per_s)
        % RateLimitedReactionWheels
        %
        %   Inputs:
        %   inertias__kg_m2: Inertias of the reaction wheels in kg m^2
        %   spin_directions_B: Spin directions of the reaction wheels in the body frame
        %   friction_coefficients__N_m_s_per_rad: Friction coefficients in N m s per rad
        %   maximum_frequencies__rad_per_s: Maximum frequencies of the reaction wheels in rad/s
        %

            arguments
                inertias__kg_m2 % is validated in base class constructor
                spin_directions_B (3,:) % is validated in base class constructor
                friction_coefficients__N_m_s_per_rad (:,1) % is validated in base class constructor
                maximum_frequencies__rad_per_s (1,:) {mustBePositive, smu.argumentValidation.mustBeEqualLength(maximum_frequencies__rad_per_s, inertias__kg_m2, 2, 1)}
            end

            obj = obj@GenericReactionWheels(inertias__kg_m2, ...
                                            spin_directions_B, ...
                                            friction_coefficients__N_m_s_per_rad);

            obj.Parameters.maximum_frequencies__rad_per_s = maximum_frequencies__rad_per_s;

        end

    end
end