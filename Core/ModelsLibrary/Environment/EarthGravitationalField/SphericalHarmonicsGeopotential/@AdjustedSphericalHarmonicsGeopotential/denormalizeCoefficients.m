function denormCoeffs = denormalizeCoefficients(normCoeffs)

%% References:
% [1] O. Montenbruck and G. Eberhard, "Geopotential," in Satellite orbits: models, methods, and applications, Berlin : New York: Springer, 2000.

[n_plus_1_max, m_plus_1_max] = size(normCoeffs);
denormCoeffs = zeros(n_plus_1_max, m_plus_1_max);

% Conversion adapted from [1]
for n_plus_1 = 1:n_plus_1_max
    for m_plus_1 = 1:m_plus_1_max
        n = n_plus_1 - 1;
        m = m_plus_1 - 1;

        if m <= n
            denormCoeffs(n_plus_1, m_plus_1) = normCoeffs(n_plus_1, m_plus_1) ...
                * sqrt( (2 - double(m==0)) * (2*n + 1) * factorial(n-m) / factorial(n+m) );
        end 
    end
end

end