classdef TimeBasedObject < handle
    %TIMEBASEDENTITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % The timebase
        timeUnitsToSecond=1/1000;

        % the current time.
        curT=0; 
    end
    
    properties (SetAccess = protected)
        Rate=50000;   
    end
        
    % time methods
    methods
        % call to change the current device time.
        % can have negative values.
        function wait(obj,t)
            obj.curT=obj.curT+t(1);
        end
        
        % Call got go back in time.
        function goBackInTime(obj,t)
            obj.wait(-t);
        end
        
        % overridable set clock rate.
        function setClockRate(obj,r)
            obj.Rate=r;
        end
        
        % move the time to nearest values.
        function toRounded(obj,duration)
            obj.curT=duration*ceil(obj.curT/duration);
        end
    end
    
    % time methods
    methods
        function [tb]=getTimebase(obj)
            tb=obj.getSecondsTimebase()/obj.timeUnitsToSecond;
        end
        
        function [tbs]=getSecondsTimebase(obj)
            tbs=(1./obj.Rate);
        end        
    end
end

