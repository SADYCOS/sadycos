function [gravitational_acceleration_I__m_per_s2, ...
          gravitational_hessian_I__1_per_s2] ...
                = execute(position_BI_I__m, ...
                            attitude_quaternion_EI, ...
                            parametersSphericalHarmonicsGeopotential,...
                            calcHessian)
% execute - Calculate gravitational and hessian acceleration in inertial
% frame using spherical harmonics geopotential model
%
%      [gravitational_acceleration_I__m_per_s2, ...
%       gravitational_hessian_I__1_per_s2] ...
%                 = execute(position_BI_I__m, ...
%                             attitude_quaternion_EI, ...
%                             parametersSphericalHarmonicsGeopotential,...
%                             calcHessian)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_EI: 4x1 quaternion of attitude from inertial to
%       Earth frame
%   parametersSphericalHarmonicsGeopotential: Structure containing
%       parameters for spherical harmonics geopotential model
%   calcHessian: true/false selection of whether the Hessian should be calculated
%
%   Outputs:
%   gravitational_acceleration_I__m_per_s2: 3x1 vector of gravitational
%       acceleration in inertial frame
%
arguments
    position_BI_I__m (3,1) {mustBeNumeric, mustBeReal}
    attitude_quaternion_EI (4,1) {mustBeNumeric, mustBeReal, smu.argumentValidation.mustBeUnitQuaternion}
    parametersSphericalHarmonicsGeopotential 
    calcHessian (1,1) {boolean}
end
%% References
% [1] O. Montenbruck and G. Eberhard, 
% “Geopotential,” in Satellite orbits: models, methods, and applications, 
% Berlin : New York: Springer, 2000, pp. 56–68.

%% Initialize outputs 
gravitational_acceleration_I__m_per_s2 = nan(3,1);
gravitational_hessian_I__1_per_s2 = nan(3,3);

%% Abbreviations
R = parametersSphericalHarmonicsGeopotential.reference_radius__m;
GM = parametersSphericalHarmonicsGeopotential.reference_earth_gravity_constant__m3_per_s2;
g = GM/R^2;

c_coeffs = parametersSphericalHarmonicsGeopotential.DenormCoeffs.C;
s_coeffs = parametersSphericalHarmonicsGeopotential.DenormCoeffs.S;

n_max = size(c_coeffs,1) - 1;

q_EI = attitude_quaternion_EI;

%% Extraxt and process position data
p_E = smu.unitQuat.att.transformVector(q_EI, position_BI_I__m);
x = p_E(1);
y = p_E(2);
z = p_E(3);
r = norm(p_E);


%% Recursive calculation of Legendre polynomial coefficients
% Algorithm adapted from [1]

% Initialize matrices for V and W
% These contain the values for V and W for all orders m of the previous two
% degrees n --> two rows
V = zeros(n_max + 2, n_max + 2);
W = V;
V(1,1) = R/r;

% Initialize acceleration vector to zero
a_E__m_per_s2 = zeros(3,1);

% Initialize hessian matrix to zero
H_E__1_per_s2 = zeros(3,3);

% Loop over all degrees n and calculate coefficients
for n = 0:n_max+1

    % Loop over all relevant orders m to calculate new values for V and W
    % for degree n+1.
    % All coefficients are zero for m > n. Therefore, only values up to n
    % are considered for the order m.

    % Start with the diagonal recursion. Then, continue with the vertical
    % recursions in a loop over all remaining orders m.
    for m = 0:1:n
        
        if m == n
            [V(n+2, m+2), W(n+2, m+2)] ...
                = recursionDiagonal(V(n+1, m+1), ...
                                    W(n+1, m+1), ...
                                    n+1, R, r, x, y);
        end

        if n == 0
         [V(n+2, m+1), W(n+2, m+1)] ...
            = recursionVertical(V(n+1, m+1), 0, ...
                                W(n+1, m+1), 0, ...
                                n+1, m, R, r, z);         
        else
        [V(n+2, m+1), W(n+2, m+1)] ...
            = recursionVertical(V(n+1, m+1), V(n, m+1), ...
                                W(n+1, m+1), W(n, m+1), ...
                                n+1, m, R, r, z);
        end
    end
end

