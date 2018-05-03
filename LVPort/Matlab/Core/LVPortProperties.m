classdef LVPortProperties < handle
    %LVPORTEVENTS INTERNAL OBJECT!! allows port to use properties update
    %system.
    
    properties
        UpdateChangesDefault=false;
        IgnoreUpdates={};
    end
    
    properties (Access = private)
        % a map for all partial update by name;
        m_oldObjectCollection=containers.Map;
    end
    
    properties (Constant)
        LVPortPropertiesEventCategory='matlab_prop';
    end
    
    methods
        function [evid]=update(obj,name,updateChanges)
            if(~exist('name','var'))
                name='';
            end
            if(~ischar(name))
                updateChanges=name;
                name='';
            end
            if(~exist('updateChanges','var'))
                updateChanges=obj.UpdateChangesDefault;
            end
            
            evid='';
            fnames=name;
            if(isempty(fnames))
                fnames=fieldnames(obj.PortObject);
            end
            
            if(iscell(fnames))
                if(length(fnames)>1)
                    evid=cell(length(fnames));
                    for i=1:length(fnames)
                        evid{i}=obj.update(fnames{i},updateChanges);
                    end
                    return;
                else
                    name=fnames{1};
                end
            end
            
            if(~isprop(obj.PortObject,'name'))
                return;
            end
            
            % check for ignores.
            if(any(contains(obj.IgnoreUpdates,name)))
                return;
            end
            
            evid=LVPortProperties.MakeEventIDFromParameterName(name);
            if(~obj.HasPostedEvent(evid))
                up={};
                up.pname=name;
                up.val=@()obj.getObjectPropertyMapByName(name,updateChanges);
                % category matlab prop
                obj.PostEvent('mUpdateProperty',up,...
                    LVPortProperties.LVPortPropertiesEventCategory,evid); 
            end
        end
        
        function [map]=getObjectPropertyMapByName(obj,name,updateChanges)
            if(~exist('updateChanges','var'))
                updateChanges=obj.UpdateChangesDefault;
            end  
            map=[];
            if(~isprop(obj.PortObject,name))
                return;
            end
            omap=ObjectMap.map(obj.PortObject.(name));
            map=LVPortObjectMap(omap);
            if(updateChanges)
                if(obj.m_oldObjectCollection.isKey(name))
                    map.removeUnchanged(obj.m_oldObjectCollection(name));
                end
                % set the new map.
                obj.m_oldObjectCollection(name)=omap;
            elseif(obj.m_oldObjectCollection.isKey(name))
                obj.m_oldObjectCollection.remove(name);
            end
        end
    end
    
    methods (Access = private, Static)
        function [evid]=MakeEventIDFromParameterName(name)
            evid=['lvport_param_update:',name];
        end
    end
end

