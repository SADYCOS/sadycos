function gravitational_force_I__N = execute(gravitational_acceleration_I__m_per_s2, ParametersPointMassGravity)
% execute - Calculate the gravitational force in the inertial frame
%
%   gravitational_force_I__N = execute(gravitational_acceleration_I__m_per_s2, ParametersPointMassGravity)
%
%   Inputs:
%   gravitational_acceleration_I__m_per_s2: Gravitational acceleration in the inertial frame
%   ParametersPointMassGravity: Parameters of the PointMassGravity model
%
%   Outputs:
%   gravitational_force_I__N: Gravitational force in the inertial frame
%

gravitational_force_I__N = ParametersPointMassGravity.mass__kg * gravitational_acceleration_I__m_per_s2;

end