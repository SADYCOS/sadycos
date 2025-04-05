classdef SphericalGravityGradientTorque < ModelBase
    methods (Static)
        gravity_gradient_torque_BI_B__Nm = execute(position_BI_I__m,...
                                            attitude_quaternion_BI,...
                                            paramsGravityGradient)

    end

    methods (Access = public)

        function obj = SphericalGravityGradientTorque(inertia__kg_m2,...
                                gravitational_parameter_Earth__m3_per_s2)
        % GravityGradientPointMass
        %
        %   Inputs:
        %   inertia__kg_m2: inertia of the spacecraft
        %   gravitational_parameter_Earth__m3_per_s2: constant
        %

        arguments
            inertia__kg_m2 (3,3) {mustBeReal}
            gravitational_parameter_Earth__m3_per_s2 (1,1) {mustBeReal,mustBePositive,mustBeFinite}
        end

            Parameters.inertia_B__kg_m2 = inertia__kg_m2;
            Parameters.gravitational_parameter_Earth__m3_per_s2 = gravitational_parameter_Earth__m3_per_s2;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end