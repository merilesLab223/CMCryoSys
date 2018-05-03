% dummy test class.
classdef Exp77c27ca2690b43b31b68791e85e1b449C<ExperimentCore
    methods
        function testUpdateTempByNamePath(exp,idx,namepath,val,n)
            expID=exp.ExpInfo.ID;
            if(~exist('idx','var'))idx=-1;end
            if(~exist('namepath','var'))namepath='a@b@c@d';end
            if(~exist('val','var'))val=eye(1000);end
            if(~exist('n','var'))n=1000;end
            idx=ExperimentCore.MakeTempParameter(expID,idx);
            
            tic;
            for i=1:n
                ExperimentCore.UpdateTempFromNamePath(expID,idx,namepath,val);
            end
            totalT=toc;
            disp(['Total set time: ',num2str(totalT*1000./n),' [ms]']);
        end        
    end
end