classdef Experiment < handle
    
    properties
        PulseGenerator
        SignalGenerator
        Counter
        InitScripts
        PulseSequence
        Notes
        SpecialData
        SpecialVec
    end
    
    methods
        function [obj] = Experiment(varargin)
            if nargin == 4;
                obj.PulseGenerator = varargin{1};
                obj.SignalGenerator = varargin{2};
                obj.Counter = varargin{3};
                obj.PulseSequence = varargin{4};
            end
        end
    end
    
    methods (Static = true)
        
        % use loadobj method for backwards compatibility of Experiment
        % classes
        function [obj] = loadobj(a)
            if isempty(cell2mat([strfind(properties(a),'Notes')]))
                a.Notes ={''};
            end
            
            if isempty(cell2mat([strfind(properties(a),'SpecialData')]))
                a.SpecialData = [];
            end
            
            if isempty(cell2mat([strfind(properties(a),'SpecialVec')]))
                a.SpecialVec = [];
            end
            obj = a;
        end
    end
    
end