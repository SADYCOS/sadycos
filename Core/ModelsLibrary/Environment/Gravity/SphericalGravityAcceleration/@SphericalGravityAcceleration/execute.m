function [gravitational_acceleration_I__m_per_s2] ...
            = execute(position_BI_I__m, ParametersPointMassGravity)
% execute - Calculate the gravitational acceleration in the inertial frame
%
%   gravitational_force_I__N = execute(gravitational_acceleration_I__m_per_s2, ParametersPointMassGravity)
%
%   Inputs:
%   position_BI_I__m: Position of the body in inertial frame of the central body
%   ParametersPointMassGravity: Parameters of the PointMassGravity model
%
%   Outputs:
%   gravitational_acceleration_I__m_per_s2: Gravitational acceleration in the inertial frame
%

position_norm_BI = norm(position_BI_I__m);

gravitational_acceleration_I__m_per_s2 ...
    = -ParametersPointMassGravity.muBody__m3_per_s2 * position_BI_I__m / position_norm_BI^3;

end