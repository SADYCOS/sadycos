classdef SimulinkModelSetting
    properties (Access = public)
        name (1,1) string
        value (1,1)
    end

    methods (Access = public)

        function obj = SimulinkModelSetting(name, value)
            arguments
                name (1,1) string {mustBeTextScalar}
                value (1,1)
            end
            obj.name = name;
            obj.value = value;
        end

    end
end