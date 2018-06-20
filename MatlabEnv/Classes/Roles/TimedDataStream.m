classdef TimedDataStream < TimeKeeper
    %TIMEDDATASTREAM Implements a timed data stream that allows data to
    %be added by channel and by time. Timed events allow for adding
    %specialized data markers at specific timed locations.
    
    properties(Access = private)
        m_tkEvents=[];
        m_tkData={};
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
            if(min(sdata)==1 && ~iscolumn(data))
                data=data';
            end
            
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
            for i=1:length(chans)
                c=chans(i);
                obj.setChannelTimedData(c,t,data(:,i));
            end
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
            
            if(~iscolumn(eventInfos))
                eventInfos=eventInfos';
            end
            
            obj.m_tkIsValid=false;
            
            if(isempty(obj.m_tkEvents))
                obj.m_tkEvents=struct();
                obj.m_tkEvents.t=t;
                obj.m_tkEvents.events=eventInfos;
            else
                ct=obj.m_tkEvents.t;
                cevents=obj.m_tkEvents.events;
                ct=TimedDataStream.f_sInsertNewTimes(t,ct,[],false);
                
                % inserting the new indexs.
                if(length(ct)==1)
                    nidxs=1;
                else
                    nidxs=interp1(ct,1:length(ct),t,'previous','extrap');
                end

                cevents(nidxs)=eventInfos;     
                obj.m_tkEvents.t=ct;
                obj.m_tkEvents.events=cevents;
            end
        end
        
        function clear(obj)
            obj.m_tkEvents={};
            obj.m_tkData={};
            obj.m_tkStream={};
            obj.m_tkStreamT=[];
            obj.m_tkIsValid=false;
            obj.curT=0;
        end
        
        function [tvals]=getAllTimeValues(obj)
            tvals=[];
            for i=1:length(obj.m_tkData)
                if(~isstruct(obj.m_tkData{i}))
                    continue;
                end
                tvals=[tvals;obj.m_tkData{i}.t];
            end
            if(~isempty(obj.m_tkEvents))
                tvals=[tvals;obj.m_tkEvents.t];
            end   
            tvals=unique(tvals);
        end
        
        function [mint]=getMinDuration(obj)
            % returns the minimal diffrence between all the times
            % in the data stream. If not min time is found (empty or 1
            % element) returns empty;
            diffs=diff(obj.getAllTimeValues());
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
            
            % getting all combined data values and t values.
            ct=obj.getAllTimeValues();
            lt=length(ct);
            
            % check for no data.
            if(lt==0)
                if(isempty(obj.m_tkEvents))
                    strm={};
                    t=[];
                else
                    t=obj.m_tkEvents.t;
                    strm=obj.m_tkEvents;
                end
                return;
            end
            
            cdata=zeros(lt,length(obj.m_tkData));
            for i=1:length(obj.m_tkData)
                di=obj.m_tkData{i};
                if(~isstruct(di))
                    continue;
                end
                
                if(~iscolumn(di.data))
                    di.data=di.data';
                end
                
                [~,did]=TimedDataStream.f_sInsertNewTimes(ct,di.t,di.data,...
                    obj.PersistValuesWhenInsertingTimes);
                cdata(:,i)=did;
            end
            
            if(ct(1)>0)
                % add the zero time.
                lt=lt+1;
                ct=[0;ct];
                cdata=[zeros(size(cdata(1,:)));cdata];
            end  
            
            durations=[diff(ct);0]; % last duration is always zero.
            
            % removing duplocates.
            [ct,idxs]=unique(ct,'last');
            durations=durations(idxs);

            
            % check if there are not events to consider.
            if(isempty(obj.m_tkEvents))
                strm={[durations,cdata]};
                t=0;
                return;
            end
            
            % finding the event locations.
            if(lt>1)
                itcIdxs=interp1(ct,1:lt,...
                    obj.m_tkEvents.t,'previous','extrap');
                itcIdxs(isnan(itcIdxs))=0;
            else
                itcIdxs=1;
            end
            
            % creating the stream.
            % searching for all indexs.
            strm={};
            t=[];
            curDataIndex=1;
            lastT=0;
            for i=1:length(itcIdxs)
                idx=itcIdxs(i);
                % the data index.
                didx=idx-1;
                % appending the event.
                if(didx>=curDataIndex)
                    % data vectors (durations).
                    ti=durations(curDataIndex:didx);
                    bi=cdata(curDataIndex:didx,:);
                    strm{end+1}=[ti,bi];
                    % start position.
                    t(end+1)=ct(curDataIndex);
                    curDataIndex=didx+1;
                end
                
                strm{end+1}=obj.m_tkEvents.events{i};
                t(end+1)=obj.m_tkEvents.t(i);                
            end
            
            if(curDataIndex<=lt)
                % data vectors (durations).
                ti=durations(curDataIndex:end);
                bi=cdata(curDataIndex:end,:);
                strm{end+1}=[ti,bi];
                % start position.
                t(end+1)=ct(curDataIndex);
            end
            
            t=t';
            strm=strm';
        end
    end
    
    methods (Access = private)
        
        function setChannelTimedData(obj,c,t,data)
            % adds data to the sepcific channel.
            if(length(obj.m_tkData)<c || ~isstruct(obj.m_tkData{c}))
                obj.m_tkData{c}=struct('t',t,'data',data);
            else
                ct=obj.m_tkData{c}.t;
                cdata=obj.m_tkData{c}.data;
                
                [ct,cdata]=TimedDataStream.f_sInsertNewTimes(t,ct,cdata,...
                    obj.PersistValuesWhenInsertingTimes);
                
                if(length(ct)~=length(cdata))
                    error('Error when inserting new times, time vector imbalance.');
                end
                if(length(ct)==1)
                    nidxs=1;
                else
                    nidxs=interp1(ct,1:length(ct),t,'previous','extrap');
                end
                
                cdata(nidxs)=data;
                obj.m_tkData{c}.t=ct;
                obj.m_tkData{c}.data=cdata;
            end
        end
    end
    
    methods(Static, Access = private)
        function [t,data]=f_sInsertNewTimes(newT,t,data,persistOld)
            
            if(~exist('persistOld','var'))
                persistOld=true;
            end
            
            % need to remake the data by doing inserts.
            % first make the new data sets.
            missingt=setdiff(newT,t);
            
            % nothing needed?
            if(isempty(missingt))
                return;
            end
            
            % finding missing t's that are before the minimal t.
            beforeMint=missingt(missingt<min(t));
            if(~isempty(beforeMint))
                % need to put zeros on that.
                missingt=missingt(missingt>=min(t));
                t=[beforeMint;t];
                data=[zeros(length(beforeMint),1);data];
            end
            
            % the new times.
            ct=[t;missingt];
            
            if(~isempty(data))
                sdata=size(data);
                % the new data.
                cdata=zeros(length(ct),sdata(2));
                % copy old data;
                cdata(1:length(t),1:sdata(2))=data;
            end
            
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
            t=ct;
            if(~isempty(data))
                data=cdata(idxs,:);
            end
        end
    end
end

