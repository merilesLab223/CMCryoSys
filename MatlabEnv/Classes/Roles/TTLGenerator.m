classdef TTLGenerator < TimedDataStream & TimeBasedObject
    %TTLGEN A ttl generation class (abstract) that allows for the creation
    % of TTL signals vs time.
    
    % NOTE!! ---------------------------
    % Requires the abstract method compileSequence(obj,t,data)
    % ----------------------------------
    properties
        defaultPulseWidth=0.1; % in ms.   
        Channel=1;
        ReduceTTLloops=true;
        MaxReducedLoopLength=500;
        % set to true if the TTL generator is to advance the times
        % automatically. (On call to Pulse, Up, Down ... etc).
        AutoAdvnceTimes=true;
    end
    
    properties(Constant)
        LOOPStartStruct=struct('type','loopstart','n',0);
        LOOPEndStruct=struct('type','loopend');
    end
    
    % TTL Methods
    methods  
        
        function SetBits(obj,b,dur,chan)
            % Sets the output bits, for durations dur, starting at
            % time obj.curT at channels chan.            
            obj.SetBitsAt(b,obj.curT,dur,chan);
            if(obj.AutoAdvnceTimes)
                obj.wait(sum(dur));
            end
        end
        
        function SetBitsAt(obj,b,t,dur,chan)
            % Sets the output bits, for durations dur, starting at
            % time t at channels chan.
            if(~exist('chan','var') || isempty(chan))
                chan=obj.Channel;
            end
            t=double(t);
            dur=double(dur);
            
            lv=size(b);
            lv=lv(1);
            if(~exist('dur','var') || isempty(dur))
                dur=ones(size(t))*obj.getTimeBase();
            end
            
            if(~isnumeric(chan) || any(chan<1))
                error('Channel must be the channel index. 1->INF');
            end
            
            if(length(dur)~=lv)
                error('The number of rows in bits(b) and time(dur) must be equal. ');
            end
            
            % calculating times and appending last values.
            if(length(dur)==1)
                t=t(1);
            else
                t=t(1)+[0;cumsum(dur(1:end-1))]; % last one dosent count..
            end
   
            % setting the timed data.
            obj.SetTimedData(t,b,chan);
        end
        
        function Up(obj,c)
            % Set the values to be up for period(s) dur.
            if(~exist('c','var') || isempty(c))
                c=obj.Channel;
            end
            obj.SetBitsAt(ones(1,length(c)),obj.curT,0,c);
        end
        
        function Down(obj,c)
            % Set the values to be down for period(s) dur.
            if(~exist('c','var') || isempty(c))
                c=obj.Channel;
            end
            obj.SetBitsAt(zeros(1,length(c)),obj.curT,0,c);
        end
        
        function PulseAt(obj,t,durUp,c)
            if(~exist('c','var')||isempty(c))
                c=obj.Channel;
            end            
            % calculate pulse times.
            
            if(~exist('durUp','var') || isempty(durUp))
                durUp=obj.defaultPulseWidth;
            end
            if(length(durUp)==1)
                durUp=ones(size(t))*durUp;
            end
            
            % making the pulse times.
            obj.curT=t(1);
            tdown=t+durUp;
            durations=[0;diff(sort([t;tdown]))];
            obj.Pulse(durations(1:2:end-1),durations(2:2:end),c);
        end

        function Pulse(obj,durUp,durDown,c)
            % Sets the up/down pulses to specific times.
            if(~exist('c','var')||isempty(c))
                c=obj.Channel;
            end
            if(~exist('durUp','var') || isempty(durUp))
                durUp=obj.defaultPulseWidth;
            end
            if(~exist('durDown','var') || isempty(durDown))
                durDown=ones(size(durUp))*obj.getTimebase();
            end
            
            ld=length(durUp);
            if(length(durDown)~=ld)
                error('The number of values in durUp must equal the number of values in durDown');
            end
            
            % interweaving durations.
            dur=zeros(ld*2,1);
            bits=zeros(ld*2,1);
            dur(1:2:end-1)=durUp;
            dur(2:2:end)=durDown;
            bits(1:2:end-1)=1;
            bits(2:2:end)=0;
            obj.SetBits(bits,dur,c);
        end
        
        function ClockSignal(obj,dur,freq,c,dutyCycle)
            % create a clock signal at time curT for duration dur.
            if(~exist('c','var'))
                c=obj.Channel;
            end
            
            if(~exist('dutyCycle','var'))
                dutyCycle=0.5;
            end
            
            tup=obj.secondsToTimebase(1/freq);
            tdown=tup*(1-dutyCycle);
            tup=tup*dutyCycle;
            n=floor(dur/(tup+tdown));
            
            % finding rem.
            remTime=dur-n*(tup+tdown);
            
            if(n>0)
                tup=repmat(tup,n,1);
                tdown=repmat(tdown,n,1);
                obj.Pulse(tup,tdown,c);
            end
            
            if(remTime==0)
                return;
            end
            if(remTime>tup)
                obj.Pulse(tup,remTime-tup,c);
            else
                obj.Up(remTime,c);
            end
        end
        
        function [dur]=getTotalDuration(obj)
            % slow version.
            [t,strm]=obj.getTimedStream();
            dur=TTLGenerator.f_sGetStreamDuration(t,strm);
        end

        function [ttl,t]=getTTLVectors(obj,loopTypeFilter)
            if(~exist('loopTypeFilter','var'))
                loopTypeFilter=[];
            elseif(ischar(loopTypeFilter))
                loopTypeFilter={loopTypeFilter};
            elseif(islogical(loopTypeFilter) && ~loopTypeFilter)
                loopTypeFilter={};
            elseif(~iscell(loopTypeFilter))
                loopTypeFilter=[];
            end
            
            [t,strm]=obj.getTimedStream();
            [ttl,durs]=TTLGenerator.f_sStreamToTTLVectors(t,strm,loopTypeFilter);
            if(isempty(durs))
                t=[];
                ttl=[];
                return;
            end
            t=[0;cumsum(durs(1:end-1))]; % covert durations to time.
        end
        
        function [curT]=StartLoop(obj,n,ltype)
            if(~exist('ltype','var'))
                ltype='';
            end
            li=obj.LOOPStartStruct;
            li.looptype=ltype;
            li.n=double(n);
            obj.SetTimedEvent(obj.curT,li);
            curT=obj.curT;
        end
        
        function EndLoop(obj)
            li=obj.LOOPEndStruct;
            obj.SetTimedEvent(obj.curT,li);
        end
    end
    
    methods(Static, Access = protected)
        
        function [ttl,durs]=f_sStreamToTTLVectors(st,strm,loopTypeFilter)
            doLoopFiltering=iscell(loopTypeFilter);
            durs=[];
            ttl=[];
            idx=1;
            lstrm=length(strm);
            while(idx<=lstrm)
                si=strm{idx};
                if(isstruct(si))
                    % event struct.
                    if(~isfield(si,'type'))
                        idx=idx+1;
                        continue;
                    end
                    
                    switch(si.type)
                        case 'loopstart'
                            eidx=TTLGenerator.f_sFindStreamLoopEnd(idx+1,strm);
                            [ittl,ldurs]=TTLGenerator.f_sStreamToTTLVectors(...
                                st(idx+1:eidx-1),strm(idx+1:eidx-1),loopTypeFilter);
                            
                            doLoop=true;
                            if(doLoopFiltering)
                                doLoop=isfield(si,'looptype') && ...
                                    any(strcmp(si.looptype,loopTypeFilter));
                            end
                            if(doLoop)                               
                                ittl=repmat(ittl,si.n,1);
                                ldurs=repmat(ldurs,si.n,1);
                            end
                            
                            itl=length(ldurs);
                            durs(end+1:end+itl)=ldurs;
                            ttl(end+1:end+itl,:)=ittl;
                            idx=eidx+1;
                            continue;
                        case 'loopend'
                            error('reached loopend without a loop start.');
                        otherwise
                            idx=idx+1;
                            continue;
                    end
                end
                
                % normal data, append.
                %ti=cumsum(si(:,1))+toffset;
                duri=si(:,1);
                bi=si(:,2:end);
                li=length(duri);
                
                ttl(end+1:end+li,:)=bi;
                durs(end+1:end+li)=duri;
                idx=idx+1;
            end
            durs=durs';
        end
        
        function [dur]=f_sGetStreamDuration(t,strm)
            lstrm=length(strm);
            idx=1;
            dur=0;
            while(idx<=lstrm)
                si=strm{idx};
                
                if(isstruct(si))
                    % event struct.
                    if(~isfield(si,'type'))
                        idx=idx+1;
                        continue;
                    end
                    
                    switch(si.type)
                        case 'loopstart'
                            eidx=TTLGenerator.f_sFindStreamLoopEnd(idx+1,strm);
                            [ldur]=TTLGenerator.f_sGetStreamDuration(...
                                t(idx+1:eidx-1),strm(idx+1:eidx-1));
                            dur=dur+ldur*si.n;
                            idx=eidx+1;
                            continue;
                        case 'loopend'
                            error('reached loopend without a loop start.');
                        otherwise
                            idx=idx+1;
                            continue;
                    end
                end
                
                dur=dur+sum(si(:,1)); % total duration.
                idx=idx+1;
            end
        end
        
        function [idx]=f_sFindStreamLoopEnd(idx,strm)
            openLoopCount=1;
            ls=length(strm);
            while(idx<ls)
                si=strm{idx};
                
                if(~isstruct(si) || ~isfield(si,'type') )
                    idx=idx+1;
                    continue;
                end
                switch(si.type)
                    case 'loopend'
                        openLoopCount=openLoopCount-1;
                    case 'loopstart'
                        openLoopCount=openLoopCount+1;
                    otherwise
                        idx=idx+1;
                        continue;
                end
                if(openLoopCount<1)
                    break;
                end
                idx=idx+1;
            end
        end
    end
    
    properties(Access = private)
        m_ttlStream=[];
        m_ttlStreamT=[];
    end
    
    % compilation methods.
    methods
        function [t,strm]=getTimedStream(obj)
            % returns the times stream as compiled by the stream collector.
            % id do reduce loops is active then loops are reduced if
            % possible.
            if(obj.IsTimedDataStreamValid)
                t=obj.m_ttlStreamT;
                strm=obj.m_ttlStream;
                return;
            end
            
            try
                % processing the stream.
                [t,strm]=getTimedStream@TimedDataStream(obj);
                
                if(obj.ReduceTTLloops)
                    [t,strm]=obj.FindLoopsAndReduce(t,strm);
                end
                
            catch err
                obj.InvalidateTimedStream;
                rethrow(err);
            end
            
            obj.m_ttlStreamT=t;
            obj.m_ttlStream=strm;
        end        
    end
    
    methods (Access = protected)
        function [t,strm]=FindLoopsAndReduce(obj,tin,strmin)
            strm={};
            t=[];
            for i=1:length(strmin)
                si=strmin{i};
                if(isstruct(si))
                    strm{end+1}=si;
                    t(end+1)=tin(i);
                    continue;
                end
                
                % not a struct, we need t find loops and then
                % reduce.
                %duri=si(:,1);
                
                duri=si(:,1);
                ti=cumsum(duri); % last dosent count.
                ti=[0;ti(1:end-1)]+tin(i);
                bi=si(:,2:end);
                chanN=size(bi);
                chanN=chanN(2);
                if(length(duri)<=1)
                    t(end+1)=tin(i);
                    strm{end+1}=si;
                    continue;
                end
                
                durs=repmat(duri,1,chanN).*bi;
                
                [linfo]=TTLGenerator.f_sFindLoops(...
                    durs,obj.MaxReducedLoopLength);
                lin=size(linfo);
                lin=lin(2);
                lastIdx=1;
                for i=1:lin
                    loopi=linfo(:,i);
                    idx=loopi(1);
                    len=loopi(2);
                    n=loopi(3);
                    if(idx>lastIdx)
                        % need to add data before loop.
                        t(end+1)=ti(lastIdx);
                        strm{end+1}=si(lastIdx:idx-1,:);
                    end
                    lastIdx=idx+n*len;
                    eidx=lastIdx-1;
                    vdidxs=idx:idx+len-1;
                    % adding loop info.
                    li=obj.LOOPStartStruct;
                    li.n=n;
                    t(end+1)=ti(idx);
                    strm{end+1}=li;
                    ldata=si(vdidxs,:);
                    t(end+1)=ti(idx);
                    strm{end+1}=ldata;
                    li=obj.LOOPEndStruct;
                    strm{end+1}=li;
                    t(end+1)=ti(eidx);
                end
                
                if(lastIdx<=length(ti))
                    % need to add data before loop.
                    t(end+1)=ti(lastIdx);
                    strm{end+1}=si(lastIdx:end,:);
                end
            end
            strm=strm';
        end        
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% helper methods.
    methods (Static, Access = protected)    
        function [loopinfo]=f_sFindLoops(data,maxn,allowOverlap)
            if(~exist('maxn','var'))maxn=Inf;end
            if(~exist('allowOverlap','var'))allowOverlap=0;end
            sdata=size(data);
            l=sdata(1);
            src=[];
            lidx=1;
            loopinfo=[];
            unlooped=[];
            sidx=0;
            lastMatchLength=0;
            lastMatchI=0;
            lastMatchLoopN=0;
            minSearchI=0;
            
            for i=1:l
                % case something was already found.
                unlooped(end+1,:)=data(i,:);
                if(lastMatchLength~=0)
                    % check succesive is ok.
                    if(~isequal(src(sidx,:),unlooped(end,:))) % check match.
                        if(lastMatchLoopN>0)
                            % found something to write home about.
                            loopinfo(1,lidx)=lastMatchI;
                            loopinfo(2,lidx)=lastMatchLength;
                            loopinfo(3,lidx)=lastMatchLoopN+1;
                            lidx=lidx+1;
                            if(~allowOverlap)
                                minSearchI=i-1;
                            end
                        end
                        % search for new location.
                        lastMatchLength=0;
                        lastMatchLoopN=0;
                    elseif(sidx+1>lastMatchLength)
                        sidx=1; % another loop?
                        lastMatchLoopN=lastMatchLoopN+1;
                    else
                        sidx=sidx+1;
                    end
                end
                % search if needed
                if(lastMatchLength==0)
                    clen=1;
                    while(i-clen>minSearchI && clen<=maxn)
                        if(isequal(unlooped(end,:),unlooped(i-clen,:)))
                            % found match lookback.
                            lastMatchI=i-clen;
                            lastMatchLength=clen;
                            lastMatchLoopN=0;
                            src=unlooped(i-clen:i-1,:);
                            if(clen==1)
                                sidx=1; % reset search.
                                lastMatchLoopN=1;
                            else
                                sidx=2; % first was matched.
                            end
                            
                            break;
                        end
                        clen=clen+1;
                    end
                end
            end
            
            if(lastMatchLoopN>0)
                % found something to write home about.
                loopinfo(1,lidx)=lastMatchI;
                loopinfo(2,lidx)=lastMatchLength;
                loopinfo(3,lidx)=lastMatchLoopN+1;
                lidx=lidx+1;
            end        
        end
    end
end

