function torque__N_m = execute(magnetic_dipole_moment__A_m2, ...
                                magnetic_field__T)
% execute - Calculate the magnetic dipole torque
%
%   torque__N_m = execute(magnetic_dipole_moment__A_m2, ...
%                         magnetic_field__T)
%
%   Inputs:
%   magnetic_dipole_moment__A_m2: Magnetic dipole moment in A m^2
%   magnetic_field__T: Magnetic field in T
%
%   Outputs:
%   torque__N_m: Magnetic dipole torque in N m
%

torque__N_m = cross(magnetic_dipole_moment__A_m2, magnetic_field__T);

end