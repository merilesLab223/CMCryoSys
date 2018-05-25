classdef (ConstructOnLoad) DAQEventStruct <  EventStruct
    %EVENTSTRUCT General event data.
    %   Used as catch all event data.
    properties
        TimeStamps=[];
        TotalTicksSinceStart=0;
        deviceTimeStamps=[];
        TickStartIndex=0;
        Elapsed=0;
        TicksElapsed=0;
        CompElapsed=0;
        AccumilatedClockOffset=0;
        IsExecuting=0;
    end
end
