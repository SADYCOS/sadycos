function parameters_cells = configureParameters()

%% General Parameters

% Simulation Duration
simulation_duration__s = 1000;

% Simulation Mode
simulation_mode = "normal";

% Pacing
enable_pacing = false;
pacing_rate = 1;

% Send Simulation Data
enable_send_sim_data = false;

% Stop Criterion
enable_stop_criterion = false;


% Subsystem-Specific Parameters

% States
% Plant
gravitational_parameter_Earth = 3.986004e14;

InitialPlantStates.RigidBody.position_BI_I__m = [6.771e6;0;0];
InitialPlantStates.RigidBody.velocity_BI_I__m_per_s = [0;sqrt(gravitational_parameter_Earth/6.771e6);0];
InitialPlantStates.RigidBody.attitude_quaternion_BI = [1;zeros(3,1)];
InitialPlantStates.RigidBody.angular_velocity_BI_B__rad_per_s = [0;0;0];
InitialPlantStates.ReactionWheels.angular_velocities__rad_per_s = 100 * ones(3,1);

% Sample Times
% Sensors
sensors_sample_time_parameter__s = [0.1, 0];

% GNC Algorithms
gnc_algorithms_sample_time_parameter__s = [0.1, 0];

% Use helper class to prepare Parameters structure
parameter_creator = ParameterCreator(InitialPlantStates, ...
                                    enable_plant_feedthrough = true, ...
                                    sensors_sample_time_parameter__s = sensors_sample_time_parameter__s, ...
                                    gnc_algorithms_sample_time_parameter__s = gnc_algorithms_sample_time_parameter__s, ...
                                    simulation_duration__s = simulation_duration__s, ...
                                    simulation_mode = simulation_mode, ...
                                    enable_pacing = enable_pacing, ...
                                    pacing_rate = pacing_rate, ...
                                    enable_send_sim_data = enable_send_sim_data, ...
                                    enable_stop_criterion = enable_stop_criterion);


% Delays
% GNC Algorithms
gnc_delay = 1;
InitialActuatorCommands.ReactionWheels.torque_commands__N_m = zeros(3,1);
InitialActuatorCommands.MagneticTorquers.magnetic_dipole_moment_commands__A_m2 = zeros(3,1);

parameter_creator.activateDelay("GncAlgorithms", gnc_delay, InitialActuatorCommands);

%% Model-Specific Parameters

% Environment Models

% Common
mjd0 = smu.time.modifiedJulianDateFromCalDat(2025, 02, 25.5);

% Time
parameter_creator.addModel("Environment", ModifiedJulianDate(mjd0))

% Atmosphere
parameter_creator.addModel("Environment", Nrlmsise00(mjd0, simulation_duration__s, true(24,1), 1e-2));

% Gravitational Field
gravitationalField_max_Degree = 3;
parameter_creator.addModel("Environment", SphericalHarmonicsGeopotential(gravitationalField_max_Degree));

% Magnetic Field
magnetic_field_max_degree = 2;
parameter_creator.addModel("Environment", Igrf(mjd0, simulation_duration__s, magnetic_field_max_degree));

% Plant Models

% Mechanics
mass__kg = 2;
inertia_B_B__kg_m2 = 1*diag([1,1,1]);
parameter_creator.addModel("Plant", RigidBodyMechanics(mass__kg, inertia_B_B__kg_m2));

% Aerodynamics
% Get absolute path of this file's folder
[this_folder,~,~] = fileparts(mfilename("fullpath"));
% Get absolute paths of all obj files
obj_files = string(fullfile(this_folder, 'obj_files', 'body.obj'));
rotation_hinge_points_CAD = zeros(3,1);

rotation_directions_CAD = [1; 0; 0];

surface_temperatures__K = num2cell(300);

surface_energy_accommodation_coefficients = num2cell(0.9);

DCM_B_from_CAD = [0, -1, 0;...
                    -1, 0, 0; ...
                    0, 0, -1];

center_of_mass_CAD = [0; 2; 0];

parameter_creator.addModel("Plant", SimplifiedVleoAerodynamics(obj_files, ...
                                                    rotation_hinge_points_CAD, ...
                                                    rotation_directions_CAD, ...
                                                    surface_temperatures__K, ...
                                                    surface_energy_accommodation_coefficients, ...
                                                    DCM_B_from_CAD, ...
                                                    center_of_mass_CAD, ...
                                                    false, ...
                                                    1));

% Gravity
parameter_creator.addModel("Plant", PointMassGravity(mass__kg));

% Reaction Wheels
reaction_wheels_spin_directions_B = eye(3);
reaction_wheels_inertias__kg_m2 = 1E-4 * ones(3,1);
reaction_wheels_friction_coefficients__N_m_s_per_rad = zeros(3,1);
reaction_wheels_maximum_frequencies__rad_per_s = 500 * ones(3,1);

parameter_creator.addModel("Plant", RateLimitedReactionWheels(reaction_wheels_inertias__kg_m2, ...
                                                                reaction_wheels_spin_directions_B, ...
                                                                reaction_wheels_friction_coefficients__N_m_s_per_rad, ...
                                                                reaction_wheels_maximum_frequencies__rad_per_s));

% Actuator Models
% Magnetic Torquers
magnetic_torquers_directions = eye(3);
magnetic_torquers_max_dipole_moments__A_m2 = 5 * ones(3,1);

parameter_creator.addModel("Actuators", GenericMagneticTorquers(magnetic_torquers_directions, ...
                                                                    magnetic_torquers_max_dipole_moments__A_m2));

% GNC Algorithms Models
qfr_proportional_gain = 1E-3;
qfr_derivative_gain = 1E-1;

parameter_creator.addModel("GncAlgorithms", QuaternionFeedbackControl(qfr_proportional_gain, qfr_derivative_gain));

%% Get Parameters Structure
Parameters = parameter_creator.getParameters();

%% Add Non-Model Parameters
Parameters.GncAlgorithms.reaction_wheels_spin_directions_B = reaction_wheels_spin_directions_B;
Parameters.GncAlgorithms.magnetic_torquers_directions_B = magnetic_torquers_directions;
Parameters.GncAlgorithms.reaction_wheels_desaturation_gain__1_per_s = 1E-2;
Parameters.GncAlgorithms.reaction_wheels_inertias__kg_m2 = reaction_wheels_inertias__kg_m2;

%% Write Structure to Cell for Output
parameters_cells = {Parameters};
end