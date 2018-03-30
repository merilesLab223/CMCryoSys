classdef NI6321TTLGenerator < NI6321Core & TTLGenerator
    %NI6321TTLGENERATOR Summary of this class goes here
    %   Detailed explanation goes here
        
    methods
        % constructor, and send info to parent.
        function obj = NI6321TTLGenerator(varargin)
            obj=obj@NI6321Core(varargin);
        end
    end
    
    properties
        ttlchan='port0/line0';
        clockAnalogInputChan='ai15';
        niTTLChan=[];
        niTTLAnalogClockChan=[];
        totalExecutionTime=0;
    end
    
    properties (Access = protected)
    end
    
    methods (Access = protected)
        function onDataReady(obj,s,e)
            % do nothing with the data.
        end
    end
    
    % device functions.
    methods (Access = protected)
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            
            % making the output channle/s.
            obj.niTTLChan=s.addDigitalChannel(obj.niDevID,obj.ttlchan,'OutputOnly');
            
            if(~obj.hasExternalClock())
                % adding and analog input channel if clock not found.
                s.addAnalogInputChannel(obj.niDevID,obj.clockAnalogInputChan,'Voltage');
                % must exist for startBackground.
                s.addlistener('DataAvailable',@(s,e)obj.onDataReady(s,e)); % dummy listener;
            end
        end
    end
    
    methods
        function prepare(obj)
            % in base class:
            % stop any execution.
            % prepare device
            prepare@NI6321Core(obj);
            s=obj.niSession;
            
            % preparing the compilation data.
            data=obj.compile();
            obj.totalExecutionTime=length(data)*obj.getTimebase();
            
            if(isempty(data))return;end
            
            s.queueOutputData(data);
            s.prepare();
        end
        
        function run(obj)
            if(obj.totalExecutionTime<=0)
                return;
            end
            obj.niSession.startBackground();
        end
    end
    
    % overriden abstract compilation
    methods
        function [rslt]=compileSequence(obj,timestamps,data)
            % making the compilation data vector with no duplicates.
            if(isempty(timestamps))
                rslt=[];
                return;
            end
            
            [t,bvals]=obj.makeTTLTimedVectors(timestamps,data);
            
            % converting ttl timed data into timebase.
            tspan=0:obj.getTimebase():max(t);
            rslt=interp1(t,bvals,tspan,'previous')';
        end
    end
end

