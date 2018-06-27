classdef ANC300Base < Device & TCPDevice
    %ANC300 Lua communication for the tcpip com.
    methods
        function [dev]=ANC300Base(varargin)
            dev@TCPDevice(varargin{:});
            pr=inputParser;
            pr.addOptional('password',dev.Password);
            pr.parse(varargin{:});
            dev.Password = pr.Results.password;
        end
    end
    
    properties(SetAccess = protected)
        IP='192.168.236.104';
        Password='123456';
        Port=7231; % lua port.
    end
    
    properties
        AllowNewlineInCode=false;
        LuaConfigureFile='';
        UseLuaConfigureFile=true;
    end

    methods (Access = protected)
        function configureDevice(dev)
            % connecting to remote.
            oldTerm=dev.DataTerminator;
            dev.DataTerminator='>';
            dev.connect();
            
            % waiting for connection.
            while(~isempty(dev.PendingBytes)&&char(dev.PendingBytes(end))~=':')
                pause(0.001);
            end
            
            % write password.
            dev.PendingBytes=[];
            dev.MarkWaitingForResponse(1);
            fwrite(dev.TcpConnection,[dev.Password,newline]);
            dev.WaitForResponse();
            rsp=dev.PendingResponseData;
            dev.PendingBytes=[];
            dev.DataTerminator=oldTerm;
            if(~endsWith(rsp,'Authorization success'))
                error('Could not connect to ANC300 device');
            end
            fwrite(dev.TcpConnection,newline);
            if(dev.UseLuaConfigureFile)
                lcf=dev.LuaConfigureFile;
                if(isempty(dev.LuaConfigureFile))
                    lcf=[mfilename('fullpath'),'.lua'];
                end
                % write the lua instructions.
                dev.WriteLuaInstructions(lcf,0,true);
            end
        end
        
        function [lines]=RemoveInvalidLines(dev,lines)
            lines=RemoveInvalidLines@TCPDevice(dev,lines);
            lines(cellfun(@(l)startsWith(l,'>'),lines))=[];
        end
    end
    
    methods
        function prepare(dev)
            % call core prepare.
            prepare@Device(dev);
        end
    end
    
    % lua methods
    methods
        function [varargout]=WriteLuaInstructions(dev,luaCode,rspLines,isfile)
            if(~exist('isfile','var'))
                isfile=false;
            end
            if(~exist('rspLines','var'))
                rspLines=0;
            end
            if(isfile)
                if(~exist(luaCode,'file'))
                    error(['Lua code file not found, "',luadCode,'".']);
                end
                luaCode=fileread(luaCode);
            end
            
            if(~dev.AllowNewlineInCode)
                luaCode=regexprep(luaCode,'[\n\r]+',' ');
            end
            
            if(rspLines>0)
                varargout{:}=dev.send(luaCode,rspLines);
            else
                dev.send(luaCode,rspLines);
                varargout={};
            end
        end
    end
end

