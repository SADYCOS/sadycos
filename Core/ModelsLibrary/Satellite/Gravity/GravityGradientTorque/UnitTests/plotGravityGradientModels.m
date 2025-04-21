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

inertia_B__kg_m2 = diag([0.6,0.15,0.1]);
% inertia_B__kg_m2 = 1e-4*[51705.21, -33.00027871, 283.850084; ...
%                         -33.00027871, 51327.91, -29.03914903;  ...
%                         283.850084, -29.03914903, 9411.55];

%% Initialise Models
% Gravity Field Models
gravitationalField_max_Degree = 12;
ParamsSHG ...
    = SphericalHarmonicsGeopotential(gravitationalField_max_Degree);

% Gravity Gradient Models
ParamsSphericalGG ...
    = SphericalGravityGradientTorque(inertia_B__kg_m2,...
                                gravitational_parameter_Earth__m3_per_s2);
ParamsHessianGG ...
    = HessianGravityGradientTorque(inertia_B__kg_m2);

%% Loop
% Gravity acceleration at position
[~,gravitational_hessian_I__1_per_s2]...
    = SphericalHarmonicsGeopotential.execute(position_BI_I__m, ...
                                        [1,0,0,0]', ...
                                        ParamsSHG.Parameters,...
                                        true);
z_angles = -180:10:170;
y_angles = -0:10:90;
n=1;
for i=1:numel(z_angles)
    for j=1:numel(y_angles)
        
        % Vary Z-direction of the satellite
        attitude_quaternion_BI ...
            = smu.unitQuat.att.fromDcm(smu.dcm.z(-z_angles(i)*pi/180)...
                                       *smu.dcm.y(y_angles(j)*pi/180)...
                                       *smu.dcm.z(z_angles(i)*pi/180));

        % General model that uses gravity from SHG
        hessiangravity_gradient_torque_BI_B__Nm = HessianGravityGradientTorque.execute(position_BI_I__m,...
                                                            attitude_quaternion_BI,...
                                                            gravitational_hessian_I__1_per_s2, ...
                                                            ParamsHessianGG.Parameters);

        % Spherical model based on point mass assumption of central body
        sphericalgravity_gradient_torque_BI_B__Nm = SphericalGravityGradientTorque.execute(position_BI_I__m,...
                                                            attitude_quaternion_BI,...
                                                            ParamsSphericalGG.Parameters);

        log_angles(n,:) = [z_angles(i),y_angles(j)];
        log_att_quat(n,:) = attitude_quaternion_BI;
        log_z_dir(n,:) = smu.unitQuat.rot.rotateVector(attitude_quaternion_BI,[0;0;1]);
        log_hessiangravity_gradient_torque_BI_B__Nm(n,:) = hessiangravity_gradient_torque_BI_B__Nm;
        log_sphericalgravity_gradient_torque_BI_B__Nm(n,:) = sphericalgravity_gradient_torque_BI_B__Nm;
        log_hessianartificial_force(n,:) = smu.unitQuat.rot.rotateVector(attitude_quaternion_BI,cross(hessiangravity_gradient_torque_BI_B__Nm,[0;0;1]));        
        log_sphericalartificial_force(n,:) = smu.unitQuat.rot.rotateVector(attitude_quaternion_BI,cross(sphericalgravity_gradient_torque_BI_B__Nm,[0;0;1]));
        n=n+1;
    end
end

%% Plot
% Points
p = plot3(log_z_dir(:,1),log_z_dir(:,2),log_z_dir(:,3),'.');
xlabel("x")
ylabel("y")
zlabel("z")
axlim = 1;
axis([-axlim,axlim,-axlim,axlim,-0.8,1.5])
grid on
hold on
axis vis3d 

% Inertia
factor = 1E-1;
[X,Y,Z] = ellipsoid(0,0,0,inertia_B__kg_m2(1,1)^-(1/2), ...
                    inertia_B__kg_m2(2,2)^-(1/2), ...
                    inertia_B__kg_m2(3,3)^-(1/2));
surf(factor*X,factor*Y,factor*Z);

hold on
qh = quiver3(log_z_dir(:,1),log_z_dir(:,2),log_z_dir(:,3), ...
    log_hessianartificial_force(:,1),...
    log_hessianartificial_force(:,2),...
    log_hessianartificial_force(:,3),1,'k');
qs = quiver3(log_z_dir(:,1),log_z_dir(:,2),log_z_dir(:,3), ...
    log_sphericalartificial_force(:,1),...
    log_sphericalartificial_force(:,2),...
    log_sphericalartificial_force(:,3),1,'r--');


earthdir_B = -initial_position_BI_I__m/norm(initial_position_BI_I__m);
earthdirArrowScale = 0.6;

quiver3(0,0,0,...
        earthdirArrowScale*earthdir_B(1),...
        earthdirArrowScale*earthdir_B(2),...
        earthdirArrowScale*earthdir_B(3))
text(earthdirArrowScale*earthdir_B(1), ...
     earthdirArrowScale*earthdir_B(2),...
     earthdirArrowScale*earthdir_B(3),"g_B");


% Body quiver 
body_quiv = quiver3(zeros(3,1),zeros(3,1),zeros(3,1),[1;0;0],[0;1;0],[0;0;1]);

% Coordinate labels
text(1.1,0,0,"x_{B}");
text(0,1.1,0,"y_{B}");
text(0,0,1.1,"z_{B}");

title("Points show direction of z-axis after direct rotation. " + ...
      "Arrows indicate change of z-axis direction that results from GG torque.",Interpreter="latex")

legend([qh,qs],'Hessian Model', 'Spherical Model')

%% Magnitude
figure
magn_hessiangg_Nm = vecnorm(log_hessiangravity_gradient_torque_BI_B__Nm,2,2);
magn_sphericalgg_Nm = vecnorm(log_sphericalgravity_gradient_torque_BI_B__Nm,2,2);

plot(magn_hessiangg_Nm,'.-')
hold on
plot(magn_sphericalgg_Nm,'--')

title('Magnitude of gravity gradient torque error between the two models')
xlabel('angle tuple')
ylabel('L (Nm)')
legend('Torque')
legend('Hessian Model', 'Spherical Model')

%% Error
figure
plot(magn_hessiangg_Nm-magn_sphericalgg_Nm)
title('Magnitude of gravity gradient torque error between the two models')
xlabel('angle tuple')
ylabel('L (Nm)')
legend('Torque')
legend('L_{Hess}-L{Spher}')