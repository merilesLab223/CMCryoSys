classdef myImage < handle
    
    properties
        figHandle
        axesHandle
        hlUpdateCounterData
        iaInstance
    end
    
    methods
        function [] = init(obj)
            obj.figHandle = figure();
            obj.axesHandle = axes();
            
            obj.hlUpdateCounterData = addlistener(obj.iaInstance,'UpdateCounterData',...
            @(src,eventdata)updateImage(obj,src,eventdata));
        end
        
        function [] = updateImage(obj,src,eventdata)
            axes(obj.axesHandle);
            imagesc(src.UnpackImage());
        end
    end
end