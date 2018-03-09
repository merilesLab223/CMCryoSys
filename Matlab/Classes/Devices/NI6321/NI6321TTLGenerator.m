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
        ttlchan='port0/line1';
        niTTLChan=[];
    end
    
    properties (Access = protected)
        preparedSequence=[];
    end
    
    % device functions.
    methods
        function configureDevice(obj)
            % find the NI devie.
            obj.validateSession();
            s=obj.niSession;
            
            % making the output channle/s.
            obj.niTTLChan=s.addDigitalChannel(obj.niDevID,obj.ttlchan,'OutputOnly');
            %obj.biTTLAnalogClockChan=s.addAnalogInputChannel(obj.niDevID,'ai5','Voltage');
        end
        
        function prepare(obj)
            % in base class:
            % stop any execution.
            % prepare device
            prepare@NI6321Core(obj);
            
            % preparing the compilation data.
            obj.preparedSequence=this.compile();
        end
        
        function run(obj)
            if(isempty(obj.preparedSequence))return;end
            s=obj.niSession;
            s.outputSingleScan(obj.preparedSequence);
        end
    end
    
    % overriden abstract compilation
    methods
        function [rslt]=compileSequence(obj,t,data)
            % making the compilation data vector.
            [t,bvals]=obj.makeTTLTimedVectors(t,data);
            
            % removing duplicates.
            [t,uidx]=unique(t);
            bvals=bvals(uidx);
            
            % converting ttl timed data into timebase.
            tspan=0:this.getTimebase():max(t);
            rslt=interp1(t,bvals,tspan,'nearest');
        end
    end
end

