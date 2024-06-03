classdef Features

    enumeration
        SpectralCentroid("SpectralCentroid")
        SpectralCrestFactor("SpectralCrestFactor")
        SpectralDecrease("SpectralDecrease")
        SpectralFlatness("SpectralFlatness")
        SpectralFlux("SpectralFlux")
        SpectralRolloff("SpectralRolloff")
        SpectralSpread("SpectralSpread")
        SpectralTonalPowerRatio("SpectralTonalPowerRatio")
        TimeZeroCrossingRate("TimeZeroCrossingRate")
        TimeAcfCoeff("TimeAcfCoeff")
        TimeMaxAcf("TimeMaxAcf")
    end

    properties 
        Name
    end

    properties (Constant)
        EnumList = enumeration('Features');  
    end

    methods (Static)
        function feature = getEnumByIndex(index)
            if index < 1 || index > numel(Features.EnumList)
                error('feature index out of range, index %d', index);
            end
            feature = Features.EnumList(index);
        end
        function index = getIndexByEnum(feature)
            index = find(Features.EnumList == feature, 1);
            if isempty(index)
                error('no feature found in enum, featureName "%s"', feature);
            end
        end
        function size = getSize()
            size = numel(Features.EnumList);
        end
    end

    methods
        function f = Features(Name)
            f.Name = Name;
        end
        function name = get.Name(obj)
            name = obj.Name;
        end
    end

end