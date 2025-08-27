classdef EarthMoonOccultation < ModelBase
    methods (Static)

        [sun_visibility_fraction] ...
                    = execute(position_BI_I__m, ...
                                sun_position_SI_I__m, ...
                                moon_position_MI_I__m,...
                                ParametersEarthMoonOccultation)
        
    end
    methods (Access = public)

        function obj = EarthMoonOccultation(earth_radius__m, ...    
                                            sun_radius__m, ...
                                            moon_radius__m)
        % EarthMoonOccultation
        %
        %   Inputs:
        %   earth_radius__m: radius of the Earth in m
        %   sun_radius__m: radius of the Sun in m
        %   moon_radius__m: radius of the Moon in m        
    
        arguments
            earth_radius__m (1,1) {mustBePositive}
            sun_radius__m (1,1) {mustBePositive}
            moon_radius__m (1,1) {mustBePositive}            
        end
    
            Parameters.earth_radius__m = earth_radius__m;
            Parameters.sun_radius__m = sun_radius__m;
            Parameters.moon_radius__m = moon_radius__m;            
    
            %% Set Parameters in ModelBase Constructor
            obj = obj@ModelBase("Parameters", Parameters);
            
        end

    end
end