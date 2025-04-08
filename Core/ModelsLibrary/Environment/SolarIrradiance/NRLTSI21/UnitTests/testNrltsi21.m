%% Script to test the function of NRLTSI21
clc
clear
close all

%% Process data
% NRLTSI21.processNrltsiProjectionData("tsi-ssi-projection_v03r00_annual_s1610_e2100_c20250225.txt");

%% Preapare model
parameters = NRLTSI21(mjuliandate(datetime('now')),42536000);

%% Execute
NRLTSI21.execute(6.1000e+04,parameters.Parameters.Nrltsi21Data)