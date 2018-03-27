classdef NI6321Clock < NI6321Core
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ctrName='ctr3'; % the counter channel.
        clockFreq=10e6;
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
    methods  (Access = protected)
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
            
            obj.configureClockParameters();
            
            disp(['Clock configured at terminal (Unchangeable) ',...
                obj.niCounterChannel.Terminal]);
        end
        
        function configureClockParameters(obj)
            obj.niCounterChannel.Frequency=obj.clockFreq;
            obj.niCounterChannel.DutyCycle=obj.dutyCycle;            
        end
    end
    
    methods
        function prepare(obj)
            obj.configureClockParameters();
            prepare@NI6321Core(obj);
        end
    end
end

