classdef HybridAeroLoadCalculator < handle
    % HYBRIDAEROLOADCALCULATOR Calculates aerodynamic loads on a satellite.
    %
    % This class provides a high-level interface for calculating the total 
    % aerodynamic force and torque acting on a satellite. It combines a 
    % satellite model, a shading pipeline to handle self-shadowing, and a 
    % Gas-Surface Interaction (GSI) model for surface-level physics.
    %
    % HybridAeroLoadCalculator methods:
    %   HybridAeroLoadCalculator - Constructor for the calculator.
    %   calc_aero_load           - Calculates total force and torque.
    %
    properties %(Access = private, Hidden = true)
        handle_ = int32(-1);
    end

    methods
        function this = HybridAeroLoadCalculator(satellite, shading_pipeline, gsi_model)
            % HYBRIDAEROLOADCALCULATOR Constructor for HybridAeroLoadCalculator.
            %
            %   obj = HybridAeroLoadCalculator(satellite, shading_pipeline, gsi_model)
            %   initializes the calculator with the necessary components.
            %
            %   Input Arguments:
            %       satellite        - A RotatableMeshSatellite object representing the geometry.
            %       shading_pipeline - A ShadingPipeline object for visibility analysis.
            %       gsi_model        - A GSI model object (e.g., Sentman) for load calculation.
            %
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("HybridAeroLoadCalculator.new", int32(satellite.handle_), int32(shading_pipeline.handle_), int32(gsi_model.handle_)));
        end
        function [force__N, torque__Nm] = calc_aero_load(this, v_rel__m_per_s,surface_temp__K, aero_conditions)
            % CALC_AERO_LOAD Calculates the total aerodynamic force and torque.
            %
            %   [force__N, torque__Nm] = calc_aero_load(this, v_rel, surface_temp, aero_conditions)
            %   performs the complete aerodynamic analysis, including shading and
            %   surface interactions, to compute the resulting loads.
            %
            %   Input Arguments:
            %       v_rel__m_per_s   - Relative velocity vector in satellite body frame [m/s].
            %       surface_temp__K  - Uniform surface temperature of the satellite [K].
            %       aero_conditions  - An AeroConditions object containing atmospheric properties.
            %
            %   Output Arguments:
            %       force__N         - Total aerodynamic force vector in body frame [N].
            %       torque__Nm       - Total aerodynamic torque vector about the origin [Nm].
            %
            [force__N, torque__Nm] = MexGateway("HybridAeroLoadCalculator.calc_aero_load", int32(this.handle_), v_rel__m_per_s, surface_temp__K, int32(aero_conditions.handle_));
        end
        function delete(this)
            % DELETE Destructor for HybridAeroLoadCalculator.
            %
            %   Releases the underlying C++ resources.
            %
            if this.handle_ ~= int32(-1)
                MexGateway("HybridAeroLoadCalculator.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
    end
end