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
        MaxWaitForTriggersToExecute=10000;
        RunTimeout=1000;
        NICardMatchPattern='6321';
        triggerTerm='';
        
        niSession=[];
        %niTrigger=[];
        hasTrigger=0;
        niDevID=[];
        
        externalClockTerminal='';
    end
    
    properties (SetAccess = private)
        IsDeleted=false;
        BatchHandle=[];
        LastStopTime=-1;
    end
    
    % methods for NI card.
    methods
        function []=stop(obj)
            s=obj.niSession;
            if(~s.IsRunning)
                disp('Called stop on a non running session.');
                return;
            end
            %if(s.Trig
            s.stop();
            wait(s);
            s.release();
            wait(s);
            obj.LastStopTime=now;
        end
        
        function [rslt]=hasExternalClock(obj)
            rslt=ischar(obj.externalClockTerminal) && ~isempty(obj.externalClockTerminal);
        end
    end
    
    methods (Access = private)
        function [rt]=do_stopcommand(obj)

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
            end
            obj.niDevID=obj.findNIDevice();
            obj.niSession=daq.createSession('ni');
            obj.niSession.addlistener('ErrorOccurred',@obj.onNIError);
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
                if(~obj.hasTrigger)
                    % need to add triggerTerm.
                    %obj.hasTrigger=1;
                    [~,obj.hasTrigger]=s.addTriggerConnection('external',[obj.niDevID,'/',obj.triggerTerm],'StartTrigger');
                end
            elseif(obj.hasTrigger~=0)
                s.removeConnection(obj.hasTrigger);
                obj.hasTrigger=0;
            end
        end
        
        function []=onNIError(obj,s,e)
            warning('Found ni error while executing:');
            %obj.stop();
            %disp(getReport(e.Error, 'extended', 'hyperlinks', 'on' ));
            error(e.Error);%obj.notify('NIError',e);
        end
    end
    
    % general method for configuration.
    methods
        % Call to run.
        function []=run(obj)
            s=obj.niSession;
            if(s.IsRunning)
                disp('Called run on an already running session.');
            end
            s.startBackground();
            tic;
            while(~s.IsRunning)
                pause(0.01);
                if(toc()>obj.timebaseToSeconds(obj.RunTimeout))
                    error('Timeout while trying to start the session.');
                end
            end
        end
        
        function []=prepare(obj,doStop)
            if(~exist('doStop','var'))
                doStop=1;
            end
            % call parent prepare.
            prepare@Device(obj);
            if(doStop)
                obj.stop();
            end
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
        
        function delete(obj)
            try
                if(obj.IsDeleted)
                    return;
                end                
                fprintf('Destopying NI6321 session object, %s\n',...
                    class(obj));
                obj.stop();
                delete(obj.niSession);
                obj.IsDeleted=true;
            catch err
            end
        end
    end
end

