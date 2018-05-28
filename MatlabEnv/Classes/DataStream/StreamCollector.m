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
    end
    
    properties (SetAccess = protected)
        Data=[0;0];
        MeanV=0; % in timebase units.
        CountsPerTimebase=0;
        Timestamps=[0;0];
        LastReadTimestamp=-1;
        LastUpdateTimestamp=-1;
    end
    
    properties (Access = protected)
        StreamT=[];
        StreamData=[];
        DataReadyEventObj=EventStruct;
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
        
        function [rslt]=getResultsMatrix(obj)
            rslt=[];
            rslt(:,1)=obj.StreamT;
            rslt(:,2)=obj.StreamData;
        end
    end
    
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            if(isempty(e.TimeStamps))
                obj.MeanV=0;
                return;
            end
            %return;
            %obj.MeanV=mean(e.Data);
            
            if(length(e.TimeStamps)>1)
                deltaT=e.TimeStamps(end)-e.TimeStamps(1);
                %obj.CountsPerTimebase=sum(e.Data)*obj.getTimebase()/deltaT;
            else
                obj.CountsPerTimebase=1;
            end
            
            ts=obj.StreamT;
            data=obj.StreamData;
            
            if(~isempty(ts) && e.TimeStamps(end)<ts(1))
                ts=[];
                data=[];
            end
            
            dlen=length(e.TimeStamps);
            data(end+1:end+dlen,:)=e.Data;
            if(isempty(ts))
                ts=e.TimeStamps;
            else
                ts(end+1:end+dlen)=e.TimeStamps;
            end
            
            if(~isempty(ts))
                % finding the locaiton where to slice.
                offset=(ts(end)-obj.CollectDT); % from end
                idxs=find(ts>offset);
                data=data(idxs);
                ts=ts(idxs);
            else
                data=[];
                ts=[];
            end
            
            obj.StreamT=ts;
            obj.StreamData=data;
            obj.Data=data;
            obj.Timestamps=ts;        
            
            curT=obj.nowInTimebase();
            obj.LastReadTimestamp=curT;
            if(curT-obj.LastUpdateTimestamp>obj.UpdateDT)
                obj.LastUpdateTimestamp=curT;
                obj.notify('DataReady',obj.DataReadyEventObj);
            end
        end
    end
end

