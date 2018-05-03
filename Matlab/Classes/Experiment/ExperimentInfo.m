classdef ExperimentInfo < handle
    
    methods
        function [obj]=ExperimentInfo()
            obj.LastTempID=0;
            % make new map (Cannot be done in auto create!).
            obj.Temp=containers.Map();
        end
    end
    
    events
        UpdateLoop;
    end
    
    properties
        ID='';
        CodeFile='';
        TempFile='';
        UpdateLoopCallTime=0.02; %[s];
    end
    
    properties (SetAccess = protected)     
        LastTempID=0;
    end
    
    properties(Access = protected)
        Temp=[];
        Events=containers.Map;
        LastAnonymousEventIndex=0;
        UpdateLoopEventInfo=EventStruct;
        LastUpdateLoopCallTimestamp=-1;
    end
    
    methods (Access = protected, Static)
        function [id]=TempIndexToID(idx)
            if(length(idx)>1)
                idx=idx(:)';
            end
            id=strtrim(num2str(idx));
        end
    end
    
    % events methods
    methods
        function PumpUpdateLoop(obj)
            curt=now*24*60*60;
            if(curt-obj.LastUpdateLoopCallTimestamp>obj.UpdateLoopCallTime)
                obj.notify('UpdateLoop',obj.UpdateLoopEventInfo);
                obj.LastUpdateLoopCallTimestamp=curt;
            end
        end
        
        function [evs]=getPendingEvents(obj,clearOld)
            if(~exist('clearOld','var'))
                clearOld=0;
            end
            evs=obj.Events.values;
            if(clearOld)
                obj.Events=containers.Map();
            end
        end
        
        function [evid]=MakeNextAnonymousId(obj,namebase)
            evid=[namebase,num2str(obj.LastAnonymousEventIndex)];
            obj.LastAnonymousEventIndex=obj.LastAnonymousEventIndex+1;
        end
        
        function [ev]=MakeEventStructure(obj,name,val,cat)
            ev={};
            ev.Name=name;
            ev.Category=cat;
            ev.Value=val;
            ev.TimeStamp=now()*24*60*60; % to seconds.            
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
            if(~obj.Events.isKey(evid))
                ev=[];
                return;
            end
            ev=obj.Events(evid);
        end
        
        function [evNames]=GetCurrentPostedEventIds(obj)
            evNames=obj.Events.keys;
        end
    end
    
    % temp methods
    methods
        function [idx]=GetFreeIdx(obj)
            idx=obj.LastTempID;
            obj.LastTempID=idx+1;
        end
        
        function [idx]=SetTemp(obj,val,idx)
            if(~exist('idx','var') || isempty(idx))
                idx=obj.GetFreeIdx();
            end
            obj.Temp(ExperimentInfo.TempIndexToID(idx))=val;
        end
        
        function [t]=HasTemp(obj,idx)
            t=obj.Temp.isKey(ExperimentInfo.TempIndexToID(idx));
        end
        
        function [o]=GetTemp(obj,idx)
            idxk=ExperimentInfo.TempIndexToID(idx);
            if(~obj.Temp.isKey(idxk))
                error(['Index ',idxk,' for temp not found.']);
            end
            o=obj.Temp(idxk);
        end
        
        function [vals,keys]=getTempValues(obj)
            vals=obj.Temp.values;
            keys=obj.Temp.keys;
        end
        
        function [o]=ClearTemp(obj,idx)
            o=[];
            if(length(idx)>1)
                o={};
                for j=1:length(idx)
                    o{j}=obj.ClearTemp(idx(j));
                end
                return;
            end
            if(~obj.HasTemp(idx))
                return;
            end
            obj.Temp.remove(strtrim(ExperimentInfo.TempIndexToID(idx)));
        end
    end
end

