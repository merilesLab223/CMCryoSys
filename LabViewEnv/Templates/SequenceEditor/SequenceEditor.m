classdef SequenceEditor<Experiment
    % code for sequence editor. 
    % this code allows the editing of a sequence that will run and create
    % pulses.
    
    methods
    end
    
    properties
        TimedSeqeunce=[];
    end
    
    % externally called functions must be public.
    methods
        function init(exp)
            disp('Sequence editor initialization. Code will run and show the resulting sequence.');
        end
        
        function [rsp]=CalculateSequence(exp,code)
        end
    end
end