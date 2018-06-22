classdef NI6321Counter < NI6321Core & TimedMeasurementReader
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=NI6321Counter(varargin)
            obj@NI6321Core(varargin{:});
            obj.IsGradient=true;
            parseAndAssignFromVarargin(obj,{'ctrName'},varargin);
        end
    end
    
    properties
        ctrName='ctr0'; % the counter channel.
    end
        
    properties
        UseTimedDataUnits=true;
    end
    
    properties(Constant)
        MinDurationInSeconds=0.010;
    end
    
    methods
        function ResetCounter(obj)
            if(~isempty(obj.niSession))
                obj.niSession.resetCounters();
            end
        end
        
        function clearConfiguration(obj)
            clearConfiguration@NI6321Core(obj);
            delete(obj.DataAvailableEventListener);
            obj.DataAvailableEventListener=[];
        end        
    end
    
    methods(Access =protected)
        function [ts,data]=processDataBatch(obj,ts,data,e)
            % convert data to timed units.
            if(obj.UseTimedDataUnits)
                cntToTimedUnits=1/(obj.Rate*obj.timeUnitsToSecond);
                data=data/cntToTimedUnits;
            end
        end

    end
   
    % device methods
    methods (Access = protected)
        
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            obj.stop();
            obj.IsContinuous=true;
            s=obj.niSession;
            s.Rate=obj.Rate;
            
            % adding counter.
            if(isempty(s.Channels))
                s.addCounterInputChannel(obj.niDevID,obj.ctrName,'EdgeCount');
            end
            s.Channels(1).ActiveEdge='Rising';
            
            if(isempty(obj.DataAvailableEventListener)||...
                    ~isvalid(obj.DataAvailableEventListener))
                obj.DataAvailableEventListener=...
                    s.addlistener('DataAvailable',@obj.dataBatchAvailableFromDevice);                
            end

            disp(['Input counter configured at terminal (Unchangeable) ',s.Channels(1).Terminal]);
        end
    end
    
    methods
        function prepare(obj)
%             obj.lastDataValue=[];
            obj.initInternalTime();
            
            % counter is continues.
            s=obj.niSession;
            prepare@NI6321Core(obj);
            obj.ResetCounter();
        end
    end
end

