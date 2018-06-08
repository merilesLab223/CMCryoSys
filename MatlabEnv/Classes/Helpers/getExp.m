function exp = getExp(expID)
    if(exist('exp','var'))
        exp=ExpCore.GetExperimentByID(expID);
    else
        exp=ExpCore.GetLastExperiment();
    end
end

