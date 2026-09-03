classdef NewVleoAerodynamics < ModelBase

    methods (Static)
                        
        [total_force_B__N, total_torque_B__Nm] ...
            = execute(attitude_quaternion_BI, ...
                        velocity_I_I__m_per_s, ...
                        wind_velocity_I_I__m_per_s, ...
                        atmosphere_mass_density__kg_per_m3, ...
                        atmosphere_number_density__1_per_m3, ...
                        atmosphere_temperature__K, ...
                        ParametersNewVleoAerodynamics)

        test
                        

    end

    methods (Access = public)

        function obj = NewVleoAerodynamics(obj_file_path, ...
                                            surface_temperature__K, ...
                                            surface_energy_accommodation_coefficient, ...
                                            temperature_ratio_method, ...
                                            shading_algorithm, ...
                                            shading_resolution)   
% NewVleoAerodynamics
        %
        %   Inputs:
        %   obj_file_path: File path to the .obj file
        %   surface_temperature__K: Surface temperature in K
        %   surface_energy_accommodation_coefficient: Surface energy accommodation coefficient
        %   temperature_ratio_method: Method to calculate temperature ratio
        %   shading_algorithm: Algorithm to use for shading calculations
        %   shading_resolution: Resolution to use for shading calculations
        %
        %    arguments
        %        obj_file_path
        %        surface_temperature__K (1,1) double {mustBePositive}
        %        surface_energy_accommodation_coefficient (1,1) double
        %        temperature_ratio_method (1,1) {mustBeInteger, mustBePositive} 
        %        shading_algorithm (1,1) {mustBeInteger, mustBePositive} 
        %        shading_resolution (1,1) {mustBeInteger, mustBePositive} 
        %    end

            %% Build Parameters 
            Parameters.obj_file_path = obj_file_path;
            Parameters.surface_temperature__K = surface_temperature__K;
            Parameters.surface_energy_accommodation_coefficient = surface_energy_accommodation_coefficient;
            Parameters.temperature_ratio_method = temperature_ratio_method;
            Parameters.shading_algorithm = shading_algorithm;
            Parameters.shading_resolution = shading_resolution;
            
            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end
    end
end