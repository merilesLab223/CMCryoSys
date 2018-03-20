classdef TimeBasedObject < handle
    %TIMEBASEDENTITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % The timebase
        Rate=50000;   
        timeUnitsToSecond=1/1000;

        % the current time.
        curT=0; 
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
    end
    
    % time methods
    methods
        function [tb]=getTimebase(obj)
            tbs=(1./obj.Rate);
            tb=tbs/obj.timeUnitsToSecond;
        end
    end
end

