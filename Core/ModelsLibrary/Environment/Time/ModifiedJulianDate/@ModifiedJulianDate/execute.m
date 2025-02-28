function current_time__mjd = execute(simulation_time__s, ParametersModifiedJulianDate)
% execute - Calculate the current time in Modified Julian Date
%
%   current_time__mjd = execute(simulation_time__s, ParametersModifiedJulianDate)
%
%   Inputs:
%   simulation_time__s: Current simulation time in seconds
%   ParametersModifiedJulianDate: Parameters of the ModifiedJulianDate model
%
%   Outputs:
%   current_time__mjd: Current time in Modified Julian Date
%

current_time__mjd = ParametersModifiedJulianDate.simulation_start_time__mjd + simulation_time__s/86400;

end