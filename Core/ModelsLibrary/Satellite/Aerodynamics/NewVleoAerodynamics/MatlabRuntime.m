function [total_force_B__N, total_torque_B__Nm] ...
             = MatlabRuntime(relative_velocity_B__m_per_s, ...
                        mass_density__kg_per_m3, ...
                        number_density__1_per_m3, ...
                        atmosphere_temperature__K, ...
                        ParametersNewVleoAerodynamics)
% MatlabRuntime - Runs the non-code-generatable MEX wrapper classes in the MATLAB runtime.
%
%   [total_force_B__N, total_torque_B__Nm] ...
%       = MatlabRuntime(relative_velocity_B__m_per_s, ...
%                       mass_density__kg_per_m3, ...
%                       number_density__1_per_m3, ...
%                       atmosphere_temperature__K, ...
%                       ParametersNewVleoAerodynamics)
%
%   Inputs:
%   relative_velocity_B__m_per_s: 3x1 vector of relative velocity in body frame
%   mass_density__kg_per_m3: Mass density of atmosphere in kg/m^3
%   number_density__1_per_m3: Number density of atmosphere in 1/m^3
%   atmosphere_temperature__K: Temperature of atmosphere in K
%   ParametersNewVleoAerodynamics: Parameters of the NewVleoAerodynamics model
%
%   Outputs:
%   total_force_B__N: 3x1 vector of aerodynamic force in body frame
%   total_torque_B__Nm: 3x1 vector of aerodynamic torque in body frame
%

%% Persistent aerodynamic objects
    persistent sentman
    persistent satellite
    persistent shading_pipeline
    persistent load_calculator
    persistent aero_conditions


%% Abreviations
Param = ParametersNewVleoAerodynamics;


%% Load parameters from the ParametersNewVleoAerodynamics structure
surface_temperature__K = Param.surface_temperature__K;
alpha_e = Param.surface_energy_accommodation_coefficient;
temperature_ratio_method = Param.temperature_ratio_method;
shading_algorithm = Param.shading_algorithm;
shading_resolution = Param.shading_resolution;
mesh_file_path = Param.obj_file_path;


%% Initialize persistent aerodynamic objects if they are empty
% Check if any of the persistent objects are empty
if isempty(sentman) || isempty(satellite) || isempty(shading_pipeline) || isempty(load_calculator)

sentman = ...
    new_vleo_aerodynamics_core.Sentman(temperature_ratio_method);

satellite = ...
    new_vleo_aerodynamics_core.RotatableMeshSatellite( ...
        mesh_file_path);

shading_pipeline = ...
    new_vleo_aerodynamics_core.ShadingPipeline( ...
        satellite, ...
        shading_algorithm, ...
        shading_resolution);

load_calculator = ...
    new_vleo_aerodynamics_core.HybridAeroLoadCalculator( ...
        satellite, ...
        shading_pipeline, ...
        sentman);
end


%% Create an AeroConditions object to hold the current atmospheric conditions
if isempty(aero_conditions)

    particle_mass__kg = mass_density__kg_per_m3 / number_density__1_per_m3;

    aero_conditions = ...
        new_vleo_aerodynamics_core.AeroConditions( ...
            mass_density__kg_per_m3, ...
            atmosphere_temperature__K, ...
            particle_mass__kg, ...
            alpha_e);
end


%% Compute the aerodynamic force and torque using the HybridAeroLoadCalculator
[force_B__N, torque_B__Nm] = load_calculator.calc_aero_load( ...
        relative_velocity_B__m_per_s, ...
        surface_temperature__K, ...
        aero_conditions);

total_force_B__N   = double(force_B__N);
total_torque_B__Nm = double(torque_B__Nm);

end

