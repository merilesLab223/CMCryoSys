classdef NI6321Core < Device & TimeBasedObject
    %NI6 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function [obj]=NI6321Core(varargin)
            obj@Device(varargin{:});
            parseAndAssignFromVarargin(obj,{'niDevID'},varargin);
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
        
        niDevID=[];
        externalClockTerminal='';
        ThrowErrors=true;
        IsContinuous=[];
        
        % the duration of the measurement. Will reset to [] after each
        % prepare.
        Duration=[];        
    end
    
    properties (Access = private)
        m_niSession=[];
    end
    
    methods
        function [rt]=get.Duration(obj)
           rt=obj.secondsToTimebase(obj.niSession.DurationInSeconds);
        end
        function set.Duration(obj,val)
            obj.niSession.DurationInSeconds=obj.timebaseToSeconds(val);
        end
        
        function [s]=get.niSession(obj)
            obj.validateSession();
            s=obj.m_niSession;
        end
        
        function [s]=get.IsContinuous(obj)
            s=obj.niSession.IsContinuous;
        end
        
        function set.IsContinuous(obj,val)
            obj.niSession.IsContinuous=val;
        end
    end
    
    properties (SetAccess = private)
        niSession=[];
        hasTrigger=0;
        IsDeleted=false;
        LastStopTime=-1;
        IsRunning=[];
        externalClockConnectionIndex=0;
        ErrorOccuredEventListener=[];
        
    end
    
    % methods for NI card.
    methods
        
        function clearConfiguration(obj)
            clearConfiguration@Device(obj);
            obj.externalClockConnectionIndex=0;
            if(~isempty(obj.ErrorOccuredEventListener)...
                    && isvalid(obj.ErrorOccuredEventListener))
                delete(obj.ErrorOccuredEventListener);
                obj.ErrorOccuredEventListener=[];
            end
            obj.hasTrigger=0;
            obj.niSession=[];
        end
        
        function [rt]=get.IsRunning(obj)
            rt=obj.isSessionRunning();
        end
        
        function []=stop(obj)
            if(~isvalid(obj))
                return;
            end
            s=obj.niSession;
            if(isempty(s))
                return;
            end

            try
                if(obj.IsRunning)
                    fprintf([obj.name,' (',class(obj),'): ']);
                    fprintf('Stopping ...');
                    s.stop();
                    disp('stopped. ');
                end
            catch err
                % restart the session and mark the current as
                % unconfigured.
                obj.clearConfiguration();
                warning(err.message);
            end
            %wait(s);
            obj.LastStopTime=now;
            stop@Device(obj);
        end
        
        function [rslt]=hasExternalClock(obj)
            rslt=ischar(obj.externalClockTerminal) && ~isempty(obj.externalClockTerminal);
        end
        
        % sets the max read chunk size.
        function SetMaxReadChunkSize(obj,size)
            obj.niSession.IsNotifyWhenDataAvailableExceedsAuto=size<=0;
            if(size>0)
                if(size>obj.niSession.NumberOfScans)
                    size=obj.niSession.NumberOfScans;
                end
                obj.niSession.NotifyWhenDataAvailableExceeds=size;
            end
        end
    end
    
    methods (Access = private)
        function [rt]=do_stopcommand(obj)
            
        end
    end
    
    % general methods
    methods (Access = protected)
        function [rt]=isSessionRunning(obj)
            rt=false;
            if(~isempty(obj.niSession))
                rt=obj.niSession.IsRunning;
            end
        end
        
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
            if(~isempty(obj.m_niSession)&&~isvalid(obj.m_niSession))
                % has invalid session. Clear the config.
                obj.clearConfiguration();
            elseif(~isempty(obj.m_niSession))
                return;
            end
            
            % find the NI devie.
            obj.niDevID=obj.findNIDevice();
            obj.m_niSession=daq.createSession('ni');
            obj.ErrorOccuredEventListener= ...
                obj.m_niSession.addlistener('ErrorOccurred',@obj.onNIError);
        end
        
        % configures clock connections after everthing else was added.
        function onDeviceConfigured(obj)
            onDeviceConfigured@Device(obj);
        end
        
        function clearClockTerms(obj)
            s=obj.niSession;
            for i=1:length(s.Connections)
                con=s.Connections(i);
                if(isa(con,'daq.ni.ScanClockConnection'))
                    s.removeConnection(i);
                    break;
                end
            end
            obj.externalClockConnectionIndex=0;            
        end
        
        function []=makeExternalClockTerms(obj)
            s=obj.niSession;
            % checking for externalClock config.
            % adding triggerTerms.
            obj.clearClockTerms();
            if(~isempty(obj.externalClockTerminal))
                % need to add triggerTerm.
                [~,obj.externalClockConnectionIndex]=s.addClockConnection('External',...
                    [obj.niDevID,'/',obj.externalClockTerminal],'ScanClock');
            end
        end
        
        function clearTirggerTerms(obj)
            s=obj.niSession;
            for i=1:length(s.Connections)
                con=s.Connections(i);
                if(isa(con,'daq.ni.StartTriggerConnection'))
                    s.removeConnection(i);
                    break;
                end
            end
            obj.hasTrigger=0;
        end
        
        function []=makeTriggerTerms(obj)
            s=obj.niSession;
            % checking for triggerTerm config.
            % adding triggerTerms.
            obj.clearTirggerTerms();
            if(~isempty(obj.triggerTerm))
                % need to add triggerTerm.
                [~,obj.hasTrigger]=s.addTriggerConnection('external',[obj.niDevID,'/',obj.triggerTerm],'StartTrigger');
            end
        end
        
        function []=onNIError(obj,s,e)
            %warning();
            msg=['Found ni error while executing:',newline,e.Error.message];
            if(obj.ThrowErrors)
                warning(msg);
            else
                disp(msg);
            end
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
            run@Device(obj);
        end
        
        function []=prepare(obj,doStop)
            if(~exist('doStop','var'))
                doStop=1;
            end
            % call parent prepare.
            prepare@Device(obj);
            s=obj.niSession;
            if(doStop || obj.IsRunning)
                obj.stop();
            end
            if(~s.IsRunning)
                s.release(); % release previous resources.
                s.Rate=obj.Rate;
                obj.makeTriggerTerms();
                obj.makeExternalClockTerms();                
            else
                warning('Session was not stopped though stop function called.');
            end
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

