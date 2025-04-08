function [total_solar_irradiance_at_1AU_W_per_m2] ...
                    = execute(current_modified_julian_date, ...
                               ParametersNrltsi21)
% execute - Get Total Solar Irradiance at 1AU distance to sun using the NRLTSI21 model 
%
% [total_solar_irradiance_at_1AU_W_per_m2] ...
%                     = execute(position_BI_I__m,...
%                                 current_modified_julian_date, ...
%                                 ParametersNrltsi21)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   current_modified_julian_date: Current modified julian date
%   ParametersNrltsi21: Structure containing NRLTSI21 parameters
%
%   Outputs:
%   total_solar_irradiance_at_1AU_W_per_m2: TSI at 1AU distance to sun in W/m^2
%
%% References:
% [1] Odele Coddington, Judith L. Lean, Doug Lindholm, Peter Pilewskie, 
% Martin Snow, and NOAA CDR Program (2017): NOAA Climate Data Record (CDR) 
% of Total Solar Irradiance (TSI), NRLTSI Version 2.1. 
% data: "tsi-ssi-projection_v03r00_annual_s1610_e2100_c20250225.txt". 
% NOAA National Centers for Environmental Information. 
% https://doi.org/10.7289/V56W985W accessed 2025-04-08.

%% Abbreviations
mjd = current_modified_julian_date;
dataMjd = [ParametersNrltsi21.mjd];
dataIrr = [ParametersNrltsi21.irradianceMean];

%% Interpolation using current mjd
if mjd < min(dataMjd) || mjd > max(dataMjd)
    warning('Target MJD %.5f is outside data range of NRLTSI21 [%.5f, %.5f].' ...
            ,mjd, min(dataMjd), max(dataMjd))
end

total_solar_irradiance_at_1AU_W_per_m2 ...
    = interp1(dataMjd,dataIrr,current_modified_julian_date, 'linear','extrap');

end