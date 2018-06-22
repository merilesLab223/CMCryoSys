function [rt]=multifun(varargin)
    for fc=varargin
        f=fc{1};
        if(~isa(f, 'function_handle'))
            continue;
        end
        f();
    end
    rt=0;
end

