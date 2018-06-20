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
        niSession=[];
        niDevID=[];
        externalClockTerminal='';
        ThrowErrors=true;
    end
    
    properties (SetAccess = private)
        hasTrigger=0;
        IsDeleted=false;
        BatchHandle=[];
        LastStopTime=-1;
        IsRunning=[];
        externalClockConnectionIndex=0;
    end
    
    % methods for NI card.
    methods
        function [rt]=get.IsRunning(obj)
            rt=false;
            if(~isempty(obj.niSession))
                rt=obj.niSession.IsRunning;
            end
        end
        
        function []=stop(obj)
            s=obj.niSession;
            if(isempty(s))
                return;
            end
            try                
                if(s.IsRunning)
                    fprintf([obj.name,' (',class(obj),': ']);
                    fprintf('Stopping ...');
                    s.stop();
                    pause(0.001);
                    disp('stopped. ');
                end
                s.release();                
            catch err
                % restart the session and mark the current as
                % unconfigured.
                obj.isConfigured=false;
                delete(s);
                obj.niSession=[];              
                obj.configure();
                obj.LastStopTime=now;
                rethrow(err);
            end
            %wait(s);
            obj.LastStopTime=now;
        end
        
        function [rslt]=hasExternalClock(obj)
            rslt=ischar(obj.externalClockTerminal) && ~isempty(obj.externalClockTerminal);
        end
        
        % sets the max read chunk size.
        function SetMaxReadChunkSize(obj,size)
            obj.niSession.IsNotifyWhenDataAvailableExceedsAuto=size<=0;
            if(size>0)
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
            if(~isempty(obj.externalClockTerminal))
                if(~obj.externalClockConnectionIndex)
                    % need to add triggerTerm.
                    [~,obj.externalClockConnectionIndex]=s.addClockConnection('External',...
                        [obj.niDevID,'/',obj.externalClockTerminal],'ScanClock');
                end
            elseif(obj.externalClockConnectionIndex~=0)
                obj.clearClockTerms();
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
            if(~isempty(obj.triggerTerm))
                if(~obj.hasTrigger)
                    % need to add triggerTerm.
                    [~,obj.hasTrigger]=s.addTriggerConnection('external',[obj.niDevID,'/',obj.triggerTerm],'StartTrigger');
                    %trg.TriggerCondition=
                end
            elseif(obj.hasTrigger~=0)
                obj.clearTirggerTerms();
            end
        end
        
        function []=onNIError(obj,s,e)
            %warning();
            msg=['Found ni error while executing:',newline,e.Error.message];
            if(obj.ThrowErrors)
                error(msg);
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
            obj.makeTriggerTerms();
            obj.makeExternalClockTerms();
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

