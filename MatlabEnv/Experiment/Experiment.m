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
        
        function update(exp,prs)
            if(~exist('prs','var'))
                prs=fieldnames(exp);
            end
            exp.ExpCore.Update(exp.CallerID,prs);
        end
    end
end

