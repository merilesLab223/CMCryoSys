classdef TTLGenerator < TimeBasedSignalGenerator
    %TTLGEN A ttl generation class (abstract) that allows for the creation
    % of TTL signals vs time.
    
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
            obj.timedTTL(lttl+1:lttl+length(t),1)=t;
            obj.timedTTL(lttl+1:lttl+length(t),2)=v;
            obj.InvalidatedData();
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
        
        % clear the timed ttl.
        function Clear(obj)
            obj.timedTTL=[];
            obj.InvalidatedData();
        end
        
        %clear the data.
        function [ttl]=GetTimedTTLData(obj)
            ttl= obj.timedTTL;
        end
    end
end

