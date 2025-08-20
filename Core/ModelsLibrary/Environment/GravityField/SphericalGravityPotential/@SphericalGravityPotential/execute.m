function [gravity_acceleration_I__m_per_s2, ...
          gravity_hessian_I__1_per_s2] ...
            = execute(position_BI_I__m, ParametersSphericalGravity, calcHessian)
% execute - Calculate the gravity acceleration in the inertial frame
%
%   gravitational_force_I__N = execute(gravitational_acceleration_I__m_per_s2, ParametersPointMassGravity)
%
%   Inputs:
%   position_BI_I__m: Position of the body in inertial frame of the central body
%   ParametersPointMassGravity: Parameters of the PointMassGravity model
%
%   Outputs:
%   gravity_acceleration_I__m_per_s2: Gravitational acceleration in the inertial frame
%   gravity_hessian_I__1_per_s2: 3x3 hessian of the gravity potential 
%       at body position in inertial frame
%

arguments
    position_BI_I__m (3,1) {mustBeNumeric, mustBeReal}
    ParametersSphericalGravity 
    calcHessian (1,1) {boolean}
end


%% References
% [1] F. L. Markley and J. L. Crassidis, Fundamentals of Spacecraft 
% Attitude Determination and Control. New York, NY: Springer New York, 2014. 
% doi: 10.1007/978-1-4939-0802-8, p. 244 eq. (7.57) 

%% Initialize outputs 
gravity_acceleration_I__m_per_s2 = nan(3,1);
gravity_hessian_I__1_per_s2 = nan(3,3);

%% Calculations
position_norm_BI = norm(position_BI_I__m);

gravity_acceleration_I__m_per_s2 ...
    = -ParametersSphericalGravity.muBody__m3_per_s2 * position_BI_I__m / position_norm_BI^3;

if calcHessian
    r = position_norm_BI;
    x = position_BI_I__m(1);
    y = position_BI_I__m(2);
    z = position_BI_I__m(3);

    % [1]
    gravity_hessian_I__1_per_s2 ...
            = ParametersSphericalGravity.muBody__m3_per_s2/r^5 ...
                                               *[3*x^2-r^2,3*x*y,3*x*z;...
                                                 3*x*y,3*y^2-r^2,3*z*y;...
                                                 3*x*z,3*y*z,3*z^2-r^2];

end


end