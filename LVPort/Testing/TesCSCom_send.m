function TesCSCom_send(sender,o)
    [namePaths,vals]=ObjectMap.map(o);
    npds=NET.createArray('CSCom.NPObjectNamepathData',length(namePaths));
    
    for i=1:length(namePaths)
        npd=CSCom.NPObjectNamepathData();
        v=vals{i};
        npd.Value=v;
        if(isnumeric(v)&&ismatrix(v))
            npd.Size=size(v);
        end
        npds(i)=npd;
    end
    omap=CSCom.NPObjectMap(npds);
    % sending to server.
    sender.Send(omap);
end

