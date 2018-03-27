classdef TimedMeasurementReader < handle & TimeBasedObject
    %MEASUREMENTREADER Reads data from an input device.
    %   Reads data from an input deviced based on timed execution.
    
    events
        DataReady;
    end
    
    properties
        ClockRatio=-1;
    end
    
    properties (SetAccess = protected)
        TickCount=0;
        ProceesedCount=0;
        InializedTimestamp=-1;
    end
        
    % called when data is ready.
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            ev=DAQEventStruct;
            ev.deviceTimeStamps=e.TimeStamps;
            ev.TimeStamps=e.TimeStamps./(obj.ClockRatio*obj.timeUnitsToSecond);%(obj.TickCount+(1:length(e.TimeStamps)))./(obj.ActiveRate*obj.timeUnitsToSecond); % rate to time
            ev.TotalTicksSinceStart=obj.TickCount;
            ev.Elapsed=ev.TimeStamps(1);
            ev.TicksElapsed=obj.TickCount/(obj.timeUnitsToSecond*obj.ClockRatio*obj.Rate);
            ev.CompElapsed=(now-obj.InializedTimestamp)*86400/obj.timeUnitsToSecond;
            
            [ev.TimeStamps,ev.Data]=obj.processDataBatch(ev.TimeStamps,e.Data,e);
            obj.TickCount=obj.TickCount+length(ev.TimeStamps);
            obj.notify("DataReady",ev);
            obj.ProceesedCount=obj.ProceesedCount+length(ev.TimeStamps);
        end
        
        function [ts,data]=processDataBatch(obj,ts,data,e)
        end
    end
    
    % Event functions
    methods
        % binds a lister to the data ready event.
        function addDataReadyListner(obj,f)
            obj.addlistener('DataReady',f);
        end
        
        function initInternalTime(obj)
            obj.ProceesedCount=0;
            obj.TickCount=0;
            obj.InializedTimestamp=now;
            if(obj.ClockRatio<0)
                obj.ClockRatio=1;
            end
        end
    end
end

