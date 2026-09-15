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
    persistent gsi_model
    persistent geometry
    persistent pipeline
    persistent calculator
    persistent conditions


%% Abreviations
Param = ParametersNewVleoAerodynamics;


%% Load parameters from the ParametersNewVleoAerodynamics structure
surface_temperature__K = Param.surface_temperature__K;
alpha_e = Param.surface_energy_accommodation_coefficient;
temperature_ratio_method = Param.temperature_ratio_method;
shading_algorithm = Param.shading_algorithm;
shading_resolution = Param.shading_resolution;
mesh_file_path = Param.obj_file_path{1};


%% Initialize persistent aerodynamic objects if they are empty
% Check if any of the persistent objects are empty
if isempty(gsi_model) || isempty(geometry) || isempty(pipeline) || isempty(calculator)

gsi_model = ...
    vat.gsi_models.Sentman(temperature_ratio_method, ...
                            alpha_e);

geometry = ...
    vat.geometry.RotatableMeshGeometry( ...
        mesh_file_path);

pipeline = ...
    vat.shading.ShadingPipeline( ...
        geometry, ...
        shading_algorithm, ...
        shading_resolution);

calculator = ...
    vat.loads.HybridForceTorqueCalculator( ...
        geometry, ...
        pipeline, ...
        gsi_model);
end


%% Create an AeroConditions object to hold the current atmospheric conditions
if isempty(conditions)

    particle_mass__kg = mass_density__kg_per_m3 / number_density__1_per_m3;

    conditions = ...
        vat.AeroConditions( ...
            mass_density__kg_per_m3, ...
            atmosphere_temperature__K, ...
            particle_mass__kg);
else
% Update the conditions object with the current atmospheric conditions
particle_mass__kg = mass_density__kg_per_m3 / number_density__1_per_m3;
conditions.setDensity(mass_density__kg_per_m3);
conditions.setTatmospheric(atmosphere_temperature__K);  
conditions.setParticleMass(particle_mass__kg);
end

%% Compute the aerodynamic force and torque using the HybridAeroLoadCalculator
[force_B__N, torque_B__Nm] = calculator.calc_aero_load( ...
        relative_velocity_B__m_per_s, ...
        surface_temperature__K, ...
        conditions);

total_force_B__N   = double(force_B__N);
total_torque_B__Nm = double(torque_B__Nm);

end

