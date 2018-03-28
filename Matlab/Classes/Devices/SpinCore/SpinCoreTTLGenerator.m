classdef SpinCoreTTLGenerator < SpinCoreBase & TTLGenerator
    %SPINCORETTLGENERATOR Summary of this class goes here
    %   Detailed explanation goes her
    
    methods (Static)
        
        function [loopinfo,data]=FindLoops(data,maxn,allowOverlap)
            if(~exist('maxn','var'))maxn=Inf;end
            if(~exist('allowOverlap','var'))allowOverlap=0;end
            sdata=size(data);
            l=sdata(2);
            if(l==1 && max(sdata)>1)
                % check wrong direction.
                [unlooped,loopi,loopn]=SpinCoreTTLGenerator.FindLoops(data',maxn);
            end
            
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
                unlooped(:,end+1)=data(:,i);
                if(lastMatchLength~=0)
                    % check succesive is ok.
                    if(~isequal(src(:,sidx),unlooped(:,end))) % check match.
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
                        if(isequal(unlooped(:,end),unlooped(:,i-clen)))
                            % found match lookback.
                            lastMatchI=i-clen;
                            lastMatchLength=clen;
                            lastMatchLoopN=0;
                            src=unlooped(:,i-clen:i-1);
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
            
            % rewrite the data since we might have a diffrent orientation.
            [linfo,data]=SpinCoreTTLGenerator.FindLoops(data,maxn,false);
            
            % reducting.
            
            totalItemsRemoved=0;
            sinfo=size(linfo);
            sdata=size(data);
            vidxs=1:sdata(2);
            
            for i=1:sinfo(2)
                linfo(1,i)=linfo(1,i)-totalItemsRemoved;% updated index.
                idx=linfo(1,i);
                len=linfo(2,i);
                n=linfo(3,i);
                idx=idx+len; % move to repeate position.
                tl=n*len;
                
                if(tl<minItemsSlice)
                    continue;
                end
                ridxs=idx:idx+tl-1;
                vidxs(ridxs)=[];
                data(:,ridxs)=[]; % matlab index issues.
                totalItemsRemoved=totalItemsRemoved+tl;
            end
        end
    end

    methods
        function [sq]=compileSequence(obj,t,data)
            % sorting the data by T, and identifying pulse trains.
            [t,bi]=obj.makeTTLTimedVectors(t,data);
            
            % finding similars to create sequence loops.
            dur=round(diff([0,t./obj.getTimebase()])).*obj.getTimebase();
            dat=[dur',bi];
            [unlooped,loopinfo,vidxs]=SpinCoreTTLGenerator.FindLoopsAndReduce(dat',20);
            
            loops={};
            slinfo=size(loopinfo);
            for i=1:slinfo(2)
                loops(i)={struct('idx',loopinfo(1,i),'l',...
                    loopinfo(2,i),'n',loopinfo(3,i))};
            end
            
            sq=struct('t',t(vidxs)',...
                'data',unlooped(2:end,:)');
            sq.loops=loops;
        end
    end
    
    methods

        function prepare(obj)
            prepare@SpinCoreBase(obj);
            obj.CoreAPI.SetClock(obj.Rate);
            sq=obj.compile();
            
            % programming the instructions.
            api=obj.CoreAPI;
            obj.StartInstructions;
            
            data=sq.data;
            t=sq.t;
            sdata=size(data);
            loops=sq.loops;
            loopn=length(sq.loops);
            if(loopn)
                loopi=loops{1};
            end
            bi=zeros(1,32);
            for i=1:sdata(1)
                if(loopn && loopi.idx==i)
                    % need to add start loop here.
                    loopi.devIdx=obj.Instruct(0,api.INST_LOOP,loopi.n);
                end
                bi(1:sdata(2))=data(i,:);
                ti=t(i);
                flags=bi2de(bi);
                if(flags>0)
                    flags=api.ALL_FLAGS_ON;
                end
                
                obj.Instruct(flags,api.INST_CONTINUE,0,ti);
                
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
    end
end

