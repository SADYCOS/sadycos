function [atmosphere_mass_density__kg_per_m3, ...
            atmosphere_number_density__1_per_m3, ...
            atmosphere_temperature__K] ...
            = execute(position_BI_I__m, ...
                            attitude_quaternion_EI, ...
                            current_modified_julian_date, ...
                            ParametersNrlmsise00)
% execute - Execute NRLMSISE00 model
%
%   [atmosphere_mass_density__kg_per_m3, ...
%       atmosphere_number_density__1_per_m3, ...
%       atmosphere_temperature__K] ...
%       = execute(position_BI_I__m, ...
%                   attitude_quaternion_EI, ...
%                   current_modified_julian_date, ...
%                   ParametersNrlmsise00)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_EI: 4x1 quaternion of attitude from inertial to
%       Earth frame
%   current_modified_julian_date: Current modified julian date
%   ParametersNrlmsise00: Structure containing NRLMSISE00 parameters
%
%   Outputs:
%   atmosphere_mass_density__kg_per_m3: Mass density of atmosphere in kg/m^3
%   atmosphere_number_density__1_per_m3: Number density of atmosphere in 1/m^3
%   atmosphere_temperature__K: Temperature of atmosphere in K
%

%% Abbreviations
q_EI = attitude_quaternion_EI;
p_I = position_BI_I__m;

%% Convert time and date
[year, month, fractional_day] = smu.time.calDatFromModifiedJulianDate(current_modified_julian_date);
[day_of_year, fractional_second_of_day] = smu.time.doySodFromCalDat(year, month, fractional_day);

% Populate date and time inputs for c function wrapper
y = int32(year);
doy = int32(day_of_year);
s = int32(fractional_second_of_day);

%% Extraxt and process position data
p_E = smu.unitQuat.att.transformVector(q_EI, p_I);

% Populate position input variables for c function wrapper
[g_lat__rad, g_lon__rad, alt__m] = smu.frames.geodeticFromEcef(p_E(1), p_E(2), p_E(3), ParametersNrlmsise00.position_precision__m);
g_lat = double(g_lat__rad * 180/pi);
g_lon = double(g_lon__rad * 180/pi);
alt = double(alt__m/1000);

%% Extract relevant atmospheric parameters for current modified julian date
% find current index (whether provided mdj is in range of data is not
% explicitly checked)
theInd = 1;
n = length(ParametersNrlmsise00.Nrlmsise00Data);
for i = 1:n
    if i == n
        theInd = i;
        break;
    elseif ParametersNrlmsise00.Nrlmsise00Data(i).mjd > current_modified_julian_date
        theInd = i - 1;
        break;
    end
end

% Populate atmospheric parameter input variables for c function wrapper
f107A = double(ParametersNrlmsise00.Nrlmsise00Data(theInd).f107average);
f107 = double(ParametersNrlmsise00.Nrlmsise00Data(theInd).f107daily);
a = double(ParametersNrlmsise00.Nrlmsise00Data(theInd).magneticindex');

%% Populate switches array
switches = int32(ParametersNrlmsise00.switches);

%% Prepare output arrays for c function wrapper
d = double(zeros(9,1));
t = double(zeros(2,1));

%% Call c function wrapper
coder.ceval('nrlmsise00Wrapper', y, doy, s, alt, g_lat, g_lon, f107A, f107, coder.ref(a), coder.ref(switches), coder.wref(d), coder.wref(t));

%% Populate output arguments
atmosphere_mass_density__kg_per_m3 = d(6);
atmosphere_number_density__1_per_m3 = sum(d([1:5, 7:9]));
atmosphere_temperature__K = t(2);
end