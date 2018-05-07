function TestCSCom_message_recived(s,e)
    disp('Recived');
    global recivedCount;
    if(isempty(recivedCount))
        recivedCount=0;
    end
    recivedCount=recivedCount+1;
    info=e.Message.GetInfos();
    info=info(1);
end

