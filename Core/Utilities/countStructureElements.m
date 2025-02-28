function num_elements = countStructureElements(Structure)
    arguments
        Structure (1,1) struct
    end

    field_names = fieldnames(Structure);
    num_elements = 0;
    for field_name = field_names.'
        the_field = Structure.(field_name{1});
        if isstruct(the_field)
            num_elements = num_elements + countStructureElements(the_field);
        else
            num_elements = num_elements + numel(the_field);
        end
    end
end