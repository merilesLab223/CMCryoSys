classdef NI6321Positioner2D < NI6321Core & Positioner2D
    %NI6321POSITIONER Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        % constructor, and send info to parent.
        function obj = NI6321Positioner2D(varargin)
            obj=obj@NI6321Core(varargin);
        end
    end
    
    properties
        xchan='ao0';
        ychan='ao1';

        niXChannel=[];
        niYChannel=[];
        
        totalExecutionTime=0;
    end
    

    % device methods
    methods
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            
            % adding channels.
            obj.niXChannel=s.addAnalogOutputChannel(obj.niDevID,obj.xchan,'Voltage');
            obj.niYChannel=s.addAnalogOutputChannel(obj.niDevID,obj.ychan,'Voltage');
        end

        % used to call a position event. 
        % the position event will be called to execute data.
        function ev(obj,t,data)
            % pushing data to the event.
            addPath(data);
        end
        
        % used to call a position event. 
        % the position event will be called to execute data.
        function prepare(obj)
            % call base class.
            prepare@NI6321Core(obj);
            s=obj.niSession;
            
            % pushing data.
            s.queueOutputData(obj.path);
            spath=size(obj.path);
            obj.totalExecutionTime=spath(1)*obj.getTimebase()*1000; % in ms.
            s.prepare();
        end
    end
end

