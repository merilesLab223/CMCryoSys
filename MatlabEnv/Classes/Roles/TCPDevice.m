classdef TCPDevice < handle
    %TCPDEVICE A device that may communicate through tcp.
    % abstract class.
    methods
        function [dev]=TCPDevice(varargin)
            pr=inputParser();
            pr.addOptional('ip',dev.IP);
            pr.addOptional('port',dev.Port);
            pr.parse(varargin{:});
            dev.IP=pr.Results.ip;
            dev.Port=pr.Results.port;
        end
    end
    
    properties(SetAccess = protected, Abstract)
        IP;
        Port;
    end
    
    properties(SetAccess = protected)
        IsConnected;
        NumberOfLinesRead=0;
        PendingResponseLines=0;
        PendingBytes=[];
        TcpConnection=[];
    end
    
    properties
        DataTerminator=newline;
        PushCommandChar=newline;
    end
        
    events
        DataReady;
    end
    
    properties(Access = protected)
        PendingResponseData=[];
    end
    
    % main tcp methods.
    methods
        % connected attribute.
        function [rt]=get.IsConnected(dev)
            rt=false;
            if(isempty(dev.TcpConnection))return;end
            rt=strcmp(dev.TcpConnection.Status,'open');
        end
        
        % conncts to the remote device.
        function connect(dev)
            if(dev.IsConnected)
                return;
            end
            dev.TcpConnection=tcpip(dev.IP,dev.Port);
            con=dev.TcpConnection;
            con.Timeout=5000;
            con.BytesAvailableFcnCount=1;
            con.BytesAvailableFcnMode='byte';
            con.BytesAvailableFcn=@dev.bytesAtPort;
            try 
                fopen(con);
            catch err
                error(['Error while connecting to ',dev.IP],err);
            end
            if(~dev.IsConnected)
                error(['Cannot connect to remote at ',dev.IP]);
            end
        end
        
        % disconnects from the remote device.
        function disconnect(dev)
            if(~dev.IsConnected)
                return;
            end
            con=dev.TcpConnection;
            dev.TcpConnection=[];
            fclose(con);
        end
        
        % writes and wait for response.
        function [varargout]=send(dev,txt,rspLines)
            if(~exist('rspLines','var'))
                rspLines=0;
            end
            dev.MarkWaitingForResponse(rspLines);
            fwrite(dev.TcpConnection,[txt,dev.PushCommandChar]);
            if(rspLines>0)
                varargout{:}=dev.WaitForResponse();
            else
                varargout={};
            end
        end
    end
    
    methods(Access = protected)
        
        % marks the current as waiting for response.
        function MarkWaitingForResponse(dev,n)
            dev.PendingResponseLines=n;
            dev.PendingResponseData={};
        end
        
        % wait for a response from the tcp device.
        function [varargout]=WaitForResponse(dev)
            dev.PendingResponseData=[];
            while(dev.PendingResponseLines>0)
                pause(0.001);% pause 1ms.
            end
            varargout{:}=dev.PendingResponseData{:};
            dev.PendingResponseData={};
        end
        
        function bytesAtPort(dev,con,info)
            if(con.BytesAvailable==0)
                return;
            end
            % reading the bytes at port.
            data=...
                fscanf(con,'%c',con.BytesAvailable);
            
            dev.PendingBytes(end+1:end+length(data))=data;

            % find lines.
            lines=strsplit(char(dev.PendingBytes),dev.DataTerminator);
            dev.PendingBytes=lines{end};
            lines=lines(1:end-1);
            % removing the invalid lines.
            lines=dev.DoLinesCleanup(lines);
            lines=dev.RemoveInvalidLines(lines);
            if(isempty(lines))
                return;
            end

            for i=1:length(lines)
                dev.NumberOfLinesRead=dev.NumberOfLinesRead+1;
                dev.LineReady(lines{i});
            end
        end
        
        function LineReady(dev,line)
            if(dev.PendingResponseLines>0)
                dev.PendingResponseData{end+1}=line;
                dev.PendingResponseLines=dev.PendingResponseLines-1;
            end
            
            ev=EventStruct;
            ev.Data=line;
            dev.notify('DataReady',ev); 
        end
        
        function [lines]=RemoveInvalidLines(dev,lines)
            lines(cellfun(@(l)isempty(l),lines))=[];
        end
        
        function [lines]=DoLinesCleanup(dev,lines)
            for i=1:length(lines)
                lines{i}=strtrim(lines{end});
            end
        end
    end
end

