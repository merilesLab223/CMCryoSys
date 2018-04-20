
if(~exist('expID','var'))
    [expID,errs,canExecute]=ExperimentCore.MakeExperiment([pwd,'\','experiment.m']);
    exp=ExperimentCore.GetExperimentByID(expID);
    tmp={};
end
tmp.a=struct();
tmp.b=[1,2;1,2];
tidx=exp.ExpInfo.SetTemp(tmp);

%% making a temp value;

%% Updating experiment parameter.
[mapid]=ExperimentCore.MakeTempUpdateMap(expID);
ExperimentCore.PopulateUpdateMap(expID,mapid,'a@b',tmp.b);
ExperimentCore.UpdateTempFieldFromMap(expID,tidx,mapid);

disp(['Value after change, idx=',num2str(tidx)]);
savedTemp=ExperimentCore.GetTempField(expID,tidx);
disp(savedTemp.a);


%% Cleaering
ExperimentCore.ClearTempField(expID,tidx);
%% loading params.
[~,tn]=exp.ExpInfo.getTempValues();
disp(['After cleanup:',num2str(length(tn)),' items remaining.']);
disp(tn);