classdef MagneticDipoleTorque < ModelBase
    methods (Static)
        torque__N_m = execute(magnetic_dipole_moment__A_m2, ...
                                magnetic_field__T)
    end
end