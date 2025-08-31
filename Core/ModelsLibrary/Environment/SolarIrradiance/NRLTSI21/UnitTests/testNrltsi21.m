%% Script to test the function of NRLTSI21
clc
clear
close all

%% Process data
% NRLTSI21.processNrltsiProjectionData("tsi-ssi-projection_v03r00_annual_s1610_e2100_c20250225.txt");

%% Preapare model
mjd0 = mjuliandate(datetime('now'));
parameters = NRLTSI21(mjd0,42536000);

%% Execute
position_BI_I__m = [6.771e6;0;0];
sun_position_SI_I__m = [1.477938877596351e+11;0;0];

total_solar_irradiance_at_1AU_W_per_m2 ...
    = NRLTSI21.execute(position_BI_I__m, ...
                       sun_position_SI_I__m, ...
                       mjd0+100,...
                       parameters.Parameters)