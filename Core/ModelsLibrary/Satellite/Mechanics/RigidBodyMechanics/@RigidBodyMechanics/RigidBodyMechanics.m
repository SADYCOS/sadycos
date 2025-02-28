classdef RigidBodyMechanics < ModelBase
    methods (Static)
        
        [position_derivative_BI_I__m_per_s, ...
            velocity_derivative_BI_I__m_per_s2, ...
            attitude_quaternion_derivative__1_per_s, ...
            angular_velocity_derivative_BI_B__rad_per_s2] ...
            = execute(net_force_I__N, ...
                        net_torque_B__N_m, ...
                        velocity_BI_I__m_per_s, ...
                        attitude_quaternion_BI, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        ParametersRigidBodyMechanics)
                        
    end

    methods (Access = public)

        function obj = RigidBodyMechanics(mass__kg, inertia_B_B__kg_m2)
        % RigidBodyMechanics
        %
        %   Inputs:
        %   mass__kg: Mass of the rigid body in kg
        %   inertia_B_B__kg_m2: Inertia of the rigid body in the body frame in kg m^2
        %

        arguments
            mass__kg (1,1) {mustBePositive}
            inertia_B_B__kg_m2 (3,3) {mustBeSymmetricPositiveDefinite}
        end

            Parameters.mass__kg = mass__kg;
            Parameters.inertia_B_B__kg_m2 = inertia_B_B__kg_m2;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end