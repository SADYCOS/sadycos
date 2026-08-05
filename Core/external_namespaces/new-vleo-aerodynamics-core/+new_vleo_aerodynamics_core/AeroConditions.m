classdef AeroConditions < handle
    % AEROCONDITIONS Atmospheric and interaction properties for aerodynamic load calculations.
    %
    % This class stores the environmental parameters required by Gas-Surface 
    % Interaction (GSI) models to calculate forces and torques. It includes
    % atmospheric density, temperature, and particle properties.
    %
    % AeroConditions methods:
    %   AeroConditions - Constructor for the atmospheric conditions.
    %
    properties %(Access = private, Hidden = true)
        handle_ = int32(-1);
    end

    methods
        function this = AeroConditions(density__kg_per_m3,...
                            temperature__K,...
                            particle_mass__kg,...
                            alpha_e)
            % AEROCONDITIONS Constructor for AeroConditions.
            %
            %   obj = AeroConditions(density, temperature, mass, alpha_e) creates an
            %   AeroConditions object with the specified atmospheric parameters.
            %
            %   Input Arguments:
            %       density__kg_per_m3 - Atmospheric density [kg/m^3].
            %       temperature__K     - Atmospheric temperature [K].
            %       particle_mass__kg  - Mean particle mass of the atmosphere [kg].
            %       alpha_e            - Energy accommodation coefficient (usually 0.0 to 1.0).
            %
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("AeroCond.new", density__kg_per_m3, temperature__K, particle_mass__kg, alpha_e));
        end
        function delete(this)
            % DELETE Destructor for AeroConditions.
            %
            %   Releases the underlying C++ AeroConditions object.
            %
            if this.handle_ ~= int32(-1)
                MexGateway("AeroCond.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
    end
end