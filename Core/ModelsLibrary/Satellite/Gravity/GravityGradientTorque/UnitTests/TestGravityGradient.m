classdef TestGravityGradient < matlab.unittest.TestCase

    methods(Test)
        function zeroAttitude_PointMass(testCase)
            % Constants
            gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2

            % Initialise Model
            inertia_B__kg_m2 = diag([0.4,1,0.1]);

            % Gravity Gradient Model
            ParamsSGGT ...
                = SphericalGravityGradientTorque(inertia_B__kg_m2,...
                                            gravitational_parameter_Earth__m3_per_s2);

            % Execute Model
            actSolution = SphericalGravityGradientTorque.execute([0,0,6.778e6]',...
                                                    [1,0,0,0]',...
                                                    ParamsSGGT.Parameters);

            expSolution = [0;0;0];
            testCase.verifyEqual(actSolution,expSolution)
        end

        function symmetricInertia_PointMass(testCase)
            % Constants
            gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2

            % Initialise Model
            inertia_B__kg_m2 = diag([1,1,1]);

            % Gravity Gradient Model
            ParamsSGGT ...
                = SphericalGravityGradientTorque(inertia_B__kg_m2,...
                                            gravitational_parameter_Earth__m3_per_s2);

            % Execute Model
            actSolution = SphericalGravityGradientTorque.execute([0,6.778e6,0]',...
                                                    dcm2quat(smu.dcm.z(rad2deg(50))),...
                                                    ParamsSGGT.Parameters);

            expSolution = [0;0;0];
            testCase.verifyEqual(actSolution,expSolution)
        end

        function nonZeroTorque_PointMass(testCase)
            import matlab.unittest.constraints.IsGreaterThanOrEqualTo

            % Constants
            gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2

            % Initialise Model
            inertia_B__kg_m2 = diag([1,0.1,1]);

            % Gravity Gradient Model
            ParamsSGGT ...
                = SphericalGravityGradientTorque(inertia_B__kg_m2,...
                                            gravitational_parameter_Earth__m3_per_s2);

            % Execute Model
            actSolution = SphericalGravityGradientTorque.execute([0,6.778e6,0]',...
                                                    dcm2quat(smu.dcm.z(rad2deg(50))),...
                                                    ParamsSGGT.Parameters);

            testCase.verifyThat(actSolution(3),IsGreaterThanOrEqualTo(0))
        end
    end
    
end