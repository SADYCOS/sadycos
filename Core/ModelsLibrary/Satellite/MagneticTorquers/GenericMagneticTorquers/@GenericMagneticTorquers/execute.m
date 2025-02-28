function total_magnetic_dipole_moment__A_m2 ...
            = execute(magnetic_dipole_moment_commands__A_m2, ...
                        ParametersMagneticTorquers)
% execute - Limit and sum the magnetic dipole moments
%
%   total_magnetic_dipole_moment__A_m2 ...
%       = execute(magnetic_dipole_moment_commands__A_m2, ...
%                 ParametersMagneticTorquers)
%
%   Inputs:
%   magnetic_dipole_moment_commands__A_m2: Commands for the magnetic dipole moments in A m^2
%   ParametersMagneticTorquers: Parameters of the GenericMagneticTorquers model
%
%   Outputs:
%   total_magnetic_dipole_moment__A_m2: Total magnetic dipole moment in A m^2
%

%% Abbreviations
directions = ParametersMagneticTorquers.directions_B;
max_dipole_moments = ParametersMagneticTorquers.max_dipole_moments__A_m2;

%% Limit and sum dipole moments
total_magnetic_dipole_moment__A_m2 = zeros(3,1);
cmd = magnetic_dipole_moment_commands__A_m2;

for ind = 1:numel(cmd)
    the_limit = max_dipole_moments(ind);
    the_direction = directions(:,ind);
    the_cmd = magnetic_dipole_moment_commands__A_m2(ind);

    if the_cmd > the_limit;
        the_cmd = the_limit;
    elseif the_cmd < -the_limit
        the_cmd = -the_limit;
    end

    total_magnetic_dipole_moment__A_m2 = total_magnetic_dipole_moment__A_m2 + the_direction * the_cmd;

end

end