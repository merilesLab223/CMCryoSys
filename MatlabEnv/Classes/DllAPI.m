classdef DllAPI < handle
    %DLLAPI Abstract base class for creating a dll api.
    methods
        % Spincore library config.
		function [obj] = DllAPI(LibraryFile,LibraryHeaders,LibraryName)
            if(exist('LibraryFile','var') && ~isempty(LibraryFile))
                obj.LibraryFile=LibraryFile;
            end
            if(exist('LibraryHeaders','var') && ~isempty(LibraryHeaders))
                if(ischar(LibraryHeaders))
                    LibraryHeaders={LibraryHeaders};
                end                
                obj.LibraryHeaders=LibraryHeaders;
            end
            if(exist('LibraryName','var') && ~isempty(LibraryName))
                obj.LibraryName=LibraryName;
            end            
            
            obj.Load();
            obj.IsInitialized=obj.init();
        end
    end
    
    properties(SetAccess = protected)
        IsInitialized=false;
    end
    
    properties (Abstract, SetAccess = protected)
        LibraryHeaders;
        LibraryFile;
        LibraryName;
    end
    
    methods (Access = public)
        % loads the api.
		function Load(api)
			if ~libisloaded(api.LibraryName)
                arglst={...
                    api.LibraryFile,...
                    api.LibraryHeaders{1},...
                    'alias',api.LibraryName};
                if(length(api.LibraryHeaders)>1)
                    for i=2:length(api.LibraryHeaders)
                        hdr=api.LibraryHeaders{i};
                        arglst{end+1}='addheader';
                        arglst{end+1}=hdr;
                    end
                end
                
                [notfound,warnings]=loadlibrary(arglst{:});
                if(~isempty(warnings))
                    warning(warnings);
                end
			end
        end
        
        function Unload(obj)
            if ~libisloaded(obj.LibraryName)return;end
            unloadlibrary(obj.LibraryName);
        end
        
        function [varargout]=Invoke(api,name,varargin)
            varargout{:}=calllib(api.LibraryName,name,varargin{:});
        end
        
    end
    
    methods (Abstract, Access = protected)
        [initialized]=init(api);
    end 
    
    methods(Static)
        function [pinfo]=MakePointerInfo(val)
            if(iscell(val))
                pinfo=cell(1,length(length(val)));
                for i=1:length(val)
                    pinfo{i}=DllAPI.MakePointerInfo(val{i});
                end
                return;
            end
            pinfo={};
            ptype=class(val);
            btype='';
            if(isenum(val))
                pinfo.cname=ptype;
                ptype='voidPtr';
                val=int32(val);
                btype='enum';
            elseif(isnumeric(val))
                ptype=[ptype,'Ptr'];
            else
                switch ptype
                    case 'char'
                        ptype='voidPtr';
                        val=[int8(val) 0];
                        btype='char';
                end
            end
            pinfo.type=btype;
            pinfo.ptr=libpointer(ptype,val);
        end
        
        function [val]=FromPointerInfo(pinfo)
            val=pinfo.ptr.Value;
            switch(pinfo.type)
                case 'char'
                    val=strtrim(char(val(val~=0)));
                case 'enum'
                    val=feval(pinfo.cname,val);
            end
        end
        
        function [s,psl]=MakePointerStruct(s)
            names=fieldnames(s);
            psl=cell(1,length(names));
            for i=1:length(names)
                fn=names{i};
                
                pinfo=DllAPI.MakePointerInfo(s.(fn));
                s.(fn)=pinfo;
                %s.(fn)=
                psl{i}=pinfo.ptr;
            end
        end
        
        function [s]=FromPointerStruct(s)
            names=fieldnames(s);
            for i=1:length(names)
                fn=names{i};
                s.(fn)=DllAPI.FromPointerInfo(s.(fn));
            end
        end
    end
end

