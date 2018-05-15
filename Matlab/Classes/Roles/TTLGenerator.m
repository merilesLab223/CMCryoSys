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
        function Set(obj,b,durations,n,chan) % with repeptitons
            if(~exist('n','var'))n=1;end % number of repetitions
            if(~exist('chan','var'))chan=obj.Channel;end
            if(~exist('durations','var'))
                durations=(1:length(b))*obj.getTimeBase();
            end
            if(~isnumeric(chan) && ~isvector(chan))
                error('Channel must be the channel index. 1...INF');
            end
            if(length(b)~=length(durations))
                error('Binary data length must be the same as duration vectpr');
            end
            data=struct('dur',durations,'b',b,'chan',chan,'n',n);
            waitFor=sum(durations*n);
            obj.appendSequence(data,waitFor);
        end
        
        % Set the values to be up for period t.
        function Up(obj,t,c)
            if(~exist('c','var'))c=obj.Channel;end
            if(~exist('t','var'))
                t=obj.getTimebase();
            end
            obj.Set(ones(length(t),1),t,1,c);
        end
        
        % Set the values to be down for period t.
        function Down(obj,t,c)
            if(~exist('c','var'))c=obj.Channel;end
            if(~exist('t','var'))t=obj.getTimebase();end
            obj.Set(zeros(length(t),1),t,1,c);
        end 
        
        function Pulse(obj,tup,tdown,c)
            if(~exist('c','var'))c=obj.Channel;end            
            if(~exist('tup','var'))tup=obj.defaultPulseWidth;end
            if(~exist('tdown','var'))tdown=obj.getTimebase();end
            obj.PulseTrain(1,tup,tdown,c);
        end
        
        function PulseTrain(obj,n,tup,tdown,c)
            if(~exist('c','var'))c=obj.Channel;end            
            if(~exist('n','var'))n=1;end
            if(~exist('tup','var'))tup=obj.defaultPulseWidth;end
            if(~exist('tdown','var'))tdown=obj.getTimebase();end
            
            if(~isnumeric(tup) || ~isnumeric(tdown))
                error('A pulse is defined buy n repeats and up/down times (numeric).');
            end
%             
%             data=;
% %             
% %             data=struct('tup',tup,'tdown',tdown,'c',c,'isPulse',1,'n',n);    
% %             tt=(tup+tdown)*n;
            obj.Set([1,0],[tup,tdown],n,c);
        end
        
        %clear the data.
        function [ttl,t]=getTimebaseTTLData(obj)
            [t,data]=obj.getRawSequence();
            [t,ttl]=obj.makeTTLTimedVectors(t,data);
        end
    end
    
    % compilation methods.
    methods(Access = protected)
        function [t,bvals]=makeTTLTimedVectors(obj,timestamps,data)
            % sorting.
            [timestamps,sidx]=sort(timestamps);
            data(:)=data(sidx);
            
            bvals=[];
            t=[];
            for i=1:length(timestamps)
                % timestamp.
                idata=data{i};
                ld=length(idata.dur);
                ti=idata.dur;
                bi=idata.b;
                
                if(idata.n>1)
                    ld=ld*idata.n;
                    repn=floor(idata.n);
                    ti=repmat(ti,1,repn);
                    bi=repmat(bi,1,repn);
                end
                
                % updating times.
                ti=timestamps(i)+cumsum(ti);
                
                % adding to times.
                t(end+1:end+ld)=ti;
                bi=repmat(bi,length(idata.chan),1);
                bvals(end+1:end+ld,idata.chan+1)=bi';
            end
            
            [t,sidx]=unique(t);
            bvals=bvals(sidx,:);
        end
    end
end

