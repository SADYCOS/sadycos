function [ActuatorsCommands, ...
            LogGncAlgorithms, ...
            GncAlgorithmsStatesUpdateInput] ...
            = gncAlgorithms(ActuatorsCommands, ...
                            LogGncAlgorithms, ...
                            GncAlgorithmsStatesUpdateInput, ...
                            SensorsOutputs, ...
                            GncAlgorithmsStates, ...
                            ParametersGncAlgorithms)

%% Abbreviations
rw_spin_directions = ParametersGncAlgorithms.reaction_wheels_spin_directions_B;
torquers_directions = ParametersGncAlgorithms.magnetic_torquers_directions_B;
gain_desat = ParametersGncAlgorithms.reaction_wheels_desaturation_gain__1_per_s;
rw_inertias = ParametersGncAlgorithms.reaction_wheels_inertias__kg_m2;

rw_angular_velocities__rad_per_s = SensorsOutputs.ReactionWheels.angular_velocities__rad_per_s;
magnetic_field_B__T = SensorsOutputs.PerfectMagnetometer.magnetic_field_B__T;

%% Navigation
position_BI_I__m = SensorsOutputs.PerfectTranslationalMotionSensor.position_BI_I__m;
velocity_BI_I__m_per_s = SensorsOutputs.PerfectTranslationalMotionSensor.velocity_BI_I__m_per_s;
attitude_quaternion_BI = SensorsOutputs.PerfectRotationalMotionSensor.attitude_quaternion_BI;
angular_velocity_BI_B__rad_per_s = SensorsOutputs.PerfectRotationalMotionSensor.angular_velocity_BI_B__rad_per_s;

%% Guidance
reference_frame_attitude_quaternion_RI = smu.frames.rotationInertialToTangential(position_BI_I__m, velocity_BI_I__m_per_s);

reference_angular_velocity_RI_I__rad_per_s = cross(position_BI_I__m, velocity_BI_I__m_per_s) / norm(position_BI_I__m)^2;
reference_angular_velocity_RI_R__rad_per_s = smu.unitQuat.att.transformVector(reference_frame_attitude_quaternion_RI, reference_angular_velocity_RI_I__rad_per_s);

%% Control
% Reaction Wheel Desaturation
rw_angular_momentum_B__kg_m2_per_s = rw_spin_directions * (rw_inertias .* rw_angular_velocities__rad_per_s);
desired_magnetic_dipole_moment__A_m2 = - gain_desat * cross(magnetic_field_B__T, rw_angular_momentum_B__kg_m2_per_s) / norm(magnetic_field_B__T)^2;

magnetic_dipole_moment_commands__A_m2 = pinv(torquers_directions) * desired_magnetic_dipole_moment__A_m2;

% Attitude
[error_quaternion_RB, ...
    angular_velocity_B__rad_per_s] = AttitudeError.execute(reference_frame_attitude_quaternion_RI, ...
                                                attitude_quaternion_BI, ...
                                                reference_angular_velocity_RI_R__rad_per_s, ...
                                                angular_velocity_BI_B__rad_per_s);

reference_angular_velocity_RI_B__rad_per_s = angular_velocity_B__rad_per_s.reference_RI;
angular_velocity_error_RB_B__rad_per_s = angular_velocity_B__rad_per_s.error_RB;

desired_torque_B__N_m = QuaternionFeedbackControl.execute(error_quaternion_RB, ...
                                            angular_velocity_error_RB_B__rad_per_s, ...
                                            ParametersGncAlgorithms.QuaternionFeedbackControl);
                                            
rw_torque_commands__N_m = - pinv(rw_spin_directions) * desired_torque_B__N_m;

%% Set Output
ActuatorsCommands.ReactionWheels.torque_commands__N_m = rw_torque_commands__N_m;
ActuatorsCommands.MagneticTorquers.magnetic_dipole_moment_commands__A_m2 = magnetic_dipole_moment_commands__A_m2;

%% Update States
% no states -> GncAlgorithmsStatesUpdateInput can stay unaltered

%% Log relevant data
LogGncAlgorithms.ActuatorsCommands = ActuatorsCommands;
LogGncAlgorithms.GncAlgorithmsStates = GncAlgorithmsStates;
LogGncAlgorithms.GncAlgorithmsStatesUpdateInput = GncAlgorithmsStatesUpdateInput;
LogGncAlgorithms.reference_frame_attitude_quaternion_RI = reference_frame_attitude_quaternion_RI;
LogGncAlgorithms.reference_angular_velocity_RI_B__rad_per_s = reference_angular_velocity_RI_B__rad_per_s;
LogGncAlgorithms.error_quaternion_RB = error_quaternion_RB;
LogGncAlgorithms.angular_velocity_error_RB_B__rad_per_s = angular_velocity_error_RB_B__rad_per_s;

end
