function mustBeValidSampleTimeParameter(sample_time_parameter__s)
    if ~all(isnumeric(sample_time_parameter__s))
        error("mustBeValidSampleTimeParameter:notNumeric","Sample time must be numeric.");
    end

    if ~all(isreal(sample_time_parameter__s))
        error("mustBeValidSampleTimeParameter:complex","Sample time must be real.");
    end

    if ~all(isfinite(sample_time_parameter__s))
        error("mustBeValidSampleTimeParameter:infinite","Sample time must be finite.");
    end

    if ~isvector(sample_time_parameter__s)
        error("mustBeValidSampleTimeParameter:notVector","Sample time must be a vector.");
    end

    if length(sample_time_parameter__s) ~= 2
        error("mustBeValidSampleTimeParameter:wrongSize","Sample time must be a vector of length 2.");
    end

    if any(sample_time_parameter__s < 0)
        error("mustBeValidSampleTimeParameter:negative","Sample time must have non-negative entries.");
    end

    if sample_time_parameter__s(1) == 0 && sample_time_parameter__s(2) ~= 0
        error("mustBeValidSampleTimeParameter:invalidSampleOffset","Sample offset must be zero if sample time is zero.");
    end
end