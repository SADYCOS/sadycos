%% Some interesting use cases VLEO torque computation
div = "=========================================";
disp(div);
disp("Starting aerodynamic and shading tests...");
disp(div);

%% Aerodynamic Model
aero.model = Sentman(1);
disp(div);
disp("Created Sentman model.");
disp(div)

T_env   = 934;  % temperature
rho     = 1e-9; % density
ao_mass = 16 * 1.6605390689252e-27;
alpha_e = 0.95;

aero.conditions = AeroConditions(rho, T_env, ao_mass, alpha_e);

%% Load Satellite Geometry
fp.current_folder = fileparts(mfilename('fullpath'));
fp.obj_file       = fullfile(fp.current_folder, ...
    "geometries/soar_satellite.obj");

satellite.geometry = RotatableMeshSatellite(fp.obj_file);
satellite.verts    = satellite.geometry.get_vertices;

% Rotate the upper panel
p1.angle  = deg2rad(45);
p1.center = [-0.15; 0.00; 0.05];
p1.axis   = [0; 0; -1];
satellite.geometry.turn_surface_around_axis( ...
    0, p1.angle, p1.center, p1.axis);

%% Setup Shading Pipeline
shader = ShadingPipeline(satellite.geometry, 1, 1000);

%% Wind Direction
% Angle of attack (rotation in the body x-z plane) and sideslip angle
% (rotation in the body x-y plane), applied to the nominal +x flow.
v_orbital__m_per_s = 7800;
alpha = deg2rad(20);
beta  = deg2rad(40);

rot_mat = wind_relative_dcm(alpha, beta);
v_rel   = rot_mat * [v_orbital__m_per_s; 0; 0];

%% Compute Panel Visibility
panel_visibility = shader.shade(v_rel);

%% Visualize Panel Visibility Result
show_mesh(satellite.geometry, panel_visibility, v_rel);

%% Torque Sweep Over Full Sphere (Unrotated Panel)
% Demonstrates why a fast per-direction shading pipeline matters: the
% aerodynamic torque is evaluated for hundreds of wind directions,
% covering the full sphere. The satellite's left-right symmetry means
% alpha in [0, 90] deg combined with beta in [0, 180] deg is sufficient
% to cover every distinct relative-wind direction.
flat.geometry         = RotatableMeshSatellite(fp.obj_file);
flat.shader           = ShadingPipeline(flat.geometry, 1, 1000);
flat.load_calculator  = HybridAeroLoadCalculator(flat.geometry, flat.shader, aero.model);

surface_temp__K = 300;

sweep.alpha_deg = 0:5:90;
sweep.beta_deg  = 0:5:180;
[sweep.ALPHA_deg, sweep.BETA_deg] = meshgrid(sweep.alpha_deg, sweep.beta_deg);

sweep.torque_x__Nm = zeros(size(sweep.ALPHA_deg));
sweep.torque_y__Nm = zeros(size(sweep.ALPHA_deg));
sweep.torque_z__Nm = zeros(size(sweep.ALPHA_deg));

disp(div);
fprintf("Sweeping %d wind directions over the unrotated panel...\n", ...
    numel(sweep.ALPHA_deg));

tic;
for i = 1:size(sweep.ALPHA_deg, 1)
    for j = 1:size(sweep.ALPHA_deg, 2)
        sweep_rot_mat = wind_relative_dcm( ...
            deg2rad(sweep.ALPHA_deg(i, j)), deg2rad(sweep.BETA_deg(i, j)));
        sweep_v_rel = sweep_rot_mat * [v_orbital__m_per_s; 0; 0];

        [~, torque__Nm] = flat.load_calculator.calc_aero_load( ...
            sweep_v_rel, surface_temp__K, aero.conditions);

        sweep.torque_x__Nm(i, j) = torque__Nm(1);
        sweep.torque_y__Nm(i, j) = torque__Nm(2);
        sweep.torque_z__Nm(i, j) = torque__Nm(3);
    end
end
sweep.total_time__s = toc;
sweep.avg_time_per_call__s = sweep.total_time__s / numel(sweep.ALPHA_deg);

fprintf("Swept %d directions in %.3f s (%.2f ms/direction).\n", ...
    numel(sweep.ALPHA_deg), sweep.total_time__s, ...
    1e3 * sweep.avg_time_per_call__s);
disp(div);

%% Visualize Torque Map
figure;

subplot(1, 3, 1);
surf(sweep.ALPHA_deg, sweep.BETA_deg, sweep.torque_x__Nm);
xlabel('\alpha [deg]'); ylabel('\beta [deg]'); zlabel('T_x [Nm]');
title('Torque X'); shading interp;

subplot(1, 3, 2);
surf(sweep.ALPHA_deg, sweep.BETA_deg, sweep.torque_y__Nm);
xlabel('\alpha [deg]'); ylabel('\beta [deg]'); zlabel('T_y [Nm]');
title('Torque Y'); shading interp;

subplot(1, 3, 3);
surf(sweep.ALPHA_deg, sweep.BETA_deg, sweep.torque_z__Nm);
xlabel('\alpha [deg]'); ylabel('\beta [deg]'); zlabel('T_z [Nm]');
title('Torque Z'); shading interp;

sgtitle('Aerodynamic Torque vs. Wind Direction (Unrotated Panel)');

%% Local Functions
function rot_mat = wind_relative_dcm(alpha, beta)
    % WIND_RELATIVE_DCM DCM mapping the nominal +x flow to a wind
    % direction given an angle of attack (rotation about the y-axis)
    % followed by a sideslip rotation (about the z-axis).
    dcm.pitch = [cos(alpha), 0, -sin(alpha);
                 0,          1,  0;
                 sin(alpha), 0,  cos(alpha)];

    dcm.yaw   = [cos(beta), -sin(beta), 0;
                 sin(beta),  cos(beta), 0;
                 0,          0,         1];

    rot_mat = dcm.yaw * dcm.pitch;
end
