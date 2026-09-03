% Some interesting use cases VLEO torque computation
div = "=========================================";
disp(div);
disp("Starting aerodynamic and shading tests...");
disp(div);


% Aerodynamic model
aero.model = Sentman(1);
disp(div);
disp("Created Sentman model.");
disp(div)

T_env   = 934;  % termperature
rho     = 1e-9; % density
ao_mass = 16 * 1.6605390689252e-27;
alpha_e = 0.95;

aero.conditions = AeroConditions(rho, T_env, ao_mass, alpha_e);

fp.current_folder  = fileparts(mfilename('fullpath'));
fp.obj_file        = fullfile(fp.current_folder, ...
    "geometries/shuttlecock_15k.obj");

satellite.geometry = RotatableMeshSatellite(fp.obj_file);
satellite.verts    = satellite.geometry.get_vertices;

n_tri = satellite.geometry.get_num_triangles;

show_mesh(satellite.geometry, zeros(n_tri,1), [1;0;0])