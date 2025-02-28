function [Structure, current_index] = populateNumericStructureFromVector(Structure, vector, start_index)
    
    arguments
        Structure (1,1) struct 
        vector (:,1) {mustBeNumeric}
        start_index (1,1) {mustBePositive} = 1
    end

    field_names = fieldnames(Structure);

    current_index = start_index;
    for field_name = field_names.'
        the_field = Structure.(field_name{1});
        if isstruct(the_field)
            [Structure.(field_name{1}), current_index] ...
            = populateNumericStructureFromVector(the_field, vector, current_index);
        else
            number_elements = numel(the_field);
            last_index = current_index + number_elements - 1;
            Structure.(field_name{1})(:) = vector(current_index:last_index);
            current_index = last_index + 1;
        end
    end

end
    