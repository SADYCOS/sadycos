function magnetic_field_I__T = execute(position_BI_I__m, attitude_quaternion_EI, current_modified_julian_date, ParametersIgrf)
% execute - Calculate the magnetic field vector in the inertial frame
% using the International Geomagnetic Reference Field (IGRF) model
%
%   magnetic_field_I__T = execute(position_BI_I__m, attitude_quaternion_EI, current_modified_julian_date, ParametersIgrf)
%
%   Inputs:
%   position_BI_I__m: 3x1 vector of position in inertial frame
%   attitude_quaternion_EI: 4x1 quaternion of attitude from inertial to
%       Earth frame
%   current_modified_julian_date: Current modified julian date
%   ParametersIgrf: Structure containing parameters for IGRF model
%
%   Outputs:
%   magnetic_field_I__T: 3x1 vector of magnetic field in inertial frame
%
%% References:
% [1] M. Plett, "Magnetic Field Models," in Spacecraft Attitude Determination and Control, Reprint., J. R. Wertz, Ed., in Astrophysics and space science library, no. 73. , Dordrecht: Kluver Acad. Publ, 1978, pp. 779–786.

%% Abbreviations
a = ParametersIgrf.reference_radius__m;
coeffs = ParametersIgrf.gaussNormCoeffs;

q_EI = attitude_quaternion_EI;
p_I = position_BI_I__m;

%% Convert time and date
[current_year, ~, ~] = smu.time.calDatFromModifiedJulianDate(current_modified_julian_date);

%% Calculate g and h coefficients
epochs = [coeffs.epoch];
n_epochs = length(epochs);

% find index of current epoch
current_epoch_idx = 1;
% assumes epochs in ascending order and at least two epochs
for i = 1:(n_epochs - 1)
    if (epochs(i+1) > current_year) || (i == (n_epochs - 1))
        current_epoch_idx = i;
        break;
    end
end

% linear interpolation
current_epoch = epochs(current_epoch_idx);

current_g_coeffs = coeffs(current_epoch_idx).g__nT;
next_g_coeffs = coeffs(current_epoch_idx+1).g__nT;
current_h_coeffs = coeffs(current_epoch_idx).h__nT;
next_h_coeffs = coeffs(current_epoch_idx+1).h__nT;

g_coeffs__T = 10^-9 * (current_g_coeffs + (current_year - current_epoch) / 5 * (next_g_coeffs - current_g_coeffs));
h_coeffs__T = 10^-9 * (current_h_coeffs + (current_year - current_epoch) / 5 * (next_h_coeffs - current_h_coeffs));

% Get maximum degree and order from size of coefficient matrix
n_max = size(current_g_coeffs, 1);
m_max = n_max;

%% Extraxt and process position data
p_E = smu.unitQuat.att.transformVector(q_EI, p_I);
[lon, lat, r] = cart2sph(p_E(1), p_E(2), p_E(3));

theta = pi/2 - lat;
phi = lon;

sintheta = sin(theta);
costheta = cos(theta);
sinphi = sin(phi);
cosphi = cos(phi);

%% Recursive calculation of the magnetic field vector
% Algorithm adapted from [1]
% That algorithm has a singularity at the poles (theta = 0 or theta = pi).
% Since all P(n,m) for m > 0 are a multiples of sin(theta), the numerical
% problems in the proximity of the poles can be avoided if the following
% variable Q is used for the recursion instead.
% Definition of Q:
%   m = 0: Q = P
%   m > 0: Q = P / sin(theta)

% Factors independent of m and P are precalculated
n_vals = 1:n_max;
B_theta_factors = - (a/r).^(n_vals+2);
B_phi_factors = B_theta_factors; 
B_r_factors = - B_theta_factors .* (n_vals + 1);

B_factors = [B_r_factors; B_theta_factors; B_phi_factors];

% Initialize magnetic field vector in local Up-South-East frame
B_USE__T = zeros(3,1);

% Initialize values for recursion loop over orders m
sinmphi = 0;
cosmphi = 1;
Q_diag = 1;
dP_diag = 0;

