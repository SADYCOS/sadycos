function mustBeNumericStructure(S)
    if ~isstruct(S)
        eidType = 'mustBeNumericStructure:nonStructure';
        msgType = 'Input must be a structure.';
        error(eidType, msgType);
    end
    if isempty(S)
        eidType = 'mustBeNumericStructure:emptyStructure';
        msgType = 'Input structure must not be empty.';
        error(eidType, msgType);
    end
    if isempty(fieldnames(S))
        eid = 'mustBeNumericStructure:noFields';
        msg = 'Input structure must have at least one field.';
        error(eid, msg);
    end
    result = findNonNumericField(S);
    if result ~= ""
        eidType = 'mustBeNumericStructure:nonNumericField';
        msgType = 'Field "%s" must be numeric.';
        error(eidType, msgType, result);
    end
end

function non_numeric_field_name = findNonNumericField(S)
    non_numeric_field_name = "";

    field_names = fieldnames(S);
    for i = 1:numel(field_names)
        current_field_name = field_names{i};
        current_field = S.(current_field_name);
        if isstruct(current_field)
            result = findNonNumericField(current_field);
            if result ~= ""
                non_numeric_field_name = append(current_field_name, ".", result);
                return
            end
        elseif ~isnumeric(current_field)
            non_numeric_field_name = current_field_name;
            return
        end
    end
end