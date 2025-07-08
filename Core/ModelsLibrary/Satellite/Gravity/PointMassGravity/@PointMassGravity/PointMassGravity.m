classdef PointMassGravity < ModelBase
    methods (Static)

        gravitational_force_I__N = execute(mass__kg, ...
                        inertia_B_B__kg_m2, ...
                        gravitational_acceleration_I__m_per_s2,...
                        ParametersPointMassGravity)
        
    end

end