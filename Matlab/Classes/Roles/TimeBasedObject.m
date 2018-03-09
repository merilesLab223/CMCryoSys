classdef TimeBasedObject < handle
    %TIMEBASEDENTITY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        % The timebase
        Rate=50000;   
    end
    
    % time methods
    methods
        function [hartbit]=getTimebase(obj)
            hartbit=1./obj.Rate;
        end
    end
end

