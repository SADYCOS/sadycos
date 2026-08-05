classdef ShadingPipeline < handle
    % SHADINGPIPELINE Manages visibility analysis for satellite surfaces.
    %
    % This class determines which triangular faces of the satellite mesh are
    % exposed to the incoming flow and which are shaded by other parts of
    % the satellite. It uses a specified shading algorithm (e.g., Binary or
    % COP) to calculate a visibility factor for each triangle.
    %
    % ShadingPipeline methods:
    %   ShadingPipeline - Constructor to initialize the shading pipeline.
    %   shade           - Calculates visibility for all surfaces.
    %
    properties %(Access = private, Hidden = true)
        % store handle as int32 to match MexGateway expectations
        handle_ = int32(-1);
    end
    methods
        function this = ShadingPipeline(satellite, shading_algorithm, num_pixel)
            % SHADINGPIPELINE Constructor for ShadingPipeline.
            %
            %   obj = ShadingPipeline(satellite, shading_algorithm, num_pixel)
            %   initializes the pipeline for a specific satellite and algorithm.
            %
            %   Input Arguments:
            %       satellite         - A RotatableMeshSatellite object.
            %       shading_algorithm - An integer specifying the algorithm:
            %                           1 = Binary Shader (Simple on/off)
            %                           2 = COP Shader (More complex)
            %       num_pixel         - The resolution (number of pixels) 
            %                           used for the visibility analysis.
            %
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            try
                this.handle_ = MexGateway("Shading.new", int32(satellite.handle_), int32(shading_algorithm), int32(num_pixel));
            catch ME
                error("Failed to create Shading pipeline: %s", ME.message);
            end
        end
        
        function delete(this)
            % DELETE Destructor for ShadingPipeline.
            %
            %   Releases the underlying C++ pipeline object.
            %
            if this.handle_ ~= int32(-1)
                MexGateway("Shading.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end
        
        function visibility = shade(this,velocity)
            % SHADE Calculates the visibility factor for each satellite triangle.
            %
            %   visibility = shade(this, velocity) returns a vector containing
            %   the exposure value (shading) for each triangle in the mesh
            %   relative to the incoming flow direction.
            %
            %   Input Arguments:
            %       velocity   - The relative velocity vector [x, y, z] in the 
            %                    satellite body frame.
            %
            %   Output Arguments:
            %       visibility - A vector of visibility factors (1.0 = exposed, 
            %                    0.0 = shaded).
            %
            visibility = MexGateway("Shading.shade", int32(this.handle_), velocity);
        end
    end
end
