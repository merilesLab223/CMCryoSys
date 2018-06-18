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
    
    properties (SetAccess = private)
        AllExperimentHandlerIDS={};
    end
    
    % handler methods
    % overrding these handlers to return the appropriate 
    % message handlers for the specific command.
    methods (Access = protected)
        function [o]=GetHandler(obj,id,e)
            import Expose.Core.*;
            if(exist('id','var'))
                % keeping the current alive since we recived a request for
                % it.
                obj.WebsocketBindings.keepAlive(id);
            end
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
                    disp(['No current active experiments are associated with caller id: ',...
                        id,'. Assumed destroyed.']);
                    o=[];
                    return;
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
            if(~obj.isWebsocketBound(id))
                return;
            end
            disp(['Destroying experiment for websocket ',id,' ... ']);            
            disp(['Destruct message: ',e.Message.Text]);
            oldexp=obj.unbindWebsocket(id);
            delete(oldexp);
            disp(['Destruction complete, ',id]);
            
        end
    end
    
    methods(Access = protected)
        function onLog(obj,s,e)
            % call to get the handler since we are logging.
            onLog@Expose.Expose(obj,s,e);
            
            if(~isvalid(obj))
                return;
            end
            
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
        
        function [rt]=isWebsocketBound(obj,sid)
            rt=false;
            if(~isvalid(obj.WebsocketBindings))
                return;
            end
            if(~obj.WebsocketBindings.contains(sid))
                return;
            end       
            rt=true;
        end
        
        function [oldExp]=unbindWebsocket(obj,sid)
            oldExp=[];
            if(~obj.isWebsocketBound(sid))
                return;
            end
            oldExp=obj.WebsocketBindings(sid);
            obj.WebsocketBindings.remove(sid);
        end
    end
    
    % experiment static methods
    methods
        function [expid]=OpenExperiment(obj,fpath,e)
            obj.AllExperimentHandlerIDS{end+1}=e.CallerID;
            expClassInfo=obj.ValidateExperimentClassName(fpath);
            [~,expname,~]=fileparts(fpath);
            expid=expClassInfo.id;
            disp(['Creating experiment "',expname,'" for websocket ',e.CallerID]);
            exp=expClassInfo.make();
            if(~isa(exp,'Experiment'))
                error('Cannot create an experiment unless class is derived from Experiment class');
            end
            
            obj.LastExperimentOpenedID=e.CallerID;
            exp.BindExperimentCore(obj,e.CallerID);
            obj.bindWebsocket(e.CallerID,exp);
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
            %fpath=lower(fpath);
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
                expClassInfo.fileName=[];
                expClassInfo.fileExt=[];
                
                % loading the class name (as the filename).
                [expClassInfo.directory,expClassInfo.fileName,expClassInfo.fileext]=...
                    fileparts(fpath);
                if(endsWith(expClassInfo.fileName,'.'))
                    expClassInfo.fileName=expClassInfo.fileName(1:end-1);
                end
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
                if(~strcmp(className,expClassInfo.fileName))
                    % need to replace and rewrite all text.
                    code=regexprep(code,...
                        '(?<=classdef *)\w+',expClassInfo.fileName,'once');
                    filewrite(fpath,code);
                    className=expClassInfo.fileName;
                end
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
