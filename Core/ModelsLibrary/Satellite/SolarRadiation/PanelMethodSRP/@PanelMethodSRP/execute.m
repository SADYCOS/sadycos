function [srp_force_B__N, srp_torque_B__Nm] ...
            = execute(position_BI_I__m,...
                        attitude_quaternion_BI, ...
                        time_current_mjd, ...
                        total_solar_irradiance_at_1AU_W_per_m2, ...
                        bodies_rotation_angles__rad, ...
                        ParametersPanelMethodSRP)
% execute - Calculate the aerodynamic force and torque in the body frame
%
% [aerodynamic_force_B__N, aerodynamic_torque_B__Nm] ...
%             = execute(position_BI_I__m, ...  
%                         sun_position_SI_I__m, ...
%                         attitude_quaternion_BI, ...
%                         pressure__N_per_m2, ...
%                         bodies_rotation_angles__rad, ...
%                         ParametersSimplifiedVleoAerodynamics)
%
%   Inputs:
%   position_BI_I__m: 3x1 inertial position of the body
%   attitude_quaternion_BI: 4x1 quaternion of body frame attitude
%   time_current_mjd: current time in modified julian date
%   bodies_rotation_angles__rad: 1xN matrix of rotation angles of bodies in body frame
%   ParametersSimplifiedVleoAerodynamics: Parameters of the SimplifiedVleoAerodynamics model
%
%   Outputs:
%   aerodynamic_force_B__N: 3x1 vector of aerodynamic force in body frame
%   aerodynamic_torque_B__Nm: 3x1 vector of aerodynamic torque in body frame
%

%% Constants
AU__m = 149597870700; %m
c_light__m_per_s = 299792458; %m/s

% Determine sun position
[sun_position_SI_I__m,~] = SimpleSolarLunarPosRelEarth.execute(time_current_mjd);

sun_sat_SB_I = position_BI_I__m-sun_position_SI_I__m;
incoming_direction_I_I = sun_sat_SB_I/norm(sun_sat_SB_I);

% Scale solar irradiance
irradiance_at_sat_W_per_m2 = total_solar_irradiance_at_1AU_W_per_m2*(AU__m^2)/(norm(sun_sat_SB_I)^2);

% Calculate solar radiation pressure
solar_radiation_pressure__N_per_m2 = irradiance_at_sat_W_per_m2/c_light__m_per_s;

%% Call panel based pressure respon from external namespace
% Prepare inputs to model
Param = ParametersPanelMethodSRP;
bodies = Param.bodies;

% Call model
[srp_force_B__N, srp_torque_B__Nm] ...
    = panel_based_pressure_response.panelMethod(attitude_quaternion_BI, ...
                                                incoming_direction_I_I, ...
                                                solar_radiation_pressure__N_per_m2, ...
                                                bodies, ...                                                       
                                                bodies_rotation_angles__rad);

end