classdef RhodeSchwarzSMA100 < RohdeSchwarzBase
    %RHODESCHWARZSMA100 Control for the SMA100.
    methods
        function [dev]=RhodeSchwarzSMA100(varargin)
            dev@RohdeSchwarzBase(varargin{:});
        end
    end
    
    properties
        Frequency=0;
        Amplitude=0;
        RFState=0;
        TriggerSource='';
    end
    
    % core tcp properties.
    properties(SetAccess = protected)
        IP='192.168.236.4';
        Port=5025; % raw port.
    end
    
    methods (Access = protected)
        
        function DevicePropertyReady(dev,name,val)
            dev.(name)=val;
        end
        
        function configureDevice(dev)
            dev.registerDeviceProperty(...
                ':SOURCE:FREQuency:FIXed?','%f','Frequency',...
                ':FREQuency:FIXed %f');
            dev.registerDeviceProperty(...
                ':SOURce:POWer:LEVel:IMMediate:AMPLitude?','%f','Amplitude',...
                ':POWER:LEVEL:IMMEDIATE:AMPLITUDE %f');
            dev.registerDeviceProperty(...
                'TRIG:FSW:SOUR?',[],'TriggerSource',...
                'TRIG:FSW:SOUR %s');
            dev.registerDeviceProperty(...
                ':OUTPUT:STATE?',[],'RFState',...
                ':OUTPUT:STATE %d');
 
            configureDevice@RohdeSchwarzBase(dev);
        end
    end
    
    methods
        function stop(dev)
            dev.Output(false);
            stop@RohdeSchwarzBase(dev);
        end
        
        function prepare(dev)
            dev.Output(true);
            prepare@RohdeSchwarzBase(dev);
        end
        
        function Output(dev,isOn)
            if(~exist('isOn','var'))
                isOn=true;
            end
            dev.RFState=double(isOn);
        end
    end
end

