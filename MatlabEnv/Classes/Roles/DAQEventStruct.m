classdef (ConstructOnLoad) DAQEventStruct <  EventStruct
    %EVENTSTRUCT General event data.
    %   Used as catch all event data.
    properties
        RawData=[];
        TimeStamps=[];
        TotalTicksSinceStart=0;
        deviceTimeStamps=[];
        Elapsed=0;
        CompElapsed=0;
        AccumilatedClockOffset=0;
    end
end
