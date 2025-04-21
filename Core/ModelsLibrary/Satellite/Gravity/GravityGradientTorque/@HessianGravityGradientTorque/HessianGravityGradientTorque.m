classdef HessianGravityGradientTorque < ModelBase
    methods (Static)
        gravity_gradient_torque_BI_B__Nm = execute(position_BI_I__m,...
                                                attitude_quaternion_BI,...
                                                gravitational_hessian_I__1_per_s2, ...
                                                paramsGravityGradient)

    end

    methods (Access = public)

        function obj = HessianGravityGradientTorque(inertia__kg_m2)
        % GravityGradientSpherical
        %
        %   Inputs:
        %   inertia__kg_m2: inertia of the spacecraft
        %

        arguments
            inertia__kg_m2 (3,3) {mustBeReal}
        end

            Parameters.inertia_B__kg_m2 = inertia__kg_m2;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end