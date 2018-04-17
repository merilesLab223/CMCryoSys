classdef ExperimentCore < handle & dynamicprops
    
    properties (SetAccess = private)
        ExpInfo=struct();
        Devices=[];
    end
    
    methods
        % return the device collection.
        function [devs]=get.Devices(exp)
            if(~isfield(exp.ExpInfo,'devices'))
                exp.ExpInfo.Devices=DeviceCollection();
            end
            devs=exp.ExpInfo.Devices;
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
        
        % generic delete function.
        function delete(obj)
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
            
            if(~isfield(obj.ExpInfo,'postedEvents')|| ~iscell(obj.ExpInfo.postedEvents))
                obj.ExpInfo.postedEvents={};
            end
            obj.ExpInfo.postedEvents{end+1}=struct('name',ev,'data',strdata);
        end
    end
    
    methods (Static) % Events
        function [ev,hasEvent]=getNextPostedEvent(expID)
            ev=[];
            hasEvent=0;
            obj=ExperimentCore.GetExperimentByID(expID);
            if(~isfield(obj.ExpInfo,'postedEvents')|| ~iscell(obj.ExpInfo.postedEvents))
                return;
            end
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
                error(['Cannot generate experiment without a source file (',fpath,'?)!']);
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
                disp(err);
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
            disp(code);
            disp(fname);
            if(exist(fname,'file'))
                delete(fname); % delete the file.
                disp('Deleted existing experiment file');
            end
            fid=fopen(fname,'a');
            fprintf(fid,"%s",code);
            fclose(fid);
            disp('wrote code');
        end
        
        function bindLocalFunctions(exp,fpath)
            
        end
        
        function RegisterExperimentStruct(expID,exp,fpath,tempPath)
            global experiment_core_experiment_list;
            if(~isstruct(experiment_core_experiment_list))
                experiment_core_experiment_list=containers.Map();
            end
            experiment_core_experiment_list(expID)=exp;
            if(isprop(exp,'ExpInfo') && isstruct(exp.ExpInfo))
                exp.ExpInfo.id=expID;
                exp.ExpInfo.codefile=fpath;
                exp.ExpInfo.tempfile=tempPath;
            end
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
        function varargout=invoke(expID,name,varargin)
            varargout={};
            exp=ExperimentCore.GetExperimentByID(expID);
            if(isempty(exp) || ~ismethod(exp,name))
                return;
            end
            nargs=nargout_for_class(exp,name);
            if(nargs==0)
                exp.(name)(varargin{:});
                return;
            end
            varargout=cell(nargs,1);
            [varargout{:}]=exp.(name)(varargin{:});
        end
        
        function [rt]=SetPropertyByName(expID,pname,pval)
            rt=0;
            exp=ExperimentCore.GetExperimentByID(expID);
            if(isempty(exp))
                return;
            end
            if(~isprop(exp,pname))
                return;
            end
            exp.(pname)=pval;
            rt=1;
        end

        function [v,vtype]=GetValidatedPropetyValue(exp,pname)
            vtype=-1;
            v=[];
            if(~isprop(exp,pname))
                return;
            end
            v=exp.(pname);
            if(isnumeric(v))
            	if(isreal(v))
                    vtype=1;
                else
                    vtype=2;
                end
            elseif(ismatrix(v))
                smat=size(v);
                ir=isreal(v);
                smat(smat==1)=[];
                dm=length(smat);
                if(dm==1)
                    if(ir)
                        vtype=3;
                    else
                        vtype=4;
                    end
                elseif(dm==2)
                    if(ir)
                        vtype=5;
                    else
                        vtype=6;
                    end
                end
            elseif(ischar(v))
                vtype=7;
            end
            
            if(vtype<0)
                v=[];
            end
        end
        
        function [pnames]=ListExperimentProperties(expID)
            pnames='';
            exp=ExperimentCore.GetExperimentByID(expID);
            if(isempty(exp))
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
end
