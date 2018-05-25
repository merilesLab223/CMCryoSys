% this class defines the general expose infrastructure to allow for
% experiment com. Experiments generation are path dependent and will demand
% a temp lib. The handling object will be path + exp dependent. 
classdef ExperimentCore < Expose.Expose
    % private constructor.
    methods
        function [obj]=ExperimentCore()
            obj.WebsocketBindings=containers.AutoRemoveMap(5*60); % 5 minutes if no access destroy.
        end
    end
    
    % handler methods
    % overrding these handlers to return the appropriate 
    % message handlers for the specific command.
    methods (Access = protected)
        function [o]=GetHandler(obj,id,e)
            import Expose.Core.*;
            % check if to get an experiment handler.
            % otherwise return the curent object as the handler.s
            getExperimentHandler=exist('id','var') && ~exist('e','var');
            hasNPMessage=exist('e','var')&&isa(e.Message,'Expose.Core.ExposeMessage');
            if(hasNPMessage)
                if(e.Message.MessageType == ExposeMessageType.Invoke)
                    getExperimentHandler=isempty(e.Message.Text) || ~startsWith(e.Message.Text,'static.'); 
                elseif(e.Message.MessageType == ExposeMessageType.Get || e.Message.MessageType == ExposeMessageType.Set)
                    getExperimentHandler=isempty(e.Message.Text) || ~strcmp(e.Message.Text,'static');
                end
            end
            if(getExperimentHandler)
                % getting the experiment handler, associated with id.
                if(~obj.WebsocketBindings.contains(id))
                    error(['No current active experiments are associated with caller id: ',id]);
                end
                o=obj.WebsocketBindings(id);
            else
                % static method or property.
                % need to replace static;
                if(hasNPMessage)
                    if(startsWith(e.Message.Text,'static'))
                        e.Message.Text=e.Message.Text(7:end);
                        if(e.Message.Text(1)=='.')
                            e.Message.Text=e.Message.Text(2:end);
                        end
                    end
                end
                o=obj;
            end
        end
        
        function [o]=CreateHandler(obj,id,e)
            obj.bindWebsocket(id,[]);
            o=obj;
        end
        
        function DestroyHandler(obj,id,e)
            % no handler destruction since experiment should persist.
            % TODO: move the keep alive and other pesistant implementation 
            % to the expose.
            obj.unbindWebsocket(id);
        end
    end
    
    methods(Access = protected)
        function onLog(obj,s,e)
            % call to get the handler since we are logging.
            onLog@Expose.Expose(obj,s,e);
            
            % keep this object alive since it is still connected.
            if(~isempty(e.CallerID))
                obj.WebsocketBindings.contains(e.CallerID);
            end
        end
    end
    
    properties(SetAccess = protected)
        WebsocketBindings=[];
        LastExperimentOpenedID=[];
    end
    
    % bindings and collections.
    methods(Access = protected)
        function bindWebsocket(obj,sid,exp)
            if(~isvalid(obj.WebsocketBindings))
                return;
            end
            obj.WebsocketBindings(sid)=exp;
        end
        
        function unbindWebsocket(obj,sid)
            if(~isvalid(obj.WebsocketBindings))
                return;
            end
            if(~obj.WebsocketBindings.contains(sid))
                return;
            end
            fprintf(['Destroying experiment for websocket ',sid,' ... ']);
            exp=obj.WebsocketBindings(sid);
            delete(exp);
            obj.WebsocketBindings.remove(sid);
            disp('OK');
        end
    end
    
    % experiment static methods
    methods
        function [id]=OpenExperiment(obj,fpath,e)
            expClassInfo=obj.ValidateExperimentClassName(fpath);
            id=e.CallerID;
            exp=expClassInfo.make();
            if(~isa(exp,'Experiment'))
                error('Cannot create an experiment unless class is derived from Experiment class');
            end
            obj.bindWebsocket(e.CallerID,exp);
            exp.Init(obj,id);
            obj.LastExperimentOpenedID=e.CallerID;
        end
    end
    
    methods(Access = private, Static)
        % validates the experiment information that is attached to a
        % specific experiment name. If a temp file is required, due
        % to duplicates creates this temp file (not implmenented).
        function [expClassInfo]=ValidateExperimentClassName(fpath)
            persistent expCoreClassInfo;
            if(isempty(expCoreClassInfo))
                expCoreClassInfo=containers.Map();
            end
            
            if(~exist(fpath,'file'))
                if(expCoreClassInfo.isKey(fpath))
                    expCoreClassInfo.remove(fpath);
                end
                error(['File ',fpath,' not found. Experiment class cannot be validated.']);
            end
            fpath=lower(fpath);
            if(filesep=='\')
                fpath=replace(fpath,'/',filesep);
            else
                fpath=replace(fpath,'\',filesep);
            end
            
            if(expCoreClassInfo.isKey(fpath))
                expClassInfo=expCoreClassInfo(fpath);
            else
                expClassInfo=struct();
                expClassInfo.id=expose_short_hash(fpath);
                expClassInfo.path=fpath;
                
                % loading the class name (as the filename).
                [expClassInfo.directory,~,~]=fileparts(fpath);
                addpath(expClassInfo.directory);
                
                % temp and path
                expClassInfo.RequiresTemp=false;
                expClassInfo.code='';
                
            end
            
            % check the class name and validate class is executable.
            code=fileread(fpath);
            if(~strcmp(code,expClassInfo.code))
                expClassInfo.code=code;
                className=regexp(code,'(?<=classdef *)\w+','match','once');
                expClassInfo.className=className;
                expClassInfo.make=@()eval(className);
            end
            
            % make temp if required.
            hasExistingClasses=which(expClassInfo.className);
            if(~isempty(hasExistingClasses))
                expClassInfo.RequiresTemp=any(~strcmpi(hasExistingClasses,fpath));
            else
                expClassInfo.RequiresTemp=false;
            end
            
            if(expClassInfo.RequiresTemp)
                error(['Temp/Experiments with the same name are not available yet.'...
                    ' Please rename your experiment or do not keep experiments with the same name'...
                    ' open at the same time.']);
            end
            
            expCoreClassInfo(fpath)=expClassInfo;
        end
    end
end
