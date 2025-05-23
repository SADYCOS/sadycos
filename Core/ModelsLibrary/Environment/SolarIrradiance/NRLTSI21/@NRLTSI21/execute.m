function [irradiance_at_sat_I_I__W_per_m2] ...
                    = execute(position_BI_I__m, ...
                               sun_position_SI_I__m, ...
                               current_modified_julian_date, ...
                               ParametersNrltsi21)
% execute - Get Total Solar Irradiance at satellite position using the NRLTSI21 model 
%
% [irradiance_at_sat_I_I__W_per_m2] ...
%                     = execute(current_modified_julian_date, ...
%                                 ParametersNrltsi21)
%
%   Inputs:
%   position_BI_I__m: 3x1 satellite position in inertial coordinates
%   sun_position_SI_I__m: 3x1 vector from the Earth to the Sun in inertial
%                               coordinates
%   current_modified_julian_date: Current modified julian date
%   ParametersNrltsi21: Structure containing NRLTSI21 parameters
%
%   Outputs:
%   irradiance_at_sat_I_I__W_per_m2: 3x1 vector of total solar 
%           irradiance (TSI) at satellite position in inertial coordinates
%   inertial coordinates in W/m^2
%
%% References:
% [1] Odele Coddington, Judith L. Lean, Doug Lindholm, Peter Pilewskie, 
% Martin Snow, and NOAA CDR Program (2017): NOAA Climate Data Record (CDR) 
% of Total Solar Irradiance (TSI), NRLTSI Version 2.1. 
% data: "tsi-ssi-projection_v03r00_annual_s1610_e2100_c20250225.txt". 
% NOAA National Centers for Environmental Information. 
% https://doi.org/10.7289/V56W985W accessed 2025-04-08.

%% Constants
AU__m = 149597870700; % m

%% Abbreviations
mjd = current_modified_julian_date;
dataMjd = [ParametersNrltsi21.Nrltsi21Data.mjd];
dataIrr = [ParametersNrltsi21.Nrltsi21Data.irradianceMean];

%% Interpolation using current mjd
if mjd < min(dataMjd) || mjd > max(dataMjd)
    warning('Target MJD %.5f is outside data range of NRLTSI21 [%.5f, %.5f].' ...
            ,mjd, min(dataMjd), max(dataMjd))
end

irradiance_at_1AU_W_per_m2 ...
    = interp1(dataMjd,dataIrr,current_modified_julian_date, 'linear','extrap');

% Get relative vector and distance
sun_sat_SB_I = position_BI_I__m-sun_position_SI_I__m;
sun_sat_norm_SB = norm(sun_sat_SB_I);
incoming_direction_I_I = sun_sat_SB_I/sun_sat_norm_SB;

% Scale solar irradiance
irradiance_at_sat_W_per_m2 = irradiance_at_1AU_W_per_m2*(AU__m^2)/(sun_sat_norm_SB^2);

% Calculate solar radiation pressure
irradiance_at_sat_I_I__W_per_m2 = irradiance_at_sat_W_per_m2*incoming_direction_I_I;

end