classdef Experiment < handle
    properties(SetAccess = private)
        CallerID=[];
        ExpCore=[];
        Devices=[];
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
        
        % the device collection
        function [devs]=get.Devices(exp)
            % the static method in exp core.
            devs=ExpCore.GetDevices();
        end
    end
end

