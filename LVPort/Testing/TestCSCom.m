% adding the .net dll.
NET.addAssembly('C:\Code\CMCryoSysCode\LVPort\CSCom\CSCom\bin\Debug\CSCom.dll');

% added the assembly, creating the server.
if(exist('server','var') && isstruct(server))
    server.StopListening;
    server=[];
end
server=CSCom.CSCom();
addlistener(server,'MessageRecived',@(s,e)TestCSCom_message_recived(s,e));
addlistener(server,'Log',@(s,e)TestCSCom_ConsoleLog(s,e));
server.DoLogging=true;
server.Listen();

if(exist('client','var') && isstruct(client))
    client.Disconnect();
    client=[];
end
client=CSCom.CSCom();
client.Connect();

% allowing for debug mode.
