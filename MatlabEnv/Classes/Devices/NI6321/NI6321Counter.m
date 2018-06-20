classdef NI6321Counter < NI6321Core & TimedMeasurementReader
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function obj=NI6321Counter(varargin)
            obj@NI6321Core(varargin{:});
            parseAndAssignFromVarargin(obj,{'ctrName'},varargin);
        end
    end
    
    properties
        ctrName='ctr0'; % the counter channel.
    end
        
    properties
        UseTimedDataUnits=true;
        % if true, first data value is ignored and is considered a 
        % startup value.
        FirstValueClearBuffer=true;
    end
    
    properties (Access = private)
        lastDataValue=[];
    end
    
    methods
        function ResetCounter(obj)
            if(~isempty(obj.niSession))
                obj.niSession.resetCounters();
            end
        end
    end
    
    methods(Access =protected)
        function [ts,data]=processDataBatch(obj,ts,data,e)
            loval=data(end);
            if(isempty(obj.lastDataValue))
                if(obj.FirstValueClearBuffer)
                    data=diff(data);
                    ts=ts(2:end);
                else
                    data=[data(1);diff(data)];
                end
            else
                data=diff([obj.lastDataValue;data]);
            end
            
            obj.lastDataValue=loval;
            
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
            s=obj.niSession;
            s.Rate=obj.Rate;
            
            % counter is continues.
            s.IsContinuous=true;
            
            % adding counter.
            s.addCounterInputChannel(obj.niDevID,obj.ctrName,'EdgeCount');
            s.Channels(1).ActiveEdge='Rising';
            obj.DataAvailableEventListener=...
                s.addlistener('DataAvailable',@obj.dataBatchAvailableFromDevice);
            disp(['Input counter configured at terminal (Unchangeable) ',s.Channels(1).Terminal]);
        end
    end
    
    methods
        function prepare(obj)
            obj.lastDataValue=[];
            obj.initInternalTime();
            prepare@NI6321Core(obj);
            obj.ResetCounter();
        end
    end
end

