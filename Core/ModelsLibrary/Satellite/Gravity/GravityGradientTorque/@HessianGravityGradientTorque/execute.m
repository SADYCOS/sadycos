function gravity_gradient_torque_BI_B__Nm...
                = execute(attitude_quaternion_BI,...
                            gravity_hessian_I__1_per_s2, ...
                            inertia_B__kg_m2)
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
%   gravity_hessian_I__1_per_s2: 3x3 hessian of the gravity potential 
%       at body position in inertial frame
%   inertia_B__kg_m2: 3x3 inertia matrix of the spacecraft in body frame
%
%   Outputs:
%   gravity_gradient_torque_BI_B__Nm: 3x1 vector of gravity gradient torque
%       in body frame
%

arguments
    attitude_quaternion_BI (4,1) {mustBeNumeric, mustBeReal, smu.argumentValidation.mustBeUnitQuaternion}
    gravity_hessian_I__1_per_s2 (3,3) {mustBeNumeric, mustBeReal} 
    inertia_B__kg_m2 (3,3) {mustBeNumeric, mustBeReal}
end

%% References
% adapted from
% [1] R. G. Gottlieb, “Fast Gravity, Gravity Partials, Normalized Gravity, 
% Gravity Gradient Torque and Magnetic Field: Derivation, Code and Data,” 
% 1993, pp. 21–23.

I = inertia_B__kg_m2;

dcm_BI = smu.unitQuat.att.toDcm(attitude_quaternion_BI);

gravitational_hessian_B__1_per_s2 = dcm_BI*gravity_hessian_I__1_per_s2*dcm_BI';
g = gravitational_hessian_B__1_per_s2;

gravity_gradient_torque_BI_B__Nm ...
    = [g(2,3)*(I(3,3)-I(2,2))+g(1,3)*I(1,2)-g(1,2)*I(1,3)+I(2,3)*(g(3,3)-g(2,2));...
       g(1,3)*(I(1,1)-I(3,3))-g(2,3)*I(1,2)+g(1,2)*I(2,3)+I(1,3)*(g(1,1)-g(3,3));...
       g(1,2)*(I(2,2)-I(1,1))+g(2,3)*I(1,3)-g(1,3)*I(2,3)+I(1,2)*(g(2,2)-g(1,1))];

end