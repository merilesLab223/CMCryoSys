classdef NI6321Core < Device & TimeBasedObject
    %NI6 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function [obj]=NI6321Core(varargin)
            if(length(varargin)>0 && ischar(varargin(1)))obj.niDevID=varargin(1);end
        end
    end
    
    events
        DataReady;
        NIError;
    end
    
    % properties
    properties
        NICardMatchPattern='6321';
        trigger='';
        
        niSession=[];
        niTrigger=[];
        niDevID=[];

    end
    
    % methods for NI card.
    methods
        function Stop(obj)
            obj.niSession.stop();
            obj.niSession.release();
        end
    end
    
    % general methods
    methods (Access = protected)
        
        function [rslt]=hasDigitalLoopback(obj)
            rslt=~isempty(obj.trigger)&&~isempty(obj.loopbackTriggerChan);
        end
        
        function [devid]=findNIDevice(obj)
            % find ni device that matches the device info.
            devs=daq.getDevices();
            for i=1:length(devs)
                if(contains(devs(i).Model,obj.NICardMatchPattern))
                    devid=devs(i).ID;
                    return;
                end
            end
            if(~exist('dev','var'))
                error(['Cannot find device with match pattern "',obj.NICardMatchPattern,'"']);
            end
        end
        
        function validateSession(obj)
            % find the NI devie.
            if(~isnumeric(obj.niSession))
                return;
            end
            obj.makeSession();
        end
        
        function makeSession(obj)
            if(~isnumeric(obj.niSession))
                obj.niSession.release();
            end
            obj.niDevID=obj.findNIDevice();
            obj.niSession=daq.createSession('ni');
            obj.niSession.addlistener('ErrorOccurred',@(s,e)obj.onNIError(s,e));
            
        end
        
        function makeTriggers(obj)
            s=obj.niSession;
            % checking for trigger config.
            % adding triggers.
            if(~isempty(obj.trigger))
                if(isempty(obj.niTrigger))
                    % need to add trigger.
                    obj.niTrigger=s.addTriggerConnection('external',[obj.niDevID,'/',obj.trigger],'StartTrigger');
                end
                
            elseif(obj.niTrigger~=0)
                s.removeConnection(0);
                obj.niTrigger=0; % kill the trigger.
            end
        end
        
        function onNIError(obj,s,e)
            obj.notify('NIError',e);
        end

    end    
    
    % general method for configuration.
    methods
        % Call to run.
        function run(obj)
            obj.niSession.startBackground();
        end
        
        function prepare(obj)
            obj.Stop();
            s=obj.niSession;
            s.Rate=obj.Rate;
            
            obj.makeTriggers();
        end
    end
end

