classdef Sentman < handle
    properties %(Access = private, Hidden = true)
        handle_ = int32(-1);
    end
    
    methods
        function this = Sentman(temperature_ratio_method)
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("Sentman.new", int32(temperature_ratio_method)));
        end
        function delete(this)
            if this.handle_ ~= int32(-1)
                MexGateway("Sentman.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
        
        function [force__N, torque__Nm] = calc_aero_force_torque(this, area__m2, normal, centroid_m, v_rel__m_per_s, surf_temp__K, aero_cond)
            [force__N, torque__Nm] = MexGateway("Sentman.calc_aero_force_torque", int32(this.handle_), area__m2, normal, centroid_m, v_rel__m_per_s, surf_temp__K, int32(aero_cond.handle_));
        end
    end
end