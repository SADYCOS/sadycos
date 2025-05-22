clc
clear
close all

basetime = juliandate(datetime("now"));

timeVec = 1:1:365*2;
log_quat = [];
for i=timeVec
    time_current_mjd = basetime+i;
    [earth_quaternion_EI] = RotationEciToEcef.execute(time_current_mjd);
    log_quat = [log_quat,earth_quaternion_EI];
end

figure
plot(timeVec,log_quat(1,:))
hold on
plot(timeVec,log_quat(2,:))
plot(timeVec,log_quat(3,:))
plot(timeVec,log_quat(4,:))
legend('q0','q1','q2','q3')


%% Check polarity
q1 = [-0.727344058413564;0;0;0.686272992831924];
q2 = -q1;

smu.unitQuat.att.separation(q1,q2)

vec = [1,0,0]';
q1_vec = smu.unitQuat.rot.rotateVector(q1,vec);
q2_vec = smu.unitQuat.rot.rotateVector(q2,vec);

%%
figure
quiver3(0,0,0,vec(1),vec(2),vec(3),'Color','k')
hold on
quiver3(0,0,0,q1_vec(1),q1_vec(2),q1_vec(3),'Color','g')
quiver3(0,0,0,q2_vec(1),q2_vec(2),q2_vec(3),'Color','r')


axis([-1,1,-1,1,-1,1])