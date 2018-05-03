classdef AutoRemoveMap < handle
    %LVPORTCOLLECTION Summary of this class goes here
    %   Detailed explanation goes here
    methods
        function [obj]=AutoRemoveMap(autoRemoveTimeout)
            if(~exist('autoRemoveTimeout','var'))
                autoRemoveTimeout=5*60;
            end
            obj.AutoRemoveTimeout=autoRemoveTimeout;
        end
    end
    
    properties
        AutoRemoveTimeout=5*60; % in seconds.
    end
    
    properties (SetAccess = protected)
        ObjectByID=containers.Map();
        AccessTimeByID=containers.Map();
    end
    
    events
        RemoveElement;
    end
    
    methods
        function o = subsref(col,id)
            if(length(id)>1|| length(id.subs)>1)
                   error('LVPortCollection:subsref',...
                      'Not a supported subscript. One value as key.');
            end      
            t=id.type;
            id=id.subs{1};            
            switch(t)
                case '{}'
                   error('LVPortCollection:subsref',...
                      'Not a supported subscripted reference');
                otherwise
                    o=col.getById(id);
            end
        end
        
        function col = subsasgn(col,id,o)
            if(length(id)>1 || length(id.subs)>1)
                   error('LVPortCollection:subsref',...
                      'Not a supported subscript. One value as key.');
            end
            t=id.type;
            id=id.subs{1};
            switch(t)
                case '{}'
                   error('MyDataClass:subsref',...
                      'Not a supported subscripted reference');
                otherwise
                    if(ismatrix(o) && isempty(o))
                        col.removeById(id);
                    else
                        col.setById(id,o);
                    end
            end
        end
    end
    
    methods (Access = protected,Static)
        function id=validateID(id)
            if(isnumeric(id))
                id=num2str(id);
            elseif(~ischar(id))
                error('Id must be a char or number(to be converted to char)');
            end
        end
    end
    
    methods
        
        function [o]=getById(col,id)
            if(~col.contains(id))
                col.cleanDead();
                return;
            end
            id=col.validateID(id);
            col.cleanDead();
            o=col.ObjectByID(id);
        end
        
        function [id]=setById(col,id,o) 
            id=col.validateID(id);
            col.setAccessed(id);
            col.ObjectByID(id)=o;
            col.cleanDead();
        end
        
        function [rt]=removeById(col,id)
            id=col.validateID(id);
            rt=false;
            ev=[];
            if(col.contains(id))
                ev=AutoRemoveMapRemoveEvent(col.ObjectByID(id),id);
            end
            if(col.ObjectByID.isKey(id))
                col.ObjectByID.remove(id);
                rt=true;
            end
            if(col.AccessTimeByID.isKey(id))
                col.AccessTimeByID.remove(id);
                rt=true;
            end
            
            if(~isempty(ev))
                col.notify('RemoveElement',ev);
            end
        end
        
        function [rt]=contains(col,id)
            id=col.validateID(id);
            rt=col.ObjectByID.isKey(id);
        end
    end
    
    methods (Static)
        function [t]=curTime()
            t=now()*(24*60*60);
        end
    end
    
    methods (Access = protected)
        function cleanDead(col)
            curT=col.curTime();
            dkeyIdxs=find(curT-cell2mat(col.AccessTimeByID.values)>col.AutoRemoveTimeout);
            if(isempty(dkeyIdxs))
                return;
            end
            allkeys=col.AccessTimeByID.keys;
            dkeys=allkeys(dkeyIdxs);
            for i=1:length(dkeys)
                col.removeById(dkeys{i});
            end
        end
        
        function setAccessed(col,id)
            col.AccessTimeByID(id)=col.curTime();
        end
    end
end

