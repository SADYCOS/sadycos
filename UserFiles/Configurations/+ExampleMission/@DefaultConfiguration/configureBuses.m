function BusesInfo = configureBuses(parameters_cells)

%% Use helper class
import BusesInfoCreator.simpleBusElement

%% Create BusesInfoCreator Object
busesInfoCreator = BusesInfoCreator(parameters_cells{1});

%% EnvironmentStates
% none -> bus with dummy element
elems = simpleBusElement('dummy', 1, 'double');

busesInfoCreator.setBusByElements("EnvironmentStates", elems);

%% EnvironmentConditions

% Nested Buses

% Time
elems = simpleBusElement('current_time__mjd', 1, 'double');

busesInfoCreator.setBusByElements('Time', elems);

% Earth Atmosphere
elems = [simpleBusElement('mass_density__kg_per_m3', 1), ...
            simpleBusElement('number_density__1_per_m3', 1), ...
            simpleBusElement('temperature__K', 1)];

busesInfoCreator.setBusByElements('EarthAtmosphere', elems);

% Earth Gravitational Field
elems = [simpleBusElement('gravitational_acceleration_I__m_per_s2', 3), ...
            simpleBusElement('gravitational_hessian_I__1_per_s2', [3,3])];

busesInfoCreator.setBusByElements('EarthGravitationalField', elems);

% Earth Magnetic Field
elems = simpleBusElement('magnetic_field_I__T', 3);

busesInfoCreator.setBusByElements('EarthMagneticField', elems);

% Earth Rotation
elems = simpleBusElement('earth_quaternion_EI', 4);

busesInfoCreator.setBusByElements('EarthRotation', elems);

% Top-Level Bus

elems = [simpleBusElement('Time', 1, 'Bus: Time'), ...
            simpleBusElement('EarthAtmosphere', 1, 'Bus: EarthAtmosphere'), ...
            simpleBusElement('EarthGravitationalField', 1, 'Bus: EarthGravitationalField'), ...
            simpleBusElement('EarthMagneticField', 1, 'Bus: EarthMagneticField'), ...
            simpleBusElement('EarthRotation', 1, 'Bus: EarthRotation')];

busesInfoCreator.setBusByElements('EnvironmentConditions', elems);

%% LogEnvironment

% Top-Level Bus

elems = [simpleBusElement('EnvironmentConditions', 1, 'Bus: EnvironmentConditions'), ...
            simpleBusElement('EnvironmentStatesDerivatives', 1, 'Bus: EnvironmentStates'), ...
            simpleBusElement('EnvironmentStates', 1, 'Bus: EnvironmentStates')];

busesInfoCreator.setBusByElements('LogEnvironment', elems);

%% PlantStates

% Nested Buses

% Rigid Body
elems = [simpleBusElement('position_BI_I__m', 3), ...
            simpleBusElement('velocity_BI_I__m_per_s', 3), ...
            simpleBusElement('attitude_quaternion_BI', 4), ...
            simpleBusElement('angular_velocity_BI_B__rad_per_s', 3)];

busesInfoCreator.setBusByElements('RigidBodyStates', elems);

% Reaction Wheels
elems = simpleBusElement('angular_velocities__rad_per_s', 3);

busesInfoCreator.setBusByElements('ReactionWheelsStates', elems);

% Top-Level Bus

elems = [simpleBusElement('RigidBody', 1, 'Bus: RigidBodyStates'), ...
            simpleBusElement('ReactionWheels', 1, 'Bus: ReactionWheelsStates')];

busesInfoCreator.setBusByElements('PlantStates', elems);

%% PlantFeedthrough

% Nested Buses

% Satellite
elems = [simpleBusElement('acceleration_BI_I__m_per_s2', 3), ...
            simpleBusElement('rotational_acceleration_BI_B__rad_per_s2', 3)];

busesInfoCreator.setBusByElements('RigidBodyAccelerations', elems);

% Top-Level Bus

elems = simpleBusElement('RigidBodyAccelerations', 1, 'Bus: RigidBodyAccelerations');

busesInfoCreator.setBusByElements('PlantFeedthrough', elems);

%% LogPlantDynamics

