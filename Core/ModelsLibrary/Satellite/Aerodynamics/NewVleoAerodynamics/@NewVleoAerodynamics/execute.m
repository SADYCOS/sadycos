function [total_force_B__N, total_torque_B__Nm] ...
            = execute(attitude_quaternion_BI, ...
                        velocity_I_I__m_per_s, ...
                        wind_velocity_I_I__m_per_s, ...
                        atmosphere_mass_density__kg_per_m3, ...
                        atmosphere_number_density__1_per_m3, ...
                        atmosphere_temperature__K, ...
                        ParametersNewVleoAerodynamics)
% execute - Calculate the aerodynamic force and torque in the body frame
%
%   [total_force_B__N, total_torque_B__Nm] ...
%               = execute(attitude_quaternion_BI, ...
%                           velocity_I_I__m_per_s, ...
%                           wind_velocity_I_I__m_per_s, ...
%                           atmosphere_mass_density__kg_per_m3, ...
%                           atmosphere_number_density__1_per_m3, ...
%                           atmosphere_temperature__K, ...
%                           ParametersNewVleoAerodynamics)
%
%   Inputs:
%   attitude_quaternion_BI: 4x1 quaternion of body frame attitude
%   velocity_I_I__m_per_s: 3x1 vector of velocity in inertial frame
%   wind_velocity_I_I__m_per_s: 3x1 vector of wind velocity in inertial frame
%   atmosphere_mass_density__kg_per_m3: Mass density of atmosphere in kg/m^3
%   atmosphere_number_density__1_per_m3: Number density of atmosphere in 1/m^3
%   atmosphere_temperature__K: Temperature of atmosphere in K
%   ParametersNewVleoAerodynamics: Parameters of the NewVleoAerodynamics model
%
%   Outputs:
%   total_force_B__N: 3x1 vector of aerodynamic force in body frame
%   total_torque_B__Nm: 3x1 vector of aerodynamic torque in body frame
%

%% Abreviations
Param = ParametersNewVleoAerodynamics;

%% Load parameters from the ParametersNewVleoAerodynamics structure
surface_temp__K = Param.surface_temperature__K;
conditions = Param.aero_conditions{1};
calculator = Param.calculator{1};

%% Update the atmospheric conditions with the current values
particle_mass__kg = atmosphere_mass_density__kg_per_m3 / atmosphere_number_density__1_per_m3;

conditions.setDensity(atmosphere_mass_density__kg_per_m3);
conditions.setTemperature(atmosphere_temperature__K);
conditions.setParticleMass(particle_mass__kg);


%% Aerodynamic Calculation
% Calculate relative velocity in inertial frame
relative_velocity_I__m_per_s = velocity_I_I__m_per_s - wind_velocity_I_I__m_per_s;

% Transform relative velocity from inertial frame I to body frame B
relative_velocity_B__m_per_s = ...
    smu.unitQuat.att.transformVector( ...
        attitude_quaternion_BI, ...
        relative_velocity_I__m_per_s);

% Change relative velocity to row vector for vat compatibility
relative_velocity_B__m_per_s = relative_velocity_B__m_per_s(:)';

[total_force_B__N, total_torque_B__Nm] = calculator.calc_aero_load( ...
    relative_velocity_B__m_per_s, surface_temp__K, conditions);

end