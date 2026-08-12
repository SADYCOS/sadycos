function test_hwm14()
% Test function for hwm14.m

alts = [200, 225, 250, 275, 300, 325, 350, 375, 400];
C = zeros(2, length(alts));
dataPath = fullfile('Core', 'ModelsLibrary', 'Environment', 'EarthAtmosphere', 'hwm14', 'bin', 'install', 'share', 'data', 'hwm14');

for i = 1:length(alts)
    C(:,i) = hwm14ifc_mex(150, 12*3600, alts(i), -45, -85, 80, dataPath);
end

C = round(C, 3);   % Round to 3 decimal places

T = [25.027,  34.297, 40.408, 44.436, 47.092, 48.843, 49.997, 50.758, 51.259;
    -68.588, -80.022, -87.560, -92.530, -95.806, -97.965, -99.389, -100.327, -100.946];

D = C - T;   % Deviation from reference values

% --- Meridional wind ---
figure;
subplot(2,1,1);
plot(alts, C(1,:), '-o', 'LineWidth', 2, 'DisplayName', 'calculated');
hold on;
plot(alts, T(1,:), '-x', 'LineWidth', 2, 'DisplayName', 'reference');
ylabel('w meridional [m/s]')
xlabel('altitude [km]')
grid on; legend;
title('Meridional Wind');

subplot(2,1,2);
bar(alts, D(1,:));
ylabel('deviation [m/s]')
xlabel('altitude [km]')
grid on;
title('Deviation from Reference');
yline(0, 'k--');

% --- Zonal wind ---
figure;
subplot(2,1,1);
plot(alts, C(2,:), '-o', 'LineWidth', 2, 'DisplayName', 'calculated');
hold on;
plot(alts, T(2,:), '-x', 'LineWidth', 2, 'DisplayName', 'reference');
ylabel('w zonal [m/s]')
xlabel('altitude [km]')
grid on; legend;
title('Zonal Wind');

subplot(2,1,2);
bar(alts, D(2,:));
ylabel('deviation [m/s]')
xlabel('altitude [km]')
grid on;
title('Deviation from Reference');
yline(0, 'k--');

end