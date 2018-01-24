classdef Counter < handle
    
    properties
        NSamples
        NAverages
        NCounterGates
        MaxCounts = 10
        MinCounts = 0
        DataDims
        AvgIndex
        RawData
        RawDataIndex
        ProcessedData
        AveragedData
        bSaveRawData
        bSaveProcessedData
        hwHandle
        hasAborted = 0
    end
    
    methods
        
        % constructor
        function [obj] = Counter()
        end
        
        
        function [obj] = init(obj)
        end
            
        function [obj] = arm(obj)
        end
        
        function [obj] = disarm(obj)
        end
        
        function [obj] = close(obj)
        end
        
        function [a] = isFinished(obj)
        end
        
        function [obj] = streamCounts(obj)
        end
        
        function [obj] = processRawDataCW(obj)
        end
        
        function [obj] = processRawDataPulsed(obj)
        end
        
    end
    
    events
        UpdateCounterData
        UpdateCounterProcData
    end
    
end