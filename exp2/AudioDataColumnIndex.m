classdef AudioDataColumnIndex
    properties
        index
    end
    enumeration
        UniqueName(1)
        AudioName(2)
        AudioNameNoExtension(3)
        Yat(4)
        Year(5)
        Month(6)
        Day(7)
        Hour(8)
        Minute(9)
    end
    methods
        function a = AudioDataColumnIndex(index)
            a.index = index;
        end
    end
end