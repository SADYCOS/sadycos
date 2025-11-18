classdef VisualizationUdpInterface < handle
    properties (Access = private)
        message_index (1,1) uint32 = 0
        time (1,1) double = NaN
        position (3,1) double = NaN(3,1)
        attitude (4,1) double = NaN(4,1)
        attitude_central_body (4,1) double = NaN(4,1)
        sun_direction (3,1) double = NaN(3,1)
        control_surface_angles (1,:) double = []
        scalars (1,:) double = []
        vectors (6,:) double = []
        systems (7,:) double = []
    end

    properties (Constant, Access = private)
        num_bytes_per_package = 508        
    end

    properties (SetAccess = immutable, GetAccess = private)
        udps (1,1)
        num_control_surface_angles (1,1) uint32
        num_scalars (1,1) uint32
        num_vectors (1,1) uint32
        num_systems (1,1) uint32
        num_bytes_payload (1,1) uint32
        empty_payload (:,1) uint8
    end

    methods (Access = public)

        function obj = VisualizationUdpInterface(remote_ip_port, ...
                                                    num_control_surface_angles, ...
                                                    num_scalars, ...
                                                    num_vectors, ...
                                                    num_systems, ...
                                                    remote_ip_address)
            arguments
                remote_ip_port (1,1) uint16 {mustBeNumeric, mustBeNonnegative}
                num_control_surface_angles (1,1) uint32 {mustBeNumeric, mustBeNonnegative}
                num_scalars (1,1) uint32 {mustBeNumeric, mustBeNonnegative}
                num_vectors (1,1) uint32 {mustBeNumeric, mustBeNonnegative}
                num_systems (1,1) uint32 {mustBeNumeric, mustBeNonnegative}
                remote_ip_address (1,1) string {mustBeTextScalar} = "127.0.0.1"
            end

            obj.udps = dsp.UDPSender("RemoteIPAddress", remote_ip_address, "RemoteIPPort", remote_ip_port);
            obj.num_control_surface_angles = num_control_surface_angles;
            obj.control_surface_angles = NaN(num_control_surface_angles, 1);
            obj.num_scalars = num_scalars;
            obj.scalars = NaN(num_scalars, 1);
            obj.num_vectors = num_vectors;
            obj.vectors = NaN(6, num_vectors);
            obj.num_systems = num_systems;
            obj.systems = NaN(7, num_systems);

            obj.num_bytes_payload = 136 ...
                                    + obj.num_control_surface_angles * 8 ...
                                    + obj.num_scalars * 8 ...
                                    + obj.num_vectors * 48 ...
                                    + obj.num_systems * 56;

            obj.empty_payload = zeros(1, obj.num_bytes_payload, "uint8");
            obj.empty_payload(1:16) = typecast([obj.num_control_surface_angles; ...
                                                obj.num_scalars; ...
                                                obj.num_vectors; ...
                                                obj.num_systems], ...
                                            "uint8");
        end

        function delete(obj)
            obj.udps.release();
        end

        function updateTime(obj, time)
            arguments
                obj (1,1) VisualizationUdpInterface
                time (1,1) double {mustBeNumeric, mustBeFinite}
            end

            obj.time = time;
        end

        function updatePosition(obj, position)
            arguments
                obj (1,1) VisualizationUdpInterface
                position (3,1) double {mustBeNumeric, mustBeFinite}
            end

            obj.position = position;
        end

        function updateAttitude(obj, attitude)
            arguments
                obj (1,1) VisualizationUdpInterface
                attitude (4,1) double {mustBeNumeric, mustBeFinite}
            end

            obj.attitude = attitude;
        end

        function updateAttitudeCentralBody(obj, attitude_central_body)
            arguments
                obj (1,1) VisualizationUdpInterface
                attitude_central_body (4,1) double {mustBeNumeric, mustBeFinite}
            end

            obj.attitude_central_body = attitude_central_body;
        end

        function updateSunDirection(obj, sun_direction)
            arguments
                obj (1,1) VisualizationUdpInterface
                sun_direction (3,1) double {mustBeNumeric, mustBeFinite}
            end

            obj.sun_direction = sun_direction;
        end

        function updateControlSurfaceAngles(obj, angles)
            arguments
                obj (1,1) VisualizationUdpInterface
                angles (1,:) double {mustBeNumeric, mustBeFinite}
            end

            if (numel(angles) ~= obj.num_control_surface_angles)
                error("The number of control surface angles must be equal to %d.", obj.num_control_surface_angles);
            end

            obj.control_surface_angles = angles;
        end

        function updateScalars(obj, scalars)
            arguments
                obj (1,1) VisualizationUdpInterface
                scalars (1,:) double {mustBeNumeric, mustBeFinite}
            end

            if (numel(scalars) ~= obj.num_scalars)
                error("The number of scalars must be equal to %d.", obj.num_scalars);
            end

            obj.scalars = scalars;
        end

        function updateVectors(obj, vectors)
            arguments
                obj (1,1) VisualizationUdpInterface
                vectors (6,:) double {mustBeNumeric, mustBeFinite}
            end

            if (size(vectors, 2) ~= obj.num_vectors)
                error("The number of vectors must be equal to %d.", obj.num_vectors);
            end

            obj.vectors = vectors;
        end

        function updateSystems(obj, systems)
            arguments
                obj (1,1) VisualizationUdpInterface
                systems (7,:) double {mustBeNumeric, mustBeFinite}
            end

            if (size(systems, 2) ~= obj.num_systems)
                error("The number of systems must be equal to %d.", obj.num_systems);
            end

            obj.systems = systems;
        end

        function payload = send(obj)
            arguments
                obj (1,1) VisualizationUdpInterface
            end

            obj.message_index = obj.message_index + 1;

            payload = obj.empty_payload;

            payload(17:end) = typecast([obj.time; ...
                                        obj.position; ...
                                        obj.attitude; ...
                                        obj.attitude_central_body; ...
                                        obj.sun_direction; ...
                                        obj.control_surface_angles(:); ...
                                        obj.scalars(:); ...
                                        obj.vectors(:); ...
                                        obj.systems(:)], ...
                                    "uint8");

            max_num_bytes_payload = obj.num_bytes_per_package - 12;
            num_packages = ceil(double(obj.num_bytes_payload) / double(max_num_bytes_payload));

            for package_index = 1:num_packages

                payload_start_index = (package_index - 1) * max_num_bytes_payload + 1;
                payload_end_index = min(payload_start_index + max_num_bytes_payload - 1, obj.num_bytes_payload);
                num_bytes_package = 12 + payload_end_index - payload_start_index + 1 ;

                package = zeros(1, num_bytes_package, "uint8");

                package(1:12) = typecast([obj.message_index, package_index, num_packages], "uint8");

                package(13:num_bytes_package) = payload(payload_start_index:payload_end_index);

                obj.udps(package);
            end
        end
    end

end