classdef testobj
   
    
    properties
        p1
        p2
        p3
        p4
    end
    
    methods
        function [obj] = testobj();
        end
        
        function [obj] = saveobj(obj)
            b = struct();
            b.p1 = obj.p1;
            b.p2 = obj.p2;
            b.p3 = obj.p3;
            b.p4 = obj.p4;
            obj = b;
        end
    end
    
    
    
    
end