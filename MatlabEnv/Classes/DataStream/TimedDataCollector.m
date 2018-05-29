classdef TimedDataCollector < handle & DataStream
    %DATACOLLECTOR Summary of this class goes here
    %   Detailed explanation goes here
    methods
        % define the reader.
        function obj = TimedDataCollector(reader)
            % call to stop operation if any.
            % default status.
            obj@DataStream(reader,false);
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
        LastResultsMeasured=0;
        MeasurementCompletedTimePrecentage=0;
    end

    % timebinned measurement definitions.
    properties (Access = protected)
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
    
    % attribute getters.
    methods
        function [rt]=get.MeasurementCompletedTimePrecentage(obj)
            rt=100*obj.CurrentMeasurementDuration./obj.Duration;
        end        
    end
    
    % called when data is ready.
    methods (Access = protected)

        % converst the data timestamps to valid data ranges. 
        function [vts,tOffset]=shiftTimestampsToValidRange(obj,ts)
            vts={};
            tOffset=[];
            
            % splice constants.
            maxT=obj.MeasurementEnd;
            lastStarted=(ceil(ts(1)/maxT)-1)*maxT; % not including edge.
            if(lastStarted<0)
                lastStarted=0; % first start.
            end
            
            % shift the timestamps according to the last measurement start.
            ts=ts-lastStarted;
            
            if(ts(end)<maxT)
                % all values.
                tOffset=lastStarted;
                return;
            end
            
            % splicing vector according to timestamps.
            splitLocs=find(diff([0;floor(ts/maxT)])>0); % the locations.
            splitLocs(end+1)=length(ts); % always split at end.
            lts=length(ts);
            lastLoc=1;
            
            for idx=splitLocs
                vts{end+1}=lastLoc:idx;
                tOffset(end+1)=lastStarted;
                if(idx<lts)
                    % advance to next measurement.
                    lastStarted=lastStarted+ts(idx+1);
                    lastLoc=idx+1;
                else
                    break;
                end
            end
        end
        
        function dataBatchAvailableFromDevice(obj,s,e)
            if(~obj.IsRunning)return;end;
            if(~obj.IsMeasurementValid)obj.prepare();end
            if(obj.Duration==0)return;end
            
            if(~isempty(e.TimeStamps))
                obj.CurrentMeasurementDuration=...
                    (e.TimeStamps(end)-obj.MeasurementStart);
            end

            % if not continues then nothing to do here.
            if(~obj.IsContinues)
                obj.processMeasurement(e.TimeStamps,e.Data,e);
                return;
            end
            
            [vts,tOffset]=obj.shiftTimestampsToValidRange(e.TimeStamps);
            if(isempty(vts))
                if(e.TimeStamps(1)-tOffset<obj.getTimebase())
                    obj.resetMeasurementTimebinData();
                end
                obj.processMeasurement(e.TimeStamps-tOffset,e.Data,e);
                return;
            end
            
            for i=1:length(vts)
                vidxs=vts{i};
                
                % check if need to reset the current data set.
                if(i>1)
                    obj.resetMeasurementTimebinData();
                end
                
                if(isempty(vidxs))
                    continue;
                end
                
                % convert timestamps from seconds.
                obj.processMeasurement(e.TimeStamps(vidxs)-tOffset(i),e.Data(vidxs));
            end
            obj.LastCollectedTimestamp=e.TimeStamps(end);
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
            obj.IsRunning=0;
            obj.fmap={};
            obj.bfidx=[];
            obj.IsMeasurementValid=false;
            obj.startTimestamps=[];
            obj.endTimestamps=[];
            obj.clearData();
        end
        
        function []=start(obj)
            if(obj.IsRunning)
                return;
            end
            obj.clearData();
            start@DataStream(obj);
        end
        
        function []=reset(obj)
            obj.clearData();
        end
        
        function clearData(obj)
            obj.Results={};
            obj.ResultsMap=[];
            obj.clearPendingData();
            obj.resetMeasurementTimebinData();
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
            obj.processCompletedBins(true);
        end
    end
    
    % measurement processing. 
    methods (Access = protected)
        function resetMeasurementTimebinData(obj)
            obj.MeasurementStartTS=-1;
            obj.compleatedBins=[];
            obj.clearPendingData();
        end
        
        function onCompleteMeasurement(obj)
            obj.stop();
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
        
        function [bidxs,bstart,bend,fidxs,ts,data]=getPendingIndexsAndData(obj,inclusive)
            % all cells within the range.
            lrts=length(obj.rawTimestamps);
            %rawts=obj.rawTimestamps;
            mint=obj.rawTimestamps(1)-obj.getTimebase();
            maxt=obj.rawTimestamps(end);

            % defults.
            bidxs=obj.fastFindTimeIndexs(mint,maxt,obj.startTimestamps,obj.endTimestamps,inclusive);
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
        
        function [comp]=processCompletedBins(obj,inclusive,cleanProcessed)
            if(~exist('cleanProcessed','var'))cleanProcessed=1;end
            
            % finding completed bins idxs.
            if(isempty(obj.rawTimestamps)) % nothing to do.
                comp=0;
                return;
            end
            
            tic;
            [bidxs,bstart,bend,fidxs,tsdata,rdata]=obj.getPendingIndexsAndData(inclusive);
            comp(1)=toc;
            
            % at this T we need to remove.
            if(cleanProcessed)
                tic;
                obj.cleanProcessedRawData();
                comp(end+1)=toc;
            end
            
            if(isempty(bidxs))return;end
            
            if(isempty(tsdata))
                disp('Found ready measurement bins without any data. Measurement rate too slow?');
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
            
            % update the timestamp;
            % in ms.
            obj.LastResultsMeasured=now*24*60*60/obj.timeUnitsToSecond;
            
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
            
            % measurement.
            if(obj.MeasurementStartTS<0)
                obj.MeasurementStartTS=timestamps(1);
            end
            
            % exrnding the search criteria since we might fall between the
            % timebase.
            sstart=obj.MeasurementStart-obj.getTimebase();
            send=obj.MeasurementEnd+obj.getTimebase();
            
            hasEnded=timestamps(end)>=send;
            % fast check boundry.
            if(timestamps(1)>send || timestamps(end)<sstart)
                vidxs=[];
            else
                % in range.
                vidxs=find(timestamps>=sstart & timestamps<=send);
            end
            
            if(~isempty(vidxs))
                timestamps=timestamps(vidxs);
                data=data(vidxs);
                ldata=length(vidxs);

                % adding to raw data.
                tic;
                obj.rawTimestamps(end+1:end+ldata)=timestamps;
                obj.rawData(end+1:end+ldata)=data;
                appendt=toc;
            end
            
            % checking for compleated bins.
            comp=0;
            [tms]=obj.processCompletedBins(hasEnded); % if ended then inclusive.
            comp=sum(tms);
            if(comp>obj.BatchProcessingWarnMinTime*obj.timeUnitsToSecond)
                disp(['TimedDataCollector: Batch processing time is hight[ms]: '...
                    ,num2str(comp*1000)]);
            end
            
            if(timestamps(end)>=send)
                if(obj.MeasurementStartTS>-1)
                    obj.onCompleteMeasurement();
                end
                if(~obj.IsContinues)
                    obj.stop();
                end
                obj.resetMeasurementTimebinData();
            end
        end
    end
end

