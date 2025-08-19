function [rw_angular_velocities_derivative__rad_per_s2, ...
            motor_torques__N_m, ...
            reaction_torque_B__N_m, ...
            gyroscopic_torque_B__N_m] ...
            = execute(motor_torque_commands__Nm, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        rw_angular_velocities__rad_per_s, ...
                        ParametersGenericReactionWheels)
% execute - Calculate the derivatives of the reaction wheel angular velocities and the reaction and gyroscopic torques
%
%   [rw_angular_velocities_derivative__rad_per_s2, ...
%       motor_torques__N_m, ...
%       reaction_torque_B__N_m, ...
%       gyroscopic_torque_B__N_m] ...
%       = execute(motor_torque_commands__Nm, ...
%                 angular_velocity_BI_B__rad_per_s, ...
%                 rw_angular_velocities__rad_per_s, ...
%                 ParametersGenericReactionWheels)
%
%   Inputs:
%   motor_torque_commands__Nm: Motor torque commands in N m
%   angular_velocity_BI_B__rad_per_s: Angular velocity in the body frame in rad per s
%   rw_angular_velocities__rad_per_s: Angular velocities of the reaction wheels in rad per s
%   ParametersGenericReactionWheels: Parameters of the GenericReactionWheels model
%
%   Outputs:
%   rw_angular_velocities_derivative__rad_per_s2: Derivatives of the reaction wheel angular velocities in rad per s^2
%   motor_torques__N_m: Actual motor torques after limiting in N m
%   reaction_torque_B__N_m: Reaction torque in the body frame in N m
%   gyroscopic_torque_B__N_m: Gyroscopic torque in the body frame in N m
%
%% References
% [1] W. Fichter and R. T. Geshnizjani, Principles of Spacecraft Control: Concepts and Theory for Practical Applications. Cham: Springer International Publishing, 2023. doi: 10.1007/978-3-031-04780-0.

%% Abreviations
% Parameters
inertias = ParametersGenericReactionWheels.inertias__kg_m2;
spin_directions = ParametersGenericReactionWheels.spin_directions_B;
friction_coefficients = ParametersGenericReactionWheels.friction_coefficients__N_m_s_per_rad;
maximum_torques__N_m = ParametersGenericReactionWheels.maximum_torques__N_m;

% States
omega = angular_velocity_BI_B__rad_per_s;
w = rw_angular_velocities__rad_per_s;
h_w = spin_directions * (inertias .* w);

%% Limit Torques
motor_torques__N_m = max(-maximum_torques__N_m, min(motor_torque_commands__Nm, maximum_torques__N_m));

%% Derivatives
% adapted from [1]
h_w_dot = - friction_coefficients .* w + spin_directions * motor_torques__N_m; % term due to omega_dot is neglected

%% Output
rw_angular_velocities_derivative__rad_per_s2 = h_w_dot ./ inertias;
gyroscopic_torque_B__N_m = - cross(omega, h_w);
reaction_torque_B__N_m = - h_w_dot;

end