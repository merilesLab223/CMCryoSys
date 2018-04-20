classdef ExperimentInfo < handle
    
    methods
        function [obj]=ExperimentInfo()
            obj.LastTempID=0;
            % make new map (Cannot be done in auto create!).
            obj.Temp=containers.Map();
        end
    end
    properties
        postedEvents={}; % a list of the posted events.
        ID='';
        CodeFile='';
        TempFile='';
    end
    
    properties (SetAccess = protected)
        Devices=DeviceCollection(); % the device collection.        
        LastTempID=0;
    end
    
    properties(Access = protected)
        Temp=[];
    end
    
    methods (Access = protected, Static)
        function [id]=TempIndexToID(idx)
            if(length(idx)>1)
                idx=idx(:)';
            end
            id=strtrim(num2str(idx));
        end
    end
    
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

