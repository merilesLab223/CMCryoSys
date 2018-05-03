function [po] = mportobj(id)
    %MPORT get the Matlab port by its id.
    p=mport(id);
    po=p.PortObject;
end

