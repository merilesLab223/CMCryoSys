classdef globalInfo< handle
    properties
        streamCollector=[];
        imageCollector=[];
        MaxImageScanRate=1e5;
    end
    
    properties (Access=private)
        m_propcol={};
    end
    
    methods(Access = protected)
        function validateProperty(obj,name,val)
            if(~obj.contains(name))
                obj.set(name,val);
            end
        end
    end
    
    methods
        function [rt]=get(obj,name,defaultVal)
            if(~exist('defaultVal','var'))defaultVal=0;end
            obj.validateProperty(name,defaultVal);
            rt=obj.m_propcol.(name);
        end
        
        function [rt]=contains(obj,name)
            rt=isfield(obj.m_propcol,name);
        end
        
        function set(obj,name,val)
            %obj.validateProperty(name);
            obj.m_propcol.(name)=val;
        end
    end
end

