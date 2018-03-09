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
        keepLastSequenceInMemory=1;
        niTTLChan=[];
    end
    
    properties (Access = protected)
        lastSequenceData=[];
        lastPrepared=-1;
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
            % stop any execution.
            % call base class.
            prepare@NI6321Core(obj);
            s=obj.niSession;
            
            % clear if needed.
            if(~obj.keepLastSequenceInMemory)
                obj.lastPrepared=-1;
                obj.lastSequenceData=[];
            end
            
            % preparing data.
            data=[];
            if(obj.hasChanged(obj.lastPrepared))
                % interpolating data to the timebase.
                tspan=min(obj.timedTTL(:,1)):obj.getTimebase():max(obj.timedTTL(:,1));
                if(length(tspan)<2)
                    data=obj.timedTTL(1,2);
                else
                    data=interp1(obj.timedTTL(:,1),obj.timedTTL(:,2),tspan,'nearest');
                end
                
                if(obj.keepLastSequenceInMemory)
                    obj.lastPrepared=now;
                end
            else
                data=obj.lastSequenceData;
            end
            
            % sending the data to the device.
             obj.lastSequenceData=data;
        end
        
        function run(obj)
            s=obj.niSession;
            data=obj.lastSequenceData;
            if(~obj.keepLastSequenceInMemory)
                obj.lastPrepared=-1;
                obj.lastSequenceData=[];
            end
            s.outputSingleScan(data);
        end
    end
end

