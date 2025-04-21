clc
clear
close all

% Constants
gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2 
average_radius_Earth__m = 6.378e6;                       % m

% Position and Inertia
altitude_BI_I__m = 300e3;
position_BI_I__m ...
    = [0;0;(average_radius_Earth__m+altitude_BI_I__m)]; % m

% Initialize
ParametersSG = SphericalGravityAcceleration(gravitational_parameter_Earth__m3_per_s2);

% Execute
gravitational_acceleration_I__m_per_s2 ...
    = SphericalGravityAcceleration.execute(position_BI_I__m, ...
                                            ParametersSG.Parameters)