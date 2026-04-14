function w = computeWind(dayOfYear, UTsec, alt_km, glat, glon, Ap)

    % Determine the folder of this class method
    thisFile = mfilename('fullpath');
    thisDir  = fileparts(thisFile);

    % Build path to installed HWM14 data directory
    dataPath = fullfile(thisDir, '..', 'bin', 'install', 'share', 'data', 'hwm14');

    if ~exist(dataPath, 'dir')
        error('hwm14:dataPathNotFound', ...
            'HWM14 data directory not found: %s', dataPath);
    end

    % Ensure char array for Fortran MEX string input
    dataPath = char(dataPath);

    % Call MEX function
    w = hwm14ifc_mex(dataPath, dayOfYear, UTsec, alt_km, glat, glon, Ap);
end
