function saveSimulationResults(obj, file_path)
        % If no path given -> set standard
        if nargin < 2 || isempty(file_path)
            timestamp = datetime("now", "Format", "yyyyMMdd_HHmmss");
            folder= "C:\Users\fn103921\Desktop\Birkle\Simulation_Results\";
                if ~exist(folder, 'dir')
                   mkdir(folder);
                end
            file_path = folder + string(timestamp) + ".mat";
        end

        % save the simulation output object
        simOut = obj.simulation_outputs;
        save(file_path, 'simOut');

        fprintf('SADYCOS >>> Simulation results saved to %s\n', file_path);
    end