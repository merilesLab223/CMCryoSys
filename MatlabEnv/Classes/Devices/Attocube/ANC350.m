classdef ANC350 < Device
    %ANC350 Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function [dev]=ANC350(devUrl)
            
        end
    end
    
    properties (SetAccess = private)
        Api;
    end
    
    methods
        function [api]=get.Api(dev)
            api=dev.GetAPI();
        end
    end
    
    methods (Access = protected)
        % configures the device.
        function configureDevice(dev)
            
        end
    end
    
    methods(Static)
        function [api]=GetAPI()
            persistent anc350api;
            if(isempty(anc350api))
                anc350api=ANC350API();
            end
            api=anc350api;
        end
    end
end

