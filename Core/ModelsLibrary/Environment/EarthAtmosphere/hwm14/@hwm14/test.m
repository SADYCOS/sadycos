function test()
% Test HWM14 wind model against reference values

altitudes = [200, 250, 300, 350, 400];
dayOfYear = 150;
UTsec     = 12 * 3600;
glat      = -45;
glon      = -85;
Ap        = 80;

T = [25.027,  40.408,  47.092,  49.997,  51.259;
    -68.588, -87.560, -95.806, -99.389, -100.946];

C = zeros(2, numel(altitudes));
for i = 1:numel(altitudes)
    C(:,i) = hwm14.computeWind(dayOfYear, UTsec, altitudes(i), glat, glon, Ap);
end

tol = 0.1;
fprintf('%-10s %-12s %-12s %-12s %-12s %-6s\n', ...
    'Alt [km]', 'Merid calc', 'Merid ref', 'Zonal calc', 'Zonal ref', 'Pass');
allPass = true;
for i = 1:numel(altitudes)
    pass = all(abs(C(:,i) - T(:,i)) < tol);
    allPass = allPass && pass;
    if pass, result = 'OK'; else, result = 'FAIL'; end
    fprintf('%-10d %-12.3f %-12.3f %-12.3f %-12.3f %-6s\n', ...
        altitudes(i), C(1,i), T(1,i), C(2,i), T(2,i), result);
end

if allPass
    fprintf('\nOverall: ALL PASSED\n');
else
    fprintf('\nOverall: SOME FAILED\n');
end

figure;
plot(altitudes, C(1,:), '-o', 'LineWidth', 2, 'DisplayName', 'calculated');
hold on;
plot(altitudes, T(1,:), '-x', 'LineWidth', 2, 'DisplayName', 'reference');
ylabel('w meridional [m/s]'); xlabel('altitude [km]');
grid on; legend;

figure;
plot(altitudes, C(2,:), '-o', 'LineWidth', 2, 'DisplayName', 'calculated');
hold on;
plot(altitudes, T(2,:), '-x', 'LineWidth', 2, 'DisplayName', 'reference');
ylabel('w zonal [m/s]'); xlabel('altitude [km]');
grid on; legend;

end