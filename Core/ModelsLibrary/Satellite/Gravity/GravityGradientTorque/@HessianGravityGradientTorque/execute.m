function gravity_gradient_torque_BI_B__Nm = execute(position_BI_I__m,...
                                                attitude_quaternion_BI,...
                                                gravitational_acceleration_I__m_per_s2, ...
                                                gravitational_hessian_I__1_per_s2, ...
                                                paramsGravityGradient)
%% Gravity Gradient General - Calculate gravity gradient torque in body
%  frame using gravitational acceleration from another source
%
%   gravity_gradient_torque_BI_B__Nm ...
%       = execute(position_BI_I__m,...
%                   attitude_quaternion_BI,...
%                   gravitational_acceleration_I__m_per_s2, ...
%                   paramsGravityGradient)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_BI: 4x1 quaternion of attitude from inertial to
%       body frame
%   gravity_gradient_I__1_per_s2: 3x1 gravity gradient in inertial frame
%   paramsGravityGradient: Structure containing parameters for general
%       gravity gradient model
%
%   Outputs:
%   gravity_gradient_torque_BI_B__Nm: 3x1 vector of gravity gradient torque
%       in body frame
%
%% References
% adapted from
% [1] F. L. Markley and J. L. Crassidis, Fundamentals of Spacecraft 
% Attitude Determination and Control. New York, NY: Springer New York, 2014. 
% doi: 10.1007/978-1-4939-0802-8.

% Constants
inertia_B = paramsGravityGradient.inertia_B__kg_m2;

%
position_BI_B__m ...
    = smu.unitQuat.att.transformVector(attitude_quaternion_BI,position_BI_I__m);
r = position_BI_B__m;
r_tilde = smu.cpm(position_BI_B__m);
r_norm = norm(position_BI_B__m);

dcm_BI = smu.unitQuat.att.toDcm(attitude_quaternion_BI);

gravitational_hessian_B__1_per_s2 = dcm_BI*gravitational_hessian_I__1_per_s2*dcm_BI';

% Nadir unit vector
nadir_B = -position_BI_B__m/r_norm;

% Gravity gradient torque in body frame for spherical Earth
% gravity_gradient_torque_BI_B__Nm ...
%         = -1/r_norm^2*(2*eye(3)*(r'*gravitational_acceleration_I__m_per_s2))*cross(nadir_B,inertia_B*nadir_B);
% gravity_gradient_torque_BI_B__Nm ...
%         = -1/r_norm^2*(2*eye(3)*(r'*gravitational_acceleration_I__m_per_s2)...
%                         +r_norm^2*gravitational_hessian_B__1_per_s2)*cross(nadir_B,inertia_B*nadir_B);
% gravity_gradient_torque_BI_B__Nm ...
%         = -(gravitational_hessian_B__1_per_s2)*cross(nadir_B,inertia_B*nadir_B);

g = gravitational_hessian_B__1_per_s2;
I = inertia_B;

gravity_gradient_torque_BI_B__Nm ...
    = [g(2,3)*(I(3,3)-I(2,2))+g(1,3)*I(1,2)-g(1,2)*I(1,3)+I(2,3)*(g(3,3)-g(2,2));...
       g(1,3)*(I(1,1)-I(3,3))-g(2,3)*I(1,2)+g(1,2)*I(2,3)+I(1,3)*(g(1,1)-g(3,3));...
       g(1,2)*(I(2,2)-I(1,1))+g(2,3)*I(1,3)-g(1,3)*I(2,3)+I(1,2)*(g(2,2)-g(1,1))];

end