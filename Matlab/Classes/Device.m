classdef Device < handle
    % constructor
    methods
        function [obj]=Device()
        end
    end
    
    properties
        name='unknown';
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
    
    % general execution functions.
    methods
        % called to configure the device.
        function configure(obj)
            if(obj.isConfigured)return;end
            configureDevice(obj);            
            obj.isConfigured=true;
        end
        
        % The call to configure. This call is the first of many calls.
        % the configuration call will be made once only.
        % if reconfiguration is needed one is to invoke. (Invalidate
        % config).
        function configureDevice(obj)
        end
        
        % Called with responce to timed event.
        function ev(obj,t,data)
        end

        % called to prepare the device before execution.
        % the assumption is the device can be prepared at this time.
        function prepare(obj)
            if(~obj.isConfigured)
                warning(['Called prepare on unconfigured device ',obj.name,'. Calling configure...']);
                obj.configure(); % call to configure if needed.
            end
        end
        
        % called to run the device.
        function run(obj)          
        end

    end
end