%% Calculate the gravity acceleration
for n = 0:n_max
    for m = 0:n
        increment = zeros(3,1);
        c = c_coeffs(n+1, m+1);
        s = s_coeffs(n+1, m+1);

        V_middle = V(n+2, m+1);
        V_right = V(n+2, m+2);
        W_middle = W(n+2, m+1);
        W_right = W(n+2, m+2);

        if m == 0
            increment(1) = - c * V_right;
            increment(2) = - c * W_right;
        else
            V_left = V(n+2, m);
            W_left = W(n+2, m);

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

%% Calculate the hessian of the gravitation potential
if calcHessian
    for n = 0:n_max
        for m = 0:n
            H_incr = zeros(3,3);
            c = c_coeffs(n+1, m+1);
            s = s_coeffs(n+1, m+1);
    
            idx_n = n+3;
    
            V_m   = V(idx_n,m+1);
            V_r   = V(idx_n,m+2);
            V_rr  = V(idx_n,m+3);        
            W_m   = W(idx_n,m+1);
            W_r   = W(idx_n,m+2);
            W_rr  = W(idx_n,m+3);
            
            if m == 0
                H_incr(1,1) = 1/2* (c*V_rr - (n+2)*(n+1)*c*V_m);
                H_incr(2,1) = 1/2*(c*W_rr);            
                H_incr(3,1) = (n+1)*(c*V_r);
                H_incr(3,2) = (n+1)*(c*W_r);
    
            elseif m == 1
                H_incr(1,1) = 1/4* (c*V_rr + s*W_rr ...
                                    + (n+1)*n* (-3*c*V_m - s*W_m));
                H_incr(2,1) = 1/4* (c*W_rr - s*V_rr...
                                    + (n+1)*n* (-c*W_m - s*V_m));
    
            else
                V_ll  = V(idx_n,m-1);
                V_l   = V(idx_n,m);
                W_ll  = W(idx_n,m-1);
                W_l   = W(idx_n,m);
    
                H_incr(1,1) = 1/4* (c*V_rr+s*W_rr ...
                                    + 2*(n-m+2)*(n-m+1) * (-c*V_m - s*W_m)...
                                    + (n-m+4)*(n-m+3)*(n-m+2)*(n-m+1) * (c*V_ll+s*W_ll));
                H_incr(2,1) = 1/4* (c*W_rr-s*V_rr...
                                    + (n-m+4)*(n-m+3)*(n-m+2)*(n-m+1) * (-c*W_ll + s*V_ll));
                H_incr(3,1) = (n-m+1)/2 * (c*V_r+s*W_r) ...
                              + (n-m+3)*(n-m+2)*(n-m+1)/2 * (-c*V_l - s*W_l);
                H_incr(3,2) = (n-m+1)/2 * (c*W_r-s*V_r) ...
                              + (n-m+3)*(n-m+2)*(n-m+1)/2 * (c*W_l - s*V_l);
    
            end
    
            H_incr(3,3) = (n-m+2)*(n-m+1)*(c*V_m + s*W_m);
    
            H_incr = g/R * H_incr;
    
            % use symmetry
            H_incr(1,2) = H_incr(2,1);
            H_incr(1,3) = H_incr(3,1);
            H_incr(2,3) = H_incr(3,2);
            
            % sum of diagonal elements is zero
            H_incr(2,2) = - H_incr(1,1) - H_incr(3,3);
    
            H_E__1_per_s2 = H_E__1_per_s2 + H_incr;
        end
    end
end

%% Transform gravitational acceleration vector into inertial frame
gravitational_acceleration_I__m_per_s2 = smu.unitQuat.att.transformVector(smu.unitQuat.invert(q_EI), a_E__m_per_s2);
dcm_IE = smu.unitQuat.att.toDcm(smu.unitQuat.invert(q_EI));
gravitational_hessian_I__1_per_s2 = dcm_IE*H_E__1_per_s2*dcm_IE';

end

function [V, W] = recursionDiagonal(V_diag, W_diag, n, R, r, x, y)
    factor = (2*n - 1) * R/r^2;
    V = factor * (x * V_diag - y * W_diag);
    W = factor * (x * W_diag + y * V_diag);
end

function [V, W] = recursionVertical(V_vert1, V_vert2, W_vert1, W_vert2, n, m, R, r, z)
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