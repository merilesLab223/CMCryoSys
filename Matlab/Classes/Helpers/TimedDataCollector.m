classdef TimedDataCollector < handle & TimeBasedObject
    %DATACOLLECTOR Summary of this class goes here
    %   Detailed explanation goes here
    methods
        % define the reader.
        function obj = TimedDataCollector(reader)
            if(~exist('reader','var') || ~isa(reader,'TimedMeasurementReader'))
                error('DataReader must be of type TimedMeasurementReader.');
            end
            obj.reader=reader;
            % binding the event listener.
            reader.addDataReadyListner(@(s,e)obj.dataBatchAvailableFromDevice(s,e));
        end
    end
    
    events
        Complete;
        TimebinComplete;
    end
    
    properties
        IsContinues=false;
        CollectCompletedTimeBins=true;
    end
    
    % the attached reader.
    properties (SetAccess = private)
        reader=[];
        IsMeasurementValid=false;
        Duration=-1;
        Results={};
    end
    
    % timebinned measurement definitions.
    properties (Access = protected)
        isAborted=0;
        mbinPartialD={}; % bins to measure.
        mbinPartialT={};
        mbinF={};
        startTimestamps=[]; % bin time to index.    
        endTimestamps=[];
        lastBinSearch={};
        curMinSearchTime=-1;
        curMaxSearchTime=Inf;
        lastSearchTime=-1;
    end
    
    % called when data is ready.
    methods (Access = protected)
        
        % converst the data timestamps to valid data ranges. 
        function [vts]=timestampsToValidRange(obj,ts)
            vts={};
            if(~obj.IsContinues)
                vts{1}=1:length(ts); % all indexs.
                return;
            end
            
            % find correct.
            ts=ts-floor(ts(1)/obj.Duration)*obj.Duration;
            
            if(ts(end)<obj.Duration)
                % single.
                vts{1}=1:length(ts); % all indexs.
                return;                
            end
            
            didx=find(diff(floor(ts(1)/obj.Duration))>0);
            didx(end)=length(ts); % also add the last index.
            sidx=1;
            for eidx=didx
                idxs=sidx:eids;
                sidx=eidx;
                vts{end+1}=idxs;
            end
        end
        
        function dataBatchAvailableFromDevice(obj,s,e)
            if(obj.isAborted)return;end;
            if(~obj.IsMeasurementValid)obj.prepare();end
            if(obj.Duration==0)return;end
            
            vts=obj.timestampsToValidRange(e.TimeStamps);
            timestamps=e.TimeStamps./obj.timeUnitsToSecond;
            for i=1:length(vts)
                % convert timestamps from seconds.
                obj.processMeasurement(timestamps(vts{i}),e.Data(vts{i}));
            end
        end
    end
    
    % Event functions
    methods
        % binds a lister to the data ready event.
        function addDataReadyListner(obj,f)
            obj.addlistener('DataReady',f);
        end
        
        % binds a lister to the complete event.
        function addCompleteListner(obj,f)
            obj.addlistener('Complete',f);
        end
    end
    
    methods (Static)
        function [rslt]=defaultCollectionFunction(d,t)
            rslt(1)=t(1); % the timestamp.
            rslt(2)=sum(diff(d)); % sum of changes.
        end
    end
    
    % measure functions.
    methods
        function Measure(obj,t,durations,f)
            % if no collection function use default.
            if(~exist('f'))f=@(s,e)TimedDataCollector.defaultCollectionFunction(s,e);end 
            ti=obj.curT+t-t(1);
            if(~exist('durations','var'))
                durations=diff([0,t]); % since first t is zero :).
            end
            obj.MeasureAt(ti,durations,f);
            obj.wait(t(end));
        end
        
        % measure at.
        function MeasureAt(obj,t,duration,f)
            if(~exist('f'))f=@(d,t)sum(diff(d));end % if no collection function assume as sum.
            obj.IsMeasurementValid=false;
            lt=length(t);
            curl=length(obj.mbinPartialT);
            obj.startTimestamps(end+1:end+lt)=t;
            obj.endTimestamps(end+1:end+lt)=t+duration;
            obj.mbinPartialD(end+1:end+lt)={[]};
            obj.mbinPartialT(end+1:end+lt)={[]};
            obj.mbinF(end+1:end+lt)={f};
        end
        
        function [t,dwell,f]=getMesaurementParams(obj)
            t=obj.startTimestamps;
            dwell=obj.endTimestamps-obj.startTimestamps;
            f=obj.mbinF;
        end
    end
    
    methods
        function clear(obj)
            obj.curT=0;
            obj.isAborted=0;
            obj.mbinPartialD={}; % bins to measure.
            obj.mbinPartialT={};
            obj.mbinF={};
            obj.startTimestamps=[]; % bin time to index.    
            obj.endTimestamps=[];
            obj.clearData();
            obj.IsMeasurementValid=false;
        end
        
        function clearData(obj)
            obj.Results={};
            obj.clearPendingData();
        end
        
        % prepares the measurement for use.
        function prepare(obj)
            if(obj.IsMeasurementValid)return;end
            
            % now sorted by time.
            if(~isempty(obj.startTimestamps))
                [st,stidx]=sort(obj.startTimestamps);
                obj.startTimestamps=obj.startTimestamps(stidx);
                obj.endTimestamps=obj.endTimestamps(stidx);
                obj.mbinPartialD=obj.mbinPartialD(stidx);
                obj.mbinPartialT=obj.mbinPartialT(stidx);
                obj.mbinF=obj.mbinF(stidx);
                obj.Duration=obj.endTimestamps(end);                
            else
                obj.Duration=0;
            end
            
            % preparing the results vector.
            obj.Results=cell(length(obj.startTimestamps),1);

            obj.curMinSearchTime=-1;
            obj.curMaxSearchTime=Inf;
            
            obj.IsMeasurementValid=1;
        end
        
        function finalizePending(obj)
            finalizeActiveBins(obj.lastBinSearch);
            obj.clearPendingData();
        end
    end
    
    % measurement processing. 
    methods (Access = protected)
        function clearPendingData(obj)
            obj.lastBinSearch={};
            obj.curMinSearchTime=-1;
            obj.curMaxSearchTime=Inf;
            obj.lastSearchTime=-1;
            obj.mbinPartialD={}; % bins to measure.
            obj.mbinPartialT={};  
        end
        function [bidx]=getValidMeasurementBinIndexs(obj,mint,maxt)
            if(mint==maxt)
                % a single timebin?
                % search for minimal.
                maxt=mint+obj.getTimebase();
            end

            % [a,b] in [x,y] if b>x && a<y
            bidx=find(...
                obj.endTimestamps>mint & obj.startTimestamps<maxt);
            
            % finding min and max t. 
            obj.curMinSearchTime=obj.startTimestamps(min(bidx));
            obj.curMaxSearchTime=obj.endTimestamps(min(bidx));
            
            %bins=obj.mbin{bidx};
            obj.lastBinSearch=bidx;
        end

        % overrideable.
        function onTimebinComplete(obj,bidxs,completed)
            if(obj.CollectCompletedTimeBins)
                obj.Results(bidxs)=completed;
            end
            
            if(~isempty(completed) && event.hasListener(obj,'TimebinComplete'))
                %obj.notify('TimebinComplete',completed);
                ev=EventStruct;
                ev.Data=completed;
                notify(obj,'TimebinComplete',ev);
            end
        end
        
        % process the measurements for the specific timestamps.
        function processMeasurement(obj,timestamps,data)
            % find appropriate timebins.
            mint=timestamps(1);
            maxt=timestamps(end);
            
            % get last search
            lastActive=obj.lastBinSearch;
            
            % getting new valid measurems.
            bidxs=obj.getValidMeasurementBinIndexs(mint,maxt);
            if(length(lastActive)>0)
                deactivatedBins=setdiff(lastActive,bidxs);
                
                % ending anything that needs it.
                obj.finalizeActiveBins(deactivatedBins);                
            end
            

            dlen=length(data);
            
            for bidx=bidxs
                % adding data to bin.
                obj.mbinPartialD{bidx}(end+1:end+dlen)=data;
                obj.mbinPartialT{bidx}(end+1:end+dlen)=timestamps;
            end
        end
        
        function finalizeActiveBins(obj,completedIdxs)
            if(isempty(completedIdxs))return;end % nothing to do.
            
            lcomp=length(completedIdxs);
            completed=cell(length(completedIdxs),1);
            
            for i=1:lcomp
                bidx=completedIdxs(i);
                bf=obj.mbinF{bidx};
                bdata=obj.mbinPartialD{bidx};
                bts=obj.mbinPartialT{bidx};
                
                obj.mbinPartialD{bidx}=[]; % clear partial.
                obj.mbinPartialT{bidx}=[]; % clear partial.
                
                completed{i}=bf(bdata,bts);
            end
            obj.onTimebinComplete(completedIdxs,completed);
        end        
    end
end

