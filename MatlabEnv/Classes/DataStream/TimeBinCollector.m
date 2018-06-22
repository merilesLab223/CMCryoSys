classdef TimeBinCollector < DataStream
    %TIMEBINCOLLECTOR A collector allowing the collection of specified
    % timebins, the timebin collector will allow the timebin data to be
    % read from the results collection.
    
    methods
        function obj = TimeBinCollector(reader)
            obj@DataStream(reader,false);
        end
    end
    
    % the events for the time bin collector.
    events
        BinComplete;
        Complete;
    end
    
    % collector methods
    methods
        function reset(obj)
            obj.Results={};
            obj.curT=0;
        end
        
        function prepare(obj)
            obj.CompleatedPercent=0;
            obj.StreamT=[];
            obj.StreamData=[];
            obj.MeasurementTimeOffset=0;
            obj.m_curBinIndex=0;
            obj.sortTBins();
            obj.m_pendingBins=1:length(obj.MeasureBins);
            obj.m_maxT=-1;
            for i=obj.m_pendingBins
                mbin=obj.MeasureBins{i};
                if(mbin.end>obj.m_maxT)
                    obj.m_maxT=mbin.end;
                end
            end
            
            obj.m_maxT=obj.m_maxT+...
                obj.secondsToTimebase(obj.OverCollectDataTicks/obj.Rate);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Collection
   
    % collection settings.
    properties
        RemoveProcessedData=true;
        AssumeConsecutiveTimeValues=true;
        OverCollectDataTicks=100;
        KeepResultsInMemory=true;
    end
    
    % collection properties.
    properties (SetAccess = protected)
        StreamT=[];
        StreamData=[];
        Results={};
        MeasurementTimeOffset=0;
        CompleatedPercent=0;
    end
    
    % collection private methods.
    properties (Access = private)
        m_curBinIndex=1;
        m_pendingBins=[];
        m_maxT=-1;
    end
    
    % collection protected methods
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            if(~obj.IsRunning)
                return;
            end
            
            if(isempty(e.TimeStamps) || isempty(obj.m_pendingBins))
                return;
            end
            
            ets=e.TimeStamps;
            
            % OvercollectDataTime is used since the precision is required.
            if(ets(1)<=obj.m_maxT)
                ts=obj.StreamT;
                data=obj.StreamData;

                if(~isempty(ts) && ets(end)<ts(1))
                    ts=[];
                    data=[];
                end

                dlen=length(ets);
                if(isempty(ts))
                    ts=ets;
                    data=e.Data;
                else
                    data(end+1:end+dlen,:)=e.Data;
                    ts(end+1:end+dlen)=ets;
                end
                if(~iscolumn(ts))
                    ts=ts';
                end
                obj.StreamT=ts;
                obj.StreamData=data;                
            end
            
            % processing the bin data.
            try
                [ridxs,rslts]=obj.processBinData();
                if(~isempty(rslts))                
                    % updating state
                    lbin=numel(obj.MeasureBins);
                    lpend=numel(obj.m_pendingBins);
                    obj.CompleatedPercent=100*(lbin-lpend)/lbin;

                    if(~isempty(ridxs))
                        if(obj.KeepResultsInMemory)
                            obj.Results(ridxs)=rslts(:);
                        end           
                        ev=BinEventStruct(ridxs,rslts);
                        obj.notify('BinComplete',ev);
                    end
                end
                if(isempty(obj.m_pendingBins))
                    obj.stop(); % stop the reader since it was complete.
                    ev=EventStruct();
                    obj.notify('Complete',ev);
                end
            catch err
                rethrow(err);
            end
        end
        
        function [ridxs,rslts]=processBinData(obj)
            ridxs=[];
            rslts={};
            if(isempty(obj.StreamT))
                return;
            end
            sts=obj.StreamT(1);
            ets=obj.StreamT(end);
            
            % finding the appropriate bins.
            requiredMinStart=Inf;
            completedIdxs=[];
            for i=1:length(obj.m_pendingBins)
                bidx=obj.m_pendingBins(i);
                mbin=obj.MeasureBins{bidx};
                if(mbin.end<ets)
                    completedIdxs(end+1)=i;
                    ridxs(end+1)=bidx;
                elseif(mbin.start<ets && mbin.end>=ets)
                    if(mbin.start<requiredMinStart)
                        requiredMinStart=mbin.start;
                    end
                end
                
                if(mbin.start>ets)
                    break; % start times are sorted.
                end
            end
            obj.m_pendingBins(completedIdxs)=[];
            
            % stop the execution if completed.
            if(isempty(obj.m_pendingBins))
                obj.stop();
            end
            
            % collecting data for the bins.
            rslts=cell(1,length(rslts));
            for i=1:length(ridxs)
                bidx=ridxs(i);
                mbin=obj.MeasureBins{bidx};
                idxs=obj.fastFindBinIdxs(mbin.start,mbin.end);
                data=[obj.StreamT(idxs),obj.StreamData(idxs,:)];
                
                rslts{i}=data;
            end
            
            if(obj.RemoveProcessedData && requiredMinStart>sts)
                % can remove.
                if(requiredMinStart>ets)
                    obj.StreamT=[];
                    obj.StreamData=[];
                elseif(requiredMinStart>=sts)
                    idxs=obj.fastFindBinIdxs(obj.StreamT(1),requiredMinStart);
                    obj.StreamT(idxs)=[];
                    obj.StreamData(idxs)=[];                    
                end
            end
        end
        
        function [idxs]=fastFindBinIdxs(obj,sts,ets)
            lt=length(obj.StreamT);
            if(obj.AssumeConsecutiveTimeValues && lt>1)
                dt=obj.StreamT(2)-obj.StreamT(1);
                if(obj.StreamT(1)>ets || obj.StreamT(1)+lt*dt<sts)
                    idxs=[];
                    return;
                end                
                if(obj.StreamT(1)>dt)                    
                    sts=sts-obj.StreamT(1);
                    ets=ets-obj.StreamT(1);
                end
                
                sidx=floor(sts/dt);
                if(sidx<=1)
                    sidx=1;
                end
                eidx=floor(ets/dt);
                idxs=(sidx:eidx);
            else
                idxs=find(obj.StreamT>=sts & obj.StreamT<ets);
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Timebins
    
    % timebin properties
    properties
    end

    % timebin protected properties
    properties (SetAccess = protected)
        % the collection of measurment tbins.
        MeasureBins={};
    end
    
    methods
        function clear(obj)
            obj.reset();
            obj.MeasureBins={};
        end

        function Measure(obj,duration)
            % if no collection function use default.
            t=obj.curT+cumsum(duration)-duration(1); % measurement times.
            obj.MeasureAt(t,duration);
            obj.wait(sum(duration)); % wait total time.
        end
        
        % measure at.
        function MeasureAt(obj,t,duration)
            lt=length(t);
            for i=1:lt
                mbin=struct();
                mbin.start=t(i);
                mbin.end=t(i)+duration(i);
                obj.MeasureBins{end+1}=mbin;
            end
            
            obj.sortTBins();
        end
    end
    
    % protected measurement methods
    methods (Access = protected)
        function sortTBins(obj)
            % gathering time indexs.
            ts=zeros(1,length(obj.MeasureBins));
            for i=1:length(ts)
                ts(i)=obj.MeasureBins{i}.start;
            end
            [~,sidxs]=sort(ts);
            obj.MeasureBins=obj.MeasureBins(sidxs);
        end
    end
end

