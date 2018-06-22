classdef BinEventStruct < EventStruct
    %TIMEBINEVEN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        BinIndexs;
    end
    
    properties(SetAccess = private)
        BinCount;
    end
    
    methods
        function [c]=get.BinCount(ev)
            c=length(ev.BinIndexs);
        end
        
        function obj = BinEventStruct(binIndexs,binData)
            obj.Data=binData;
            obj.BinIndexs=binIndexs;
        end
    end
end

