classdef TimeKeeper < handle
    %TIMEKEEPER Implements a class that keeps time.
    
    properties
        % the current time.
        curT=0; 
        
        % The timebase
        timeUnitsToSecond=1/1000;        
    end
    
    methods

        function wait(obj,dur)
            % add dur to curT.
            obj.curT=obj.curT+dur(1);
        end
        
        function goBackInTime(obj,dur)
            % substract dur from curT. Same as wait(-dur);
            obj.wait(-dur);
        end
        
        function t=timebaseToSeconds(obj,t)
            % convert the current timebase to seconds.
            t=t*obj.timeUnitsToSecond;
        end
        
        function [t]=nowInTimebase(obj)
            % returns the now() function in the the timekeeper timebase.
            t=now*24*60*60./obj.timeUnitsToSecond;
        end 
        
        function [tb]=secondsToTimebase(obj,t)
            % converts seconds to timebase.
            tb=t/obj.timeUnitsToSecond;
        end        
    end
end

