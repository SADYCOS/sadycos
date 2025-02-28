classdef BusesInfoCreator < handle
    
    properties (Access = private, Constant)
        default_buses_names = ["EnvironmentConditions"; ...
                                    "EnvironmentStates"; ...
                                    "PlantOutputs"; ...
                                    "PlantFeedthrough"; ...
                                    "PlantStates"; ...
                                    "SensorsOutputs"; ...
                                    "SensorsStates"; ...
                                    "ActuatorsOutputs"; ...
                                    "ActuatorsStates"; ...
                                    "GncAlgorithmsStates"; ...
                                    "ActuatorsCommands"; ...
                                    "LogEnvironment"; ...
                                    "LogSensors"; ...
                                    "LogActuators"; ...
                                    "LogPlantDynamics"; ...
                                    "LogPlantOutput"; ...
                                    "LogGncAlgorithms"]
    end

    properties (SetAccess = immutable)
        required_buses_names (:,1) string
        num_required_buses (1,1) uint64
    end

    properties(Access = private)
        buses_list (:,1) struct = struct('Name',{},'Bus',{})
    end

    methods (Static)

        function aBusElement = simpleBusElement(name, dimensions, dataType, complexity)
        %% simpleBusElement
        % Create a simple bus element.
        %
        % Inputs:
        %   name: Name of the bus element.
        %   dimensions: Dimensions of the bus element.
        %   dataType: Data type of the bus element.
        %
        % Outputs:
        %   aBusElement: The created bus element.
        %

            arguments
                name {mustBeTextScalar}
                dimensions (:,1) {mustBePositive, mustBeInteger}
                dataType {mustBeTextScalar} = 'double'
                complexity {mustBeTextScalar} = 'real'
            end
            
            aBusElement = Simulink.BusElement;
            aBusElement.Name = name;
            aBusElement.Dimensions = dimensions;
            aBusElement.DataType = dataType;
            aBusElement.Complexity = complexity;
        end

    end
    
    methods (Access = public)

        function obj = BusesInfoCreator(Parameters)
        %% BusesInfoCreator
        % Create a BusesInfoCreator object.
        %
        % Inputs:
        %   Parameters: The Parameters struct.

            arguments
                Parameters (1,1) struct
            end

            obj.required_buses_names = obj.default_buses_names;

            % Add Required Buses Depending on Parameters
            if Parameters.General.enable_send_sim_data
                obj.required_buses_names(end+1) = "LogSendSimData";
            end

            if Parameters.General.enable_stop_criterion
                obj.required_buses_names(end+1) = "LogStopCriterion";
            end

            obj.num_required_buses = numel(obj.required_buses_names);


        end

        function setBusByElements(obj, name, elements)
        %% setBusByElements
        % Set a bus by its elements.
        %
        % Inputs:
        %   name: Name of the bus.
        %   elements: Elements of the bus.
        %

            arguments
                obj BusesInfoCreator
                name {mustBeTextScalar}
                elements (:,1) Simulink.BusElement
            end

            aBus = Simulink.Bus;
            aBus.Elements = elements;

            obj.setBus(name, aBus);
        end

        function setBus(obj, name, bus)
        %% setBus
        % Set a bus.
        %
        % Inputs:
        %   name: Name of the bus.
        %   bus: The bus.
        %
            arguments
                obj BusesInfoCreator
                name {mustBeTextScalar}
                bus (:,1) Simulink.Bus
            end

            % check if bus with same name already exists
            bus_index = find(strcmp(name, string({obj.buses_list.Name})), 1);
            if ~isempty(bus_index)
                % Overwrite nested bus
                warning('Bus with name "%s" has already been set. Overwriting.', name);
                obj.buses_list(bus_index).Bus = bus;
                return
            else
                % bus with this name does not already exist -> add new bus         
                Entry.Name = name;
                Entry.Bus = bus;
                obj.buses_list(end+1) = Entry;
            end
        end

        function [flag, reason] = isComplete(obj)
        %% isComplete
        % Check if all required buses and nested buses are set.
        %
        % Outputs:
        %   flag: True if all required buses and nested buses are set, false otherwise.
        %   reason: Reason why the buses are not complete.
        %

            % check if all required buses are set
            for required_bus_name = obj.required_buses_names.'
                required_bus_index = find(strcmp(required_bus_name, string({obj.buses_list.Name})), 1);
                if isempty(required_bus_index)
                    flag = false;
                    reason = sprintf('Required bus "%s" not set.', required_bus_name);
                    return;
                end
            end

            % check if all nested buses are set
            [flag, reason] = obj.allNestedBusesAreSet(obj.buses_list);
        end

        function BusesInfo = getBusesInfo(obj)
        %% getBusesInfo
        %
        % Outputs:
        %   BusesInfo: Struct containing relevant information on all buses.
        %

            [flag, reason] = obj.isComplete();
            if ~flag
                error("Cannot return bus templates: %s",reason);
            end
            
            BusesInfo.buses_list = obj.buses_list;

            AllBusTemplates = struct();
            for Entry = BusesInfo.buses_list.'
                [AllBusTemplates, ~] = obj.createBusTemplate(AllBusTemplates, Entry.Name);
            end

            for name = obj.required_buses_names.'
                BusesInfo.BusTemplates.(name) = AllBusTemplates.(name);
            end
        end
        
    end

    methods (Access = private)

        function [flag, reason] = allNestedBusesAreSet(obj, buses_list_entries)
            % initialize outputs
            flag = true;
            reason = '';

            for Entry = buses_list_entries.'
                for element = Entry.Bus.Elements.'
    
                    % check if element is a nested bus
                    if startsWith(element.DataType, 'Bus: ')
                        nested_bus_name = element.DataType(6:end);
    
                        % check if nested bus is set
                        nested_bus_index = find(strcmp(nested_bus_name, string({obj.buses_list.Name})), 1);
                        if ~isempty(nested_bus_index)
                            % nested bus is set
                            % can have have nested buses itself -> check
                            % if all of them are set as well
                            the_nested_bus = obj.buses_list(nested_bus_index);
                            [flag, reason] = obj.allNestedBusesAreSet(the_nested_bus);
                            if flag
                                continue
                            else
                                return
                            end
                        end

                        % nested bus is not set
                        flag = false;
                        reason = sprintf('Bus "%s" has nested bus "%s" that is not set.', Entry.Name, nested_bus_name);
                        return    
                    end
    
                end
            end
        end

        function [BusTemplates, current_template] = createBusTemplate(obj, BusTemplates, name)
            fn = fieldnames(BusTemplates);

            fn_index = find(strcmp(name, fn), 1);

            if ~isempty(fn_index)
                % template already exists
                the_fn = fn{fn_index};
                current_template = BusTemplates.(the_fn);
            else
                % template does not exist -> create it

                % find the corresponding entry
                entry_index = find(strcmp(name, string({obj.buses_list.Name})), 1);
                if isempty(entry_index)
                    error('Bus with name "%s" not found in the list of buses.', name);
                end
                Entry = obj.buses_list(entry_index);
    
                current_template = struct();
                for element = Entry.Bus.Elements.'
                    the_data_type = element.DataType;
                    if startsWith(the_data_type, 'Bus: ')
                        nested_bus_name = the_data_type(6:end);
                        [BusTemplates, element_template] = obj.createBusTemplate(BusTemplates, nested_bus_name);
                        current_template.(element.Name) = element_template;
                    else
                        the_dimensions = element.Dimensions;

                        % if dimensions is scalar, convert it to a 1x2 array
                        if isscalar(the_dimensions)
                            fixed_dimensions = [the_dimensions, 1];
                        else
                            fixed_dimensions = the_dimensions;
                        end
                        % if data type is boolean, convert it to logical
                        if strcmp(the_data_type, 'boolean')
                            fixed_data_type = 'logical';
                        else
                            fixed_data_type = the_data_type;
                        end

                        current_template.(element.Name) = createArray(fixed_dimensions, fixed_data_type);
                    end
                end
    
                BusTemplates.(name) = current_template;
            end
        end
    end
end

