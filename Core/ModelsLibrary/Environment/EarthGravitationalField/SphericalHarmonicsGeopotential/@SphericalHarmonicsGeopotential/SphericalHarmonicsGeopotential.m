classdef SphericalHarmonicsGeopotential < ModelBase
    methods (Static)

        gravitational_acceleration_I__m_per_s2 ...
            = execute(position_BI_I__m, ...
                        attitude_quaternion_EI, ...
                        parametersSphericalHarmonicsGeopotential)

        denormCoeffs = denormalizeCoefficients(normCoeffs)

        GeopotentialData = processGeopotentialData(file_name, num_header_lines, variable_names_line, saveFileFlag)

    end

    methods (Access = public)

        function obj = SphericalHarmonicsGeopotential(max_degree)
        % SphericalHarmonicsGeopotential
        %
        %   Inputs:
        %   max_degree: Maximum degree of spherical harmonics geopotential
        %       coefficients to load
        %

        arguments
            max_degree (1,1) {mustBeInteger, mustBePositive}
        end

            % Load data for spherical-Harmonics Geopotential
            [this_folder,~,~] = fileparts(mfilename("fullpath"));
            data = load(fullfile(this_folder, "ProcessedGeopotentialData", 'SphericalHarmonicsGeopotentialCoefficients.mat'));
            
            % Copy reference radius of coefficients into parameter structure
            Parameters.reference_radius__m = data.reference_radius__m;
            
            % Copy reference earth gravity constant of coefficients into parameter structure
            Parameters.reference_earth_gravity_constant__m3_per_s2 = data.reference_earth_gravity_constant__m3_per_s2;
            
            % Copy coefficients only up to desired maximum degree into parameter structure
            Parameters.DenormCoeffs.C = data.DenormCoeffs.C(1:(max_degree+1), 1:(max_degree+1));
            Parameters.DenormCoeffs.S = data.DenormCoeffs.S(1:(max_degree+1), 1:(max_degree+1));

            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);

        end

    end
end