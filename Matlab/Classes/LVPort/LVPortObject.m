classdef LVPortObject < handle
    %LVPORTOBJECT A calls for integrating matlab with labview.
    %   This class allows the integration of matlab with labview, by
    %   defining a global variable accesable by an ID, thus allowing the
    %   backend synchronization of labview parameters and methods.
    
    %   All synchronization of the port is kept in an info object (Port)
    %   that allows communication and event manipulation between labview
    %   and matlab.
    
    % the port item cannot should not be overriden or replaced.
    
    properties (SetAccess = private)
        Port=[];
    end

    methods
        function [p]=get.Port(obj)
            if(isempty(obj.Port))
                obj.Port=LVPort(obj);
            end
        end
    end
end

