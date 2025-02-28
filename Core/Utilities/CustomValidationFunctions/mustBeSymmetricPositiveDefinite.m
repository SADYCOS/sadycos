function mustBeSymmetricPositiveDefinite(M)
    if ~ismatrix(M)
        eid = 'mustBeSymmetricPositiveDefinite:notMatrix';
        msg = 'Input must be a matrix';
        throwAsCaller(MException(eid,msg))
    end

    try chol(M);
    catch ME
        eid = 'mustBeSymmetricPositiveDefinite:notSymmetricPositiveDefinite';
        msg = 'Input must be symmetric positive definite';
        throwAsCaller(MException(eid,msg))
    end
end