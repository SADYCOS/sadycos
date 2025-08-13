function saveSimulationResults(obj, file_path)
        % If no path given -> set standard
        if nargin < 2 || isempty(file_path)
            timestamp = datestr(now,'yyyymmdd_HHMMSS');
            file_path = fullfile(pwd, ['SimulationResults_' timestamp '.mat']);
        end

        % safe the simulation output object
        simOut = o.simulation_outputs;
        save(file_path, 'simOut');

        fprintf('SADYCOS >>> Simulation results saved to %s\n', file_path);
    end