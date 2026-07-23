classdef AeroConditions < handle
    properties %(Access = private, Hidden = true)
        handle_ = int32(-1);
    end

    methods
        function this = AeroConditions(density__kg_per_m3,...
                            temperature__K,...
                            particle_mass__kg,...
                            alpha_e)
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("AeroCond.new", density__kg_per_m3, temperature__K, particle_mass__kg, alpha_e));
        end
        function delete(this)
            if this.handle_ ~= int32(-1)
                MexGateway("AeroCond.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
    end
end