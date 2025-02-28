function gravitational_acceleration_I__m_per_s2 ...
            = execute(position_BI_I__m, ...
                        attitude_quaternion_EI, ...
                        parametersSphericalHarmonicsGeopotential)
% execute - Calculate gravitational acceleration in inertial frame using
% spherical harmonics geopotential model
%
%   gravitational_acceleration_I__m_per_s2 ...
%       = execute(position_BI_I__m, ...
%                   attitude_quaternion_EI, ...
%                   parametersSphericalHarmonicsGeopotential)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_EI: 4x1 quaternion of attitude from inertial to
%       Earth frame
%   parametersSphericalHarmonicsGeopotential: Structure containing
%       parameters for spherical harmonics geopotential model
%
%   Outputs:
%   gravitational_acceleration_I__m_per_s2: 3x1 vector of gravitational
%       acceleration in inertial frame
%
%% References
% [1] O. Montenbruck and G. Eberhard, 
% “Geopotential,” in Satellite orbits: models, methods, and applications, 
% Berlin : New York: Springer, 2000, pp. 56–68.

%% Abbreviations
R = parametersSphericalHarmonicsGeopotential.reference_radius__m;
GM = parametersSphericalHarmonicsGeopotential.reference_earth_gravity_constant__m3_per_s2;
g = GM/R^2;

c_coeffs = parametersSphericalHarmonicsGeopotential.DenormCoeffs.C;
s_coeffs = parametersSphericalHarmonicsGeopotential.DenormCoeffs.S;

n_max = size(c_coeffs,1) -1;

q_EI = attitude_quaternion_EI;
p_I = position_BI_I__m;

%% Extraxt and process position data
p_E = smu.unitQuat.att.transformVector(q_EI, p_I);
x = p_E(1);
y = p_E(2);
z = p_E(3);
r = norm(p_E);


%% Recursive calculation of gravitational acceleration vector
% Algorithm adapted from [1]

% Initialize matrices for V and W
% These contain the values for V and W for all orders m of the previous two
% degrees n --> two rows
V = zeros(2, n_max + 2);
W = V;
V(2,1) = R/r;

% Initialize acceleration vector to zero
a_E__m_per_s2 = zeros(3,1);

% Loop over all degrees n
for n = 0:n_max

    % Loop over all relevant orders m to calculate new values for V and W
    % for degree n+1.
    % All coefficients are zero for m > n. Therefore, only values up to n
    % are considered for the order m.

    % Start with the diagonal recursion. Then, continue with the vertical
    % recursions in a loop over all remaining orders m.
    for m = n:-1:0
        
        if m == n
            [V(2, m+2), W(2, m+2)] ...
                = recursionDiagonal(V(2, m+1), ...
                                    W(2, m+1), ...
                                    n+1, R, r, x, y);
        end

        [V(2, m+1), V(1, m+1), W(2, m+1), W(2, m+1)] ...
            = recursionVertical(V(2, m+1), V(1, m+1), ...
                                W(2, m+1), W(2, m+1), ...
                                n+1, m, R, r, z);
    end

    % Calculate accelerations from new row of values for V and W
    
    for m = 0:n
        increment = zeros(3,1);
        c = c_coeffs(n+1, m+1);
        s = s_coeffs(n+1, m+1);
        V_middle = V(2, m+1);
        V_right = V(2, m+2);
        W_middle = W(2, m+1);
        W_right = W(2, m+2);

        if m == 0
            increment(1) = - c * V_right;
            increment(2) = - c * W_right;
        else
            V_left = V(2, m);
            W_left = W(2, m);

            factor = (n-m+2) * (n-m+1);

            increment(1) = - c * V_right - s * W_right ...
                            + factor *(c * V_left + s * W_left);
            increment(2) = - c * W_right + s * V_right ...
                            + factor * (- c * W_left + s * V_left);

            increment = 1/2 * increment;
        end
        increment(3) = (n-m+1) * (- c * V_middle - s * W_middle);
        increment = g * increment;

        a_E__m_per_s2 = a_E__m_per_s2 + increment;
    end
end

%% Transform gravitational acceleration vector into inertial frame
gravitational_acceleration_I__m_per_s2 = smu.unitQuat.att.transformVector(smu.unitQuat.invert(q_EI), a_E__m_per_s2);

end

function [V, W] = recursionDiagonal(V_diag, W_diag, n, R, r, x, y)
    factor = (2*n - 1) * R/r^2;
    V = factor * (x * V_diag - y * W_diag);
    W = factor * (x * W_diag + y * V_diag);
end

function [V, V_vert1, W, W_vert1] = recursionVertical(V_vert1, V_vert2, W_vert1, W_vert2, n, m, R, r, z)
    factor1 = R/r^2 / (n-m);
    factor2 = (2*n - 1) * z;
    factor3 = (n+m-1) * R;
    V = factor1 * (factor2 * V_vert1 - factor3 * V_vert2);
    if m == 0
        W = 0;
    else
        W = factor1 * (factor2 * W_vert1 - factor3 * W_vert2);
    end
end