classdef Sentman < handle
    % SENTMAN Sentman's Gas-Surface Interaction (GSI) model.
    %
    % This class implements the Sentman model for calculating aerodynamic 
    % forces and torques on surface elements. It considers the diffuse 
    % reflection of particles and the energy accommodation between the flow 
    % and the satellite surface.
    %
    % Sentman methods:
    %   Sentman                - Constructor for the Sentman model.
    %   calc_aero_force_torque - Calculates loads for a single surface element.
    %
    properties %(Access = private, Hidden = true)
        handle_ = int32(-1);
    end
    
    methods
        function this = Sentman(temperature_ratio_method)
            % SENTMAN Constructor for the Sentman model.
            %
            %   obj = Sentman(temperature_ratio_method) initializes the model.
            %
            %   Input Arguments:
            %       temperature_ratio_method - An integer flag specifying the 
            %           method used for calculating the temperature ratio 
            %           between the surface and the incoming flow.
            %
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("Sentman.new", int32(temperature_ratio_method)));
        end
        function delete(this)
            % DELETE Destructor for Sentman model.
            %
            %   Releases the underlying C++ model object.
            %
            if this.handle_ ~= int32(-1)
                MexGateway("Sentman.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
        
        function [force__N, torque__Nm] = calc_aero_force_torque(this, area__m2, normal, centroid_m, v_rel__m_per_s, surf_temp__K, aero_cond)
            % CALC_AERO_FORCE_TORQUE Calculates aerodynamic loads for a surface element.
            %
            %   [force__N, torque__Nm] = calc_aero_force_torque(this, area, 
            %   normal, centroid, v_rel, surf_temp, aero_cond) computes the 
            %   local force and torque vectors based on Sentman's equations.
            %
            %   Input Arguments:
            %       area__m2       - Surface area of the element [m^2].
            %       normal         - Unit normal vector of the surface element.
            %       centroid_m     - 3D centroid position of the element [m].
            %       v_rel__m_per_s - Relative velocity vector of the flow [m/s].
            %       surf_temp__K   - Temperature of the satellite surface [K].
            %       aero_cond      - An AeroConditions object with atmospheric data.
            %
            %   Output Arguments:
            %       force__N       - Resulting aerodynamic force vector [N].
            %       torque__Nm     - Resulting aerodynamic torque vector [Nm].
            %
            [force__N, torque__Nm] = MexGateway("Sentman.calc_aero_force_torque", int32(this.handle_), area__m2, normal, centroid_m, v_rel__m_per_s, surf_temp__K, int32(aero_cond.handle_));
        end
    end
end