% Loop over for all orders m
for m = 0:m_max

    % For the zeroth order (m=0), the first relevant degree is n=1.
    % Therefore, an update of the magnetic field vector due to an entry on
    % the main diagonal only needs to be calculated for m>0.
    if m>0
        % Update sinmphi and cosmphi recursively to avoid unnecessary calls
        % to sin() and cos().
        sinmphi_tmp = sinmphi;
        sinmphi = cosphi * sinmphi + sinphi * cosmphi;
        cosmphi = - sinphi * sinmphi_tmp + cosphi * cosmphi;
        
        % The gauss coefficients g and h are zero for n < m resulting in
        % the respective summands for the magnetic field vector to be zero
        % as well. 
        % Therefore, only degrees n with n >= m need to be considered.
        
        % First relevant degree: n = m
        n = m;
        % calculate P and dP on main diagonal recursively from previous
        % entries on main diagonal
        [P, Q_diag, dP_diag] ...
            = recursionDiagonal(m, ...
                                Q_diag, ...
                                dP_diag, ...
                                sintheta, ...
                                costheta);
    
        B_USE__T = updateB(B_USE__T, ...
                        B_factors(:,n), ...
                        g_coeffs__T(n,m+1), ...
                        h_coeffs__T(n,m+1), ...
                        m, ...
                        sinmphi, ...
                        cosmphi, ...
                        P, ...
                        Q_diag, ...
                        dP_diag);
    end

    % Initialize values for recursion loop over degrees n
    Q_vert1 = Q_diag;
    Q_vert2 = 0;
    dP_vert1 = dP_diag;
    dP_vert2 = 0;

    % Loop over all remaining degrees n of the current order m
    for n = (m+1):n_max
        % calculate P and dP recursively from their previous two entries in
        % vertical direction (i.e. along n), respectively
        [P, Q_vert1, Q_vert2, dP_vert1, dP_vert2] ...
            = recursionVertical(n, ...
                                m, ...
                                Q_vert1, ...
                                Q_vert2, ...
                                dP_vert1, ...
                                dP_vert2, ...
                                sintheta, ...
                                costheta);

        B_USE__T = updateB(B_USE__T, ...
                        B_factors(:,n), ...
                        g_coeffs__T(n,m+1), ...
                        h_coeffs__T(n,m+1), ...
                        m, ...
                        sinmphi, ...
                        cosmphi, ...
                        P, ...
                        Q_vert1, ...
                        dP_vert1);
    end
end

%% Transform magnetic field vector into inertial frame

% Transformation matrix from USE to E frame
T_E_USE = [sintheta * cosphi, costheta * cosphi, -sinphi; ...
            sintheta * sinphi, costheta * sinphi, cosphi; ...
            costheta, -sintheta, 0];

B_E__T = T_E_USE * B_USE__T;

% Transformation from E to I frame
magnetic_field_I__T = smu.unitQuat.att.transformVector(smu.unitQuat.invert(q_EI), B_E__T);

end

%% Auxiliary functions
function B = updateB(B, B_factor, g, h, m, sinmphi, cosmphi, P, Q, dP)
    coeff_combi_1 = g * cosmphi + h * sinmphi;
    coeff_combi_2 = m * (- g * sinmphi + h * cosmphi);

    B = B + B_factor .* ...
        [ coeff_combi_1 * P; ...
            coeff_combi_1 * dP; ...
            coeff_combi_2 * Q];
end

function [P, Q, dP] = recursionDiagonal(m, Q_diag, dP_diag, sintheta, costheta)
    % Calculate Q(n,n) and dP(n,n) on main diagonal from previous entries
    % on main diagonal,
    % i.e. from Q(n-1,n-1) and dP(n-1,n-1)

    if m == 1
        k = 1;
    else
        k = sintheta;
    end

    % Recursions
    Q = k * Q_diag;
    dP = sintheta * dP_diag + costheta * k * Q_diag;

    % Calculate P from Q
    P = sintheta * Q;
end

function [P, Q, Q_vert1, dP, dP_vert1] = recursionVertical(n, m, Q_vert1, Q_vert2, dP_vert1, dP_vert2, sintheta, costheta)
    % Calculate Q(n,m) and dP(n,m) from previous two degrees,
    % i.e. from Q(n-1,m), Q(n-2,m), dP(n-1,m) and dP(n-2,m)

    if n == 1
        K = 0;
    else
        K = ((n-1)^2 - m^2) / ((2*n-1) * (2*n-3));
    end

    if m == 0
        k = 1;
    else
        k = sintheta;
    end

    % Recursions
    Q = costheta * Q_vert1 - K * Q_vert2;
    dP = costheta * dP_vert1 - sintheta * k * Q_vert1 - K * dP_vert2;

    % Calculate P from Q
    P = k * Q;
end