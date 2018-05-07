classdef (ConstructOnLoad) EventStruct < event.EventData & dynamicprops
    %EVENTSTRUCT General event data.
    %   Used as catch all event data.
    properties
        Data=[];
    end
    
    methods
        function EventStruct(data)
            if(~exist('data','var'))
                Data=data;
            end
        end
    end
end

