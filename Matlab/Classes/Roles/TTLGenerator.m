classdef TTLGenerator < TimeBasedSignalGenerator
    %TTLGEN A ttl generation class (abstract) that allows for the creation
    % of TTL signals vs time.
    
    % NOTE!! ---------------------------
    % Requires the abstract method compileSequence(obj,t,data)
    % ----------------------------------
    
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
        function Set(obj,v,t)
            lttl=0;
            if(~isempty(obj.timedTTL))
                lttl=length(obj.timedTTL(:,1));
            end
            if(~exist('t','var'))
                t=(1:length(v))*obj.getTimeBase();
            end
            if(length(t)==1)
                % append and wait for t.
                obj.appendSequence(t,v,t);
            else
                data=struct('t',t,'v',v);
                waitFor=sum(t);
                obj.appendSequence(t,data,waitFor);
            end
        end
        
        % Set the values to be up for period t.
        function Up(obj,t)
            if(~exist('t','var'))
                t=obj.getTimebase();
            end
            obj.Set(ones(length(t),1),t);
        end
        
        % Set the values to be down for period t.
        function Down(obj,t)
            if(~exist('t','var'))t=obj.getTimebase();end
            obj.Set(zeros(length(t),1),t);
        end 
        
        function Pulse(obj,tup,tdown)
            if(~exist('tup','var'))tup=obj.getTimebase();end
            if(~exist('tdown','var'))tdown=obj.getTimebase();end
            obj.Up(tup);
            obj.Down(tdown);
        end
        
        %clear the data.
        function [ttl]=getTimbaseTTLData(obj)
            ttl= this.compile();
        end
    end
    
    % compilation methods.
    methods(Access = protected)
        function [t,bvals]=makeTTLTimedVectors(obj,t,data)
            bvals=[];
            t=[];
            for i=1:length(t)
                % timestamp.
                if(isstruct(data))
                    idata=data{i};
                    it=t+idata.t; % timestamps;
                    t(end+1:end+length(it))=it;
                    bvals(end+1:end+length(it))=idata.data;
                else
                    t(end+1)=t;
                    bvals(end+1)=data{i};
                end
            end
            [t,sidx]=sort(t);
            bvals=bvals(sidx);
        end
    end
end

