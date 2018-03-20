classdef NI6321Clock < NI6321Core
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ctrName='ctr3'; % the counter channel.
        clockFreq=1e6;
        dutyCycle=0.5; % in % of freq.
        niCounterChannel=[]; 
    end
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321Clock(varargin)
            obj=obj@NI6321Core(varargin);
            obj.Rate=obj.clockFreq;
        end
    end
    
    % called when data is ready.
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            obj.notify("DataReady",e);
        end
    end
    
    % device methods
    methods
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            s.Rate=obj.Rate;
            
            % counter is continues.
            s.IsContinuous=true;
            
            % adding counter timebase.
            obj.niCounterChannel=s.addCounterOutputChannel(...
                obj.niDevID,obj.ctrName,'PulseGeneration');
            
            obj.niCounterChannel.Frequency=obj.clockFreq;
            obj.niCounterChannel.DutyCycle=obj.dutyCycle;
            
            disp(['Clock configured at terminal (Unchangeable) ',...
                obj.niCounterChannel.Terminal]);
        end
    end
end

