function test()

% Method of NewVleoAerodynamics class to test functionality of the NewVleoAerodynamics model
% The Method runs a test case to compute aerodynamic forces and torques based on given inputs
% and compares the results with expected values.

%% Create model
temperature_ratio_method = 1;
model = NewVleoAerodynamics(temperature_ratio_method);

%% Prepare inputs (Values taken from "C:\Users\st173938\Desktop\sadycos\Core\
% external_namespaces\new-vleo-aerodynamics-core\+new_vleo_aerodynamics_core\test_sentman.m")
attitude_quaternion_BI = [1; 0; 0; 0];      % neutral attitude 
velocity_I_I__m_per_s = [7800; 0; 0];      
wind_velocity_I_I__m_per_s = [0; 0; 0];     % no wind
surface_temperature__K = 300;
rho = 1.2482e-11;
atomic_oxygen_mass__kg = 16 * 1.6605390689252e-27;
number_density = rho / atomic_oxygen_mass__kg;
atmosphere_temperature__K = 934;
alpha_e = 0.9;

%% Call execute method to compute aerodynamic force and torque
[force_B__N, torque_B__Nm] = ...
    NewVleoAerodynamics.execute( ...
        attitude_quaternion_BI, ...
        velocity_I_I__m_per_s, ...
        wind_velocity_I_I__m_per_s, ...
        surface_temperature__K, ...
        model.Parameters, ...
        rho, ...
        number_density, ...
        atmosphere_temperature__K, ...
        alpha_e);


% Display results
format long e
disp('Aerodynamic force (N):');
disp(force_B__N);
disp('Aerodynamic torque (Nm):');
disp(torque_B__Nm);


%% Results of the model's own test skript test_sentman.m 
% "Core\external_namespaces\new-vleo-aerodynamics-core\+new_vleo_aerodynamics_core\test_sentman.m"
total_force_expected= [-0.010242516; -1.6674179e-05; 1.6171982e-05];
total_torque_expected = [-9.4590789e-05; 0.0041177799; 0.019368965];

% Display expected results
disp('Expected aerodynmic force (N):');
disp(total_force_expected);
disp('Expected aerodynmic torque (Nm):');
disp(total_torque_expected);

%% Calculate difference between calculated and expected
diff_force = force_B__N - total_force_expected;
diff_torque = torque_B__Nm - total_torque_expected;

disp('Difference calculated minus expected force:');
disp(diff_force);
disp('Difference calculated minus expected torque:');
disp(diff_torque);

end