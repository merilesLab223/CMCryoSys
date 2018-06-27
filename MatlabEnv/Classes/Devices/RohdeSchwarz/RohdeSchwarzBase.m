classdef RohdeSchwarzBase < Device & TCPDevice
    %RohdeSchwarzAPI Controls the communication betwen
    methods
        function [dev]=RohdeSchwarzBase(varargin)
            dev@TCPDevice(varargin{:});
            dev.DeviceStatePropertiesDictionary=containers.Map();
        end
    end
    
    properties(SetAccess = protected)
        DeviceStatePropertiesDictionary=[];
    end
    
    methods(Access = protected)
        function configureDevice(dev)
            dev.connect();
            dev.reset();
            dev.QueryProperties();
        end
        
        function DevicePropertyReady(dev,name,val)
            dev.(name)=val;
        end
    end
    
    methods
        function prepare(dev)
            dev.SetPropertiesToDevice();
            pause(0.1);
        end
        
        function run(dev)
            % dose nothing now.
            run@Device(dev);
        end
        
        function registerDeviceProperty(dev,query,parseStr,propertyName...
                ,setStr,defaultValue)
            if(~exist('defaultValue','var'))
                defaultValue=[];
            end
            if(~exist('setStr','var'))
                setStr=[];
            end
            
            dev.DeviceStatePropertiesDictionary(propertyName)=...
                struct('Query',query,'ParseStr',parseStr,'SetStr',setStr);
            
            dev.DevicePropertyReady(propertyName,defaultValue);
        end
        
        function QueryProperties(dev)
            pnames=dev.DeviceStatePropertiesDictionary.keys;
            pdefs=dev.DeviceStatePropertiesDictionary.values;
            for i=1:length(pnames)
                pn=pnames{i};
                info=pdefs{i};
                [rsp]=dev.send(info.Query,1);
                
                if(~isempty(info.ParseStr))
                    val=textscan(rsp,info.ParseStr);
                    val=val{1};
                else
                    val=rsp;
                end
                dev.DevicePropertyReady(pn,val);
            end
        end
        
        function SetPropertiesToDevice(dev)
            pnames=dev.DeviceStatePropertiesDictionary.keys;
            pdefs=dev.DeviceStatePropertiesDictionary.values;
            for i=1:length(pnames)
                pn=pnames{i};
                info=pdefs{i};
                if(isempty(info.SetStr))
                    continue;
                end
                cmnd=sprintf(info.SetStr,dev.(pn));
                dev.send(cmnd);
            end
        end
            
        function reset(dev)
            dev.send('*RST');
        end
    end
end

