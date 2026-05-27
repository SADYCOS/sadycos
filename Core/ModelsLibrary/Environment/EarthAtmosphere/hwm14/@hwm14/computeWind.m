function w = computeWind(dayOfYear, UTsec, alt_km, glat, glon, Ap)

    % Determine the path to the hwm14ifc_mex function
    thisFile = mfilename('fullpath');           % Get the full path of the current function
    hwm14Root = fileparts(fileparts(thisFile)); % Go up two levels to reach the hwm14 root directory
    dataPath  = fullfile(hwm14Root, 'bin', 'install', 'share', 'data', 'hwm14');

    % Check if the data folder exists, if not, throw an error
    if ~isfolder(dataPath)
        error('hwm14:dataNotFound', ...
              'HWM14 data folder not found at:\n%s', dataPath);
    end

    % Compute the atmospheric wind velocity
    w = hwm14ifc_mex(dayOfYear, UTsec, alt_km, glat, glon, Ap, dataPath);
end