% Nested Buses

% Forces
elems = [simpleBusElement('net_force_I__N', 3), ...
            simpleBusElement('gravitational_force_I__N', 3), ...
            simpleBusElement('aerodynamic_force_B__N', 3)];

busesInfoCreator.setBusByElements('Forces', elems);

% Torques
elems = [simpleBusElement('net_torque_B__N_m', 3), ...
            simpleBusElement('gravity_gradient_torque_BI_B__Nm', 3), ...
            simpleBusElement('aerodynamic_torque_B__Nm', 3), ...
            simpleBusElement('magnetic_torque_B__N_m', 3), ...
            simpleBusElement('reaction_torque_B__N_m', 3), ...
            simpleBusElement('gyroscopic_torque_B__N_m', 3)];

busesInfoCreator.setBusByElements('Torques', elems);

% Top-Level Bus

elems = [simpleBusElement('PlantFeedthrough', 1, 'Bus: PlantFeedthrough'), ...
            simpleBusElement('PlantStatesDerivatives', 1, 'Bus: PlantStates'), ...
            simpleBusElement('PlantStates', 1, 'Bus: PlantStates'), ...
            simpleBusElement('Forces', 1, 'Bus: Forces'), ...
            simpleBusElement('Torques', 1, 'Bus: Torques')];

busesInfoCreator.setBusByElements('LogPlantDynamics', elems);

%% PlantOutputs

% Top-Level Bus

elems = [simpleBusElement('RigidBody', 1, 'Bus: RigidBodyStates'), ...
            simpleBusElement('ReactionWheels', 1, 'Bus: ReactionWheelsStates')];

busesInfoCreator.setBusByElements('PlantOutputs', elems);

%% LogPlantOutput

% Top-Level Bus

elems = simpleBusElement('PlantOutputs', 1, 'Bus: PlantOutputs');

busesInfoCreator.setBusByElements('LogPlantOutput', elems);

%% SensorsStates
% none -> bus with dummy element
elems = [simpleBusElement('dummy', 1, 'double')];

busesInfoCreator.setBusByElements("SensorsStates", elems);

%% SensorsOutputs

% Nested Buses

% Perfect Clock
elems = simpleBusElement('current_time__mjd', 1, 'double');

busesInfoCreator.setBusByElements('PerfectClockOutputs', elems);

% Perfect Translational Motion Sensor
elems = [simpleBusElement('position_BI_I__m', 3), ...
            simpleBusElement('velocity_BI_I__m_per_s', 3), ...
            simpleBusElement('acceleration_BI_I__m_per_s2', 3)];

busesInfoCreator.setBusByElements('PerfectTranslationalMotionSensorOutputs', elems);

% Perfect Rotational Motion Sensor
elems = [simpleBusElement('attitude_quaternion_BI', 4), ...
            simpleBusElement('angular_velocity_BI_B__rad_per_s', 3), ...
            simpleBusElement('rotational_acceleration_BI_B__rad_per_s2', 3)];

busesInfoCreator.setBusByElements('PerfectRotationalMotionSensorOutputs', elems);

% Perfect Magnetometer
elems = simpleBusElement('magnetic_field_B__T', 3, 'double');

busesInfoCreator.setBusByElements('PerfectMagnetometerOutputs', elems);

% Perfect Reaction Wheels Rate Sensor
elems = simpleBusElement('angular_velocities__rad_per_s', 3, 'double');

busesInfoCreator.setBusByElements('ReactionWheelsSensorOutputs', elems);

% Top-Level Bus

elems = [simpleBusElement('PerfectClock', 1, 'Bus: PerfectClockOutputs'), ...
            simpleBusElement('PerfectTranslationalMotionSensor', 1, 'Bus: PerfectTranslationalMotionSensorOutputs'), ...
            simpleBusElement('PerfectRotationalMotionSensor', 1, 'Bus: PerfectRotationalMotionSensorOutputs'), ...
            simpleBusElement('PerfectMagnetometer', 1, 'Bus: PerfectMagnetometerOutputs'), ...
            simpleBusElement('ReactionWheels', 1, 'Bus: ReactionWheelsSensorOutputs')];

