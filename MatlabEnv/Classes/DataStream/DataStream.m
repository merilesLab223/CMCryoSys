classdef DataStream < handle & TimeBasedObject
    %DATASTREAM Summary of this class goes here
    %   Detailed explanation goes here
            
    methods
        function obj = DataStream(reader,isrunning)
            if(~exist('reader','var') || ~isa(reader,'TimedMeasurementReader'))
                error('DataReader must be of type TimedMeasurementReader.');
            end
            if(~exist('isrunning','var'))isrunning=0;end
            
            %obj.reader=reader;
            % binding the event listener.
            obj.Reader=reader;
            if(isrunning)
                obj.start();
            else
                obj.stop();
            end
        end
    end
    
    properties (SetAccess = protected)
        IsRunning=0;
        Reader=[];
    end
    
    properties (Access = protected)
        DataReadyEventListner=[];
    end
    
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            % empty function.
        end
    end
    
    methods
        function delete(obj)
            try
                obj.stop();
                %delete(obj.DataReadyEventListner);
            catch err
            end
        end
        
        function start(obj)
            obj.IsRunning=1;
            obj.deleteActiveEventListener();
            obj.DataReadyEventListner=...
                obj.Reader.addlistener('DataReady',@obj.dataBatchAvailableFromDevice);
        end
        
        function stop(obj)
            obj.IsRunning=0;
            obj.deleteActiveEventListener();
        end
        
        function reset(obj)
        end
        
        function prepare(obj)
        end
    end
    
    methods(Access = protected)
        function deleteActiveEventListener(obj)
            if(~isempty(obj.DataReadyEventListner)&& isvalid(obj.DataReadyEventListner))
                obj.DataReadyEventListner.Enabled=0;
                delete(obj.DataReadyEventListner);
            end            
        end
    end
end

