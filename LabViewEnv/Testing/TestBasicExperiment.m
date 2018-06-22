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
    end
end