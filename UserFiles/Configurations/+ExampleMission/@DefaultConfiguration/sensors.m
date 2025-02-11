function [SensorsOutputs, ...
            LogSensors, ...
            SensorsStatesUpdateInput] ...
            = sensors(SensorsOutputs, ...
                        LogSensors, ...
                        SensorsStatesUpdateInput, ...
                        EnvironmentConditions, ...
                        PlantOutputs, ...
                        PlantFeedthrough, ...
                        SensorsStates, ...
                        ParametersSensors)

%% Abbreviations
attitude_quaternion_BI = PlantOutputs.RigidBody.attitude_quaternion_BI;

%% Set Output

% Perfect Clock
SensorsOutputs.PerfectClock.current_time__mjd ...
    = EnvironmentConditions.Time.current_time__mjd;

% Perfect Translational Motion Sensor
SensorsOutputs.PerfectTranslationalMotionSensor.position_BI_I__m ...
    = PlantOutputs.RigidBody.position_BI_I__m;

SensorsOutputs.PerfectTranslationalMotionSensor.velocity_BI_I__m_per_s ...
    = PlantOutputs.RigidBody.velocity_BI_I__m_per_s;

SensorsOutputs.PerfectTranslationalMotionSensor.acceleration_BI_I__m_per_s2 ...
    = PlantFeedthrough.RigidBodyAccelerations.acceleration_BI_I__m_per_s2;

% Perfect Rotational Motion Sensor
SensorsOutputs.PerfectRotationalMotionSensor.attitude_quaternion_BI ...
    = attitude_quaternion_BI;

SensorsOutputs.PerfectRotationalMotionSensor.angular_velocity_BI_B__rad_per_s ...
    = PlantOutputs.RigidBody.angular_velocity_BI_B__rad_per_s;

SensorsOutputs.PerfectRotationalMotionSensor.rotational_acceleration_BI_B__rad_per_s2 ...
    = PlantFeedthrough.RigidBodyAccelerations.rotational_acceleration_BI_B__rad_per_s2;

% Perfect Magnetometer
SensorsOutputs.PerfectMagnetometer.magnetic_field_B__T ...
    = smu.unitQuat.att.transformVector(attitude_quaternion_BI, EnvironmentConditions.EarthMagneticField.magnetic_field_I__T);

% Perfect Reaction Wheels Rate Sensor
SensorsOutputs.ReactionWheels.angular_velocities__rad_per_s ...
    = PlantOutputs.ReactionWheels.angular_velocities__rad_per_s;

%% Update States
% no states -> SensorsStatesUpdateInput can stay unaltered

%% Log relevant data
LogSensors.SensorsOutputs = SensorsOutputs;
LogSensors.SensorsStatesUpdateInput = SensorsStatesUpdateInput ;
LogSensors.SensorsStates = SensorsStates;

end
