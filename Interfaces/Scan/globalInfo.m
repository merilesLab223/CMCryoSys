classdef globalInfo< handle & dynamicprops
    properties
        streamCollector=[];
        imageCollector=[];
    end
    
    methods
        function [rt]=getOrAdd(obj,name,defaultVal)
            if(~isfield(obj,name))
                obj.addprop(name);
                obj.(name)=defaultVal;
            end
            rt=obj.(name);
        end
    end
end

