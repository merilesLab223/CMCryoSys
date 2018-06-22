classdef Experiment < handle
    properties(SetAccess = private)
        CallerID=[];
        ExpCore=[];
        Devices=[];
    end

    methods
        function BindExperimentCore(exp,expCore,callerID)
            exp.CallerID=callerID;
            exp.ExpCore=expCore;
        end
        
        function update(exp,prs,async)
            if(~exist('prs','var'))
                prs=fieldnames(exp);
            end
            if(~exist('async','var'))
                async=true;
            end            
            exp.ExpCore.Update(exp.CallerID,prs,~async);
        end
        
        % the device collection
        function [devs]=get.Devices(exp)
            % the static method in exp core.
            devs=ExpCore.GetDevices();
        end
    end
end

