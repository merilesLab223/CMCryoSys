classdef ExperimentCore < handle
    
    properties
        ExperimentID;
    end
    
    methods
        % registers the experiment core by name to the global
        % running object.
        function obj = ExperimentCore()
        end
        
        function init(obj,varargin)
            error('The experiment code must contain a function called init.');
        end
        
        function [linfo]=loop(obj,varargin)
            error('The experiment code must contain a function called loop.');
        end
        
        function [rlst]=finalize(obj,varargin)
            error('The experiment code must contain a function called finalize.');
        end
        
        function delete(obj)
        end
    end
    
    properties (Constant)
        BaseFileName='ExperimentCoreClassFactory.m';
        MatchClassName='classdef ExperimentCoreClassFactory';
        MatchCodeInsert='% ___INPUT__CODE__INSERT__LOC';
        ExperimentNameBaseGenerate='Temp_Exp_Class_N';
    end
    
    methods (Static)
        function [expID,errs,canExecute]=MakeExperiment(code,expID,allowMulti)
            if(~exist('allowMulti','var'))allowMulti=0;end
            if(~exist('code','var')||~ischar(code))error('Cannot generate experiment without code!');end
            if(~exist('expID','var'))expID='';end
            
            disp(code);
            basepath=[pwd,'\'];
            % checking loding the global;
            
            if(isempty(expID))
                [className,expID]=ExperimentCore.MakeNewExperimentClassName(...
                    ExperimentCore.ToExperimentIDString(basepath),allowMulti);
            else
                ExperimentCore.ClearExperimentByID(expID);
                className=ExperimentCore.ExperimentIDToClassName(expID);
            end
            
            % make the script.
            fpath=[fileparts(mfilename('fullpath')),'\',ExperimentCore.BaseFileName];
            
            scpt=fileread(fpath);
            scpt=replace(scpt,ExperimentCore.MatchClassName,['classdef ',className]);
            scpt=replace(scpt,ExperimentCore.MatchCodeInsert,code);

            % write to file.
            spath=[basepath,className,'.m'];
            fid = fopen(spath,'wt');
            fprintf(fid, "%s", scpt);
            fclose(fid);
            
            errs=checkcode(spath,'-string');
            canExecute=1;
            try
                exp=eval(className);
                ExperimentCore.RegisterExperimentStruct(expID,exp);
            catch err
                canExecute=0;
            end
        end
        
        function RegisterExperimentStruct(expID,exp)
            global experiment_core_experiment_list;
            if(~isstruct(experiment_core_experiment_list))
                experiment_core_experiment_list=containers.Map();
            end
            experiment_core_experiment_list(expID)=exp;
        end
        
        function [name]=MakeRandExperimentClassName(i)
            name=[ExperimentCore.ExperimentNameBaseGenerate,num2str(i)];
        end
        
        function [cname,expID]=MakeNewExperimentClassName(basename,allowMulti)
            if(~exist('allowMulti','var'))allowMulti=0;end
            cname=ExperimentCore.MakeRandExperimentClassName(0);
            expID=[basename,cname];
            if(~allowMulti)
                return;
            end
            i=1;
            while(ExperimentCore.HasExperimentByID(expID))
                cname=ExperimentCore.MakeRandExperimentClassName(i);
                expID=[basename,cname];
                i=i+1;
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
        
        function [str]=ToExperimentIDString(str)
            str(~isstrprop(str,'alphanum'))='_';
        end
        
        function [className]=ExperimentIDToClassName(str)
            className='';
            locs=strfind(str,ExperimentCore.ExperimentNameBaseGenerate);
            if(isempty(locs))
                return;
            end
            className=str(locs(end):end);
        end
        
        function varargout=invoke(expID,name,varargin)
            varargout={};
            exp=ExperimentCore.GetExperimentByID(expID);
            if(isempty(exp) || ~ismethod(exp,name))
                return;
            end
            nargs=nargout([class(exp),'>',class(exp),'.',name]);
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
            if(isempty(exp) || ~ismethod(exp,name))
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
