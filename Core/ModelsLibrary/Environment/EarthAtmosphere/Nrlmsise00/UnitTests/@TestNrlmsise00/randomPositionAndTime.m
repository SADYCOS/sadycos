function randomPositionAndTime(testCase)

import matlab.unittest.constraints.IsEqualTo
import matlab.unittest.constraints.AbsoluteTolerance

n = 1e3; % number of tests

%% Limits
disp(">>> Setting limits for random values generation.");
lon_lim = [-180, 180];
lat_lim = [-90, 90];
alt_lim = [1e5, 5e5];
year_lim = [1961, 2030];
dayOfYear_lim = [1, 365];
UTseconds_lim = [0, 86400];

limits = [lon_lim; lat_lim; alt_lim; year_lim; dayOfYear_lim; UTseconds_lim];

%% Generate test values
disp(">>> Generating random position and time values.");
random_numbers = rand(6, n);

test_values = (limits(:,2) - limits(:,1)) .* random_numbers + limits(:,1);

lon = test_values(1,:);
lat = test_values(2,:);
alt = test_values(3,:);
year = round(test_values(4,:));
dayOfYear = round(test_values(5,:));
UTseconds = test_values(6,:);

%% Comparison values from matlab functions
disp(">>> Calculating atmospheric data using matlab functions.")
[this_folder, ~, ~] = fileparts(mfilename('fullpath'));
csv_file = fullfile(this_folder, "..", "..", "ExternalData", "SW-All.csv");
mat_file = aeroReadSpaceWeatherData(csv_file);
try
[f107average,f107daily,magneticIndex] = fluxSolarAndGeomagnetic(year,dayOfYear,UTseconds,mat_file);
catch ME
    delete(mat_file);
    rethrow(ME);
end
delete(mat_file);

[T, rho] = atmosnrlmsise00(alt, lat, lon, year, dayOfYear, UTseconds, f107average, f107daily, magneticIndex, ones(23,1), 'Oxygen', 'Warning');

matlab_mass_density = rho(:,6);
matlab_number_density = sum(rho(:,[1:5, 7:9]), 2);
matlab_temperature = T(:,2);

%% Testing c implementation implementation
disp(">>> Calculating atmospheric data using c implementation in Simulink.")
[x,y,z] = geodetic2ecef(wgs84Ellipsoid,lat,lon,alt);

mjd = nan(1,n);
for i = 1:n
    [month, fractional_day] = smu.time.calDatFromDoySod(year(i), dayOfYear(i), UTseconds(i));

    mjd(i) = smu.time.modifiedJulianDateFromCalDat(year(i), month, fractional_day);
end

Nrlmsise00Data = Nrlmsise00.loadProcessedSpaceWeatherData();

Parameters.position_precision__m = 1;
Parameters.Nrlmsise00Data = Nrlmsise00Data;
Parameters.switches = ones(24,1);

disp(">>>> Creating Simulink input.")
simIn = Simulink.SimulationInput("testnrlmsise00_model");
simIn = simIn.setModelParameter('StartTime', num2str(1));
simIn = simIn.setModelParameter('StopTime', num2str(n));
simIn = simIn.setVariable('Parameters', Parameters);

c_code_folder = fullfile(this_folder, "..", "..", "c_code");
wrapper_folder = fullfile(c_code_folder, "wrapper");
wrapper_header_file = fullfile(wrapper_folder, "nrlmsise00Wrapper.h");
submodule_folder = fullfile(c_code_folder, 'nrlmsise-00');
simIn = simIn.setModelParameter("SimCustomHeaderCode", """" + wrapper_header_file + """");
simIn = simIn.setModelParameter("SimUserIncludeDirs", """" + wrapper_folder + """" + newline ...
                                                        + """" + submodule_folder + """");
simIn = simIn.setModelParameter("SimUserSources", "nrlmsise00Wrapper.c" + newline ...
                                                    + "nrlmsise-00.c" + newline ...
                                                    + "nrlmsise-00_data.c");

simIn = simIn.setVariable('Parameters', Parameters);

indata = concat(Simulink.SimulationData.Dataset(timeseries([x;y;z], 1:n, "Name", "position_BI_I__m")), ...
                Simulink.SimulationData.Dataset(timeseries(mjd, 1:n, "Name", "modified_julian_date")));
simIn = setExternalInput(simIn,indata);

disp(">>>> Running Simulink simulation.")
out = sim(simIn);

cimpl_mass_density = out.yout{1}.Values.Data;
cimpl_number_density = out.yout{2}.Values.Data;
cimpl_temperature = out.yout{3}.Values.Data;

%% Comparison
disp("Comparing results.")
max_mass_density_relative_error = max(abs((cimpl_mass_density - matlab_mass_density)./matlab_mass_density));
max_number_density_relative_error = max(abs((cimpl_number_density - matlab_number_density)./matlab_number_density));
max_temperature_relative_error = max(abs((cimpl_temperature - matlab_temperature)./matlab_temperature));

tolerance = 1e-3;

testCase.verifyThat(max_mass_density_relative_error, IsEqualTo(0, "Within", AbsoluteTolerance(tolerance)), sprintf("Maximum relative error in mass density exceeds %.4g.", tolerance));
testCase.verifyThat(max_number_density_relative_error, IsEqualTo(0, "Within", AbsoluteTolerance(tolerance)), sprintf("Maximum relative error in number density exceeds %.4g.", tolerance));
testCase.verifyThat(max_temperature_relative_error, IsEqualTo(0, "Within", AbsoluteTolerance(tolerance)), sprintf("Maximum relative error in temperature exceeds %.4g.", tolerance));

end