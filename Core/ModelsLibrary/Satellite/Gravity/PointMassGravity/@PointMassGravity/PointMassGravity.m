classdef PointMassGravity < ModelBase
    methods (Static)

        gravitational_force_I__N = execute(gravitational_acceleration_I__m_per_s2, ParametersPointMassGravity)
        
    end

    methods (Access = public)

        function obj = PointMassGravity(mass__kg)
        % PointMassGravity
        %
        %   Inputs:
        %   mass__kg: Mass of the point mass in kg
        %

        arguments
            mass__kg (1,1) {mustBePositive}
        end

            Parameters.mass__kg = mass__kg;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end
        
    end
end