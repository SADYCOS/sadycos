classdef RotatableMeshSatellite < handle
    % ROTATABLEMESHSATELLITE Represents a satellite model with rotatable surfaces.
    %
    % This class manages the geometric data of a satellite, including vertices
    % and triangles, and allows for the rotation of specific parts around defined
    % axes. It is used as the base geometry for shading and aerodynamic load 
    % calculations.
    %
    % RotatableMeshSatellite methods:
    %   RotatableMeshSatellite   - Constructor to load a satellite model.
    %   get_vertices             - Retrieves the vertex data of the satellite.
    %   get_num_triangles        - Retrieves the total number of triangles.
    %   turn_surface_around_axis - Rotates a specific surface of the satellite.
    %
    properties %(Access = private, Hidden = true)
        % store handle as int32 to match MexGateway expectations
        handle_ = int32(-1);
    end
    methods
        function this = RotatableMeshSatellite(file_path)
            % ROTATABLEMESHSATELLITE Constructor for RotatableMeshSatellite.
            %
            %   obj = RotatableMeshSatellite(file_path) creates a satellite 
            %   object by loading the geometry from the specified file.
            %
            %   Input Arguments:
            %       file_path - Path to the 3D model file (e.g., .obj or .stl).
            %
            assert(this.handle_ == int32(-1), "This object is already constructed.");
            this.handle_ = int32(MexGateway("Satellite.new", string(file_path)));
        end
      
        function delete(this)
            % DELETE Destructor for RotatableMeshSatellite.
            %
            %   Releases the underlying C++ satellite object.
            %
            if this.handle_ ~= int32(-1)
                MexGateway("Satellite.delete", int32(this.handle_));
                this.handle_ = int32(-1);
            end
        end

        function vertices = get_vertices(this)
            % GET_VERTICES Retrieves the vertex positions of the satellite.
            %
            %   vertices = get_vertices(this) returns a flat array of vertex 
            %   positions (x, y, z triplets).
            %
            %   Output Arguments:
            %       vertices - Array of vertex coordinates [3 x N].
            %
            vertices = MexGateway("Satellite.get_vertices", int32(this.handle_));
        end

        function num_triangles = get_num_triangles(this)
            % GET_NUM_TRIANGLES Retrieves the total number of triangles in the model.
            %
            %   num_triangles = get_num_triangles(this) returns the total count
            %   of triangular faces across all meshes of the satellite.
            %
            %   Output Arguments:
            %       num_triangles - The number of triangles.
            %
            num_triangles = MexGateway("Satellite.get_num_triangles", int32(this.handle_));
        end

        function turn_surface_around_axis(this,surface_id, angle__rad, origin, axis)
            % TURN_SURFACE_AROUND_AXIS Rotates a specific satellite component.
            %
            %   turn_surface_around_axis(this, surface_id, angle, origin, axis)
            %   applies a rotation to the specified mesh or surface.
            %
            %   Input Arguments:
            %       surface_id - The ID of the surface or mesh to rotate.
            %       angle__rad - The rotation angle in radians.
            %       origin     - The 3D coordinates [x, y, z] of the rotation origin.
            %       axis       - The 3D vector [x, y, z] defining the axis of rotation.
            %
            MexGateway("Satellite.turn_surface_around_axis", int32(this.handle_), int32(surface_id), angle__rad, origin, axis)
        end
    end
end
