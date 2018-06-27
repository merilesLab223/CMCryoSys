classdef StreamCollector< handle & DataStream
    %STREAMCOLLECTOR Summary of this class goes here
    %   Detailed explanation goes here
        
    methods
        function obj = StreamCollector(reader)
            obj@DataStream(reader,false);
        end
    end
    
    events
        DataReady;
    end
    
    properties
        CollectDT=3000; % in timebase.
        UpdateDT=100; % in timebase.
        PadZeros=false; % in timebase.
        IntegrationTime=1; % in timebase.
    end
    
    properties (SetAccess = protected)
        Data=[0;0];
        MeanV=0; % in timebase units.
        Timestamps=[0;0];
        LastReadTimestamp=-1;
        LastUpdateTimestamp=-1;
        LastStartedTimestamp=-1;
    end
    
    properties (Access = protected)
        StreamT=[];
        StreamData=[];
        DataReadyEventObj=EventStruct;
        BatchT=[];
        BatchData=[];
    end
    
    methods
        function start(obj)
            obj.clear();
            start@DataStream(obj);
        end
        
        function clear(obj)
        	obj.StreamT=[];
            obj.StreamData=[];
        end
        
        function reset(obj)
            obj.clear();
        end
        
        function prepare(obj)
        end
        
        function [data,dt]=getData(obj)
            data=obj.StreamData;
            ts=obj.StreamT;
            dt=1;
            if(isempty(ts))
                return;
            end
            if(length(ts)>1)
                dt=ts(2)-ts(1);
            end
            if(obj.PadZeros)
                N=ceil(obj.CollectDT/dt);
                sdata=size(data);
                missing=N-sdata(1);
                if(missing>0)
                    data=[zeros(missing,1);data];
                    ts=[ones(missing,1)*ts(1);ts];
                end
            end
        end
        
        function [data,t]=getRawData(obj)
            data=obj.StreamData;
            t=obj.StreamT;
        end
        
        function [rslt]=getResultsMatrix(obj)
            rslt=[];
            rslt(:,1)=obj.StreamT;
            rslt(:,2)=obj.StreamData;
        end
    end
    
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            if(isempty(e.TimeStamps))
                return;
            end
            
            % collect current data.
            ts=obj.BatchT;
            data=obj.BatchData;
            
            if(~isempty(ts) && e.TimeStamps(end)<ts(1))
                ts=[];
                data=[];
            end
            
            if(isempty(ts))
                ts=e.TimeStamps;
                data=e.Data;
            else
                dlen=length(e.TimeStamps);
                ts(end+1:end+dlen)=e.TimeStamps;
                data(end+1:end+dlen,:)=e.Data;
            end
            
            % last mean value collected for read batch.
            obj.MeanV=mean(data,1);
            
            % if still empty.
            if(isempty(ts))
                % finding the locaiton where to slice.
                data=[];
                ts=[];
            end
            
            % reset the data back.
            obj.BatchT=ts;
            obj.BatchData=data;      
            
            % process the current.
            obj.processCurrentData(e);
        end
        
        function processCurrentData(obj,e)
            curT=obj.nowInTimebase();
            obj.LastReadTimestamp=curT;
            if(curT-obj.LastUpdateTimestamp>obj.UpdateDT)
%                 bt=obj.BatchT;
%                 bd=obj.BatchData;
%                 obj.BatchT=[];
%                 obj.BatchData=[];
%                 
%                 lt=length(bt);
%                 obj.StreamT(end+1:end+lt)=bt;
%                 obj.StreamData(end+1:end+lt,:)=bd;
%                 
%                 [obj.StreamT,obj.StreamData]=...
%                     obj.SliceToOffset(obj.StreamT,obj.StreamData);
                [bt,bd]=obj.processCurrentBatchToIntegratedStream();
                obj.LastUpdateTimestamp=curT;
                ev=DAQEventStruct();
                ev.Data=bd;
                ev.TimeStamps=bt;
                ev.Elapsed=e.Elapsed;
                ev.CompElapsed=e.CompElapsed;
                ev.TotalTicksSinceStart=e.TotalTicksSinceStart;
                ev.AccumilatedClockOffset=e.AccumilatedClockOffset;
                obj.notify('DataReady',ev);
            end            
        end
        
        function [bt,bdata]=processCurrentBatchToIntegratedStream(obj)
            bt=obj.BatchT;
            bdata=obj.BatchData; 
            if(isempty(bt))
                return;
            end
            
            % splicing to integration time.
            if(length(bt)>1)            
                intT=obj.IntegrationTime;
                maxT=floor(double(bt(end)-bt(1))/double(intT))...
                    *intT;
                if(maxT==0)
                    return;
                end
                [~,maxIdx]=min(abs(bt-maxT-bt(1)));
                if(maxIdx==1)
                    return;
                end
                obj.BatchT=bt(maxIdx+1:end);
                obj.BatchData=bdata(maxIdx+1:end);            
                bt=bt(1:maxIdx);
                bdata=bdata(1:maxIdx);
                t0=bt(1);
                [bt,bdata]=StreamToTimedData(bdata,obj.IntegrationTime,bt(2)-bt(1));
                bt=bt+t0;
            end
            if(isempty(bt))
                return;
            end
            lt=length(bt);
            obj.StreamT(end+1:end+lt)=bt;
            obj.StreamData(end+1:end+lt,:)=bdata;
            [obj.StreamT,obj.StreamData]=...
                obj.SliceToOffset(obj.StreamT,obj.StreamData);    
        end        
        
        function [ts,data]=SliceToOffset(obj,ts,data)
            if(isempty(ts))
                return;
            end
            offset=(ts(end)-obj.CollectDT); % from end
            idxs=find(ts>offset);
%             idxs=idxs(idxs<=length(data));
            data=data(idxs);
            ts=ts(idxs);            
        end
    end
end