busesInfoCreator.setBusByElements('SensorsOutputs', elems);

%% LogSensors

% Top-Level Bus

elems = [simpleBusElement('SensorsOutputs', 1, 'Bus: SensorsOutputs'), ...
            simpleBusElement('SensorsStatesUpdateInput', 1, 'Bus: SensorsStates'), ...
            simpleBusElement('SensorsStates', 1, 'Bus: SensorsStates')];

busesInfoCreator.setBusByElements('LogSensors', elems);

%% GncAlgorithmsStates
% none -> bus with dummy element
elems = simpleBusElement('dummy', 1, 'double');

busesInfoCreator.setBusByElements("GncAlgorithmsStates", elems);

%% ActuatorsCommands

% Nested Buses

% Reaction Wheels
elems = simpleBusElement('torque_commands__N_m', 3);

busesInfoCreator.setBusByElements('ReactionWheelsCommands', elems);

% Magnetic Torquers
elems = simpleBusElement('magnetic_dipole_moment_commands__A_m2', 3);

busesInfoCreator.setBusByElements('MagneticTorquersCommands', elems);

% Top-Level Bus

elems = [simpleBusElement('ReactionWheels', 1, 'Bus: ReactionWheelsCommands'), ...
            simpleBusElement('MagneticTorquers', 1, 'Bus: MagneticTorquersCommands')];

busesInfoCreator.setBusByElements('ActuatorsCommands', elems);

%% LogGncAlgorithms

% Top-Level Bus

elems = [simpleBusElement('ActuatorsCommands', 1, 'Bus: ActuatorsCommands'), ...
            simpleBusElement('GncAlgorithmsStates', 1, 'Bus: GncAlgorithmsStates'), ...
            simpleBusElement('GncAlgorithmsStatesUpdateInput', 1, 'Bus: GncAlgorithmsStates'), ...
            simpleBusElement('reference_frame_attitude_quaternion_RI', 4, 'double'), ...
            simpleBusElement('reference_angular_velocity_RI_B__rad_per_s', 3, 'double'), ...
            simpleBusElement('error_quaternion_RB', 4, 'double'), ...
            simpleBusElement('angular_velocity_error_RB_B', 3, 'double')];

busesInfoCreator.setBusByElements('LogGncAlgorithms', elems);

%% ActuatorsStates
% none -> bus with dummy element
elems = [simpleBusElement('dummy', 1, 'double')];

busesInfoCreator.setBusByElements("ActuatorsStates", elems);

%% ActuatorsOutputs

% Nested Buses

% Reaction Wheels

elems = simpleBusElement('torque_commands__N_m', 3, 'double');
busesInfoCreator.setBusByElements('ReactionWheelsOutputs', elems);

% Magnetic Torquers

elems = simpleBusElement('magnetic_dipole_moment_B__A_m2', 3, 'double');
busesInfoCreator.setBusByElements('MagneticTorquersOutputs', elems);

% Top-Level Bus
elems = [simpleBusElement('ReactionWheels', 1, 'Bus: ReactionWheelsOutputs'), ...
            simpleBusElement('MagneticTorquers', 1, 'Bus: MagneticTorquersOutputs')];

busesInfoCreator.setBusByElements('ActuatorsOutputs', elems);

%% LogActuators

% Top-Level Bus

elems = [simpleBusElement('ActuatorsOutputs', 1, 'Bus: ActuatorsOutputs'), ...
            simpleBusElement('ActuatorsStates', 1, 'Bus: ActuatorsStates'), ...
            simpleBusElement('ActuatorsStatesUpdateInput', 1, 'Bus: ActuatorsStates')];

busesInfoCreator.setBusByElements('LogActuators', elems);

%% LogSendSimData

elems = simpleBusElement('udp_data_vector', 7, 'double');

busesInfoCreator.setBusByElements('LogSendSimData', elems);

%% LogStopCriterion

elems = simpleBusElement('stop_criterion', 1, 'boolean');

busesInfoCreator.setBusByElements('LogStopCriterion', elems);

%% Get Outputs
BusesInfo = busesInfoCreator.getBusesInfo();

end