classdef NI6321AnalogReader < NI6321Core
    %NI6321POSITIONER Summary of this class goes here
    %   Detailed explanation goes here
    properties
        rchan='ai0';
        niReaderChannel=0;
    end
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321AnalogReader(varargin)
            obj=obj@NI6321Core(varargin);
        end
    end
    
    methods (Access = protected)
        function dataBatchAvailableFromDevice(obj,s,e)
            %LastRead=data;
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
            
            % reader is continues.
            s.IsContinuous=true;
            
            obj.niReaderChannel=s.addAnalogInputChannel(obj.niDevID,obj.rchan,'Voltage');
            s.addlistener('DataAvailable',@(s,e)obj.dataBatchAvailableFromDevice(s,e));
        end

        % used to call a position event. 
        % the position event will be called to execute data.
        function ev(obj,t,data)
            error('NI analog reader cannot have timed events.');
        end
        
        % used to call a position event. 
        % the position event will be called to execute data.
        function prepare(obj)
            s=obj.niSession;
            s.Rate=obj.Rate;
            obj.niSession.prepare();
        end
        
        % device runner.
        function run(obj)
            obj.niSession.startBackground();
        end
    end
end

