classdef TimedMeasurementReader < handle & TimeBasedObject
    %MEASUREMENTREADER Reads data from an input device.
    %   Reads data from an input deviced based on timed execution.
    
    events
        DataReady;
    end
    
    properties
        ClockRatio=-1;
        % true to ignore the errors.
        IgnoreErrors=false;
        AccumilatedOffsetWarningTime=1000;
    end
    
    properties (SetAccess = protected)
        TickCount=0;
        ProceesedCount=0;
        InitizliedTimestamp=-1;
        FirstDataBatchTimestamp=-1;
        ComputerToReaderTimeOffset=0;
        IsTMReaderDeleted=false;
        WaitStatus=0;
        LastError=-1;
        LastErrorTimestamp=-1;
    end
    
    properties (Access = private)
        m_LastAccumilatedOffset=0;
        m_eventDataStruct=DAQEventStruct;
        m_lastWaitTime=-1;
        m_waitCount=1;
    end

    properties (Access=protected)
        DataAvailableEventListener=[];
    end
    
    % called when data is ready.
    methods (Access = protected)
        
        function dataBatchAvailableFromDevice(obj,s,e)
            try
                if(obj.IsTMReaderDeleted) % check for clear all deleted.
                    return;
                end

                if(obj.FirstDataBatchTimestamp<0)
                    obj.FirstDataBatchTimestamp=now;
                end
                computerElapsedTime=(now-obj.FirstDataBatchTimestamp)*86400/obj.timeUnitsToSecond;
                firstTimestamp=e.TimeStamps(1)/obj.timeUnitsToSecond;
                accumilatedClockOffset=computerElapsedTime-firstTimestamp;

                if(accumilatedClockOffset-obj.m_LastAccumilatedOffset>=...
                        obj.AccumilatedOffsetWarningTime)
                    obj.m_LastAccumilatedOffset=accumilatedClockOffset;
                    disp(['Accumilated datareader offset is large, [ms] ',...
                        num2str(accumilatedClockOffset)]);
                end
                obj.ComputerToReaderTimeOffset=accumilatedClockOffset;

                
                if(obj.m_eventDataStruct.IsExecuting)
                    obj.m_eventDataStruct=DAQEventStruct;
                end
                
                ev=obj.m_eventDataStruct;
                ev.IsExecuting=1;
                ev.deviceTimeStamps=e.TimeStamps;
                ev.TimeStamps=e.TimeStamps./(obj.ClockRatio*obj.timeUnitsToSecond);%(obj.TickCount+(1:length(e.TimeStamps)))./(obj.ActiveRate*obj.timeUnitsToSecond); % rate to time
                ev.TotalTicksSinceStart=obj.TickCount;
                ev.Elapsed=ev.TimeStamps(1);
                ev.TicksElapsed=obj.TickCount/(obj.timeUnitsToSecond*obj.ClockRatio*obj.Rate);
                ev.CompElapsed=computerElapsedTime;
                ev.AccumilatedClockOffset=accumilatedClockOffset;

                [ev.TimeStamps,ev.Data]=obj.processDataBatch(ev.TimeStamps,e.Data,e);
                obj.TickCount=obj.TickCount+length(ev.TimeStamps);
                obj.ProceesedCount=obj.ProceesedCount+length(ev.TimeStamps);

                obj.notify("DataReady",ev);
                ev.IsExecuting=0;
            catch err
                obj.LastError=err;
                obj.LastErrorTimestamp=now;
                if(obj.IgnoreErrors)
                    return;
                end
                error(err);
            end
        end
        
        function [ts,data]=processDataBatch(obj,ts,data,e)
        end
    end
    
    % Event functions
    methods
        % binds a lister to the data ready event.
        function initInternalTime(obj)
            obj.ProceesedCount=0;
            obj.FirstDataBatchTimestamp=-1;
            obj.TickCount=0;
            obj.InitizliedTimestamp=now;
            if(obj.ClockRatio<0)
                obj.ClockRatio=1;
            end
        end
        
        function delete(obj)
            try
                obj.IsTMReaderDeleted=true;
                if(~isempty(obj.DataAvailableEventListener))
                    delete(obj.DataAvailableEventListener);
                end
            catch err
            end
        end
    end
end

