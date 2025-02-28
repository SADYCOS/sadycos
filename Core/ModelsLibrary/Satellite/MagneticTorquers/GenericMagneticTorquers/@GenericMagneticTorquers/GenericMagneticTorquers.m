classdef GenericMagneticTorquers < ModelBase
    methods (Static)
        
        total_magnetic_dipole_moment__A_m2 = execute(dipole_moment_commands__A_m2, ...
                                                        ParametersMagneticTorquers)
    end

    methods (Access = public)

        function obj = GenericMagneticTorquers(directions_B, max_dipole_moments__A_m2)
        % GenericMagneticTorquers
        %
        %   Inputs:
        %   directions_B: Directions of the magnetic dipoles in the body frame
        %   max_dipole_moments__A_m2: Maximum dipole moments in A m^2
        %

            arguments
                directions_B (3,:) {mustBeNumeric, mustBeReal, mustBeUnitColumns}
                max_dipole_moments__A_m2 (1,:) {mustBePositive, smu.argumentValidation.mustBeEqualLength(max_dipole_moments__A_m2, directions_B, 2, 2)}
            end
            
            Parameters.directions_B = directions_B;
            Parameters.max_dipole_moments__A_m2 = max_dipole_moments__A_m2;

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end