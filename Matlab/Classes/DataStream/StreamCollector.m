classdef StreamCollector< handle & DataStream
    %STREAMCOLLECTOR Summary of this class goes here
    %   Detailed explanation goes here
        
    methods
        function obj = StreamCollector(reader)
            obj@DataStream(reader,false);
        end
    end
    
    properties
        IntegrateDT=1;
        CollectDT=3000; % in timebase.
    end
    
    properties (SetAccess = protected)
        Data=[0;0];
        MeanV=0;
        Timestamps=[0;0];
        LastReadTimestamp=-1;
    end
    
    properties (Access = protected)
        StreamT=[];
        StreamData=[];
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
    end
    
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            if(isempty(e.TimeStamps))
                obj.MeanV=0;
                return;
            end
            obj.MeanV=mean(e.Data);
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
            
            if(obj.IntegrateDT>0 && ~isempty(ts))
                [ts,data]=StreamToTimedData([ts,data],...
                    obj.timebaseToSeconds(obj.IntegrateDT));
            end
            
            obj.LastReadTimestamp=now*24*60*60./obj.timeUnitsToSecond;
        end
    end
end

