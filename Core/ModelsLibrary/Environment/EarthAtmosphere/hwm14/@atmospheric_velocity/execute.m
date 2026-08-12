function [atmospheric_wind_I_I__m_per_s] ...
            = execute(position_BI_I__m, ...
                            attitude_quaternion_EI, ...
                            current_modified_julian_date, ...
                            ParametersHwm14)
% execute - Execute HWM14 model
%
%   [atmospheric_wind_I_I__m_per_s] ... 
%       = execute(position_BI_I__m, ...
%                   attitude_quaternion_EI, ...
%                   current_modified_julian_date, ...
%                   ParametersHwm14)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_EI: 4x1 quaternion of attitude from inertial to Earth frame
%   current_modified_julian_date: Current modified julian date
%   ParametersHwm14: Structure containing Hwm14 parameters
%
%   Outputs:
%   atmospheric_wind_I_I__m_per_s: Atmospheric wind velocity in inertial frame in meters per second
%
%% References
% [1] Doornbos, E., van den Ijssel, J., Lühr, H., Förster, M., Koppenwallner, G. (2010): 
% Neutral density and crosswind determination from arbitrarily oriented multi-axis 
% accelerometers on satellites.
% Journal of Spacecraft and Rockets, 47, 4, 580-589 
%
% [2] 
%% Abbreviations
q_EI = attitude_quaternion_EI;
p_I = position_BI_I__m;

%% Convert time and date
[year, month, fractional_day] = smu.time.calDatFromModifiedJulianDate(current_modified_julian_date);
[day_of_year, fractional_second_of_day] = smu.time.doySodFromCalDat(year, month, fractional_day);

% Populate date and time inputs for Hwm14 function
doy = double(day_of_year);
UT_s = double(fractional_second_of_day);

%% Extract and process position data
p_E = smu.unitQuat.att.transformVector(q_EI, p_I);

% Populate position input variables for Hwm14 function
[g_lat__rad, g_lon__rad, alt__m] = smu.frames.geodeticFromEcef(p_E(1), p_E(2), p_E(3), ParametersHwm14.position_precision__m);
glat_deg = double(g_lat__rad * 180/pi);
glon_deg = double(g_lon__rad * 180/pi);
alt_km = double(alt__m/1000);

%% Extract relevant atmospheric parameters for current modified julian date
% find current index (whether provided mjd is in range of data is not
% explicitly checked)
theInd = 1;
n = length(ParametersHwm14.Hwm14Data);
for i = 1:n
    if i == n
        theInd = i;
        break;
    elseif ParametersHwm14.Hwm14Data(i).mjd > current_modified_julian_date
        theInd = i - 1;
        break;
    end
end

% Populate magnetic index input variable for Hwm14 function
Ap = double(ParametersHwm14.Hwm14Data(theInd).magneticindex');

%% Load the path to the hwm14ifc_mex function
dataPath = ParametersHwm14.dataPath;

%% Compute the meridional and zonal atmospheric wind velocity in N-E frame (North-East)
coder.extrinsic('hwm14ifc_mex');

w = zeros(2,1);     % Preallocate output vector for meridional and zonal wind velocity

w_tmp = hwm14ifc_mex(doy, UT_s, alt_km, glat_deg, glon_deg, Ap, dataPath); 
w = double(w_tmp);

w_meridional = w(1);    % w_meridional > 0 means northward wind
w_zonal = w(2);         % w_zonal      > 0 means eastward wind

%% Compute atmospheric wind velocity in ECEF frame under the assumption of atmospheric corotation

% Build unit vectors for meridional and zonal wind velocity in ECEF frame
e_hat_E = [-sin(g_lon__rad);
            cos(g_lon__rad);
            0];

n_hat_E = [-sin(g_lat__rad)*cos(g_lon__rad);
           -sin(g_lat__rad)*sin(g_lon__rad);
            cos(g_lat__rad)];

u_hat_E = [ cos(g_lat__rad)*cos(g_lon__rad);
            cos(g_lat__rad)*sin(g_lon__rad);
            sin(g_lat__rad)];

% Transform meridional and zonal wind velocity into ECEF frame 
wind_velocity_E__m_per_s = w_zonal      * e_hat_E ...
                          + w_meridional * n_hat_E ...
                          + 0 * u_hat_E;

% Compute atmospheric corotation in ECEF frame
omega_E__rad_per_s = 7.292115e-5; % value adapted from [1]; Rotation rate of the Earth in radians per second
omega_E_vec_E__rad_per_s = [0; 0; omega_E__rad_per_s];
corotation_velocity_E__m_per_s = cross(omega_E_vec_E__rad_per_s, p_E);

% Total atmospheric wind velocity in ECEF frame
atmospheric_wind_E__m_per_s = wind_velocity_E__m_per_s + corotation_velocity_E__m_per_s;

%% Populate output arguments
% Transform wind velocity from ECEF frame to the inertial frame
atmospheric_wind_I_I__m_per_s = smu.unitQuat.att.transformVector(smu.unitQuat.invert(q_EI), atmospheric_wind_E__m_per_s);
end