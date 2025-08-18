function error_quaternion_RB = execute(reference_frame_attitude_quaternion_RI, ...
                                        body_frame_attitude_quaternion_BI)
% execute - Calculate the error quaternion between two attitude quaternions
%
%   error_quaternion_RB = execute(reference_frame_attitude_quaternion_RI, ...
%                                   body_frame_attitude_quaternion_BI)
%
%   This function calculates the error quaternion between two attitude quaternions.
%   Each of the input quaternions should be a 4-element vector representing the
%   attitude of a frame (R and B, respectively) relative to a common reference
%   frame I. The resulting error quaternion describes the attitude of the R frame
%   relative to the B frame.
%
%   Inputs:
%       reference_frame_attitude_quaternion_RI - 4-element vector representing the attitude of the R frame relative to the I frame
%       body_frame_attitude_quaternion_BI - 4-element vector representing the attitude of the B frame relative to the I frame
%
%   Outputs:
%       error_quaternion_RB - 4-element vector representing the error quaternion from the R frame to the B frame
%

    error_quaternion_RB = smu.unitQuat.att.separation(reference_frame_attitude_quaternion_RI, ...
                                                        body_frame_attitude_quaternion_BI);

end