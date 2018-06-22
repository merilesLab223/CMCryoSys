classdef NI6321Clock < NI6321Core & Clock
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ctrName='ctr3'; % the counter channel.
        %niCounterChannel=[]; 
    end
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321Clock(varargin)
            obj=obj@NI6321Core(varargin);
            parseAndAssignFromVarargin(obj,{'ctrName','clockFreq'},varargin);
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
            %obj.niCounterChannel=...
                s.addCounterOutputChannel(obj.niDevID,obj.ctrName,'PulseGeneration');
            
            obj.configureClockParameters();
            
            disp(['Clock configured at terminal (Unchangeable) ',...
                s.Channels(1).Terminal]);
        end
        
        function configureClockParameters(obj)
            s=obj.niSession;
            s.Channels(1).Frequency=obj.clockFreq;
            s.Channels(1).DutyCycle=obj.dutyCycle;            
        end
    end
    
    methods
        function prepare(obj)
            obj.stop();
            obj.configureClockParameters();
            prepare@NI6321Core(obj);
        end
    end
end

