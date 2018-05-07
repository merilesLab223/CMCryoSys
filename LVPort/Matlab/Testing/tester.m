classdef tester < LVPortObject 
    % tester for testing.
    
    properties
        SomeVal=[];
        SimpleNum=32;
        SimpleString='a';
    end

    methods
        function [rval]=someMethod(obj,ival)
            rval=ival+2;
        end
    end
end