classdef PulseBlasterPulseSequence < PulseSequence
    
    properties
        MicrowaveHardwareChannel = 3;
        PhaseBitResolution = 6;
        PhaseHardwareLines = [12,13,14,15,20,18]; % decrease phase offset
    end
     
    methods
        function [obj] = PulseBlasterPulseSequence(varargin)
            
            if nargin == 0,
                ps = PulseSequence();
            elseif nargin == 1,
                ps0 = varargin{1};
                ps = ps0.clone();
            end
            
            obj = obj@PulseSequence(ps.Channels,ps.Groups, ps.Sweeps, ps.SweepIndex, ps.SequenceName,ps.Listeners);
        end
        
        function [channels] = getHardwareChannels(obj)
            channels = [[obj.Channels(:).HWChannel],obj.PhaseHardwareLines];
        end
        
        function [b] = saveobj(a)
            
        end
    end
end