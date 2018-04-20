classdef ObjectMap < handle
    
    properties(Constant)
        ArraySeperator='!#!';
        PathSeperator='@';
    end
    
    properties(Constant, Access = private)
    end
    
    % fast get meta info.
    
    methods(Static)
        function [t]=IsField(o,name)
            t=false;
            try
                [~]=o.(name);
                t=true;
            catch err
            end
        end
        
        % returns the type to be associated with the object for the object tree
        % purpose.
        function [t]=getType(o)
            if(iscell(o))
                t='carray';
            elseif(isstruct(o) && numel(o)>1)
                t='sarray';
            elseif(isobject(o)||isstruct(o))
                t='object';
            elseif(isstring(o)||ischar(o))
                t='string';
            elseif(isnumeric(o))
                % numeric.
                if(islogical(o))
                    t='boolean';
                elseif(~isreal(o))
                    t='complex';
                else
                    t='real';
                end
                
            else
                t='unconvertable';
            end
        end
        
        function [o]=getDefaultValue(ot)
            switch(ot)
                case 'carray'
                    o={};
                case 'sarray'
                    o={};
                case 'object'
                    o=struct();
                case 'string'
                    o='';
                case 'boolean'
                    o=0;
                case 'complex'
                    o=0+i0;
                case 'real'
                    o=0;
                otherwise 
                    o=[];
            end
        end        
        
        % converts a matlab object into an object tree allowing
        % transfer of the object by name.
        % allowed types that will not be converted.
        % real, complex, real matrix, complex matrix, string, bool (logical)            
        function [namePaths,vals] = map(o,basename)
            if(~exist('basename','var'))basename='';end
            basename=strtrim(basename);
            col=containers.Map;

            ObjectMap.parseObject(col,o,basename);
            namePaths=col.keys;
            vals=col.values;
        end
        
        % either updates or constructs a new object according to the map.
        function [o]=fromMap(namePaths,vals,o)
            % either array or struct.
            if(~ischar(namePaths)&&~(iscell(namePaths)&&ischar(namePaths{1})))
                error('namePaths must be a char array (or a cell array of char arrays)');
            end
            if(~iscell(namePaths))
                namePaths={namePaths};
            end
            if(~iscell(vals))
                vals={vals};
            end
            
            if(length(vals)~=length(namePaths))
                error('The number of namePaths must match the number of values.');
            end
            
            if(isempty(namePaths))
                o=[];
                return;
            end
            
            namePaths=strtrim(namePaths);
            
            if(length(namePaths)==1 && isempty(namePaths{1}))
                o=vals{1};
                return;
            end
            
            % validating o.
            if(~exist('o','var')||~(isstruct(o) || iscell(o)))o={};end
            
            % updating object.
            for i=1:length(namePaths)
                o=ObjectMap.update(o,namePaths{i},vals{i});
            end
        end
        
        % update a sepcific value of an object given a namepath
        % and a value.
        function [o]=update(o,namepath,val)
            namepathAr=strsplit(namepath,ObjectMap.PathSeperator);
            o=ObjectMap.updateByPath(o,namepathAr,val,1);
        end
        
        
        % search and find the value id exists.
        function [val,hasval]=getValueFromNamepath(o,namepath,to)
            val=ObjectMap.getDefaultValue(to);
            if(isempty(strtrim(namepath)))
                val=o;
                return;
            end

            namepathAr=strsplit(namepath,ObjectMap.PathSeperator);
            [v,hasval]=ObjectMap.findValue(o,namepathAr,1);
            if(logical(hasval) || strcmp(ObjectMap.getType(v),to))
                val=v;
            end
        end
    end
    
    methods(Static, Access = protected)
        
        function [rt,hasval]=findValue(o,namepathAr,i)
            hasval=0;
            rt=[];
            
            % getting the corrected name.
            name=strtrim(namepathAr{i});

            % search for indexs (would apply only to cells).
            arsplit=strsplit(name,ObjectMap.ArraySeperator); % notation for indexing.
            idx=-1;
            if(length(arsplit)>1)
                idx=str2num(arsplit{2})+1; % convert from index zero to 1.
                name=arsplit{1};
            end

            if(~isvarname(name))
                % ignore this not a name.
                % nothing to update.
                return;
            end

            % must be a field now.
            if(~ObjectMap.IsField(o,name))
                return;
            end
 
            if(i==length(namepathAr)) 
                % the value.
                hasval=1;
                if(idx>0)
                    rt=o.(name);%{idx};
                    rt=rt{idx};
                else
                    rt=o.(name);
                end
                return;
            end
            co=o.(name);
            if(idx>0)
                % looking in array.
                if(length(o.(name))>idx)
                    return;
                end
                co=co{idx};
            end
            [rt,hasval]=ObjectMap.findValue(co,namepathAr,i+1);
        end
        
        function [o]=updateByPath(o,namepathAr,val,i)
            % getting the corrected name.
            name=strtrim(namepathAr{i});

            % search for indexs (would apply only to cells).
            arsplit=strsplit(name,ObjectMap.ArraySeperator); % notation for indexing.
            idx=-1;
            if(length(arsplit)>1)
                idx=str2num(arsplit{2})+1; % convert from index zero to 1.
                name=arsplit{1};
            end

            if(~isvarname(name))
                % ignore this not a name.
                % nothing to update.
                return;
            end
%            name(~isstrprop(name,'alphanum'))='_';  

            if(~isstruct(o))
                o=struct();
            end

            if(i==length(namepathAr))
                % the value.
                if(idx>0)
                    o.(name){idx}=val;
                else
                    o.(name)=val;
                end
                return;
            end

            % Creating if needed.
            if(~ObjectMap.IsField(o,name))
                o.(name)={}; % either array or struct.
            end

            if(idx>0)
                ival=[]; % nothing.
                if(length(o.(name))>=idx)
                    ival=o.(name){idx};
                end
                o.(name){idx}=ObjectMap.updateByPath(ival,namepathAr,val,i+1);
            else
                o.(name)=ObjectMap.updateByPath(o.(name),namepathAr,val,i+1);
            end            
        end
        
        % recursive call to update an object.
        function parseObject(col,o,basename)
            t=ObjectMap.getType(o);
            switch(t)
                case 'unconvertable'
                    % nothing to do.
                    return;
                case 'carray'
                    if(isempty(o))
                        return; % nothing to do.
                    end
                    l=numel(o);
                    for i=1:l
                        % note -1 is since matlab index start from 1
                        % and we want to convert to another lang. 
                        newname=[basename,ObjectMap.ArraySeperator,num2str(i-1)];
                        ObjectMap.parseObject(col,o{i},newname);
                    end
                case 'sarray'
                    if(isempty(o))
                        return; % nothing to do.
                    end
                    l=numel(o);
                    for i=1:l
                        % note -1 is since matlab index start from 1
                        % and we want to convert to another lang.
                        newname=[basename,ObjectMap.ArraySeperator,num2str(i-1)];
                        ObjectMap.parseObject(col,o(i),newname);
                    end            
                case 'object'
                    if(~isempty(basename))
                        basename=[basename,'@'];
                    end
                    try
                        %metaclass(o).PropertyList
                        om={'X','Y'};%'fieldnames(o);
                        for i=1:length(om)
                            fn=om{i};
                            ObjectMap.parseObject(col,o.(fn),[basename,fn]);
                        end                 
                    catch err
                    end
                otherwise
                    % string or number. (but a value).
                    col(basename)=o;
            end
        end
    end
end

