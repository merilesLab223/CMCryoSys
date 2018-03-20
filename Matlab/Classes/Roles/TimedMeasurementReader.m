classdef TimedMeasurementReader < handle & TimeBasedObject
    %MEASUREMENTREADER Reads data from an input device.
    %   Reads data from an input deviced based on timed execution.
    
    events
        DataReady;
    end
        
    % called when data is ready.
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            obj.notify("DataReady",e);
        end
    end
    
    % Event functions
    methods
        % binds a lister to the data ready event.
        function addDataReadyListner(obj,f)
            obj.addlistener('DataReady',f);
        end
    end
end

