function gravitational_force_I__N = execute(mass__kg, ...
                        gravitational_acceleration_I__m_per_s2)
% execute - Calculate the gravitational force in the inertial frame
%
%   gravitational_force_I__N = execute(mass__kg, gravitational_acceleration_I__m_per_s2)
%
%   Inputs:
%   gravitational_acceleration_I__m_per_s2: Gravitational acceleration in the inertial frame
%   mass__kg: Satellite mass in kg
%
%   Outputs:
%   gravitational_force_I__N: Gravitational force in the inertial frame
%

gravitational_force_I__N = mass__kg * gravitational_acceleration_I__m_per_s2;

end