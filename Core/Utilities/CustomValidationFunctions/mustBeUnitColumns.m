function mustBeUnitColumns(spin_directions)
    if any(abs(vecnorm(spin_directions) - 1) >= 1e-6)
        eid = "mustBeUnitColumns:NotUnitColumns";
        msg = "Each column must be a unit vector";
        error(eid,msg);
    end
end