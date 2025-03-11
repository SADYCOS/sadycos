function gravity_gradient_torque_BI_B__Nm = execute(position_BI_I__m,...
                                                    attitude_quaternion_BI,...
                                                    paramsGravityGradient)
%% Gravity Gradient Point Mass - Calculate gravity gradient torque in body
%  frame for a point mass gravity
%
%   gravity_gradient_torque_BI_B__Nm ...
%       = execute(position_BI_I__m,...
%                   attitude_quaternion_BI,...
%                   paramsGravityGradient)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_BI: 4x1 quaternion of attitude from inertial to
%       body frame
%   paramsGravityGradient: Structure containing parameters for general
%       gravity gradient model
%
%   Outputs:
%   gravity_gradient_torque_BI_B__Nm: 3x1 vector of gravity gradient torque
%       in body frame
%
%% References
% [1] F. L. Markley and J. L. Crassidis, Fundamentals of Spacecraft 
% Attitude Determination and Control. New York, NY: Springer New York, 2014. 
% doi: 10.1007/978-1-4939-0802-8.

% constants
mu = paramsGravityGradient.gravitational_parameter_Earth__m3_per_s2;
inertia_B = paramsGravityGradient.inertia_B__kg_m2;


position_BI_B__m = smu.unitQuat.att.transformVector(attitude_quaternion_BI,    ...
                                              position_BI_I__m);

% Nadir unit vector
nadir_B = -position_BI_B__m/norm(position_BI_B__m);

% Gravity gradient torque in body frame for spherical Earth
gravity_gradient_torque_BI_B__Nm = 3 * mu/ norm(position_BI_B__m)^3 ...
                        * cross(nadir_B, inertia_B * nadir_B);

end