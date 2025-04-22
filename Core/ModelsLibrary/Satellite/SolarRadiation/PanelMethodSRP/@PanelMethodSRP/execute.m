function [srp_force_B__N, srp_torque_B__Nm] ...
            = execute(attitude_quaternion_BI, ...
                        irradiance_at_sat_I_I__W_per_m2, ...
                        bodies_rotation_angles__rad, ...
                        ParametersPanelMethodSRP)
% execute - Calculate the aerodynamic force and torque in the body frame
%
% [srp_force_B__N, srp_torque_B__Nm] ...
%             = execute(attitude_quaternion_BI, ...
%                        irradiance_at_sat_I_I__W_per_m2, ...
%                        bodies_rotation_angles__rad, ...
%                        ParametersSimplifiedVleoAerodynamics)
%
%   Inputs:
%   attitude_quaternion_BI: 4x1 quaternion of body frame attitude
%   irradiance_at_sat_I_I__W_per_m2: 3x1 vector of total solar 
%           irradiance (TSI) at satellite position in inertial coordinates
%   bodies_rotation_angles__rad: 1xN matrix of rotation angles of bodies in body frame
%   ParametersSimplifiedVleoAerodynamics: Parameters of the SimplifiedVleoAerodynamics model
%
%   Outputs:
%   srp_force_B__N: 3x1 vector of force due to solar radiation pressure in body frame
%   srp_torque_B__Nm: 3x1 vector of torque due to solar radiation pressure in body frame
%
%% Reference
% [1] O. Montenbruck and G. Eberhard, 
% “Geopotential” in Satellite orbits: models, methods, and applications, 
% Berlin : New York: Springer, 2000, pp. 56–68.

%% Constants
c_light__m_per_s = 299792458; %m/s

%% Call panel based pressure response from external namespace
% Prepare inputs to model
Param = ParametersPanelMethodSRP;
bodies = Param.bodies;

solar_radiation_pressure_I_I__N_per_m2 = irradiance_at_sat_I_I__W_per_m2/(c_light__m_per_s);

% Call smu panel method
[srp_force_B__N, srp_torque_B__Nm] ...
    = panel_based_pressure_response.panelMethod(attitude_quaternion_BI, ...
                                                solar_radiation_pressure_I_I__N_per_m2, ...
                                                bodies, ...                                                       
                                                bodies_rotation_angles__rad);

end