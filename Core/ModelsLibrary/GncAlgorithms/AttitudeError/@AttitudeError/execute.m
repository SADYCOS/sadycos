function [error_quaternion_RB, ...
            angular_velocity_B__rad_per_s, ...
            angular_acceleration_B__rad_per_s2] ...
            = execute(reference_frame_attitude_quaternion_RI, ...
                        body_frame_attitude_quaternion_BI, ...
                        reference_angular_velocity_RI_R__rad_per_s, ...
                        body_angular_velocity_BI_B__rad_per_s, ...
                        reference_angular_acceleration_RI_R__rad_per_s2, ...
                        body_angular_acceleration_BI_B__rad_per_s2)
% execute - Calculate the error quaternion and angular velocity/acceleration errors
%
%   [error_quaternion_RB, ...
%    angular_velocity_B__rad_per_s, ...
%    angular_acceleration_B__rad_per_s2] ...
%    = execute(reference_frame_attitude_quaternion_RI, ...
%                body_frame_attitude_quaternion_BI, ...
%                reference_angular_velocity_RI_R__rad_per_s, ...
%                body_angular_velocity_BI_B__rad_per_s, ...
%                reference_angular_acceleration_RI_R__rad_per_s2, ...
%                body_angular_acceleration_BI_B__rad_per_s2)
%
%   This function calculates the error quaternion between two attitude quaternions
%   and optionally computes angular velocity and acceleration errors. Each input
%   quaternion represents the attitude of a frame (R and B, respectively) relative
%   to a common reference frame I. The resulting error quaternion describes the
%   attitude of the R frame relative to the B frame. The angular velocity and
%   acceleration inputs must be given in their respective frames (R and B).
%
%   Inputs:
%       reference_frame_attitude_quaternion_RI - 4x1 vector representing the attitude of the R frame relative to the I frame
%       body_frame_attitude_quaternion_BI - 4x1 vector representing the attitude of the B frame relative to the I frame
%       reference_angular_velocity_RI_R__rad_per_s - 3x1 vector of the angular velocity of the R frame relative to the I frame expressed in R frame [rad/s] (optional)
%       body_angular_velocity_BI_B__rad_per_s - 3x1 vector of the angular velocity of the B frame relative to the I frame expressed in B frame [rad/s] (optional)
%       reference_angular_acceleration_RI_R__rad_per_s2 - 3x1 vector of the angular acceleration of the R frame relative to the I frame expressed in R frame [rad/s²] (optional)
%       body_angular_acceleration_BI_B__rad_per_s2 - 3x1 vector of the angular acceleration of the B frame relative to the I frame expressed in B frame [rad/s²] (optional)
%
%   Outputs:
%       error_quaternion_RB - 4x1 vector representing the attitude of the R frame relative to the B frame
%       angular_velocity_B__rad_per_s - struct containing angular velocity data in B frame [rad/s]
%           .reference_RI - 3x1 vector of reference angular velocity transformed to B frame
%           .error_RB_B - 3x1 vector of angular velocity error in B frame
%       angular_acceleration_B__rad_per_s2 - struct containing angular acceleration data in B frame [rad/s²]
%           .reference_RI - 3x1 vector of reference angular acceleration transformed to B frame
%           .error_RB - 3x1 vector of angular acceleration error in B frame
%

arguments
    reference_frame_attitude_quaternion_RI (4,1) double
    body_frame_attitude_quaternion_BI (4,1) double
    reference_angular_velocity_RI_R__rad_per_s (3,1) double = nan(3,1)
    body_angular_velocity_BI_B__rad_per_s (3,1) double = nan(3,1)
    reference_angular_acceleration_RI_R__rad_per_s2 (3,1) double = nan(3,1)
    body_angular_acceleration_BI_B__rad_per_s2 (3,1) double = nan(3,1)
end

% Always calculate error quaternion
error_quaternion_RB = smu.unitQuat.att.separation(reference_frame_attitude_quaternion_RI, ...
                                                    body_frame_attitude_quaternion_BI);

% Early return if only quaternion is needed
if nargout <= 1
    return;
end

% Validate angular velocity inputs
if any(isnan([reference_angular_velocity_RI_R__rad_per_s ; body_angular_velocity_BI_B__rad_per_s]))
    error('Both angular velocity inputs must be provided when requesting angular velocity error.');
end

% Calculate angular velocity error
reference_angular_velocity_RI_B__rad_per_s = ...
    smu.unitQuat.att.transformVector(error_quaternion_RB, ...
                                     reference_angular_velocity_RI_R__rad_per_s);
angular_velocity_error_RB_B__rad_per_s = reference_angular_velocity_RI_B__rad_per_s ...
                                            - body_angular_velocity_BI_B__rad_per_s;

angular_velocity_B__rad_per_s.reference_RI = reference_angular_velocity_RI_B__rad_per_s;
angular_velocity_B__rad_per_s.error_RB_B = angular_velocity_error_RB_B__rad_per_s;

% Early return if acceleration is not needed
if nargout <= 2
    return;
end

% Validate angular acceleration inputs
if any(isnan([reference_angular_acceleration_RI_R__rad_per_s2 ; body_angular_acceleration_BI_B__rad_per_s2]))
    error('Both angular acceleration inputs must be provided when requesting angular acceleration error.');
end

% Calculate angular acceleration error
reference_angular_acceleration_RI_B__rad_per_s2 = ...
    smu.unitQuat.att.transformVector(error_quaternion_RB, ...
                                     reference_angular_acceleration_RI_R__rad_per_s2) ...
    + cross(angular_velocity_error_RB_B__rad_per_s, reference_angular_velocity_RI_B__rad_per_s);
angular_acceleration_error_RB_B__rad_per_s2 = reference_angular_acceleration_RI_B__rad_per_s2 ...
                                                - body_angular_acceleration_BI_B__rad_per_s2;

angular_acceleration_B__rad_per_s2.reference_RI = reference_angular_acceleration_RI_B__rad_per_s2;
angular_acceleration_B__rad_per_s2.error_RB = angular_acceleration_error_RB_B__rad_per_s2;

end