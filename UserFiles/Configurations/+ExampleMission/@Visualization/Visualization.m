classdef Visualization < ExampleMission.DefaultConfiguration

    methods (Static)
        
        function parameters_cells = configureParameters()

            % Get parameters from the parent class
            parameters_cells = configureParameters@ExampleMission.DefaultConfiguration();

            % Adjust parameters in the Settings array
            parameters_cells{1}.Settings(3) = SimulinkModelSetting("EnablePacing", "on");
            parameters_cells{1}.Settings(4) = SimulinkModelSetting("PacingRate", "1");

            % Adjust parameter directly in the struct
            parameters_cells{1}.General.enable_send_sim_data = true;


        end

        LogSendSimData ...
            = sendSimData(LogSendSimData, ...
                            simulation_time__s, ...
                            LogEnvironment, ...
                            LogSensors, ...
                            LogActuators, ...
                            LogPlantDynamics, ...
                            LogPlantOutput,...
                            LogGncAlgorithms, ...
                            Parameters)

    end
end