classdef APTStrainGauge < APTobj
    
    %A subclass to handle things specific to the piezo strain gauge
    properties
        %Current position in units
        currentPosition
        
        %Unit for position: 1 position (microns); 2 voltage (V); 3 force (N)
        dispMode
        
    end
    
    methods
       
        %Method to get the current reading
        function curReading = getReading(obj)
            [resultCode,curReading] = obj.controlHandle.SG_GetReading(obj.HWChannel,0);
        end
        
        %Method to read current display units
        function dispMode = getDispMode(obj)
            [resultCode,dispMode] = obj.controlHandle.SG_GetDispMode(obj.HWChannel,0);
        end
        
        %Method to set the current display units
        function setDispMode(obj,newMode)
            obj.controlHandle.SG_SetDispMode(obj.HWChannel,newMode);
        end
        
        %Method to get the maximum travel of the piezo hooked up to SG
        function maxTravel = getMaxTravel(obj)
            [resultCode, maxTravel] = obj.controlHandle.SG_GetMaxTravel(obj.HWChannel,0);
        end
        
        %Method to handle ActiveX events
        function eventHandler(obj,varargin)
            if(strcmp(varargin{end},'HWResponse'))
                error('APTStrainGauge fired an HWResponse event which indicates a serious fault.');
            end
        end
        
        
    end %methods
    
    methods (Access = protected)
        function subInit(obj)
            %Register an eventHandler for all events so we can capture the
            %MoveComplete event.
            obj.controlHandle.registerevent(@obj.eventHandler)
            
            %Check the current display mode
            obj.dispMode = obj.getDispMode();
            
        end
    end
    
end
