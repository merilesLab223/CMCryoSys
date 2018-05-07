classdef CSCom < handle
    %CSCOM Implements the websocket connection module to be used
    methods
        function obj = CSCom(url)
            if(~exist('url','var'))url='ws://localhost:50001/LVPort';end
            NetO=CSCom.CSCom(url);
            NetO.addlistener('Log',@obj.onLog);
            NetO.addlistener('MessageRecived',@obj.onMessage);
        end
    end
    
    properties
        ShowLogs=false;
    end
    
    properties (SetAccess = private)
        NetO=[];
    end
    
    events
        Log;
        MessageRecived;
    end
    
    methods
        function Listen(obj)
            obj.NetO.Listen();
        end
        
        function Connect(obj)
            obj.NetO.Connect();
        end
        
        function Stop(obj)
            obj.NetO.Stop();
        end
        
        function Send(obj,msg,mtype,o)
            % making the message from the map.
            if(~isa(msg,'CSComMessage'))
                msg=CSComMessage.FromMatlabObj(msg,mtype,o);
            end

            obj.NetO.Send(msg.ToNetObject());
        end
    end
    
    methods(Access = protected)
        function onLog(obj,s,e)
            msg=e.Message;
            obj.notify('Log',EventStruct(msg));
            if(obj.ShowLogs)
                disp(msg);
            end
        end
        
        function onMessage(obj,s,e)
            if(~event.hasListener(obj,'MessageRecived'))
                return;
            end
            msg=CSComMessage.FromNetObject(e.Message);
            obj.notify('MessageRecived',EventStruct(msg));
        end
    end

    methods(Static)
        function [val]=NetValueToRawData(nval)
            vc=class(nval);
            vc=class(nval);
            vc=lower(vc);
            if(contains(vc,'.boolean'))
                var=logical(nval);
            elseif(contains(vc,'.double'))
                val=double(nval);
            elseif(contains(vc,'.single'))
                val=single(nval);
            elseif(contains(vc,'.sbyte'))
                val=int8(nval);
            elseif(contains(vc,'.byte'))
                val=uint8(nval);
            elseif(contains(vc,'.uint16'))
                val=uint16(nval);
            elseif(contains(vc,'.int16'))
                val=int16(nval);
            elseif(contains(vc,'.uint32'))
                val=uint32(nval);
            elseif(contains(vc,'.int32'))
                val=int32(nval);
            elseif(contains(vc,'.uint64'))
                val=uint64(nval);
            elseif(contains(vc,'.int64'))
                val=int64(nval);
            elseif(contains(vc,'.char'))
                val=char(nval);
            elseif(contains(vc,'.string')) % string will become char.
                val=char(nval);
            end
        end
    end
end

