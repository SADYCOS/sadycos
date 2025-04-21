clc
clear
close all

% Constants
gravitational_parameter_Sun__m3_per_s2 = 1.32712440018e20;  % m^3/s^2 
% gravitational_parameter_Moon_m3_per_s2 = 4.9048695e12;  % m^3/s^2 
average_radius_Earth__m = 6.378e6;                       % m
astronomical_unit__m = 149597870700;

% Position and Inertia
altitude_BI_I__m = 300e3;
initial_position_BI_I__m ...
    = [(average_radius_Earth__m+altitude_BI_I__m);0;0]; % m
position_additional_body_AI_I_m = [astronomical_unit__m;0;0];

% Initialize
ParametersThirdBodyGravity = ThirdBodyGravity(gravitational_parameter_Sun__m3_per_s2);

% Loop over orbit
numPoints = 20;
for i=1:numPoints
    postion_anomaly_quat = smu.unitQuat.att.fromDcm(smu.dcm.z(i*2/numPoints*pi));
    position_BI_I__m = smu.unitQuat.att.transformVector(postion_anomaly_quat,initial_position_BI_I__m);

    [gravitational_acceleration_add_I__m_per_s2] ...
                = ThirdBodyGravity.execute(position_BI_I__m,...
                          position_additional_body_AI_I_m,...
                          ParametersThirdBodyGravity.Parameters);
    
    log_position_BI_I__m(i,:) = position_BI_I__m;
    log_gravitational_acceleration(i,:) = gravitational_acceleration_add_I__m_per_s2;

end

%% Plotting
close all
figure

% Earth
plot(0,0,'o')
text(1e6,0,"Earth")
hold on

% Sun
au_scaling = 5e3;
plot(astronomical_unit__m/au_scaling,0,'bo')
text(astronomical_unit__m/au_scaling-3e6,0,"Sun")

r = norm(initial_position_BI_I__m);
h = rectangle('Position',[-r -r 2*r 2*r],'Curvature',[1,1]);
text(0,r+1e6,"Orbit")

for i=1:numPoints
    q = quiver(log_position_BI_I__m(i,1),...
            log_position_BI_I__m(i,2),...
            log_gravitational_acceleration(i,1),...
            log_gravitational_acceleration(i,2),...
            0.4*norm(log_position_BI_I__m(i,1:2))/norm(log_gravitational_acceleration(i,1:2)));
end
text(r+3e6,0,"acceleration")
axis equal
grid minor

title("3rd Body Acceleration in Earth-Centered Frame - not to scale")
xlabel('x_{eci} (m)')
ylabel('y_{eci} (m)')