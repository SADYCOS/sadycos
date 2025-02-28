function gaussCoeffs = gaussFromSchmidt(schmidtCoeffs)

%% References:
% [1] M. Plett, "Magnetic Field Models," in Spacecraft Attitude Determination and Control, Reprint., J. R. Wertz, Ed., in Astrophysics and space science library, no. 73. , Dordrecht: Kluver Acad. Publ, 1978, pp. 779–786.

[n_max, m_plus_1_max] = size(schmidtCoeffs);
gaussCoeffs = zeros(n_max, m_plus_1_max);

% Conversion adapted from [1]
for n = 1:n_max
    for m_plus_1 = 1:m_plus_1_max
        m = m_plus_1 - 1;

        if m <= n
            gaussCoeffs(n,m_plus_1) = schmidtCoeffs(n,m_plus_1) ...
                * sqrt( (2 - double(m==0)) * factorial(n-m) / factorial(n+m) ) ...
                * doubleFactorial(2*n-1) /factorial(n-m);
        end 
    end
end

end

% utility function
function out = doubleFactorial(in)
out = prod(in:-2:1);
end