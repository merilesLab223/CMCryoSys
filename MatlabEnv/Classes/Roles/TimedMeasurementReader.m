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
        UseAccumilatedTickCountForTime=true;
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
                
                dbatch=struct();
                dbatch.data=e.Data;
                dbatch.ts=e.TimeStamps;
                obj.postNextDataBatch(dbatch);
                
            catch err
                obj.LastError=err;
                obj.LastErrorTimestamp=now;
                if(obj.IgnoreErrors)
                    return;
                end
                error(err);
            end
        end
    end
    
    methods (Access = protected)
        function [ts,data]=processDataBatch(obj,ts,data)
        end
    end
    
    properties(Access = private)
        m_processDataEventDispatch=[];
        m_processDataEventDispatchWaiting={};
    end
    
    % async data processing.
    methods(Access = private)
        function postNextDataBatch(obj,dbatch)
            if(isempty(obj.m_processDataEventDispatch))
                obj.m_processDataEventDispatch=events.CSDelayedEventDispatch();
                
                obj.m_processDataEventDispatch.addlistener('Ready',...
                    @obj.processWaitingDataBatches);
            end
            obj.m_processDataEventDispatchWaiting{end+1}=dbatch;
            obj.m_processDataEventDispatch.trigger(1);
        end
        
        function processWaitingDataBatches(obj,s,e)
            if(obj.FirstDataBatchTimestamp<0)
                obj.FirstDataBatchTimestamp=now;
                obj.m_LastAccumilatedOffset=0;
            end
            
            if(isempty(obj.m_processDataEventDispatchWaiting))
                return;
            end
            
            accumTimeOffset=int32(obj.secondsToTimebase(...
                (now-obj.FirstDataBatchTimestamp)*24*60*60));
            
            dbatches=obj.m_processDataEventDispatchWaiting;
            obj.m_processDataEventDispatchWaiting={};
            % collecitng the data.
            dlen=0;
            columns=1;
            for i=1:length(dbatches)
                dlen=dlen+length(dbatches{i}.ts);
                sdata=size(dbatches{i}.data);
                if(columns<sdata(2))
                    columns=sdata(2);
                end
            end
            
            data=zeros(dlen,columns);
            ts=zeros(dlen,1);
            lastPos=1;
            for i=1:length(dbatches)
                dsize=size(dbatches{i}.data);
                idxs=lastPos:lastPos+dsize(1)-1;
                ts(idxs)=dbatches{i}.ts;
                data(idxs,1:dsize(2))=dbatches{i}.data;
                lastPos=idxs(end)+1;
            end
            
            % salve old device timestamps;
            devts=ts;

            if(obj.UseAccumilatedTickCountForTime)
                tps=1/(obj.Rate*obj.timeUnitsToSecond);
                ts=(obj.TickCount+([1:dlen]')-1)*tps;
            else
                ts=ts./(obj.ClockRatio*obj.timeUnitsToSecond);                    
            end
            
            % processing the current.
            [ts,data]=obj.processDataBatch(ts,data);
            obj.TickCount=obj.TickCount+dlen;
            
            ev=DAQEventStruct();
            ev.Data=data;
            ev.TimeStamps=ts;
            ev.TotalTicksSinceStart=obj.TickCount;
            ev.deviceTimeStamps=devts;
            
            ev.Elapsed=obj.secondsToTimebase(obj.TickCount/obj.Rate);
            ev.CompElapsed=obj.secondsToTimebase(...
                (now-obj.FirstDataBatchTimestamp)*24*60*60);
%             ev.AccumilatedClockOffset=accumTimeOffset-ev.Elapsed;
%             
%             if(ev.AccumilatedClockOffset>obj.AccumilatedOffsetWarningTime)
%                 warning(['Accumilated datareader offset is large, [ms] ',...
%                         num2str(ev.AccumilatedClockOffset)]);
%                 obj.FirstDataBatchTimestamp=-1;
%             end
%             
            try
                obj.notify("DataReady",ev);
            catch err
                obj.LastError=err;
                obj.LastErrorTimestamp=now;
                if(obj.IgnoreErrors)
                    warning(err);
                else
                    error(err);
                end
            end
            
            if(~isempty(obj.m_processDataEventDispatchWaiting))
                obj.m_processDataEventDispatch.trigger(1);
            end
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

