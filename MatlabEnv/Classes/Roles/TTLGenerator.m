classdef TTLGenerator < TimeBasedSignalGenerator
    %TTLGEN A ttl generation class (abstract) that allows for the creation
    % of TTL signals vs time.
    
    % NOTE!! ---------------------------
    % Requires the abstract method compileSequence(obj,t,data)
    % ----------------------------------
    properties
        defaultPulseWidth=0.1; % in ms.        
        Channel=0;
    end
    
    properties (Access = protected)
        % the collection of timed ttl values with zeros and ones.
        timedTTL=[];
        lastChanged=-1;
    end
    
    methods (Access = protected)
        % called to let the object know that new data was added.
        function InvalidatedData(obj)
            obj.lastChanged=now;
        end
        
        % call to see if the signals have changed.
        function [c]=hasChanged(obj,since)
            c=since<=obj.lastChanged;
        end
    end
    
    % TTL Methods
    methods        
        % Set the values to be down for period t.
        function Set(obj,b,t,dur,n,chan) % with repeptitons
            if(~exist('n','var'))
                n=1;% number of repetitions
            end 
            if(~exist('chan','var'))
                chan=obj.Channel;
            end
            
            lv=length(b);
            if(~exist('dur','var'))
                dur=ones(size(t))*obj.getTimeBase();
            end
            
            if(~isnumeric(chan) && ~isvector(chan))
                error('Channel must be the channel index. 1...INF');
            end
            if(length(dur)==1)
                dur=ones(size(t))*dur;
            end
            if(length(b)~=lv ||length(t)~=lv)
                error('Must be that length(b)==length(t)');
            end
            [maxt,maxti]=max(t);
            mtdur=dur(maxti);
            cycleDur=(maxt+mtdur);
            
            data=struct('t',t+obj.curT,'b',b,'chan',chan,'cycle',cycleDur,'n',n);
            obj.appendSequence(data,cycleDur*n);
        end
        
        % Set the values to be up for period t.
        function Up(obj,t,c,dur)
            if(~exist('c','var'))
                c=obj.Channel;
            end
            if(~exist('t','var'))
                t=obj.getTimebase();
            end
            if(~exist('dur','var'))
                dur=obj.defaultPulseWidth;
            end
            obj.Set(ones(size(t)),t,dur,1,c);
        end
        
        % Set the values to be down for period t.
        function Down(obj,t,c,dur)
            if(~exist('dur','var'))
                dur=obj.defaultPulseWidth;
            end
            if(~exist('c','var'))
                c=obj.Channel;
            end
            if(~exist('t','var'))
                t=obj.getTimebase();
            end
            if(~exist('dur','var'))
                dur=obj.defaultPulseWidth;
            end
            obj.Set(zeros(size(t)),t,dur,1,c);
        end 
        
        function Pulse(obj,t,durUp,c,durDown)
            if(~exist('c','var'))
                c=obj.Channel;
            end
            if(~exist('durUp','var'))
                durUp=obj.defaultPulseWidth;
            end
            if(~exist('durDown','var'))
                durDown=obj.getTimebase();
            end
            obj.PulseTrain(t,1,durUp,c,durDown);
        end
        
        function ClockSignal(obj,dur,freq,c,dutyCycle)
            if(~exist('dutyCycle','var'))
                dutyCycle=0.5;
            end
            tup=1/(freq*obj.timeUnitsToSecond);
            tdown=tup*(1-dutyCycle);
            tup=tup*dutyCycle;
            n=ceil(dur/(tup+tdown));
            obj.PulseTrain(0,n,tup,c,tdown);
        end
        
        function PulseTrain(obj,t,n,durUp,c,durDown)
            if(~exist('n','var') || isempty(n))
                n=1;
            end
            if(~exist('c','var') || isempty(c))
                c=obj.Channel;
            end
            if(~exist('durUp','var') || isempty(durUp))
                durUp=obj.defaultPulseWidth;
            end
            if(~exist('durDown','var') || isempty(durDown))
                durDown=obj.getTimebase();
            end
            
            lv=length(t);
            if(length(durUp)==1)
                durUp=ones(size(t))*durUp;
            end
            if(length(durDown)==1)
                durDown=ones(size(t))*durDown;
            end
            tval=zeros(size(t));
            bval=zeros(size(t));
            dur=zeros(size(t));
            uidxs=1:2:lv*2;
            didxs=2:2:lv*2;
            
            tval(uidxs)=t;
            bval(uidxs)=1;
            dur(uidxs)=durUp;
            
            tval(didxs)=t+durUp;
            bval(didxs)=0;
            dur(didxs)=durDown;
            
            obj.Set(bval,tval,dur,n,c);
        end
        
        %clear the data.
        function [ttl,t]=getTimebaseTTLData(obj)
            [t,data]=obj.getRawSequence();
            [t,ttl]=obj.makeTTLTimedVectors(t,data);
        end
    end
    
    % compilation methods.
    methods(Access = protected)
        function [t,bvec]=makeTTLTimedVectors(obj,timestamps,data)
            % sorting.
            [timestamps,sidx]=sort(timestamps);
            data(:)=data(sidx);
            
            % searching for basic parmeters
            maxChan=0;
            ltot=0;
            for i=1:length(timestamps)
                idata=data{i};
                ltot=ltot+length(idata.t)*idata.n;
                if(max(idata.chan)>maxChan)
                    maxChan=max(idata.chan);
                end
            end
            
            % need to convert to time/bit value.
            %basecv=ones(1,maxChan+1)*-1;
            bvals=ones(ltot,maxChan+1)*-1;
            t=ones(ltot,1);
            cpos=0;
            for i=1:length(timestamps)
                % timestamp.
                idata=data{i};
                ni=validatevector(idata.n);
                if(ni==0)
                    continue;
                end             
                ld=length(idata.t);
                ti=validatevector(idata.t);
                bi=validatevector(idata.b);
                
                toffset=ones(size(ti))*idata.cycle;
                toffset=toffset*[0:ni-1];
                toffset=toffset(:);
                ti=repmat(ti,ni,1)+toffset;
                bi=repmat(bi,ni,1);
                
                % converting to channels.
