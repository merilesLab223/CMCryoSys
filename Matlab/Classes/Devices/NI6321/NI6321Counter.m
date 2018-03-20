classdef NI6321Counter < NI6321Core & TimedMeasurementReader
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ctrName='ctr0'; % the counter channel.
        clockTerm='pfi14';
        niCounterChannel=[]; 
        niCounterTimebase=[]; 
    end
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321Counter(varargin)
            obj=obj@NI6321Core(varargin);
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
            
            % adding counter.
            [obj.niCounterChannel,idx]=s.addCounterInputChannel(obj.niDevID,obj.ctrName,'EdgeCount');
            obj.niCounterChannel.ActiveEdge='Rising';
            s.addlistener('DataAvailable',@(s,e)obj.dataBatchAvailableFromDevice(s,e));
            disp(['Input counter configured at terminal (Unchangeable) ',obj.niCounterChannel.Terminal]);

            % adding the clock connection.
            if(ischar(obj.clockTerm)&&~isempty(obj.clockTerm))
                s.addClockConnection('External',[obj.niDevID,'\',obj.clockTerm],'ScanClock');        
                disp(['Input counter clock configured to terminal ',obj.clockTerm]);
            end  
        end
    end
end

