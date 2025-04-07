%% Plotting script for exploring the gravity gradient models
clc
clear
close all

%% Constants
gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2 
average_radius_Earth__m = 6.378e6;                       % m


%% Position and Inertia
initial_altitude_BI_I__m = 900e6;
initial_position_BI_I__m ...
    = [(average_radius_Earth__m+initial_altitude_BI_I__m);0;0]; % m

%% Initialise Models
Parameters = [];

% Gravity Field Models
gravitationalField_max_Degree = 1;
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

    % log_hessian_ashg(i,:) = hessian_ashg_I__1_per_s2;    
    log_gradient_ashg(i,:) = diag(hessian_ashg_I__1_per_s2);
    log_gradient_spherical(i,:) = gradient_spherical_I__1_per_s2;

end

%% Plot
%% Components
figure
% magn_shg_m_per_s2 = vecnorm(log_gradient_ashg,2,2);
% magn_ashg_m_per_s2 = vecnorm(log_gradient_spherical,2,2);
plot(log_gradient_ashg)
hold on
plot(log_gradient_spherical,'--')

title('Magnitude of gravity gradient of the two models')
xlabel('index')
ylabel('e (m/s^2)')
legend('a_{ashg}','','','a_{spherical}')

%% Error
if 0
figure
plot(magn_shg_m_per_s2-magn_2_m_per_s2)
title('Gravity gradient error of the two models')
xlabel('index')
ylabel('e (m/s^2)')
legend('a_{spherical}-a_{2}')
end