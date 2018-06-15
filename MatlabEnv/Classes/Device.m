classdef Device < handle
    % constructor
    methods
        function [obj]=Device()
        end
    end
    
    events
        DeviceConfigured;
    end
    
    properties
        name='';
        isConfigured=false;
    end

    % helper methods
    methods(Access = private)
        function [fname]=findExecutatbleFuncName(obj,base,role)
            fname=[base,'_',role];
            if(~ismethod(obj,fname))
                disp(['Role configuration for role',role,' method ',base,' in device "',obj.name,'" not found']);
                return;
            end
        end
    end
    
    methods (Access = protected)
        % called after the device was configured. Overrideable
        function []=onDeviceConfigured(obj)
            e=EventStruct;
            e.Data=obj;
            obj.notify('DeviceConfigured',e);
        end   
    end
    
    % general execution functions.
    methods
        % called to configure the device.
        function []=configure(obj)
            if(obj.isConfigured)
                return;
            end
            disp(['Configuring device ',obj.name,' of type ',class(obj)]);
            configureDevice(obj);            
            obj.isConfigured=true;
            obj.onDeviceConfigured();
        end
        
        % called to prepare the device before execution.
        % the assumption is the device can be prepared at this time.
        function []=prepare(obj)
            if(~obj.isConfigured)
                fprintf(['Configuring ',obj.name,' (',class(obj),') ...']);
                obj.configure(); % call to configure if needed.
            end
        end
        
        % general function stop.
        function stop(dev)
        end
    end
    
    methods (Abstract)
        % called to run the current device implementation and sequence.
        []=run(obj); % must override to create a device.
    end
    
    methods (Abstract, Access = protected)
        % The call to configure. This call is the first of many calls.
        % the configuration call will be made once only.
        % if reconfiguration is needed one is to invoke. (Invalidate
        % config).
        []=configureDevice(obj);        
    end
end

