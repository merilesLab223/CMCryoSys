function [p] = mport(id)
    %MPORT get the Matlab port by its id.
    if(~LVPort.Ports.contains(id))
        error('LVPort:',['A matlab port with id "',id,'" not found']);
    end
    p=LVPort.Ports(id);
end

