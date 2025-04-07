%% Plotting script for exploring the gravity gradient models
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
    = [(average_radius_Earth__m+initial_altitude_BI_I__m);0;0]; % m

%% Initialise Models
Parameters = [];

% Gravity Field Models
gravitationalField_max_Degree = 12;
% ParamsSHG = SphericalHarmonicsGeopotential(gravitationalField_max_Degree);
ParamsASHG = AdjustedSphericalHarmonicsGeopotential(gravitationalField_max_Degree);
ParamPointMassGravity = PointMassGravity(gravitational_parameter_Earth__m3_per_s2);

%% Loop
position_BI_I__m = initial_position_BI_I__m;
for i=1:10
    if i>1
        position_BI_I__m = smu.rotateAroundOrigin(initial_position_BI_I__m,pi*rand,[rand,rand,0]');
    end

    % Gravity hessian from SHG
    ashgOut ...
        = AdjustedSphericalHarmonicsGeopotential.execute(position_BI_I__m, ...
                                            [1,0,0,0]', ...
                                            ParamsASHG.Parameters);
    hessian_ashg_I__1_per_s2 = ashgOut.gravitational_hessian_I__1_per_s2;
    
    [~, gradient_spherical_I__1_per_s2] ...
    = PointMassGravity.execute(position_BI_I__m,ParamPointMassGravity.Parameters);

    log_position(i,:) = position_BI_I__m;

    log_hessian_ashg(i,:,:) = hessian_ashg_I__1_per_s2;  

    x = position_BI_I__m(1);
    y = position_BI_I__m(2);
    z = position_BI_I__m(3);
    r = norm(position_BI_I__m);
    log_hessian_spherical(i,:,:) = gravitational_parameter_Earth__m3_per_s2/r^5*[3*x^2-r^2,3*x*y,3*x*z;...
                                             3*x*y,3*y^2-r^2,3*z*y;...
                                             3*x*z,3*y*z,3*z^2-r^2];
end

%% Plot
% Components
figure
plot(log_hessian_ashg(:,1,1))
hold on
plot(log_hessian_ashg(:,2,2))
plot(log_hessian_ashg(:,3,3))
plot(log_hessian_ashg(:,2,1))
plot(log_hessian_ashg(:,3,1))
plot(log_hessian_ashg(:,3,2))

plot(log_hessian_spherical(:,1,1),'--')
plot(log_hessian_spherical(:,2,2),'--')
plot(log_hessian_spherical(:,3,3),'--')
plot(log_hessian_spherical(:,2,1),'--')
plot(log_hessian_spherical(:,3,1),'--')
plot(log_hessian_spherical(:,3,2),'--')

title('Magnitude of gravity gradient of the two models')
xlabel('index')
ylabel('e (m/s^2)')
legend('a_{ashg}','','','','','','a_{spherical}')

% Error
figure
for i=1:size(log_hessian_ashg,1)
    magn_ashg_m_per_s2(i) = norm(squeeze(log_hessian_ashg(i,:,:)));
    magn_spher_m_per_s2(i) = norm(squeeze(log_hessian_spherical(i,:,:)));
end

plot(magn_ashg_m_per_s2-magn_spher_m_per_s2)
title('Difference of matrixnorm of hessians of the two models')
xlabel('index')
ylabel('e (m/s^2)')
legend('||H_{ashg}||-||H_{spher}||')
