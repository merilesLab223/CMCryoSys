classdef BinEventStruct < EventStruct
    %TIMEBINEVEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        BinIndex;
    end
    
    methods
        function obj = BinEventStruct(binIndex,binData)
            obj.Data=binData;
            obj.BinIndex=binIndex;
        end
    end
end

