function desired_torque_B__N_m = execute(error_quaternion_RB, ...
                                            angular_velocity_error_RB_B, ...
                                            ParametersQuaternionFeedbackControl)
% execute - Calculate the desired torque in the body frame using quaternion feedback control
%
%   desired_torque_B__N_m = execute(error_quaternion_RB, ...
%                                   angular_velocity_error_RB_B, ...
%                                   ParametersQuaternionFeedbackControl)
%
%   Inputs:
%   error_quaternion_RB: 4x1 quaternion describing rotation from body to reference frame
%   angular_velocity_error_RB_B: 3x1 vector of angular velocity error in body frame [rad/s]
%   ParametersQuaternionFeedbackControl: Parameters of the QuaternionFeedbackControl model
%
%   Outputs:
%   desired_torque_B__N_m: 3x1 vector of desired torque in body frame [N⋅m]
%
%% References
% [1] B. Wie, Space vehicle dynamics and control, 2nd ed. in AIAA education series. Reston, VA: American Institute of Aeronautics and Astronautics, 2008.

%% Abbreviations
Kp = ParametersQuaternionFeedbackControl.Kp;
Kd = ParametersQuaternionFeedbackControl.Kd;

%% Algorithm
% adapted from "Controller 2" in ch. "7.3.1 Quaternion Feedback Control" of [1]

desired_torque_B__N_m = Kp * sign(error_quaternion_RB(1)) * error_quaternion_RB(2:4) + Kd * angular_velocity_error_RB_B; 
% the error quaternion used here describes the rotation from the body frame to the reference frame (opposite to the error quaternion in [1])
% -> the sign of the proportional term is inverted 
end