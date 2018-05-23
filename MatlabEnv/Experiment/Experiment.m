classdef Experiment < handle
    properties(SetAccess = private)
        CallerID=[];
        ExpCore=[];
    end

    methods
        function Init(exp,expCore,callerID)
            exp.CallerID=callerID;
            exp.ExpCore=expCore;
        end
    end
end

