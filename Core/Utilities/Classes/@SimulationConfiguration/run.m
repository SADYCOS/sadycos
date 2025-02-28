function run(obj, NameValueArgs)

arguments
    obj (1,1) SimulationConfiguration
    NameValueArgs.use_parsim (1,1) logical = false
end

%% Create Simulink Interface Files
SimulationConfiguration.codeWrapper(@() obj.createSimulinkInterfaceFiles(), "Generating Simulink Interface Files");

%% Start Simulations
if NameValueArgs.use_parsim
    the_function = @() parsim(obj.simulation_inputs, "ShowSimulationManager","on", "UseFastRestart", "on");
else
    the_function = @() sim(obj.simulation_inputs);
end

obj.simulation_outputs = SimulationConfiguration.codeWrapper(the_function, "Running Simulations");

end