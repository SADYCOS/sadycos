function atmospheric_velocity ...
            = execute()

% execute - Calculate aerodynamic velocity using
% hwm14 model and atmospheric corotation

cd(fullfile("Core","ModelsLibrary","Environment","EarthAtmosphere", ...
"hwm14","@AtmosphericVelocity","externalData"));

w = hwm14(150, 12*3600, 400, -45, -85, 80);

atmospheric_velocity = w + corotation;

end