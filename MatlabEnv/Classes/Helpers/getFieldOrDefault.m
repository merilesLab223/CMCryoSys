function [v] = getFieldOrDefault(obj,name,dval)
%GETFIELDORDEFAULT Returns the field by name or otherwise the default
%value
    if(~exist('dval','var'))
        dval=[];
    end
    if(isfield(obj,name))
        v=obj.(name);
    else
        v=dval;
    end
end

