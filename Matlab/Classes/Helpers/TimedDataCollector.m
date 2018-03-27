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
        defaultValue=[];
        ExtenalClockRate=-1;
        DefaultProcessingFunction=@(t,d)TimedDataCollector.defaultCollectionFunction(t,d);
        BatchProcessingWarnMinTime=1000;
    end
    
    % the attached reader.
    properties (SetAccess = private)
        reader=[];
        IsMeasurementValid=false;
        Duration=-1;
        MeasurementStart=-1;
        MeasurementEnd=-1;
        MeasurementStartTS=-1;
        CurrentMeasurementDuration=-1;
        Results={};
        ResultsMap=[];
        TimestampRateToExternalClockRatio=-1;
        LastCollectedTimestamp=0;
    end
    
    % timebinned measurement definitions.
    properties (Access = protected)
        isAborted=0;
        rawData=[]; % bins to measure.
        % data.
        rawTimestamps=[];
        bfidx=[];
        fmap={};
        startTimestamps=[]; % bin time to index.    
        endTimestamps=[];
        lastCompleted=-1;
        compleatedBins=[];
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
            
            obj.CurrentMeasurementDuration=...
                (now-obj.MeasurementStartTS)*24*60*60;
            
            %timestamps=;
            
            obj.processMeasurement(e.TimeStamps,e.Data,e);
            obj.LastCollectedTimestamp=e.TimeStamps(end);
            return;
            vts=obj.timestampsToValidRange(e.TimeStamps);
            
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
        function [rslt]=defaultCollectionFunction(t,d)
            rslt=[t,d];
        end
    end
    
    % measure functions.
    methods
        function Measure(obj,duration,f)
            % if no collection function use default.
            if(~exist('f'))f=obj.DefaultProcessingFunction;end 
            t=obj.curT+cumsum(duration)-duration(1); % measurement times.
            obj.MeasureAt(t,duration,f);
            obj.wait(sum(duration)); % wait total time.
        end
        
        % measure at.
        function MeasureAt(obj,t,duration,f)
            if(~exist('f'))f=obj.DefaultProcessingFunction;end % if no collection function assume as sum.
            obj.IsMeasurementValid=false;
            lt=length(t);

            obj.startTimestamps(end+1:end+lt)=t;
            obj.endTimestamps(end+1:end+lt)=t+duration;
            fidx=length(obj.fmap)+1;
            
            obj.fmap(fidx)={f};
            obj.bfidx(end+1:end+lt)=fidx;
        end
        
        % return current measurements.
        function [t,dwell]=getMesaurementParams(obj)
            t=obj.startTimestamps;
            dwell=obj.endTimestamps-obj.startTimestamps;
        end
    end
    
    methods
        function clear(obj)
            obj.curT=0;
            obj.isAborted=0;
            obj.fmap={};
            obj.bfidx=[];
            obj.IsMeasurementValid=false;
            obj.startTimestamps=[];
            obj.endTimestamps=[];
            obj.clearData();
        end
        
        function clearData(obj)
            obj.Results={};
            obj.ResultsMap=[];
            obj.clearPendingData();
        end
        
        function [ct]=getRawPendingTickCount(obj)
            ct=length(obj.rawTimestamps);
        end
        
        % prepares the measurement for use.
        function prepare(obj)
            if(obj.IsMeasurementValid)return;end
            
            % now sorted by time.
            obj.Results={};
            if(~isempty(obj.startTimestamps))
                [st,stidx]=sort(obj.startTimestamps);
                obj.startTimestamps=obj.startTimestamps(stidx);
                obj.endTimestamps=obj.endTimestamps(stidx);
                obj.bfidx=obj.bfidx(stidx);
                obj.Duration=obj.endTimestamps(end);
                obj.MeasurementStart=obj.startTimestamps(1);
                obj.MeasurementEnd=max(obj.endTimestamps);
                obj.Results(1:length(obj.startTimestamps))={obj.defaultValue};
            else
                obj.Duration=0;
                obj.MeasurementStart=0;
                obj.MeasurementEnd=0;
            end
            
            if(obj.ExtenalClockRate<0)
                obj.ExtenalClockRate=obj.Rate;
            end
            obj.TimestampRateToExternalClockRatio=obj.Rate./obj.ExtenalClockRate;
            obj.resetMeasurementTimebinData();
            obj.IsMeasurementValid=1;
        end
        
        function finalizePending(obj)
            obj.processCompletedBins();
            
            %obj.clearPendingData();
        end
    end
    
    % measurement processing. 
    methods (Access = protected)
        function resetMeasurementTimebinData(obj)
            obj.MeasurementStartTS=-1;
            obj.compleatedBins=[];
        end
        
        function onCompleteMeasurement(obj)
            ev=EventStruct;
            ev.Data=(now-obj.MeasurementStartTS)*24*60*60/obj.timeUnitsToSecond;
            obj.notify('Complete',ev);
        end
        
        function [idxs]=fastFindTimeIndexs(obj,st,en,sts,ets,isInclusive)
            if(~exist('ets','var'))ets=sts;end
            if(~exist('isInclusive','var'))isInclusive=0;end
            
            if(isInclusive)
                idxs=find(ets>st & sts<en);
            else
                idxs=find(sts>=st & ets<=en);
            end      
        end
        
        function clearPendingData(obj)
            obj.rawData=[]; % bins to measure.
            obj.rawTimestamps=[];
        end
        
        % assume timestamps are orederd.
        function [idxs]=fastFindMultiOrderedIndexs(obj,ts,compareTo,findMax)
            lt=length(ts);
            lcomp=length(compareTo);
            idxs=ones(lt,1)*-1;
            
            ots=ts;
            [ts,sidx]=sort(ts);
            
            if(findMax)
                srcidxs=lt:-1:1;
                ctidx=lcomp;
            else
                srcidxs=1:lt;
                ctidx=1;
            end
            
            abort=0;
            for i=srcidxs
                % searching for the next index where
                % a change in value is found.
                
                while(true)
                    t=ts(i);
                    tsi=compareTo(ctidx);
                    
                    if(findMax && t>=tsi || ~findMax&& t<=tsi) % for both max and min. max is backwards.
                        % moved on to the next val.
                        idxs(i)=ctidx;
                        break;
                    end
                    if(~findMax)
                        ctidx=ctidx+1;
                        if(ctidx>lcomp)
                            abort=1;
                            break;
                        end
                    else
                        ctidx=ctidx-1;
                        if(ctidx<1)
                            abort=1;
                            break;
                        end                        
                    end
                end
                
                if(abort)
                    break;% out of search pattern.
                end            
            end
            idxs=idxs(sidx);
        end
        
        function cleanProcessedRawData(obj)
            % check if any other bin not included has a final timestamp
            % larger.
            maxt=obj.rawTimestamps(end);
            
            % finding the maxt to remove from.
            tic;
            lts=length(obj.endTimestamps);
            % anything crosses.
            vidxs=find(obj.endTimestamps>=maxt & obj.startTimestamps<=maxt);
            if(~isempty(vidxs))
                maxt=min(obj.startTimestamps(vidxs));
                % we have something withing therefore keep the last.
                % just in case. (Edge condition for numeric sum).
                maxt=maxt-obj.getTimebase();
            end
           
            comp=toc;
            
            % max index to delete.
            if(obj.rawTimestamps(1)>=maxt)
                return; % nothing to do.
            end
            
            % finding where to delete to.
            [~,mitd]=min(abs(obj.rawTimestamps-maxt));
            lrt=length(obj.rawTimestamps);
            
            while(mitd>0 && obj.rawTimestamps(mitd)>=maxt)
                mitd=mitd-1; % remove
                if(mitd==0)
                    return;
                end
            end

            
            %mitd=find(obj.rawTimestamps>maxt,1,'first');
            obj.rawTimestamps(1:mitd)=[]; % delete.
            obj.rawData(1:mitd)=[]; % delete. 
        end
        
        function [bidxs,bstart,bend,fidxs,ts,data]=getPendingIndexsAndData(obj)
            % all cells within the range.
            lrts=length(obj.rawTimestamps);
            %rawts=obj.rawTimestamps;         
            mint=obj.rawTimestamps(1);
            maxt=obj.rawTimestamps(end);

            % defults.
            bidxs=obj.fastFindTimeIndexs(mint,maxt,obj.startTimestamps,obj.endTimestamps);
            bstart=[];
            bend=[];
            fidxs=[];
            ts=[];
            data=[];
            if(isempty(bidxs))
                return;
            end
            
            % removing completed.
            if(~isempty(obj.compleatedBins))
                bidxs=setdiff(bidxs,obj.compleatedBins);
                % check again.
                if(isempty(bidxs))
                    return;
                end                
            end
            
            % marking as compelted.
            obj.compleatedBins(end+1:end+length(bidxs))=bidxs;
            
            % export data.
            bstart=obj.startTimestamps(bidxs);
            bend=obj.endTimestamps(bidxs);
            fidxs=obj.bfidx(bidxs);
           
            st=bstart(1);
            et=max(bend(end));
            tsidxs=obj.fastFindTimeIndexs(st,et,obj.rawTimestamps);
            ts=obj.rawTimestamps(tsidxs);
            data=obj.rawData(tsidxs);
        end
        
        function [comp]=processCompletedBins(obj,cleanProcessed)
            if(~exist('cleanProcessed','var'))cleanProcessed=1;end
            
            % finding completed bins idxs.
            if(isempty(obj.rawTimestamps)) % nothing to do.
                return;
            end
            
            tic;
            [bidxs,bstart,bend,fidxs,tsdata,rdata]=obj.getPendingIndexsAndData();
            comp(1)=toc;
            
            % at this T we need to remove.
            if(cleanProcessed)
                tic;
                obj.cleanProcessedRawData();
                comp(end+1)=toc;
            end
            
            if(isempty(bidxs))return;end
            
            if(isempty(tsdata))
                warning('Found ready measurement bins without any data. Measurement rate too slow?');
                return;
            end
            
            % make default values (so not to remake in loop).
            tic;
            lbins=length(bidxs);
            rslts={};
            rslts(1:lbins)={[0,0]}; % default value.
            comp(end+1)=toc;
            
            % Parmeters for loop.
            lstfidx=-1;
            
            % finding indexs.
            tic;
            minidxs=obj.fastFindMultiOrderedIndexs(bstart,tsdata,0);
            maxidxs=obj.fastFindMultiOrderedIndexs(bend,tsdata,1);
            comp(end+1)=toc;
            
            tic;
            for i=1:length(minidxs)
                mini=minidxs(i);
                maxi=maxidxs(i);
                
                matchedIdxs=mini:maxi;
                if(mini<=0 || maxi<=0 || isempty(matchedIdxs))
                    continue;
                    %rsltMap(idx,:)=[0,0];
                end
                
                vd=rdata(matchedIdxs);
                vts=tsdata(matchedIdxs);
                fidx=fidxs(i);
                if(lstfidx<0 || lstfidx~=fidx)
                    f=obj.fmap{fidx};
                    lstfidx=fidx;
                end
                
                % some unknown result vector..
                rslts{i}=f(vts',vd');
            end
            
            % writing results.
            comp(end+1)=toc;
            
            tic;
            obj.Results(bidxs)=rslts;
            comp(end+1)=toc;
            
            tic;
            evd=EventStruct;
            evd.Data=bidxs;
            obj.notify('TimebinComplete',evd);
            comp(end+1)=toc;
        end
        
        function callProcessComplete(obj)
            disp('Completed');
        end
        
        % process the measurements for the specific timestamps.
        function processMeasurement(obj,timestamps,data,ev)
            % find appropriate timebins.
            if(isempty(obj.startTimestamps) || isempty(timestamps)) 
                return;
            end
            
            % before measurement started.
            if(timestamps(end)<obj.MeasurementStart)
                obj.resetMeasurementTimebinData();
                return;
            end
            
            % out of bounds on end, reset measurement ts and call complete.
            if(timestamps(1)>obj.MeasurementEnd)
                if(obj.MeasurementStartTS>-1)
                    obj.onCompleteMeasurement();
                end
                
                obj.resetMeasurementTimebinData();
                return;
            end

            % measurement.
            if(obj.MeasurementStartTS<0)
                obj.MeasurementStartTS=now;
            end
            
            % exrnding the search criteria since we might fall between the
            % timebase.
            sstart=obj.MeasurementStart-obj.getTimebase();
            send=obj.MeasurementEnd+obj.getTimebase();
            vidxs=find(timestamps>=sstart &...
                timestamps<=send);
            
            timestamps=timestamps(vidxs);
            data=data(vidxs);
            ldata=length(vidxs);
            
            % adding to raw data.
            tic;
            obj.rawTimestamps(end+1:end+ldata)=timestamps;
            obj.rawData(end+1:end+ldata)=data;
            appendt=toc;
            
            % checking for compleated bins.
            comp=0;
            [tms]=obj.processCompletedBins();
            comp=sum(tms);
            if(comp>obj.BatchProcessingWarnMinTime/1000)
                disp(['TimedDataCollector: Batch processing time is hight[ms]: '...
                    ,num2str(comp*1000)]);
            end
            
            if(timestamps(end)>=obj.MeasurementEnd)
                if(obj.MeasurementStartTS>-1)
                    obj.onCompleteMeasurement();
                end
                
                obj.resetMeasurementTimebinData();
            end
        end
    end
end

