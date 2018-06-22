function [exp]=getExp(expID)
    if(~exist('expID','var'))
        exp=ExpCore.GetLastExperiment;
    else
        exp=ExpCore.GetExperiment(expID);
    end
end
