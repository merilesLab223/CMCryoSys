classdef ANC300Control < ANC300Base
    methods
        function [dev]=ANC300Control(varargin)
            dev@ANC300Base(varargin{:});
        end
    end
    
    methods
        function setPosition(dev,x,y)
            rsp=dev.WriteLuaInstructions(...
                    ['setPositionVoltage(',num2str(x),',',num2str(y),');'],1);
            if(~strcmp(rsp,'ok'))
                error(['Error while setting position, ',rsp]);
            end
        end
    end
    
    methods(Access = protected)
        function configureDevice(dev)
            if(dev.UseLuaConfigureFile)
                if(isempty(dev.LuaConfigureFile))
                    dev.LuaConfigureFile=[mfilename('fullpath'),'.lua'];
                end
            end
            configureDevice@ANC300Base(dev);
        end        
    end
end

