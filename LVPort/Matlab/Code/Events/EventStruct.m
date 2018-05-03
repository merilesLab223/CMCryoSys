classdef (ConstructOnLoad) EventStruct < event.EventData & dynamicprops
    %EVENTSTRUCT General event data.
    %   Used as catch all event data.
    properties
        Data=[];
    end
end

