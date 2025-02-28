classdef ParameterCreator < handle

    properties (Access = private, Constant)
        subsystems_option_delay = ["Sensors", "Actuators", "GncAlgorithms"]
        subsystems_option_states = ["Environment", ParameterCreator.subsystems_option_delay]
        all_subsystems = ["Plant", ParameterCreator.subsystems_option_states]
    end

    properties (SetAccess = immutable, GetAccess = private)
        InitialPlantStates (1,1) struct
        SampleTimeParameters__s (1,1) struct
        is_discrete (1,1) struct
        simulation_duration__s (1,1) double {mustBePositive} = 10
        simulation_mode (1,1) string
        enable_pacing (1,1) logical
        pacing_rate (1,1) double {mustBePositive, mustBeFinite} = 1
        enable_send_sim_data (1,1) logical
        enable_stop_criterion (1,1) logical
    end

    properties (Access = private)
        InitialStates (1,1) struct = ParameterCreator.createDefaultStruct(ParameterCreator.subsystems_option_states, struct([]))
        DelayValues (1,1) struct = ParameterCreator.createDefaultStruct(ParameterCreator.subsystems_option_delay, 0)
        InitialDelayOutputs (1,1) struct = ParameterCreator.createDefaultStruct(ParameterCreator.subsystems_option_delay, struct([]))
        models_cells (1,1) struct = ParameterCreator.createDefaultStruct(ParameterCreator.all_subsystems, cell(1,0))
    end

    methods (Access = public)
        function obj = ParameterCreator(InitialPlantStates, ...
                                        NameValueArgs)

            arguments
                InitialPlantStates (1,1) struct {mustBeNumericStructure}
                NameValueArgs.sensors_sample_time_parameter__s (1,2) double {mustBeValidSampleTimeParameter} = [0, 0]
                NameValueArgs.actuators_sample_time_parameter__s (1,2) double {mustBeValidSampleTimeParameter} = [0, 0]
                NameValueArgs.gnc_algorithms_sample_time_parameter__s (1,2) double {mustBeValidSampleTimeParameter} = [0, 0]
                NameValueArgs.simulation_duration__s (1,1) double {mustBePositive} = 10
                NameValueArgs.simulation_mode (1,1) string {mustBeMember(NameValueArgs.simulation_mode, ["normal", "accelerator", "rapid-accelerator"])} = "normal"
                NameValueArgs.enable_pacing (1,1) logical = false
                NameValueArgs.pacing_rate (1,1) double {mustBePositive, mustBeFinite} = 1
                NameValueArgs.enable_send_sim_data (1,1) logical = false
                NameValueArgs.enable_stop_criterion (1,1) logical = false 
            end

            obj.InitialPlantStates = InitialPlantStates;

            obj.SampleTimeParameters__s.Sensors = NameValueArgs.sensors_sample_time_parameter__s;
            obj.is_discrete.Sensors = ParameterCreator.isDiscreteSampleTimeParameter(obj.SampleTimeParameters__s.Sensors);        

            obj.SampleTimeParameters__s.Actuators = NameValueArgs.actuators_sample_time_parameter__s;
            obj.is_discrete.Actuators = ParameterCreator.isDiscreteSampleTimeParameter(obj.SampleTimeParameters__s.Actuators);   

            obj.SampleTimeParameters__s.GncAlgorithms = NameValueArgs.gnc_algorithms_sample_time_parameter__s;
            obj.is_discrete.GncAlgorithms = ParameterCreator.isDiscreteSampleTimeParameter(obj.SampleTimeParameters__s.GncAlgorithms);   

            obj.simulation_duration__s = NameValueArgs.simulation_duration__s;
            obj.simulation_mode = NameValueArgs.simulation_mode;
            obj.enable_pacing = NameValueArgs.enable_pacing;
            obj.pacing_rate = NameValueArgs.pacing_rate;
            obj.enable_send_sim_data = NameValueArgs.enable_send_sim_data;
            obj.enable_stop_criterion = NameValueArgs.enable_stop_criterion;

        end

        function activateDelay(obj, subsystem_name, delay_time__s, InitialOutput)

            arguments
                obj (1,1) ParameterCreator
                subsystem_name (1,1) string
                delay_time__s (1,1) double {mustBePositive, mustBeFinite}
                InitialOutput (1,1) struct {mustBeNumericStructure}
            end

            obj.mustBeValidSubsystemName(subsystem_name, obj.subsystems_option_delay);

            % If system is discrete, check and if necessary change delay time to be an integer multiple of the sample time 
            if obj.is_discrete.(subsystem_name)
                
                sample_time__s = obj.SampleTimeParameters__s.(subsystem_name)(1);
                number_delay_steps = delay_time__s / sample_time__s;

                if (number_delay_steps == ceil(number_delay_steps))
                    delay_value = number_delay_steps;
                else
                    new_number_delay_steps = ceil(number_delay_steps);
                    new_delay_time__s = new_number_delay_steps * sample_time__s;
                    warning("Delay time of discrete subsystem %s must be an integer multiple of the subsystem's sample time (%f s). " ...
                            + "Desired delay time will be rounded up to the next possible delay time:\n" ...
                            + "Desired: %f s = %f * %f s\n" ...
                            + "New: %f s = %d * %f s", ...
                            subsystem_name, sample_time__s, ...
                            delay_time__s, number_delay_steps, sample_time__s, ...
                            new_delay_time__s, new_number_delay_steps, sample_time__s);
                    
                    delay_value = new_number_delay_steps;
                end

            else
                delay_value = delay_time__s;
            end

            obj.DelayValues.(subsystem_name) = delay_value;
            obj.InitialDelayOutputs.(subsystem_name) = InitialOutput;

        end

        function activateStates(obj, subsystem_name, InitialStates)

            arguments
                obj (1,1) ParameterCreator
                subsystem_name (1,1) string
                InitialStates (1,1) struct {mustBeNumericStructure}
            end

            obj.mustBeValidSubsystemName(subsystem_name, obj.subsystems_option_states);

            obj.InitialStates.(subsystem_name) = InitialStates;

        end

        function addModel(obj, subsystem_name, model)
            arguments
                obj (1,1) ParameterCreator
                subsystem_name (1,1) string
                model (1,1) ModelBase
            end

            obj.models_cells.(subsystem_name)(end+1) = {model};

        end

        function Parameters = getParameters(obj)

            %% Create Parameters Structure
            Parameters = struct();

            %% Simulation Duration
            Parameters.Settings(1) = SimulinkModelSetting("StopTime", convertCharsToStrings(num2str(obj.simulation_duration__s)));

            %% Simulation Mode
            Parameters.Settings(2) = SimulinkModelSetting("SimulationMode", obj.simulation_mode);

            %% Pacing
            if obj.enable_pacing
                enable_pacing_string = "on";
            else
                enable_pacing_string = "off";
            end
            Parameters.Settings(3) = SimulinkModelSetting("EnablePacing", enable_pacing_string);
            Parameters.Settings(4) = SimulinkModelSetting("PacingRate", convertCharsToStrings(num2str(obj.pacing_rate)));

            %% Send Simulation Data
            Parameters.General.enable_send_sim_data = obj.enable_send_sim_data;

            %% Stop Criterion
            Parameters.General.enable_stop_criterion = obj.enable_stop_criterion;

            %% Subsystem-Specific Parameters
            
            % Sample Times
            Parameters.General.SampleTimeParameters__s = obj.SampleTimeParameters__s;

            % States
            Parameters.General.States.Type = obj.getStatesTypes();
            Parameters.General.States.InitialStates = obj.InitialStates;
            Parameters.General.States.InitialStates.Plant = obj.InitialPlantStates;

            % Delays
            any_delay = (sum(cell2mat(struct2cell(obj.DelayValues))) > 0);
            if ~any_delay
                error("At least one of the subsystems %s must have a delay to prevent algebraic loops due to PlantFeedthrough.", ...
                        strjoin(obj.subsystems_option_delay, ", "));
            end
            Parameters.General.Delays.Type = obj.getDelayTypes();
            Parameters.General.Delays.Value = obj.DelayValues;
            Parameters.General.Delays.InitialOutputs = obj.InitialDelayOutputs;

            %% Model-Specific Parameters
            for subsystem = obj.all_subsystems
                
                % check if there are models for the subsystem
                if isempty(obj.models_cells.(subsystem))
                    % add empty structure for subsystem
                    Parameters.(subsystem) = struct();
                    continue;
                end

                for model_cell = obj.models_cells.(subsystem)
                    model = model_cell{1};
                    % copy the parameters of the model to the Parameters structure
                    Parameters.(subsystem).(class(model)) = model.Parameters;

                    % copy the Settings of the model to the Parameters structure
                    if ~isempty(model.Settings)
                        for setting = model.Settings
                            % check if setting with that name already exists in the Settings structure
                            setting_index = find(strcmp(setting.name, [Parameters.Settings.name]), 1);
                            if ~isempty(setting_index)
                                % setting with that name already exists

                                % check if setting is one of the settings that can be combined
                                if ismember(setting.name, ["SimCustomHeaderCode", "SimUserIncludeDirs", "SimUserSources"])
                                    % combine the two values with a newline
                                    Parameters.Settings(setting_index).value ...
                                        = Parameters.Settings(setting_index).value + newline + setting.value;
                                else
                                    error("Simulink Model Parameter %s already exists and cannot be combined.", setting.name);
                                end

                            else
                                % setting with that name does not exist -> add it
                                Parameters.Settings(end+1) = setting;
                            end
                        end
                    end
                end
            end

        end

    end

    methods (Access = private, Static)
        
        function DefaultStruct = createDefaultStruct(fields, default_value)
            DefaultStruct = cell2struct(repmat({default_value}, 1, numel(fields)), fields, 2);
        end

        function is_discrete_flag = isDiscreteSampleTimeParameter(sample_time_parameter__s)
            if sample_time_parameter__s(1) > 0
                is_discrete_flag = true;
            else
                is_discrete_flag = false;
            end
        end

        function mustBeValidSubsystemName(subsystem_name, valid_subsystem_names)
            if ~ismember(subsystem_name, valid_subsystem_names)
                error("Subsystem %s must be one of the subsystems %s.", subsystem_name, strjoin(valid_subsystem_names, ", "));
            end
        end

    end

    methods (Access = private)

        function DelayTypes = getDelayTypes(obj)
            DelayTypes = struct();
            for subsystem = obj.subsystems_option_delay
                if obj.DelayValues.(subsystem) == 0                    
                    DelayTypes.(subsystem) = "none";
                else
                    if obj.is_discrete.(subsystem)
                        DelayTypes.(subsystem) = "discrete";
                    else
                        DelayTypes.(subsystem) = "continuous";
                    end
                end
            end
        end

        function StatesTypes = getStatesTypes(obj)
            StatesTypes = struct();
            for subsystem = obj.subsystems_option_states
                if isempty(obj.InitialStates.(subsystem))
                    StatesTypes.(subsystem) = "none";
                else
                    if subsystem == "Environment"
                        StatesTypes.(subsystem) = "continuous";
                    else
                        if obj.is_discrete.(subsystem)
                            StatesTypes.(subsystem) = "discrete";
                        else
                            StatesTypes.(subsystem) = "continuous";
                        end
                    end
                end
            end
        end

    end

end

