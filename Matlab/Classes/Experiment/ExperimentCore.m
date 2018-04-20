classdef ExperimentCore < handle
    
    properties (SetAccess = private)
        ExpInfo=[];
        Devices=[];
    end
    
    properties (Access = private)
        m_exp_core_data_Struct=0;
    end
    
    methods
        
        % return the device collection.
        function [devs]=get.Devices(exp)
            devs=exp.ExpInfo.Devices;
        end
        
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
        function [rlst]=update(obj,varargin)
        end
    end
    
    methods (Access = protected)
        % call to update a specific field.
        function Update(obj,fid)
            if(exist('fid','var'))
                obj.Post('updateField',fid);
            else
                obj.Post('updateAllFields','');
            end
        end
        
        % call to notify the client of a specific event.
        function Post(obj,ev,strdata)
            if(~exist('strdata','var'))strdata='';end
            obj.ExpInfo.postedEvents{end+1}=struct('name',ev,'data',strdata);
        end
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
            expID=['Exp',hash(lower(fpath)),'C'];
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
            
            nargs=nargout_for_class(exp,name);
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
            idx=exp.ExpInfo.SetTemp(struct(),idx);
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
        function [errorString]=UpdateTempFieldFromMap(expID,idx,mapid)
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
        
        function [mapid]=MakeTempUpdateMap(expID,l)
            exp=ExperimentCore.GetExperimentByID(expID);
            if(~exist('l','var'))l=0;end
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end
            
            map=struct();
            map.values=cell(1,l);
            map.names=cell(1,l);
            mapid=exp.ExpInfo.SetTemp(map);
        end
        
        function []=PopulateUpdateMap(expID,mapid,name,val,idx)
            exp=ExperimentCore.GetExperimentByID(expID);
            
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end
            
            map=exp.ExpInfo.GetTemp(mapid);
            if(~exist('idx','var'))
                idx=length(map.values)+1;
            end
            map.values{idx}=val;
            map.names{idx}=name;
            exp.ExpInfo.SetTemp(map,mapid);
        end
        
        % search and find the value id exists.
        function [vs,hasval]=GetValueInfoFromParameter(expID,idx,namepath,to)
            exp=ExperimentCore.GetExperimentByID(expID);
            vs=1;
            hasval=0;
            if(~isobject(exp))
                %error('Experiment not found when trying to set temp value.');
                return;
            end

            o=exp.ExpInfo.GetTemp(idx);
            [val,hasval]=ObjectMap.getValueFromNamepath(o,namepath,to);
            vs=size(val);
        end
        
        function val=GetValueFromParameter(expID,idx,namepath,to)
            exp=ExperimentCore.GetExperimentByID(expID);
            ObjectMap.getDefaultValue(to);
            if(~isobject(exp))
                %val=ObjectMap.getDefaultValue(to);
                %error('Experiment not found when trying to set temp value.');
                return;
            end

            o=exp.ExpInfo.GetTemp(idx);
            [val,hasval]=ObjectMap.getValueFromNamepath(o,namepath,to);
            if(~hasval)
                return;
            end
            if((to(1)=='r' || tp(1)=='c') && numel(val)>1)
                val=reshape(val,[1,numel(val)]);
            end
        end        
%         
%         function [vs,hasval]=GetValueSizeFromParameter(expID,idx,namepath,to)
%             exp=ExperimentCore.GetExperimentByID(expID);
%             hasval=0;
%             vs=1;
%             if(~isobject(exp))
%                 %error('Experiment not found when trying to set temp value.');
%                 return;
%             end
% 
%             o=exp.ExpInfo.GetTemp(idx);
%             [val,hasval]=ObjectMap.getValueFromNamepath(o,namepath,to);
%             vs=size(val);
%         end

    end
    
    methods (Static)
%         function [vtype]=GetLVType(v)
%             vtype=-1;
%             if(isnumeric(v))
%             	if(isreal(v))
%                     vtype=1;
%                 else
%                     vtype=2;
%                 end
%             elseif(ismatrix(v))
%                 smat=size(v);
%                 ir=isreal(v);
%                 smat(smat==1)=[];
%                 dm=length(smat);
%                 if(dm==1)
%                     if(ir)
%                         vtype=3;
%                     else
%                         vtype=4;
%                     end
%                 elseif(dm==2)
%                     if(ir)
%                         vtype=5;
%                     else
%                         vtype=6;
%                     end
%                 end
%             elseif(ischar(v))
%                 vtype=7;
%             end
%             
%             if(vtype<0)
%                 v=[];
%             end
%         end        
    end
end
