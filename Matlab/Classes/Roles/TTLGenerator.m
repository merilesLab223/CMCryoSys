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
        function Set(obj,v,t,c)
            if(~exist('c','var'))c=obj.Channel;end
            
            lttl=0;
            if(~isempty(obj.timedTTL))
                lttl=length(obj.timedTTL(:,1));
            end
            if(~exist('t','var'))
                t=(1:length(v))*obj.getTimeBase();
            end
            data=struct('t',t,'v',v,'c',c);
            waitFor=sum(t);
            obj.appendSequence(data,waitFor);
        end
        
        % Set the values to be up for period t.
        function Up(obj,t,c)
            if(~exist('c','var'))c=obj.Channel;end
            if(~exist('t','var'))
                t=obj.getTimebase();
            end
            obj.Set(ones(length(t),1),t,c);
        end
        
        % Set the values to be down for period t.
        function Down(obj,t,c)
            if(~exist('c','var'))c=obj.Channel;end
            if(~exist('t','var'))t=obj.getTimebase();end
            obj.Set(zeros(length(t),1),t,c);
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
            
            data=struct('tup',tup,'tdown',tdown,'c',c,'isPulse',1,'n',n);    
            tt=(tup+tdown)*n;
            obj.appendSequence(data,tt);
        end
        
        %clear the data.
        function [ttl,t]=getTimebaseTTLData(obj)
            ttl=obj.compile();
            t=(0:length(ttl)-1)*obj.getTimebase();
        end
    end
    
    % compilation methods.
    methods(Access = protected)
        function [t,bvals]=makeTTLTimedVectors(obj,timestamps,data)
            bvals=[];
            t=[];
            for i=1:length(timestamps)
                % timestamp.
                if(isstruct(data))
                    idata=data{i};
                    it=timestamps(i)+idata.t; % timestamps;
                    t(end+1:end+length(it))=it;
                    bvals(end+1:end+length(it))=idata.data;
                else
                    t(end+1)=timestamps(i);
                    bvals(end+1)=data{i};
                end
            end
            [t,sidx]=unique(t);
            bvals=bvals(sidx);
        end
    end
end

