classdef TestBasicExperiment<Experiment
    properties
        TestMatrix=eye(100);
        MatrixSize=100;
        DelayTime=200;
        TestString='';
    end
    
    methods
        function testGraphUpdate(obj,n)
            if(~exist('n','var'))
                n=Inf;
            end
            i=1;
            while(i<n)
                obj.TestMatrix=eye(obj.MatrixSize)+rand(obj.MatrixSize);
                obj.update('TestMatrix');
                pause(obj.DelayTime/1000);
                i=i+1;
            end
        end
        
        function [rt]=testSendError(obj)
            error('this is an error');
            rt=true;
        end
        
        function [rt]=testSendWarning(obj)
            warning('this is a warning');
            rt=true;
        end
    end
end