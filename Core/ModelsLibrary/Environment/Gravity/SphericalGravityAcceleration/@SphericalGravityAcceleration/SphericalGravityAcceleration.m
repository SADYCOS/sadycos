 classdef SphericalGravityAcceleration < ModelBase
    methods (Static)

        [gravitational_acceleration_I__m_per_s2] ...
            = execute(position_BI_I__m, ParametersPointMassGravity)
        
    end

    methods (Access = public)

        function obj = SphericalGravityAcceleration(muBody__m3_per_s2)
        % PointMassGravity
        %
        %   Inputs:
        %   muBody__m3_per_s2: Gravitational constant of the body of interest
        %

        arguments
            muBody__m3_per_s2 (1,1) {mustBePositive,mustBeNumeric}
        end

            Parameters.muBody__m3_per_s2 = muBody__m3_per_s2;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end
        
    end
end