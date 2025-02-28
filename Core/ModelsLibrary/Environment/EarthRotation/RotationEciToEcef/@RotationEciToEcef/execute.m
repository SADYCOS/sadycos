function [earth_quaternion_EI] = execute(time_current_mjd)
% calculation of current Earth rotation compared to the earth centred inertial reference frame
% as described in
% [1] F. L. Markley and J. L. Crassidis, 
% Fundamentals of Spacecraft Attitude Determination and Control. 
% New York, NY: Springer New York, 2014. doi: 10.1007/978-1-4939-0802-8.


time_current_jd = time_current_mjd + 2.4000e+06;
time_current = datetime(time_current_mjd,'ConvertFrom','modifiedjuliandate');

% T0, the number of Julian centuries elapsed since J2000
t_0 = (floor(time_current_jd)-2451545)/36525;

% calculate angle
theta_gmst = pi/180*1/240*mod(24110.54841+ 8640184.812866*t_0+0.093104*t_0^2-6.2E-6*t_0^3+...
    1.002737909350795*(3600*time_current.Hour + 60*time_current.Minute+ ...
                        time_current.Second),86400);

% make quaternion from angle
earth_quaternion_EI = smu.unitQuat.rot.fromAxisAngle([0;0;1], theta_gmst);
end

