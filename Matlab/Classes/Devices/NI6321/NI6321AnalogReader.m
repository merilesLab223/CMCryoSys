classdef NI6321AnalogReader < NI6321Core & TimedMeasurementReader
    %NI6321POSITIONER Summary of this class goes here
    %   Detailed explanation goes here
    properties
        readchan='ai0';
        niReadereadchannel=[];
    end
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321AnalogReader(varargin)
            obj=obj@NI6321Core(varargin);
        end
    end
    
    % device methods
    methods  (Access = protected)
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            s.Rate=obj.Rate;
            
            % reader is continues.
            s.IsContinuous=true;
            
            obj.niReadereadchannel=s.addAnalogInputChannel(obj.niDevID,obj.readchan,'Voltage');
            s.addlistener('DataAvailable',@(s,e)obj.dataBatchAvailableFromDevice(s,e));
        end
    end
    
    methods
        % preapre & run functions are inherited from parent.     
        function run(obj)
            obj.initInternalTime();
            run@NI6321Core(obj);
        end
    end
end

