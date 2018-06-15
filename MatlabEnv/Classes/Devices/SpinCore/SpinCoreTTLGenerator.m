classdef SpinCoreTTLGenerator < SpinCoreBase & TTLGenerator
    %SPINCORETTLGENERATOR Summary of this class goes here
    %   Detailed explanation goes her
    
    properties    
        % The maximal loop lenth to send to device.
        MaxLoopLength   = 1000000;
        
        % long delay min time (in timebase). the time where the instruction is split into
        % a long delay instruction. See SpinCore API for help.
        LongDelayMinTime = 60*60*1000; % an hour
    end
    
    % general methods.
    methods 
        function prepare(obj)
            prepare@SpinCoreBase(obj);
            sq=obj.compile();
            
            % programming the instructions.
            api=obj.CoreAPI;
            obj.StartInstructions;
            
            data=sq.data;
            dur=sq.durations;
            sdata=size(data);
            loops=sq.loops;
            
            minIT=obj.MinimalInstructionTime/obj.timeUnitsToSecond;
            
            loopn=length(sq.loops);
            if(loopn)
                loopi=loops{1};
            end
            minDur=obj.secondsToTimebase(obj.MinimalInstructionTime);
            for i=1:sdata(1)
                % getting the data.
                bi=zeros(1,32);
                bi(1:sdata(2))=data(i,:);
                duri=dur(i);
                if(duri<minDur)
                    duri=minDur;
                end                
                flags=bi2de(bi);
                
                % adding the isntruction.
                if(loopn && loopi.idx==i)
                    % need to add start loop here.
                    loopi.devIdx=obj.Instruct(0,api.INST_LOOP,loopi.n);
                end
                
                % instructing and delay if needed.
                if(duri>obj.LongDelayMinTime)
                    % case where we need a long delay.
                    ldn=floor(duri/obj.LongDelayMinTime);
                    duri=rem(duri,obj.LongDelayMinTime);
                    
                    % sending instruction.
                    obj.Instruct(flags,api.INST_LONG_DELAY,ldn,obj.LongDelayMinTime);
                    if(duri>=minIT)
                        obj.Instruct(flags,api.INST_CONTINUE,0,duri);
                    end
                else
                    % send nbormal commands.
                    obj.Instruct(flags,api.INST_CONTINUE,0,duri);
                end
                
                % loop ends and loop advance.
                if(loopn && loopi.idx+loopi.l-1==i)
                    obj.Instruct(0,api.INST_END_LOOP,loopi.devIdx);
                    loops=loops(2:end);
                    loopn=length(loops);
                    if(loopn)
                        loopi=loops{1};
                    end
                end
            end
            
            obj.EndInstructions;
        end
        
        function [sq]=compileSequence(obj,t,data)
            % sorting the data by T, and identifying pulse trains.
            [t,bi]=obj.makeTTLTimedVectors(t,data);
            
            % finding similars to create sequence loops.
            durations=round(diff([t./obj.getTimebase()])).*obj.getTimebase();
            durations=[durations;0];
            data=[durations,bi];
            [data,loopinfo,vidxs]=SpinCoreTTLGenerator.FindLoopsAndReduce(data,500);
            data=data(:,2:end);
            durations=durations(vidxs);
            
            loops={};
            slinfo=size(loopinfo);
            indexOffset=0;
            
            dataIdxs=1:length(vidxs);
            
            for i=1:slinfo(2)
                idx=loopinfo(1,i)+indexOffset;
                l=loopinfo(2,i);
                
                % getting the loop splits.
                n=SpinCoreTTLGenerator.num2Chunks(loopinfo(3,i)+1,obj.MaxLoopLength);
                indexOffset=indexOffset+(length(n)-1)*l;
                didxs=repmat(idx:idx+l-1,1,(length(n)-1));
                if(~isempty(didxs))
                    % insert into the vector.
                    dataIdxs=[dataIdxs(idx:idx+l-1),didxs,dataIdxs(idx+l:end)];
                end
                
                % adding the loop items.
                for j=1:length(n)
                    loopi=struct('idx',idx+(j-1)*l,'l',l,'n',n(j)); % loop n is one larger then loop index.
                    loops(end+1)={loopi};
                end
            end
            
            if(indexOffset>0)
                % extending data.
                data=data(dataIdxs,:);
                durations=durations(dataIdxs);
            end
            
            sq=struct('durations',durations,...
                'data',data);
            sq.loops=loops;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% helper methods.
    methods (Static)    
        function [loopinfo,data]=FindLoops(data,maxn,allowOverlap)
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
                            loopinfo(3,lidx)=lastMatchLoopN;                            
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
                loopinfo(3,lidx)=lastMatchLoopN;
                lidx=lidx+1;
            end        
        end
        
        function [data,linfo,vidxs]=FindLoopsAndReduce(data,maxn,minItemsSlice)
            if(~exist('maxn','var'))maxn=Inf;end
            if(~exist('minItemsSlice','var'))minItemsSlice=2;end
            comp=[];
            % rewrite the data since we might have a diffrent orientation.
            tic;
            [linfo,data]=SpinCoreTTLGenerator.FindLoops(data,maxn,false);
            comp(end+1)=toc;
            
            % reducting.
            
            totalItemsRemoved=0;
            sinfo=size(linfo);
            sdata=size(data);
            removedIdxs=[];
            ld=sdata(1);
            vidxs=1:ld;

            tic;
            newIndexs=zeros(sinfo(2),1);
            for i=1:sinfo(2)
                newIndexs(i)=linfo(1,i)-totalItemsRemoved;% updated index.
                idx=linfo(1,i);
                len=linfo(2,i);
                n=linfo(3,i);
                idx=idx+len; % move to repeate position.
                tl=n*len;
                
                if(tl<minItemsSlice)
                    continue;
                end
                ridxs=idx:idx+tl-1;
                removedIdxs(end+1:end+tl)=ridxs;
                totalItemsRemoved=totalItemsRemoved+tl;
            end
            linfo(1,:)=newIndexs;
            comp(end+1)=toc;
            
            removedIdxs=unique(removedIdxs);
            vidxs(removedIdxs)=[];
            data(removedIdxs,:)=[]; % matlab index issues.            
        end
        
        function [n]=num2Chunks(num,max)
            n=ones(floor(num/max),1)*max;
            rn=rem(num,max);
            if(rn>0)
                n(end+1)=rn;
            end
        end
    end

        
end

