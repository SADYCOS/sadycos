function w = computeWind(dayOfYear, UTsec, alt_km, glat, glon, Ap)

    % Call MEX function
    w = hwm14ifc_mex(dayOfYear, UTsec, alt_km, glat, glon, Ap);
    
end
