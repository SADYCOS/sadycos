classdef QuaternionFeedbackControl < ModelBase
    methods (Static)
        
        desired_torque_B__N_m = execute(reference_frame_attitude_quaternion_RI, ...
                                            body_frame_attitude_quaternion_BI, ...
                                            angular_velocity_BI_B__rad_per_s, ...
                                            ParametersQuaternionFeedbackControl)
                                            
    end

    methods (Access = public)

        function obj = QuaternionFeedbackControl(proportional_gain, derivative_gain)
        % QuaternionFeedbackControl
        %
        %   Inputs:
        %   proportional_gain: Proportional gain for quaternion feedback control
        %   derivative_gain: Derivative gain for quaternion feedback control
        %

        arguments
            proportional_gain (1,1) {mustBeNumeric}
            derivative_gain (1,1) {mustBeNumeric}
        end

            Parameters.Kp = proportional_gain;
            Parameters.Kd = derivative_gain;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end