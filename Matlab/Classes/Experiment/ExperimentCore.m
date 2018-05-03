classdef ExperimentCore < handle
    
    properties (SetAccess = private)
        ExpInfo=[];
    end
    
    properties (Access = private)
        m_exp_core_data_Struct=0;
        m_exp_default_ignore_list={'ExpInfo','Devices'};
    end
    
    methods
        % return the device collection.
        function [info]=get.ExpInfo(exp)
            if(isnumeric(exp.m_exp_core_data_Struct))
                exp.m_exp_core_data_Struct=ExperimentInfo();
            end
            info=exp.m_exp_core_data_Struct;
        end
        
        % registers the experiment core by name to the global
        % running object.
        function obj = ExperimentCore()
        end
        
        % a function to be called when initializitng the object.
        % may have a check to be called once.
        function init(obj,varargin)
            global devices;
            if(~exist(devices))
            end
        end
        
        % a function to be called when running the procedure.
        function run(obj,varargin)
        end
        
        % A function to be called when we are executing the data.
        function [linfo]=loop(obj,varargin)
        end
        
        % A function to be called when the data is upated.
        function [evid]=update(obj,name,varargin)
            evid='[No event called]';
            if(~exist('name','var'))
                name=fieldnames(obj);
            end
            
            if(iscell(name))
                if(length(name)>1)
                    for i=1:length(name)
                        obj.update(name{i},varargin{:});
                    end
                    % updating all.
                    return;
                else
                    name=name{1};
                end
            end
            
            if(any(contains(obj.m_exp_default_ignore_list,name)))
                return;
            end
            
            if(isempty(varargin))
                % search for the parameter in the exp.
                if(isfield(obj,name)||isprop(obj,name))
                    val=obj.(name);
                else
                    val=[];
                end
            else
                val=varargin(:);
            end
            
            evid=['mUpdateExperimentParameter_',name];

            ev=obj.ExpInfo.GetPostedEvent(evid);
            if(~isempty(ev) && isfield(ev,'tempid'))
                tempid=ev.tempid;
                obj.ExpInfo.SetTemp(val,ev.tempid);
            else % need new temp (if not null).
                tempid=obj.ExpInfo.SetTemp(val);
            end
            
            obj.ExpInfo.PostEvent('mUpdateExperimentParameter',struct(...
                'name',name,'tempid',tempid),'matlab',evid);
        end
        
        % call to notify the client of a specific event.
        function Post(obj,ev,strdata)
            if(~exist('strdata','var'))
                strdata='';
            end
            obj.ExpInfo.PostEvent(ev,struct('name',ev,'data',strdata));
        end        
    end
    
    methods (Access = protected)

    end
    
    methods (Static) % Events
        function [ev,hasEvent]=getNextPostedEvent(expID)
            ev=[];
            hasEvent=0;
            obj=ExperimentCore.GetExperimentByID(expID);
            if(isempty(obj.ExpInfo.postedEvents))
                return;
            end
            hasEvent=1;
            ev=obj.ExpInfo.postedEvents{1};
            obj.ExpInfo.postedEvents(1)=[]; % delete first.
        end
    end
    
    methods (Static)
        function [expID,errs,canExecute]=MakeExperiment(fpath,expID)
            if(~exist('fpath','var')||~ischar(fpath)||~exist(fpath,'file'))
                if(~ischar(fpath))
                    fpath='UNKNOWN';
                end
                %error(['Cannot generate experiment without a source file (',fpath,'?)!']);
            end
            
            if(~exist('expID','var'))expID='';end
            [ftpath,className]=ExperimentCore.MakeExperimentTempFile(fpath);
            expID=className;

            errs=checkcode(ftpath,'-string');
            canExecute=1;
            try
                exp=eval(className);
                ExperimentCore.RegisterExperimentStruct(expID,exp,fpath,ftpath);
            catch err
                canExecute=0;
                %disp(err);
            end
        end
        
        function [fname,className]=MakeExperimentTempFile(fpath)
            className=ExperimentCore.PathToExperimentID(fpath);
            tempdir=[pwd,'\','ExpTemp'];
            if(~exist(tempdir,'file')) % check for folder.
                mkdir(tempdir);
            end
            addpath(tempdir);% make sure we can access it.
            fname=[tempdir,'\',className,'.m'];
            code=fileread(fpath);
            code=regexprep(code,'(?<=classdef *)\w+',className,'ignorecase','once');
            %disp(code);
            %disp(fname);
            if(exist(fname,'file'))
                oldcode=fileread(fname);
                if(strcmp(oldcode,code))
                    %disp('Code the same, skipping write.');
                    return;
                end
                delete(fname); % delete the file.
                %disp('Deleted existing experiment file');
            end
            fid=fopen(fname,'a');
            fprintf(fid,"%s",code);
            fclose(fid);
            %disp('wrote code');
        end
        
        function RegisterExperimentStruct(expID,exp,fpath,tempPath)
            global experiment_core_experiment_list;
            if(~isstruct(experiment_core_experiment_list))
                experiment_core_experiment_list=containers.Map();
            end
            ExperimentCore.ClearExperimentByID(exp);
            exp.ExpInfo.ID=expID;
            exp.ExpInfo.CodeFile=fpath;
            exp.ExpInfo.TempFile=tempPath;
            experiment_core_experiment_list(expID)=exp;
        end

        function [rt]=HasExperimentByID(expID)
            rt=false;
            if(~exist('expID','var'))return;end
            global experiment_core_experiment_list;
            if(~isa(experiment_core_experiment_list,'containers.Map'))
                return;
            end
            rt=experiment_core_experiment_list.isKey(expID);
        end
        
        function [exp]=GetExperimentByID(expID)
            exp=[];
            if(~exist('expID','var'))return;end
            if(~ExperimentCore.HasExperimentByID(expID))return;end;
            global experiment_core_experiment_list;
            exp=experiment_core_experiment_list(expID);
        end
        
        function [rt]=ClearExperimentByID(expID)
            rt=false;
            if(~exist('expID','var'))return;end
            if(~ExperimentCore.HasExperimentByID(expID))return;end;
            
            % clearing the class.
            global experiment_core_experiment_list;
            exp=ExperimentCore.GetExperimentByID(expID);
            experiment_core_experiment_list.remove(expID);
            delete(exp);
            rt=true;
        end
        
        function [expID]=PathToExperimentID(fpath)
            expID=['Exp',lvport_hash(lower(fpath)),'C'];
        end
    end
    
    methods(Static) % propeties and functions
        function varargout=invokeMethod(expID,name,argTempIdx)
            varargout={};
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp) || ~ismethod(exp,name))
                %error('Experiment '+expID+' not found.');
                return;
            end
            iargs={};
            if(argTempIdx>0)
                % some arguments from a control.
                % reading and clearing.
                iargs=ExperimentCore.GetTempField(expID,argTempIdx);
                ExperimentCore.ClearTempField(expID,argTempIdx);
            end
            
            nargs=lvport_nargout_for_class(exp,name);
            if(nargs==0)
                exp.(name)(iargs{:});
                return;
            end
            varargout=cell(nargs,1);
            [varargout{:}]=exp.(name)(iargs{:});
        end
        
        function [rt]=SetPropertyByName(expID,pname,pval)
            rt=0;
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                return;
            end
            if(~isprop(exp,pname))
                return;
            end
            exp.(pname)=pval;
            rt=1;
        end
        
        function [rt]=UpdatePropetiesFromTempValue(expID,idx,clearTemp)
            rt=0;
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                return;
            end
            
            data=ExperimentCore.GetTempField(expID,idx);
            if(~exist('clearTemp','var') || clearTemp)
                ExperimentCore.ClearTempField(expID,idx);
            end
            
            if(iscell(data))
                % cannot be a cell must have a named value to update.
                % to update.
                return; 
            end
            
            names=fieldnames(data);
            %lastError='';
            for i=1:length(names)
                pname=names{i};
                if(~isprop(exp,pname))
                    continue;
                end
                % updating.
                exp.(pname)=data.(pname);
                rt=1;
            end            
        end
        
        function [pnames]=ListExperimentProperties(expID)
            pnames='';
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                return;
            end

            bclass=superclasses(exp);
            bprops={};
            if(~isempty(bclass))
                bprops=properties(bclass{1});
            end
            
            pnames=setdiff(properties(exp),bprops);
            pnames=strjoin(pnames,',');
        end
    end
    
    properties (Constant, Access = private)
        TEMP_FIELD_NAME_SPLIT='@';
    end
    
    % temporary parameters.
    methods (Static)
        % makes a temp parameter to allow the paramter 
        % to be accessed. 
        function [idx]=MakeTempParameter(expID,idx)
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                %error('Experiment not found when trying to make temp value.');
                idx=-1;
                return;
            end
            
            if(~exist('idx','var') || idx<0)idx=[];end
            idx=exp.ExpInfo.SetTemp({},idx);
        end
        
        % Update properties in the temp parameter.
        function [data]=GetTempField(expID,idx)
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                %error('Experiment not found when trying to get temp value.');
                data=[];
                return;
            end
            
            data=exp.ExpInfo.GetTemp(idx);
        end
        
        function [hasTemp]=HasTempField(expID,idx)
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp) || ~exp.ExpInfo.HasTemp(idx))
                %error('Experiment not found when trying to get temp value.');
                hasTemp=0;
            else
                hasTemp=1;
            end 
        end
        
        function [data]=ClearTempField(expID,idx)
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                %error('Experiment not found when trying to clear temp value.');
                data=[];
                return;
            end
            data=exp.ExpInfo.ClearTemp(idx);
        end
        
        % Update properties in the temp parameter.
        function [errorString]=UpdateTempFromNamePath(expID,idx,namepath,val)
            exp=ExperimentCore.GetExperimentByID(expID);
            errorString='';
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end

            o=exp.ExpInfo.GetTemp(idx);
            try
                uo=ObjectMap.update(o,namepath,val);
                exp.ExpInfo.SetTemp(uo,idx);
            catch err
                errorString=getReport(err);
            end
        end
        
        % Update properties in the temp parameter.
        function [errorString]=UpdateTempFromFieldMap(expID,idx,mapid)
            exp=ExperimentCore.GetExperimentByID(expID);
            errorString='';
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end

            map=exp.ExpInfo.GetTemp(mapid);
            exp.ExpInfo.ClearTemp(mapid);
            try
                uo=ObjectMap.fromMap(map.names,map.values,ExperimentCore.GetTempField(expID,idx));
                exp.ExpInfo.SetTemp(uo,idx);
            catch err
                errorString=getReport(err);
            end
        end
        
        function [namePaths,tos,hasTemp]=GetTempFieldMap(expID,idx)
            exp=ExperimentCore.GetExperimentByID(expID);
            hasTemp=0;
            namePaths='';
            tos='';
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end
            if(~exp.ExpInfo.HasTemp(idx))
                return;
            end
            hasTemp=1;
            o=exp.ExpInfo.GetTemp(idx);
            [namePaths,vals]=ObjectMap.map(o);
            lv=length(vals);
            tos=cell(1,lv);
            for i=1:length(vals)
                tos{i}=ObjectMap.getType(vals{i});
            end
            
            tos=strjoin(strtrim(tos),newline);
            namePaths=strjoin(strtrim(namePaths),newline);
        end
        
        % search and find the value id exists.
        function [val,vs,hasval]=GetValueFromTemp(expID,idx,namepath,to)
            vs=1;
            val=ObjectMap.getDefaultValue(to);
            hasval=0;            
            
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end

            o=exp.ExpInfo.GetTemp(idx);
            [val,hasval]=ObjectMap.getValueFromNamepath(o,namepath,to);
            vs=size(val);
            vs=vs(end:-1:1);
            if(isnumeric(val) && numel(val)>1)
                if(~isa(val,'double'))
                    val=double(val);
                end
                val=reshape(val,[1,numel(val)]);
            end
        end
    end
    
    % mesaging methods.
    methods(Static)
        % copy the messages structure to the temp data holders.
        function [tid]=PumpMessages(expID)
            exp=ExperimentCore.GetExperimentByID(expID);
            tid=-1;
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end
            evs=exp.ExpInfo.getPendingEvents(true);
            if(~iscell(evs))
                evs={evs};
            end
            if(~isempty(evs))
                for i=1:length(evs)
                    val=evs{i}.Value;
                    if(isempty(val))
                        evs{i}.Value=[];
                        continue;
                    end
                    evs{i}.DataIndex=exp.ExpInfo.SetTemp(evs{i}.Value);
                    evs{i}.Value=[];
                end
                [tid]=exp.ExpInfo.SetTemp(evs);
            end
            
            exp.ExpInfo.PumpUpdateLoop();
        end
        
    end    
    
    % debug
    methods
        function debugStoreCurrentStateToDisk(exp,ignoreList)        
            m=containers.Map;
            m('ExpInfo')=true;
            if(exist('ignoreList','var'))
                if(ischar(ignoreList))
                    ignoreList={ignoreList};
                end
                for i=1:length(ignoreList)
                    m(ignoreList{i})=true;
                end
            end
            
            data=struct();
            fns=fieldnames(exp);

            for i=1:length(fns)
                if(m.isKey(fns{i}))
                    continue;
                end
                data.(fns{i})=exp.(fns{i});
            end
            disp('Ignored:');
            disp(ignoreList');
            disp('Storing:');
            disp(fieldnames(data));
            save([exp.ExpInfo.CodeFile,'.mat'],'data');
            disp('ok.');
        end
        
        function debugLoadStoredStateFromDisk(exp,filename)
            if(~exist('filename','var'))
                filename=[exp.ExpInfo.CodeFile,'.mat'];
            end
            
            disp(['Loading ',filename,'...']);
            data=load(filename);
            data=data.data;
            
            fns=fieldnames(data);
            
            for i=1:length(fns)
                if(~isprop(exp,fns{i}))
                    disp([fns{i},' Skipped no prop.']);
                    continue;
                end
                disp([fns{i},' OK.']);
                try
                exp.(fns{i})=data.(fns{i});
                catch err
                    warning(err.message);
                end
            end
        end
    end
end
