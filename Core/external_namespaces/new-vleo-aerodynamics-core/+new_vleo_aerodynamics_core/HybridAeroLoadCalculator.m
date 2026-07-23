classdef HybridAeroLoadCalculator < handle
    properties %(Access = private, Hidden = true)
        handle_ = int32(-1);
    end

    methods
        function this = HybridAeroLoadCalculator(satellite, shading_pipeline, gsi_model)
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("HybridAeroLoadCalculator.new", int32(satellite.handle_), int32(shading_pipeline.handle_), int32(gsi_model.handle_)));
        end
        function [force__N, torque__Nm] = calc_aero_load(this, v_rel__m_per_s,surface_temp__K, aero_conditions)
            [force__N, torque__Nm] = MexGateway("HybridAeroLoadCalculator.calc_aero_load", int32(this.handle_), v_rel__m_per_s, surface_temp__K, int32(aero_conditions.handle_));
        end
        function delete(this)
            if this.handle_ ~= int32(-1)
                MexGateway("HybridAeroLoadCalculator.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
    end
end