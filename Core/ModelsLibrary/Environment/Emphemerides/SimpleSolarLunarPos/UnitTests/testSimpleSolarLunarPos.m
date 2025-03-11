%% Script to test the Simple Solar Lunar Position model
clc
clear
close all

% Time
time0_mjd = mjuliandate(2026,1,1);

%% Loop
tvec = 1:1:365;
log_sun_position_SI_I__m = zeros(numel(tvec),3);
log_moon_position_MI_I__m = zeros(numel(tvec),3);

for i=1:numel(tvec)
    time_current_mjd = time0_mjd + tvec(i);
    [sun_position_SI_I__m,moon_position_MI_I__m] ...
                            = SimpleSolarLunarPos.execute(time_current_mjd);

    log_sun_position_SI_I__m(i,:) = sun_position_SI_I__m;
    log_moon_position_MI_I__m(i,:) = moon_position_MI_I__m;
    
end

%% Plotting
figure
ax = axes;
plot3(log_sun_position_SI_I__m(:,1), ...
    log_sun_position_SI_I__m(:,2),...
    log_sun_position_SI_I__m(:,3))
hold on
plot3(log_moon_position_MI_I__m(:,1), ...
        log_moon_position_MI_I__m(:,2),...
        log_moon_position_MI_I__m(:,3))

grid on
xlabel('x_{eci} (m)')
ylabel('y_{eci} (m)')
zlabel('z_{eci} (m)')