function [m] = validatevector(m)
    if(isvector(m))
        m=m';
    end
end

