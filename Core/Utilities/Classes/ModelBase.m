classdef (Abstract) ModelBase < handle

    properties (SetAccess = protected, GetAccess = public)
        Parameters (1,1) struct
        Settings (1,:) SimulinkModelSetting
    end

    methods (Abstract, Static)
        execute
    end

    methods (Access = public)

        function obj = ModelBase(NameValueArgs)
            arguments
                NameValueArgs.Settings (1,:) SimulinkModelSetting = SimulinkModelSetting.empty(1,0)
            end
            obj.Settings = NameValueArgs.Settings;
        end

    end

end