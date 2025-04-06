%% Plotting script for exploring the gravity gradient models
clc
clear
close all

%% Constants
gravitational_parameter_Earth__m3_per_s2 = 3.986004e14;  % m^3/s^2 
average_radius_Earth__m = 6.378e6;                       % m


%% Position and Inertia
initial_altitude_BI_I__m = 300e3;
initial_position_BI_I__m ...
    = [0;0;(average_radius_Earth__m+initial_altitude_BI_I__m)]; % m

position_BI_I__m = initial_position_BI_I__m;

inertia_B__kg_m2 = diag([0.4,1,0.1]);

%% Initialise Models
Parameters = [];

% Gravity Field Models
gravitationalField_max_Degree = 3;
ParamsSHG = SphericalHarmonicsGeopotential(gravitationalField_max_Degree);
ParamsASHG = AdjustedSphericalHarmonicsGeopotential(gravitationalField_max_Degree);

%% Loop

for i=1:10

    position_BI_I__m = smu.rotateAroundOrigin(initial_position_BI_I__m,pi*rand,[rand,rand,0]');

    % Gravity acceleration at position
    acc_shg_I__m_per_s2 ...
        = SphericalHarmonicsGeopotential.execute(position_BI_I__m, ...
                                            [1,0,0,0]', ...
                                            ParamsSHG.Parameters);

    ashgOut ...
        = AdjustedSphericalHarmonicsGeopotential.execute(position_BI_I__m, ...
                                            [1,0,0,0]', ...
                                            ParamsASHG.Parameters);
    acc_ashg_I__m_per_s2 = ashgOut.gravitational_acceleration_I__m_per_s2;
    
    [gx,gy,gz] = gravitysphericalharmonic( position_BI_I__m', 'EGM2008', gravitationalField_max_Degree,'Error' );
    acc_matlab_I__m_per_s2 = [gx,gy,gz];
    clearvars gx gy gz

    log_position(i,:) = position_BI_I__m;
    log_acceleration_shg(i,:) = acc_shg_I__m_per_s2;
    log_acceleration_ashg(i,:) = acc_ashg_I__m_per_s2;

    log_acceleration_matlab(i,:) = acc_matlab_I__m_per_s2;

end

%% Plot
%% Magnitudes
figure
magn_shg_m_per_s2 = vecnorm(log_acceleration_shg,2,2);
magn_ashg_m_per_s2 = vecnorm(log_acceleration_ashg,2,2);

magn_2_m_per_s2 = vecnorm(log_acceleration_matlab,2,2);
plot(magn_shg_m_per_s2)
hold on
plot(magn_ashg_m_per_s2,'o')
plot(magn_2_m_per_s2,'--')

title('Magnitude of gravity error between the two models')
xlabel('index')
ylabel('e (m/s^2)')
legend('a_{shg}','a_{ashg}','a_{matlab}')

%% Error
if 0
figure
plot(magn_shg_m_per_s2-magn_2_m_per_s2)
title('Magnitude of gravity error between the two models')
xlabel('index')
ylabel('e (m/s^2)')
legend('a_{spherical}-a_{2}')
end