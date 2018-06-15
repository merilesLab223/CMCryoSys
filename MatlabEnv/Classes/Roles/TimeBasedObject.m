classdef TimeBasedObject < handle & TimeKeeper
    %TIMEBASEDENTITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = protected)
        Rate=50000;   
    end
        
    % time methods
    methods        
        % overridable set clock rate.
        function setClockRate(obj,r)
            obj.Rate=r;
        end
        
        % move the time to nearest values.
        function toRounded(obj,duration)
            if(~exist('duration','var'))
                duration=obj.getTimebase();
            end
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

