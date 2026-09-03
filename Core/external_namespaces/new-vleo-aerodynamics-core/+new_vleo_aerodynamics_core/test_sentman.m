%% Clean Up Workspace
clc;
clear;

disp("Starting aerodynamic and shading tests...");

%% Initialize Aerodynamic Models
% Initialize the Sentman aerodynamic model (ID: 1)
sentman_model = Sentman(1);
disp("Created Sentman model.");

% Initialize atmospheric conditions
% Parameters: density, temperature, molecular mass, accommodation coefficient
T_inf = 934.0; 
atomic_oxygen_mass = 16 * 1.6605390689252e-27;
accommodation_coeff = 0.9;
aero_conditions = AeroConditions(1.2482e-11, T_inf, atomic_oxygen_mass, accommodation_coeff);
disp("Created aerodynamic conditions.");

% Run a single test calculation for the Sentman model
% Arguments: panel_idx, normal_vec, center_vec, velocity_vec, temp, conditions
sentman_model.calc_aero_force_torque(1, [0; 0; 1], [0; 0; 0], [7800; 0; 0], 288, aero_conditions);

%% Load Satellite Geometry
current_folder = fileparts(mfilename('fullpath'));
mesh_file_path = fullfile(current_folder, 'International Space Station.obj');

iss_satellite = RotatableMeshSatellite(mesh_file_path);

% Rotate a specific surface/panel of the satellite 90 degrees around the Y-axis
% rotation_angle_rad = pi / 2;
% rotation_center = [0, 0, 0];
% rotation_axis = [0, 1, 0];
% iss_satellite.turn_surface_around_axis(1, rotation_angle_rad, rotation_center, rotation_axis);

satellite_vertices = iss_satellite.get_vertices();
fprintf("loaded satellite geometry with %d triangles",iss_satellite.get_num_triangles())
%% Benchmark Shading Pipeline
% Initialize shading pipeline with a resolution/grid size of 800
shading_pipeline = ShadingPipeline(iss_satellite,1, 800);
num_iterations = 100;
relative_velocity_m_s = [7800.0; 0.0; 0.0];

disp("Benchmarking shading pipeline...");
tic;
for i = 1:num_iterations
    panel_visibility = shading_pipeline.shade(relative_velocity_m_s);
end
total_shading_time = toc;

avg_shading_time = total_shading_time / num_iterations;
fprintf('Average shading call duration: %.6f seconds.\n', avg_shading_time);

%% Benchmark Hybrid Aerodynamic Load Calculator
load_calculator = HybridAeroLoadCalculator(iss_satellite, shading_pipeline, sentman_model);
surface_temp_k = 300.0;

disp("Benchmarking aerodynamic load calculations...");
tic;
for i = 1:num_iterations
    [total_force_N, total_torque_Nm] = load_calculator.calc_aero_load(relative_velocity_m_s, surface_temp_k, aero_conditions);
end
total_load_calc_time = toc;

avg_load_calc_time = total_load_calc_time / num_iterations;
fprintf('Average load calculation call duration: %.6f seconds.\n', avg_load_calc_time);

disp("All tests completed successfully.");

%% visualize last shading result
show_mesh(iss_satellite, panel_visibility, relative_velocity_m_s);