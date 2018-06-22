classdef MyExperiment<Experiment
    %MyExperiment an example experiment.
    %getExp returns the last created experiment.
    
    methods
    end
    
    properties
        ExampleButton=false;
        ExampleValue=0;
        ExampleStruct=struct();
        IsBusy=false;
    end
    
    % externally called functions must be public.
    methods
        function init(exp)
            disp('do some init stuff');
        end
        
        function [rsp]=MyMethod(exp,txt)
            exp.IsBusy=true;
            exp.update('IsBusy');
            exp.ExampleValue=rand()*100; % a single double value.
            disp(txt);
            rsp=['Recived "',txt,'" in matlab function'];
            exp.IsBusy=false;
            exp.update({'IsBusy','ExampleValue'});
        end
    end
end