function [gravitational_acceleration_I__m_per_s2] ...
                = execute(position_BI_I__m,...
                          position_additional_body_AI_I_m,...
                          ParametersThirdBodyGravity)
% execute - Calculate the gravitational acceleration due to an 
% additional (third) body in the inertial frame
%
% [gravitational_acceleration_I__m_per_s2] ...
%                 = execute(position_BI_I__m,...
%                           position_additional_body_AI_I_m,...
%                           ParametersThirdBodyGravity)
%   Inputs:
%   position_BI_I__m: Position of the body in inertial frame of the central body
%   position_additional_body_AI_I_m: Position of the additional body in inertial frame of the central body
%   ParametersThirdBodyGravity: Parameters of the PointMassGravity model
%
%   Outputs:
%   gravitational_acceleration_I__m_per_s2: Gravitational acceleration in the inertial frame
%
%% References
% [1] O. Montenbruck and G. Eberhard, 
% “Sun and Moon,” in Satellite orbits: models, methods, and applications, 
% Berlin : New York: Springer, 2000, pp. 69–70.

% Gravity parameter
muAddBody = ParametersThirdBodyGravity.muAddBody__m3_per_s2;

% Position additional body relative to the body
position_AB_I__m = position_additional_body_AI_I_m - position_BI_I__m;

% Gravitational acceleration due to additional (third) body 
% (spherical gravity model and correction for accelerated central body)
% adapted from [1]
gravitational_acceleration_I__m_per_s2 ...
            = muAddBody * (position_AB_I__m / norm(position_AB_I__m)^3 ...
                           - position_additional_body_AI_I_m / norm(position_additional_body_AI_I_m)^3);

end