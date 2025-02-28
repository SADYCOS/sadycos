function [desired_torque_B__N_m, ...
            error_quaternion_RB, ...
            angular_velocity_error_RB_B] ...
            = execute(reference_frame_attitude_quaternion_RI, ...
                        reference_angular_velocity_RI_B__rad_per_s, ...
                        body_frame_attitude_quaternion_BI, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        ParametersQuaternionFeedbackControl)
% execute - Calculate the desired torque in the body frame using quaternion feedback control
%
%   [desired_torque_B__N_m, ...
%    error_quaternion_RB, ...
%    angular_velocity_error_RB_B] ...
%    = execute(reference_frame_attitude_quaternion_RI, ...
%               reference_angular_velocity_RI_B__rad_per_s, ...
%               body_frame_attitude_quaternion_BI, ...
%               angular_velocity_BI_B__rad_per_s, ...
%               ParametersQuaternionFeedbackControl)
%
%   Inputs:
%   reference_frame_attitude_quaternion_RI: 4x1 quaternion of reference frame attitude
%   reference_angular_velocity_RI_B__rad_per_s: 3x1 vector of reference frame angular velocity
%   body_frame_attitude_quaternion_BI: 4x1 quaternion of body frame attitude
%   angular_velocity_BI_B__rad_per_s: 3x1 vector of body frame angular velocity
%   ParametersQuaternionFeedbackControl: Parameters of the QuaternionFeedbackControl model
%
%   Outputs:
%   desired_torque_B__N_m: 3x1 vector of desired torque in body frame
%   error_quaternion_RB: 4x1 quaternion of error quaternion
%   angular_velocity_error_RB_B: 3x1 vector of angular velocity error
%
%% References
% [1] B. Wie, Space vehicle dynamics and control, 2nd ed. in AIAA education series. Reston, VA: American Institute of Aeronautics and Astronautics, 2008.

%% Abbreviations
Kp = ParametersQuaternionFeedbackControl.Kp;
Kd = ParametersQuaternionFeedbackControl.Kd;

%% Error quaternion
error_quaternion_RB = smu.unitQuat.att.separation(reference_frame_attitude_quaternion_RI, body_frame_attitude_quaternion_BI);

%% Angular Velocity Error
angular_velocity_error_RB_B = reference_angular_velocity_RI_B__rad_per_s - angular_velocity_BI_B__rad_per_s;

%% Algorithm
% adapted from "Controller 2" in ch. "7.3.1 Quaternion Feedback Control" of [1]

desired_torque_B__N_m = Kp * sign(error_quaternion_RB(1)) * error_quaternion_RB(2:4) + Kd * angular_velocity_error_RB_B; 
% the error quaternion used here describes the rotation from the body frame to the reference frame (opposite to the error quaternion in [1])
% -> the sign of the proportional term is inverted 
end