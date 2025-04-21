clc
clear
% close all

%% Prepare and run single sim
o = ExampleMission.DefaultConfiguration;
% o.forceRecompile;
o.run


%% Open simulink dataviewer
Simulink.sdi.view

%% Show animation
% replayPositionAndAttitude(o,1)