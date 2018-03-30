classdef NI6321Core < Device & TimeBasedObject
    %NI6 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function [obj]=NI6321Core(varargin)
            if(length(varargin)>0 && ischar(varargin(1)))obj.niDevID=varargin(1);end
        end
    end
    
    events
        NIError;
    end
    
    % properties
    properties
        NICardMatchPattern='6321';
        triggerTerm='';
        
        niSession=[];
        niTrigger=[];
        niDevID=[];
        
        externalClockTerminal='';
    end
    
    % methods for NI card.
    methods
        function []=stop(obj)
            try
                obj.niSession.stop();
                obj.niSession.release();
            catch e
                warning('Error accured while trying to stop the session..');
                error(e.message);
            end
        end
        
        function [rslt]=hasExternalClock(obj)
            rslt=ischar(obj.externalClockTerminal) && ~isempty(obj.externalClockTerminal);
        end
    end
    
    % general methods
    methods (Access = protected)
        
        function [rslt]=hasDigitalLoopback(obj)
            rslt=~isempty(obj.triggerTerm)&&~isempty(obj.loopbacktriggerTermChan);
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
        
        function []=validateSession(obj)
            % find the NI devie.
            if(~isnumeric(obj.niSession))
                return;
            end
            obj.makeSession();
        end
        
        function []=makeSession(obj)
            if(~isnumeric(obj.niSession))
                obj.stop();
                %obj.niSession.release();
            end
            obj.niDevID=obj.findNIDevice();
            obj.niSession=daq.createSession('ni');
            obj.niSession.addlistener('ErrorOccurred',@(s,e)obj.onNIError(s,e));

        end
        
        % configures clock connections after everthing else was added.
        function onDeviceConfigured(obj)
            if(obj.hasExternalClock())
                obj.niSession.addClockConnection('External',...
                    [obj.niDevID,'/',obj.externalClockTerminal],'ScanClock');
            end
            
            onDeviceConfigured@Device(obj);
        end
        
        function []=maketriggerTerms(obj)
            s=obj.niSession;
            % checking for triggerTerm config.
            % adding triggerTerms.
            if(~isempty(obj.triggerTerm))
                if(isempty(obj.niTrigger))
                    % need to add triggerTerm.
                    obj.niTrigger=s.addTriggerConnection('external',[obj.niDevID,'/',obj.triggerTerm],'StartTrigger');
                end
            elseif(obj.niTrigger~=0)
                s.removeConnection(0);
                obj.niTrigger=[]; % kill the triggerTerm.
            end
        end
        
        function []=onNIError(obj,s,e)
            obj.notify('NIError',e);
        end
    end    
    
    % general method for configuration.
    methods
        % Call to run.
        function []=run(obj)
            obj.niSession.startBackground();
        end
        
        function []=prepare(obj)
            % call parent prepare.
            prepare@Device(obj);
            s=obj.niSession;
            s.Rate=obj.Rate;
            
            obj.maketriggerTerms();
        end
        
        function [data]=single(obj)
            
            isPrevContinues=obj.niSession.IsContinuous;
            if(obj.niSession.IsContinuous)
                obj.niSession.IsContinuous=false;
                obj.prepare();
            end
            data=obj.niSession.startForeground();
            obj.niSession.IsContinuous=isPrevContinues;
        end
    end
end

