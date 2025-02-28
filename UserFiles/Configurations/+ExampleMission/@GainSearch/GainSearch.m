classdef GainSearch < ExampleMission.DefaultConfiguration

    methods (Static)
        function parameters_cells = configureParameters()
            num_Kp_values = 7;
            Kp_values = 10.^linspace(-5,1,num_Kp_values);
            Kd_values = Kp_values;
            [Kp_mesh, Kd_mesh] = meshgrid(Kp_values, Kd_values);

            num_simulations = numel(Kp_mesh);
            parameters_cells = repmat(configureParameters@ExampleMission.DefaultConfiguration(), num_simulations, 1);
            for index = 1:num_simulations
                parameters_cells{index}.GncAlgorithms.QuaternionFeedbackControl.Kp = Kp_mesh(index);
                parameters_cells{index}.GncAlgorithms.QuaternionFeedbackControl.Kd = Kd_mesh(index);
            end

        end

        function BusesInfo = configureBuses(parameters_cells)

            num_simulations = numel(parameters_cells);
            BusesInfo = repmat(struct('buses_list',{},'BusTemplates',{}), 1, num_simulations);

            for index = 1:num_simulations
                BusesInfo(index) = configureBuses@ExampleMission.DefaultConfiguration(parameters_cells(index));                
            end

        end

        function simulation_inputs = configureSimulationInputs(parameters_cells, BusesInfo)

            num_simulations = numel(parameters_cells);
            simulation_inputs(num_simulations) = Simulink.SimulationInput;

            for index = 1:num_simulations
                simulation_inputs(index) = configureSimulationInputs@ExampleMission.DefaultConfiguration(parameters_cells(index), BusesInfo(index));
                simulation_inputs(index) = simulation_inputs(index).setVariable('Kp_log', log10(parameters_cells{index}.GncAlgorithms.QuaternionFeedbackControl.Kp));
                simulation_inputs(index) = simulation_inputs(index).setVariable('Kd_log', log10(parameters_cells{index}.GncAlgorithms.QuaternionFeedbackControl.Kd));
            end

        end
    end

    methods (Access = public)
        function fig = plotRmsError(obj)
            num_simulations = numel(obj.parameters_cells);
            rms_error = inf(num_simulations, 1);
            kp = nan(size(rms_error));
            kd = kp;
            for index = 1:num_simulations
                error_quaternion = obj.simulation_outputs(index).logsout{6}.Values.error_quaternion_RB;
                [~, angles] = smu.unitQuat.rot.toAxisAngle((sign(error_quaternion.Data(:,1)) .* error_quaternion.Data)');
                duration = error_quaternion.Time(end) - error_quaternion.Time(1);
                rms_error(index) = sqrt(trapz(error_quaternion.Time, angles'.^2) / duration);

                kp(index) = obj.parameters_cells{index}.GncAlgorithms.QuaternionFeedbackControl.Kp;
                kd(index) = obj.parameters_cells{index}.GncAlgorithms.QuaternionFeedbackControl.Kd;
            end
            fig = figure;
            scatter(kp, kd, [], rms_error, 'filled');
            cb = colorbar;
            xlabel('Proportional Gain');
            ylabel('Derivative Gain');
            ylabel(cb, 'RMS Angle Error in rad^2 s');
            yscale('log');
            xscale('log');
            title('RMS Angle Error During Gain Search');
        end
    end
end