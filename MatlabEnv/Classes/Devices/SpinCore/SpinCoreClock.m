classdef SpinCoreClock < SpinCoreBase & Clock
    %SPINCORECLOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Channel=[1];
    end
    
    methods
        function prepare(obj)
            % call to prepare.
            obj.StartInstructions();
            api=obj.CoreAPI;
            
            tcycle=1/(obj.clockFreq*obj.timeUnitsToSecond);
            tup=tcycle*obj.dutyCycle;
            tdown=tcycle*obj.dutyCycle;
            
            nestc=4;
            % go to down mode.
            obj.InstructBinary(obj.Channel,0);
            
            lidx=zeros(1,nestc);
            for i=1:nestc
                lidx(i)=obj.InstructStartLoop(1e6);
            end
            
            obj.InstructBinary(obj.Channel,1,tup);
            obj.InstructBinary(obj.Channel,0,tdown);
            
            for i=1:nestc
                obj.InstructEndLoop(lidx(i));
            end
            
            obj.EndInstructions();
        end
    end
end

