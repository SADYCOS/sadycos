%% Plotting script for exploring the gravity gradient models
% this script can be used to check the implementation of the hessian of the
% gravity potential of the spherical harmonics geopotential model against the
% hessian of a spherical geopotential (radially symmetric) from 

% [1] F. L. Markley and J. L. Crassidis, Fundamentals of Spacecraft 
% Attitude Determination and Control. New York, NY: Springer New York, 2014. 
% doi: 10.1007/978-1-4939-0802-8, p. 244 eq. (7.57) 


clc
clear
close all

%% Constants
gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2 
average_radius_Earth__m = 6.378e6;                       % m
R = average_radius_Earth__m;
g = gravitational_parameter_Earth__m3_per_s2/R^2;

%% Position and Inertia
initial_altitude_BI_I__m = 400e3;
initial_position_BI_I__m ...
    = [0;0;(average_radius_Earth__m+initial_altitude_BI_I__m)]; % m
attitude_quaternion_EI = smu.unitQuat.att.fromDcm(smu.dcm.z(rand*2*pi));

%% Initialise Models
Parameters = [];

% Gravity Field Models
gravitationalField_max_Degree = 1;
ParamsSHG = SphericalHarmonicsGeopotential(gravitationalField_max_Degree);

%% Loop
position_BI_I__m = initial_position_BI_I__m;
gravitational_acceleration_I__m_per_s2 = zeros(3,1);
gravitational_hessian_I__1_per_s2 = zeros(3,3);

for i=1:10
    if i>1
        position_BI_I__m = smu.rotateAroundOrigin(initial_position_BI_I__m,pi*rand,[rand,rand,0]');
    end

    % Gravity hessian from SHG
    [gravitational_acceleration_I__m_per_s2, ...
     gravitational_hessian_I__1_per_s2]...
        = SphericalHarmonicsGeopotential.execute(position_BI_I__m, ...
                                            attitude_quaternion_EI, ...
                                            ParamsSHG.Parameters,...
                                            true);    

    log_position(i,:) = position_BI_I__m;
    log_hessian_shg(i,:,:) = gravitational_hessian_I__1_per_s2;  

    x = position_BI_I__m(1);
    y = position_BI_I__m(2);
    z = position_BI_I__m(3);
    r = norm(position_BI_I__m);
    log_hessian_spherical(i,:,:) ...
        = gravitational_parameter_Earth__m3_per_s2/r^5 ...
                                           *[3*x^2-r^2,3*x*y,3*x*z;...
                                             3*x*y,3*y^2-r^2,3*z*y;...
                                             3*x*z,3*y*z,3*z^2-r^2];
end

%% Plot
% Components
figure
subplot(2,1,1)
plot(log_hessian_shg(:,1,1))
hold on
plot(log_hessian_shg(:,2,2))
plot(log_hessian_shg(:,3,3))
plot(log_hessian_shg(:,2,1))
plot(log_hessian_shg(:,3,1))
plot(log_hessian_shg(:,3,2))

plot(log_hessian_spherical(:,1,1),'*')
plot(log_hessian_spherical(:,2,2),'*')
plot(log_hessian_spherical(:,3,3),'*')
plot(log_hessian_spherical(:,2,1),'*')
plot(log_hessian_spherical(:,3,1),'*')
plot(log_hessian_spherical(:,3,2),'*')

title('Magnitude of gravity gradient of the two models')
xlabel('index')
ylabel('$H~(1/s^2)$', Interpreter='latex')
legend('H_{shg}','','','','','','','','','H_{spherical}')

% Error
subplot(2,1,2)
magn_err_m_per_s2 = zeros(size(log_hessian_shg,1),1);
for i=1:size(log_hessian_shg,1)
    magn_err_m_per_s2(i) = norm(squeeze(log_hessian_shg(i,:,:)...
                                        -log_hessian_spherical(i,:,:)));
end
plot(magn_err_m_per_s2);
title('Matrixnorm of difference in hessians of the two models')
xlabel('index')
ylabel('$e_H~(1/s^2)$', Interpreter='latex')
legend('||H_{shg}-H_{spher}||')
