classdef NI6321Counter < NI6321Core & TimedMeasurementReader
    %NI6321COUNTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        ctrName='ctr0'; % the counter channel.
        %niCounterChannel=[];
        %niCounterTimebase=[];
    end
    
    properties (Access = private)
        lastDataValue=[];
    end
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321Counter(varargin)
            obj=obj@NI6321Core(varargin);
        end
    end
    
    methods(Access =protected)
        function [ts,data]=processDataBatch(obj,ts,data,e)
            loval=data(end);
            if(isempty(obj.lastDataValue))
                data=diff([data(1);data]);
            else
                data=diff([obj.lastDataValue;data]);
            end
            obj.lastDataValue=loval;
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
            %[obj.niCounterChannel,idx]=...
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
        end
    end
end

