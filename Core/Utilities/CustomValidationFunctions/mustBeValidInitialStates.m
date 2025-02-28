function mustBeValidInitialStates(InitialStates)
    % a structure with no fields is valid
    if isempty(fieldnames(InitialStates))
        return
    end
    mustBeNumericStructure(InitialStates);
end