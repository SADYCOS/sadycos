classdef hwm14 < ModelBase
    methods (Static)

        atmospheric_velocity_BI_I__m_per_s ...
            = execute(position_BI_I__m)

        createHWMmexFunction()

        computeWind(dayOfYear, UTsec, alt_km, glat, glon, Ap)

    end
end