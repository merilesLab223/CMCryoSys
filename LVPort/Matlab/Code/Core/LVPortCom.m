classdef LVPortCom < handle
    %LVPORTCOM INTERNAL!! Methods to communicate between labview and matlab, using
    %the object maps.
    
    properties (Access = private)
        % a collection of temporary objects to use for the mapping
        % of the object value.
        TempObjects=AutoRemoveAutoIDMap(60); % auto remove timeout is 1 minute.
        LastTempAutoID=0;
        ObjectHasLoopMethod=[];

        LoopEventInfo=EventStruct();
    end
    
    events
        Loop;
    end
    
    % temp value methods
    methods
        function ClearTempObject(obj,id)
            obj.TempObjects.removeById(id);
        end   
        
        function [id]=SetTempObject(obj,o,id)
            if(~exist('id','var'))
                id=-1;
            end
            ot=struct();
            ot.obj=o;
            ot.map=[];
            id=obj.TempObjects.setById(id,ot);
        end
        
        function [o]=GetTempObject(obj,id)
            o=[];
            if(~obj.TempObjects.contains(id))
                return;
            end
            o=obj.TempObjects(id).obj;
        end
        
        function [namepaths,otypes]=GetTempMapInfo(obj,id)
            namepaths='';
            otypes='';
            if(~obj.TempObjects.contains(id))
                return;
            end
            ot=obj.validateObjectTempMap(obj.TempObjects(id),id);
            namepaths=strjoin(ot.map.ValMap.keys,'@');
            otypes=strjoin(ObjectMap.getType(ot.map.ValMap.values),'@');
        end
        
        function [hasval,val,vsize,idxs]=GetTempNampathValue(obj,id,namepath)
            hasval=0;
            val=[];
            vsize=[0,0];
            idxs=[];
            if(~obj.TempObjects.contains(id))
                return;
            end
            ot=obj.validateObjectTempMap(obj.TempObjects(id),id);
            [hasval,val,vsize,idxs]=ot.map.GetNampathInfo(namepath);
        end
        
        function [isok]=SetTempNamepathValue(obj,id,namepath,val)
            isok=0;
            if(~obj.TempObjects.contains(id))
                return;
            end
            ot=obj.TempObjects(id);
            ObjectMap.update(ot.obj,namepath,val);
            obj.TempObjects(id)=ot;
            isok=1;
        end
    end
    
    % direct set namepath values to object properties.
    methods
        function [isok]=SetPortObjectNamepathValue(obj,namepath,val)
            [~,isok]=ObjectMap.update(obj.PortObjecy,namepath,val);
            if(isok)
                isok=1;
            else
                isok=0;
            end
        end
    end
    
    methods (Access = private)
        function [ot]=validateObjectTempMap(obj,ot,id)
            if(isempty(ot.map))
                % making the map;
                if(isa(ot.obj,'function_handle'))
                    ot.map=ot.obj();
                else
                    ot.map=LVPortObjectMap(ot.obj);
                    obj.TempObjects(id)=ot;
                end
            end            
        end
    end
    
    % com methods.
    methods
        % call to pump all messages into temp objects
        % and return the ids with the message names.
        function [mnames,mcats,mtempids]=PumpMessages(obj)
            % check for loop method.
            if(isempty(obj.ObjectHasLoopMethod))
                obj.ObjectHasLoopMethod=ismethod(obj.PortObject,'loop');
            end
            
            if(obj.ObjectHasLoopMethod)
                obj.PortObject.loop();
            end
            
            if(event.hasListeners(obj,'Loop'))
                obj.notify('Loop',obj.LoopEventInfo);
            end
            
            % get all pending events.
            evs=obj.PumpEvents();
            levs=length(evs);
            mnames=cells(1,levs);
            mcats=cells(1,levs);
            mtempids=ones(1,levs)*(-1);
            for i=1:length(evs)
                ev=evs{i};
                mnames{i}=ev.Name;
                mcats{i}=ev.Category;
                mtempids(i)=obj.SetTempObject(ev.Value);
            end
        end
    end
    
    % method invoke methods
    methods
        % invcokes a method and returns its temp value id (or -1).
        function [isok,outargsTempID]=InvokeMethod(obj,name,inargsTempID)
            isok=0;
            outargsTempID=-1;
            if(~ismethod(obj.PortObject))
                return;
            end
            
            if(inargsTempID>-1)
                iargs=obj.GetTempObject(inargsTempID);
            else
                iargs={};
            end
            
            nargs=lvport_nargout_for_class(obj.PortObject,name);
            if(nargs==0)
                exp.(name)(iargs{:});
                return;
            end
            aout=cell(nargs,1);
            [aout{:}]=exp.(name)(iargs{:});
            
            outargsTempID=obj.SetTempObject(aout);
        end
    end
end

