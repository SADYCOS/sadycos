function simulation_inputs = createSimulationInputs(parameters_cells, BusesInfo)

arguments
    parameters_cells (:,1) cell
    BusesInfo (:,1) struct
end

num_simulations = numel(parameters_cells);
    
%% Create Simulation Input Object
simulation_inputs = repmat(Simulink.SimulationInput('sadycos'), num_simulations, 1);

for index = 1:num_simulations
    %% Get Data for Individual Simulation
    TheParameters = parameters_cells{index};
    TheBusesInfo = BusesInfo(index);
    the_simulation_input = simulation_inputs(index);

    %% Set Simulink Model Parameters from Settings structure
    for simulink_model_parameter = TheParameters.Settings
        the_simulation_input = the_simulation_input.setModelParameter(simulink_model_parameter.name, simulink_model_parameter.value);
    end
    % remove Settings from Parameters, so the Parameters structure can be used within Simulink
    TheParameters = rmfield(TheParameters, 'Settings');

    %% Set Variables
    % Parameters
    the_simulation_input = the_simulation_input.setVariable('Parameters', TheParameters);

    % BusTemplates
    the_simulation_input = the_simulation_input.setVariable('BusTemplates', TheBusesInfo.BusTemplates);

    % Buses
    for i = 1:length(TheBusesInfo.buses_list)
        the_simulation_input = setVariable(the_simulation_input, TheBusesInfo.buses_list(i).Name, TheBusesInfo.buses_list(i).Bus);
    end

    %% Set Simulation Input
    simulation_inputs(index) = the_simulation_input;
end

end