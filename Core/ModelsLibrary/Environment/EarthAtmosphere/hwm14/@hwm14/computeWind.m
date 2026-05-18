function computeWind(dayOfYear, UTsec, alt_km, glat, glon, Ap)

    % Compute the atmospheric wind velocity
    hwm14ifc_mex(dayOfYear, UTsec, alt_km, glat, glon, Ap);
end