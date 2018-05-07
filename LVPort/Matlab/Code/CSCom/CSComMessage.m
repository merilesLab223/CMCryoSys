classdef CSComMessage
    %CSCOMMESSAGE Summary of this class goes here
    %   Detailed explanation goes here

    methods
        function obj = CSComMessage(msg,type,map)
            if(ischar(msg))
                obj.Message=msg;
            else
                objMessage=[];
            end
            
            if(isnumeric(type))
                objMessageType=type;
            else
                objMessageType=-1;
            end
            
            if(isa(map,'containers.Map'))
                obj.Namepaths=map;
            end
        end
    end
    
    properties(SetAccess = private)
        Message=[];
        MessageType=[];
        Namepaths=[];
    end
    
    methods
        function netO=ToNetObject(obj)
        end
    end
    
    methods(Static)
        function [o]=FromNetObject(nobj)
            % need to convert message to message map.
            % then send message.
            infos=nobj.NamePaths;
            map=containers.Map();
            for i=1:length(infos)
                info=infos(i);
                namepath=CSCom.NetValueToRawData(info.Namepath);
                if(~ischar(namepath))
                    continue;
                end
                mv=struct();
                mv.idxs=int32(info.idxs);
                mv.size=int32(info.Size);
                mv.value=CSCom.NetValueToRawData(info.Value);
                
                map(namepath)=mv;
            end
            
            o=CSComMessage(nobj.Message,...
                int32(nobj.MessageType),map);                 
        end
        
        % convert to net object.
        function [cscmsg]=FromMatlabObj(msg,mtype,o)
            map=ObjectMap.mapToCollection(o);
            
        end
    end
        
end

