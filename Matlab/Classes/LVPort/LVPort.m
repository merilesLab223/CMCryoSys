classdef LVPort < handle & LVPortEvents & LVPortProperties & LVPortCom
    %PORT Holds a collection of methods, event postings and other about a
    %labview port object implementation.
    
    methods
        function [obj]=LVPort(portObject)
            if(~exist('portObject','var'))
                portObject=LVPortObject;
            end
            if(~isa(portObject,'LVPortObject'))
                error('Port object must be derived from class "LVPortObject"');
            end
            PortObject=portObject;
        end
    end
    
    % main methods.
    properties (SetAccess = protected)
        PortObject=[];
        ID='';
    end
    
    properties (Constant)
        % global map with auto destroy.
        Ports=AutoRemoveMap;
    end
    
    % global generation methods
    methods (Static)
        function [id,errors]=PortObjectFromCodeFile(fpath)            
            if(~exist('fpath','var')||~ischar(fpath)||~exist(fpath,'file'))
                if(~ischar(fpath))
                    fpath='UNKNOWN';
                end
                id=-1;
                errors=['Path "',fpath,'" not found or not a valid path'];
                return;
            end
            errors=[];
            if(~exist('expID','var'))id='';end
            [ftpath,className]=LVPort.MakePortObjectTempCodeFile(fpath);
            id=className;

            errors=[errors,checkcode(ftpath,'-string')];
            try
                po=eval(className);
                LVPort.RegisterPortObject(id,po);
            catch err
                id=-1;
                errors=[errors,err.message];
            end
        end
        
        function [className]=MakePortObjectTempCodeFile(fpath,autoAccess)
            if(~exist('autoAccess','var'))autoAccess=true;end
            className=LVPort.PathToLVID(fpath);
            tempdir=[pwd,'\','LVTemp'];
            if(~exist(tempdir,'file')) % check for folder.
                mkdir(tempdir);
            end
            
            if(autoAccess)
                addpath(tempdir);% make sure we can access it.
            end
            
            fname=[tempdir,'\',className,'.m'];
            code=fileread(fpath);
            code=regexprep(code,'(?<=classdef *)\w+',className,'ignorecase','once');
            
            % checking if exists, and if the same, then ignore write.
            % otherwise delete old.
            if(exist(fname,'file'))
                oldcode=fileread(fname);
                if(strcmp(oldcode,code))
                    return;
                end
                delete(fname);
            end
            
            % write all.
            fid=fopen(fname,'a');
            fprintf(fid,"%s",code);
            fclose(fid);
        end
        
        function [id]=PathToLVID(fpath)
            id=['P',lvport_hash(lower(fpath)),'C'];
        end
        
        function [id]=RegisterPortObject(id,po)
            LVPort.Ports(id)=p;
            if(isprop(p,'Port'))
                po.Port.ID=id;
            end
        end
    end
end

