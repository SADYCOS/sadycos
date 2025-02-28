function [position_derivative_BI_I__m_per_s, ...
            velocity_derivative_BI_I__m_per_s2, ...
            attitude_quaternion_derivative__1_per_s, ...
            angular_velocity_derivative_BI_B__rad_per_s2] ...
            = execute(net_force_I__N, ...
                        net_torque_B__N_m, ...
                        velocity_BI_I__m_per_s, ...
                        attitude_quaternion_BI, ...
                        angular_velocity_BI_B__rad_per_s, ...
                        ParametersRigidBodyMechanics)
% execute - Calculate the derivatives of the position, velocity, attitude quaternion, and angular velocity
%
%   [position_derivative_BI_I__m_per_s, ...
%       velocity_derivative_BI_I__m_per_s2, ...
%       attitude_quaternion_derivative__1_per_s, ...
%       angular_velocity_derivative_BI_B__rad_per_s2] ...
%       = execute(net_force_I__N, ...
%                   net_torque_B__N_m, ...
%                   velocity_BI_I__m_per_s, ...
%                   attitude_quaternion_BI, ...
%                   angular_velocity_BI_B__rad_per_s, ...
%                   ParametersRigidBodyMechanics)
%
%   Inputs:
%   net_force_I__N: Net force in the inertial frame
%   net_torque_B__N_m: Net torque in the body frame
%   velocity_BI_I__m_per_s: Velocity in the inertial frame
%   attitude_quaternion_BI: Attitude quaternion from the body frame to the inertial frame
%   angular_velocity_BI_B__rad_per_s: Angular velocity in the body frame
%   ParametersRigidBodyMechanics: Parameters of the RigidBodyMechanics model
%
%   Outputs:
%   position_derivative_BI_I__m_per_s: Derivative of the position in the inertial frame
%   velocity_derivative_BI_I__m_per_s2: Derivative of the velocity in the inertial frame
%   attitude_quaternion_derivative__1_per_s: Derivative of the attitude quaternion
%   angular_velocity_derivative_BI_B__rad_per_s2: Derivative of the angular velocity
%
                   
%% Abbreviations
% Parameters
mass = ParametersRigidBodyMechanics.mass__kg;
inertia = ParametersRigidBodyMechanics.inertia_B_B__kg_m2;

% States
v = velocity_BI_I__m_per_s;
q = attitude_quaternion_BI;
omega = angular_velocity_BI_B__rad_per_s;

%% Derivatives
% Translation
r_dot = v;
v_dot = net_force_I__N / mass;

% Rotation
q_dot = 1/2 * smu.unitQuat.qpml(q) * [0; omega];
omega_dot = inertia \ (net_torque_B__N_m - cross(omega, inertia * omega));

%% Output
position_derivative_BI_I__m_per_s = r_dot;
velocity_derivative_BI_I__m_per_s2 = v_dot;
attitude_quaternion_derivative__1_per_s = q_dot;
angular_velocity_derivative_BI_B__rad_per_s2 = omega_dot;

end