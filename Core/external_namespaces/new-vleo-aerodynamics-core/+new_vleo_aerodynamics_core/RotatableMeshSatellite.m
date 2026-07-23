classdef RotatableMeshSatellite < handle
    properties %(Access = private, Hidden = true)
        % store handle as int32 to match MexGateway expectations
        handle_ = int32(-1);
    end
    methods
        function this = RotatableMeshSatellite(file_path)
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("Satellite.new", string(file_path)));
        end
      
        function delete(this)
            if this.handle_ ~= int32(-1)
                MexGateway("Satellite.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end

        function vertices = get_vertices(this)
            vertices = MexGateway("Satellite.get_vertices", int32(this.handle_));
        end

        function num_triangles = get_num_triangles(this)
            num_triangles = MexGateway("Satellite.get_num_triangles", int32(this.handle_));
        end

        function turn_surface_around_axis(this,surface_id, angle__rad, origin, axis)
            MexGateway("Satellite.turn_surface_around_axis", int32(this.handle_), int32(surface_id), angle__rad, origin, axis)
        end
    end
end
