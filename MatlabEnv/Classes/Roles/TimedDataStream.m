classdef TimedDataStream < TimeKeeper
    %TIMEDDATASTREAM Implements a timed data stream that allows data to
    %be added by channel and by time. Timed events allow for adding
    %specialized data markers at specific timed locations.
    
    properties(Access = private)
        m_tkEvents={};
        m_tkEventsT=[];
        m_tkData=[];
        m_tkDataT=[];
        m_tkStream={};
        m_tkStreamT={};
        m_tkIsValid=false;
    end
    
    properties
        % if true, when inserting new times, into diffrent channels the
        % values in channels not inserted are copied to the inserted
        % values.
        PersistValuesWhenInsertingTimes=true;
    end
    
    properties(SetAccess = private)
        IsTimedDataStreamValid=false;
    end
    
    methods
        function [rt]=get.IsTimedDataStreamValid(obj)
            rt=obj.m_tkIsValid;
        end
        
        function InvalidateTimedStream(obj)
            obj.m_tkIsValid=false;
        end
        
        function SetTimedData(obj,t,data,chans)
            % sets timed data. Used property chans to specific the channel.
            % data channels is in the columns.
            if(~iscolumn(t))
                t=t';
            end
            
            sdata=size(data);
            if(sdata(1)~=length(t))
                error('TimeKeeper:error:Length of vector t must be equal to the number of rows in data');
            end
            if(~exist('chans','var'))
                chans=1:sdata(2); % on colums.
            elseif(sdata(2)==1&&length(chans)>1)
                data=repmat(data,1,length(chans));
                sdata=size(data);
            end
            
            if(length(chans)~=sdata(2))
                error('TimeKeeper:error:Number of columns in data must match the number of channels.');
            end
            
            if(sdata(2)==1 && length(chans)>1)
                data=repmat(data,1,length(chans));
            end
            
            obj.m_tkIsValid=false;
            
            % first remove duplicates from input.
            [t,idxs]=unique(t,'last');
            data=data(idxs,:);
            
            % finding the maximal channel.
            maxChan=max(chans);
            sdata=size(obj.m_tkData);
            maxCurChan=sdata(2);
            if(maxCurChan>maxChan)
                maxChan=maxCurChan;
            end   
            
            % for empties.
            if(isempty(obj.m_tkDataT))
                obj.m_tkDataT=t;
                obj.m_tkData=zeros(length(t),maxChan);
                obj.m_tkData(:,chans)=data;
                return;
            end
            
            % need to remake the data by doing inserts.
            % first make the new data sets.
            [ct,cdata]=TimedDataStream.f_sInsertNewTimes(t,obj.m_tkDataT,obj.m_tkData,...
                obj.PersistValuesWhenInsertingTimes);
            
            % interpolating to insert the new data values to appropriate t.
            if(length(ct)==1)
                ndidxs=1;
            else
                ndidxs=interp1(ct,1:length(ct),t,'previous','extrap');
            end
            cdata(ndidxs,chans)=data;
            
            % copy new data.
            obj.m_tkDataT=ct;
            obj.m_tkData=cdata;
        end
        
        function SetTimedEvent(obj,t,eventInfos)
            % sets events into the TimedDataStream.
            if(~iscell(eventInfos))
                eventInfos={eventInfos};
            end
            
            if(length(t)~=length(eventInfos))
                error('length of vector t(1) must be equal to length of cell vector eventInfos(2)');
            end
            
            if(~iscolumn(t))
                t=t';
            end
            
            obj.m_tkIsValid=false;
            
            if(isempty(obj.m_tkEventsT))
                obj.m_tkEventsT=t;
                obj.m_tkEvents=eventInfos;
                return;
            end
            
            % checking for missing t values.
            missingt=setdiff(t,obj.m_tkEventsT);
            ct=[obj.m_tkEventsT;missingt];
            cdata=[obj.m_tkEvents;cell(1,length(missingt))];
            
            % sorting the new times.
            [ct,idxs]=sort(ct);
            cdata=cdata(idxs);
            
            % inserting the new indexs.
            if(length(ct)==1)
                nidxs=1;
            else
                nidxs=interp1(ct,1:length(ct),t,'previous','extrap');
            end
            
            cdata(nidxs)=eventInfos;
            
            obj.m_tkEventsT=ct;
            obj.m_tkEvents=cdata;
        end
        
        function clear(obj)
            obj.m_tkEvents={};
            obj.m_tkEventsT=[];
            obj.m_tkData=[];
            obj.m_tkDataT=[];
            obj.m_tkStream={};
            obj.m_tkStreamT=[];
            obj.m_tkIsValid=false;
            obj.curT=0;
        end
        
        function [mint]=getMinDuration(obj)
            % returns the minimal diffrence between all the times
            % in the data stream. If not min time is found (empty or 1
            % element) returns empty;
            diffs=diff(sort([obj.m_tkDataT;obj.m_tkEventsT]));
            mint=[];
            if(isempty(diffs))
                return;
            end
            mint=min(diffs);
        end
        
        function [t,strm]=getTimedStream(obj)
            % compiles and returns the timed stream. The stream is composed
            % of cells.
            
            if(obj.m_tkIsValid)
               strm=obj.m_tkStream;
               t=obj.m_tkStreamT;
               return;
            end
               
            if(~isempty(obj.m_tkDataT))
                rawT=obj.m_tkDataT;
                rawData=obj.m_tkData;
                if(rawT(1)>0)
                    rawT=[0;rawT];
                    sdata=size(rawData);
                    rawData=[zeros(1,sdata(2));rawData];
                end
                durations=[diff(rawT);0];      
            else
                rawT=[];
                durations=[];
                rawData=[];
            end
            
            % checks for empties.
            areValuesSet=false;
            if(isempty(obj.m_tkDataT) && isempty(obj.m_tkEventsT))
                t=[];
                strm={};
                areValuesSet=true;
            elseif(isempty(rawT))
                t=obj.m_tkEventsT;
                strm=obj.m_tkEvents;
                areValuesSet=true;
            elseif(isempty(obj.m_tkEventsT))
                t=0;
                strm={[durations,rawData]};
                areValuesSet=true;
            end
            if(areValuesSet)
                obj.m_tkStream=strm;
                obj.m_tkStreamT=t;
                obj.m_tkIsValid=true;
                return;
            end
            
            % checkinf for missing data values for event times.
            % need to remake the data by doing inserts.
            % first make the new data sets.
            [rawT,rawData]=TimedDataStream.f_sInsertNewTimes(obj.m_tkEventsT,...
                rawT,rawData,true);
            
            %redo the durations (since we have new ones).
            durations=[diff(rawT);0];
            
            % find intersection of data.
            dlen=length(rawT);
            if(dlen>1)
                itcIdxs=interp1(rawT,1:dlen,...
                    obj.m_tkEventsT,'previous','extrap');
            else
                itcIdxs=1;
            end
            
            if(any(isnan(itcIdxs)))
                error('Error while processing stream. Event t not found.');
            end
            
            % searching for all indexs.
            strm={};
            t=[];
            curDataIndex=1;
            lastT=0;
            for i=1:length(itcIdxs)
                idx=itcIdxs(i);
                didx=idx-1;

                % appending the event.
                if(didx>=curDataIndex)
                    % data vectors (durations).
                    ti=durations(curDataIndex:didx);
                    bi=rawData(curDataIndex:didx,:);
                    strm{end+1}=[ti,bi];
                    % start position.
                    t(end+1)=rawT(curDataIndex);
                    curDataIndex=didx+1;
                end
                
                strm{end+1}=obj.m_tkEvents{i};
                t(end+1)=obj.m_tkEventsT(i);                
                                
            end
            
            if(curDataIndex<=dlen)
                % data vectors (durations).
                ti=durations(curDataIndex:end);
                bi=rawData(curDataIndex:end,:);
                strm{end+1}=[ti,bi];
                % start position.
                t(end+1)=rawT(curDataIndex);
            end
            
            t=t';
            strm=strm';
            obj.m_tkStream=strm;
            obj.m_tkStreamT=t;
            obj.m_tkIsValid=true;
        end
    end
    
    methods(Static, Access = private)
        function [t,data]=f_sInsertNewTimes(newT,t,data,persistOld)
            
            if(~exist('persistOld','var'))
                persistOld=true;
            end
            
            % need to remake the data by doing inserts.
            % first make the new data sets.
            sdata=size(data);
            missingt=setdiff(newT,t);
            % the new times.
            ct=[t;missingt];
            % the new data.
            cdata=zeros(length(ct),sdata(2));
            
            % copy old data;
            cdata(1:length(t),1:sdata(2))=data;
            
            % interpolating time positions to extend the data.
            if(persistOld && ~isempty(t))
                if(length(t)==1)
                    ndidxs=1;
                else
                    ndidxs=interp1(t,1:length(t),missingt,...
                        'previous','extrap');                    
                end

                ndidxs(isnan(ndidxs))=1;
                if(~isempty(missingt))
                    cdata(length(t)+1:end,:)=cdata(ndidxs,:);
                end
            end
            
            % sorting the new data.
            [ct,idxs]=sort(ct);
            cdata=cdata(idxs,:);
            
            t=ct;
            data=cdata;
        end
    end
end