%                 cbi=basecv; % all current channels.
%                 cbi(idata.chan+1)=1;
%                 bi=bi*cbi;
                t(cpos+1:cpos+ld*ni)=ti;
                for c=idata.chan
                    bvals(cpos+1:cpos+ld*ni,c+1)=bi;
                end
                
                cpos=cpos+ld*ni;
            end
            
            % sort the data.
            [t,sidxs]=sort(t);
            bvals=bvals(sidxs,:);
            ut=unique(t);
            lut=length(ut);
            bvec=zeros(lut,maxChan+1);
            
            % merge the data.
            utidx=1;
            curb=zeros(1,maxChan+1);
            for i=1:length(t)
                ti=t(i);
                bi=bvals(i,:);
                while(ti~=ut(utidx))
                    utidx=utidx+1;
                    if(utidx>lut)
                        break;
                    end
                end
                if(utidx>lut)
                    break;
                end
                
                % updating the curb.
                vidxs=find(bi>-1);
                curb(vidxs)=bi(vidxs);
                bvec(utidx,:)=curb;
            end
            
            t=ut;
            
%             sbvals=size(bvals);
            
%             tall=t;
%             t=unique(t);
%             tidxs=1:length(t);
%             bvalAll=bvals;
%             bvals=zeros(length(t),maxChan+1);
%            
%             % on all channels.
%             for c=1:sbvals(2)
%                 cbvals=bvalAll(:,c);
%                 % filtering all of -1.
%                 cvalidIdxs=find(cbvals>-1);
%                 cbvals=cbvals(cvalidIdxs);
%                 % filtering all unqiue,
%                 [ct,ctidxs]=unique(tall(cvalidIdxs),'last');
%                 cbvals=cbvals(ctidxs);
%                 
%                 totidxs=interp1(t,tidxs,ct,'previous');
%                 bvals(totidxs,c)=cbvals;
%             end [tidxs]=interp1(ut,1:length(ut),t,'previous');
%             
%             % fillup.
%             for i=1:length(t)
%                 bv=bvalAll(i,:);
%             end
            
        end
    end
end

