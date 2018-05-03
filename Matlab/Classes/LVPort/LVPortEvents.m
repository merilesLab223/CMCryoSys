classdef LVPortEvents < handle
    %LVPORTEVENTS INTERNAL OBJECT!! allows port to use event posting
    %system.
    
    properties
        Events=containers.Map;
    end
    
    properties (Access = private)
        m_lastAnonymousEventIndex=0;
    end
    
    methods
        
        function [evid]=MakeNextAnonymousId(obj,namebase)
            evid=[namebase,num2str(obj.m_lastAnonymousEventIndex)];
            obj.LastAnonymousEventIndex=obj.m_lastAnonymousEventIndex+1;
        end
        
        function [evid]=PostEvent(obj,name,val,cat,evid)
            ev=obj.MakeEventStructure(name,val,cat);
            if(~exist('evid','var'))
                evid=name;
            end
            obj.Events(evid)=ev;
        end
        
        function [evid]=PostAnonymousEvent(obj,name,val,cat)
            evid=obj.PostEvent(name,val,cat,obj.MakeNextAnonymousId(name));
        end
        
        function [ev]=GetPostedEvent(obj,evid)
            ev=[];
            if(obj.HasPostedEvent(evid))
                ev=obj.Events(evid);
            end
        end
        
        function [rt]=HasPostedEvent(obj,evid)
            rt=obj.Events.isKey(evid);
        end
    end
    
    methods
        % pumps all the evnets and removes the current.
        function [evs]=PumpEvents(obj)
            evcol=obj.Events;
            obj.ClearEvents();
            evs=evcol.values;
        end
        
        % clear all events.
        function ClearEvents(obj)
            obj.Events=containers.Map;
        end
        
        % returns current events.
        function [evs]=GetEvents(obj)
            evs=obj.Events.values;
        end
    end
end

