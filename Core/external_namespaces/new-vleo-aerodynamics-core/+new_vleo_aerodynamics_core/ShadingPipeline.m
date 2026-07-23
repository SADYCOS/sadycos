classdef ShadingPipeline < handle
    properties %(Access = private, Hidden = true)
        % store handle as int32 to match MexGateway expectations
        handle_ = int32(-1);
    end
    methods
        function this = ShadingPipeline(satellite, shading_algorithm, num_pixel)
            %
            %shading algotihm 1 = binary, 2 = cop
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            try
                this.handle_ = MexGateway("Shading.new", int32(satellite.handle_), int32(shading_algorithm), int32(num_pixel));
            catch ME
                error("Failed to create Shading pipeline: %s", ME.message);
            end
        end
        
        function delete(this)
            if this.handle_ ~= int32(-1)
                MexGateway("Shading.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
        
        function visibility = shade(this,velocity)
            visibility = MexGateway("Shading.shade", int32(this.handle_), velocity);
        end
    end
end
