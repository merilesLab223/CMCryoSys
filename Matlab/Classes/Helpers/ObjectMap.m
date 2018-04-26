classdef ObjectMap < handle
    
    properties(Constant)
        ArraySeperator='!#!';
        PathSeperator='@';
    end
    
    properties(Constant, Access = private)
    end
    
    % fast get meta info.
    
    methods(Static)
        
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
            elseif(islogical(o))
                t='boolean';
            elseif(isnumeric(o))
                % numeric.
                if(~isreal(o))
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
        function [o,wasUpdated]=update(o,namepath,val)
            namepathAr=strsplit(namepath,ObjectMap.PathSeperator);
            [o,wasUpdated]=ObjectMap.updateByPath(o,namepathAr,val,1);
        end
        
        
        % search and find the value id exists.
        function [val,hasval]=getValueFromNamepath(o,namepath,to)
            hasval=0;
            hasType=0;
            if(exist('to','var'))
                val=ObjectMap.getDefaultValue(to);
                hasType=1;
            else
                val=[];
            end
            
            namepathAr=strsplit(namepath,ObjectMap.PathSeperator);
            [v,hasval]=ObjectMap.findValue(o,namepathAr,1);
            if(hasType&&~strcmp(ObjectMap.getType(v),to))
                return;
            end
            
            if(hasval)
                val=v;
            end
        end
    end
    
    methods(Static, Access = protected)
        function [rt,hasval]=findValue(o,namepathAr,i)
            hasval=0;
            rt=[];   
            
            if(i>length(namepathAr))
                % reached path end, o is the value.
                % has to be.
                rt=o;
                hasval=1;
                return;
            end
            
            % Geting the type of the object to check for.
            to=ObjectMap.getType(o);
            namepart=namepathAr{i};

            switch(to)
                case 'unconvertable'
                    % nothing to do.
                    return;
                case 'carray'
                    % expecting an index.
                    idx=str2num(namepart)+1;
                    if(idx<1 || length(o)<idx)
                        return;
                    end
                    [rt,hasval]=ObjectMap.findValue(o{idx},namepathAr,i+1);
                case 'sarray'
                    idx=str2num(namepart)+1;
                    if(idx==0 || length(o)<idx)
                        return;
                    end
                    [rt,hasval]=ObjectMap.findValue(o(idx),namepathAr,i+1);
                case 'object'
                    if(~isvarname(namepart))
                        % if the variables must be trucked (thire name)
                        % would mean that you cannot update this variable
                        % back to labview.
                        namepart(~isstrprop(namepart,'alphanum'))='_';
                    end
                    if(~isfield(o,namepart))
                        return;
                    end
                    [rt,hasval]=ObjectMap.findValue(o.(namepart),namepathAr,i+1);
                otherwise
                   if(length(namepathAr)==i)
                       rt=o;
                       hasval=1;
                   else
                       %error in namepath.
                   end
                   return;
            end
        end
        
        function [rt]=isNamePartAnArrayIndex(namepathAr,i)
            rt=0;
            if(length(namepathAr)>=i)
                namepart=namepathAr{i};
                if(~isempty(namepart))
                    rt=isstrprop(namepart(1),'digit');
                end
            end
        end
        
        function [o,wasUpdated]=updateByPath(o,namepathAr,val,i)
            wasUpdated=0; 
            
            if(i>length(namepathAr))
                % reached path end, o is the value
                wasUpdated=1;
                o=val;
                return;
            end
            
            % check if next is an index.
            isArrayIndex=ObjectMap.isNamePartAnArrayIndex(namepathAr,i);
            namepart=namepathAr{i};
            
            % checking if the current object matches the needed value type.
            to=ObjectMap.getType(o);
            if(isArrayIndex)
                % expecting an array.
                idx=str2num(namepart)+1;   
                if(idx<1)
                    idx=1;
                end
                
                switch(to)
                    case 'sarray'
                        ival=[];
                        if(idx<=length(o))
                            ival=o(idx);
                        end
                        
                        [ival,wasUpdated]=ObjectMap.updateByPath(ival,namepathAr,val,i+1);
                        o(idx)=ival;
                    otherwise
                        ival=[];
                        if(strcmp(to,'carray'))
                            if(idx<=length(o))
                                ival=o{idx};
                            end
                        else
                            % anything else is not an array, overwrite o.
                            o={};
                        end

                        [ival,wasUpdated]=ObjectMap.updateByPath(ival,namepathAr,val,i+1);
                        o{idx}=ival;
                        return;
                end
            else
                % should be an object (otherwise already dealt with;
                ival=[];
                isAnArray=ObjectMap.isNamePartAnArrayIndex(namepathAr,i+1);
                updateToSelf=isempty(namepart);

                if(updateToSelf)
                    ival=o;
                elseif(isfield(o,namepart))
                    ival=o.(namepart);
                    to=ObjectMap.getType(ival);
                end
                
                % check for construct.
                if(isAnArray)
                    if(~strcmp(to,'sarray')&&~strcmp(to,'carray'))
                        ival={};
                    end
                elseif(~strcmp(to,'object'))
                    ival=struct();
                end
                
                if(updateToSelf)
                    [o,wasUpdated]=ObjectMap.updateByPath(ival,namepathAr,val,i+1); 
                else
                    [o.(namepart),wasUpdated]=ObjectMap.updateByPath(ival,namepathAr,val,i+1); 
                end

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
                    if(~isempty(basename))
                        basename=[basename,ObjectMap.PathSeperator];
                    end                       
                    l=numel(o);
                    for i=1:l
                        % note -1 is since matlab index start from 1
                        % and we want to convert to another lang. 
                        newname=[basename,num2str(i-1)];
                        ObjectMap.parseObject(col,o{i},newname);
                    end
                case 'sarray'
                    if(isempty(o))
                        return; % nothing to do.
                    end
                    if(~isempty(basename))
                        basename=[basename,ObjectMap.PathSeperator];
                    end                    
                    l=numel(o);
                    for i=1:l
                        % note -1 is since matlab index start from 1
                        % and we want to convert to another lang.
                        newname=[basename,num2str(i-1)];
                        ObjectMap.parseObject(col,o(i),newname);
                    end    
                case 'object'
                    if(~isempty(basename))
                        basename=[basename,ObjectMap.PathSeperator];
                    end
                    om=fieldnames(o);
                    for i=1:length(om)
                        fn=om{i};
                        ObjectMap.parseObject(col,o.(fn),...
                            [basename,fn]);
                    end             
                otherwise
                    % string or number. (but a value).
                    col(basename)=o;
            end
        end
        
    end

end

