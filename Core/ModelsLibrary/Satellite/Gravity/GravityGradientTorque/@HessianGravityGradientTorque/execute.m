function gravity_gradient_torque_BI_B__Nm...
                = execute(attitude_quaternion_BI,...
                            gravitational_hessian_I__1_per_s2, ...
                            paramsHessianGravityTorque)
%% HessianGravityGradient - Calculate gravity gradient torque in body
%  frame using a given hessian of the gravity potential
%
%   gravity_gradient_torque_BI_B__Nm ...
%       = execute(attitude_quaternion_BI,...
%                  gravitational_hessian_I__1_per_s2, ...
%                  paramsGravityGradient)
%
%   Inputs:
%   attitude_quaternion_BI: 4x1 quaternion of attitude from inertial to
%       body frame
%   gravitational_hessian_I__1_per_s2: 3x3 hessian of the gravity potential 
%       at body position in inertial frame
%   paramsHessianGravityTorque: Structure containing parameters for general
%       gravity gradient model
%
%   Outputs:
%   gravity_gradient_torque_BI_B__Nm: 3x1 vector of gravity gradient torque
%       in body frame
%
%% References
% adapted from
% [1] R. G. Gottlieb, “Fast Gravity, Gravity Partials, Normalized Gravity, 
% Gravity Gradient Torque and Magnetic Field: Derivation, Code and Data,” 
% 1993, pp. 21–23.

inertia_B = paramsHessianGravityTorque.inertia_B__kg_m2;
I = inertia_B;

dcm_BI = smu.unitQuat.att.toDcm(attitude_quaternion_BI);

gravitational_hessian_B__1_per_s2 = dcm_BI*gravitational_hessian_I__1_per_s2*dcm_BI';
g = gravitational_hessian_B__1_per_s2;

gravity_gradient_torque_BI_B__Nm ...
    = [g(2,3)*(I(3,3)-I(2,2))+g(1,3)*I(1,2)-g(1,2)*I(1,3)+I(2,3)*(g(3,3)-g(2,2));...
       g(1,3)*(I(1,1)-I(3,3))-g(2,3)*I(1,2)+g(1,2)*I(2,3)+I(1,3)*(g(1,1)-g(3,3));...
       g(1,2)*(I(2,2)-I(1,1))+g(2,3)*I(1,3)-g(1,3)*I(2,3)+I(1,2)*(g(2,2)-g(1,1))];

end