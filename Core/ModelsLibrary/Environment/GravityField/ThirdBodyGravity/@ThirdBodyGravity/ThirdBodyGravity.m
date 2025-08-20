 classdef ThirdBodyGravity < ModelBase
    methods (Static)

        [gravitational_acceleration_I__m_per_s2] ...
            = execute(position_BI_I__m,...
                      position_additional_body_AI_I_m,...
                      ParametersThirdBodyGravity)
        
    end

    methods (Access = public)

        function obj = ThirdBodyGravity(muBody__m3_per_s2)
        % ThirdBodyGravity
        %
        %   Inputs:
        %   muAddBody__m3_per_s2: Gravitational constant of the additional body
        %

        arguments
            muBody__m3_per_s2 (1,1) {mustBePositive,mustBeNumeric}
        end

            Parameters.muAddBody__m3_per_s2 = muBody__m3_per_s2;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end
        
    end
end