classdef SpinCoreClock < SpinCoreBase & Clock
    %SPINCORECLOCK Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Channel=[0];
    end
    
    methods
        function prepare(obj)
            % call to prepare.
            obj.StartInstructions();
            api=obj.CoreAPI;
            
            upflags=obj.ChannelValToFlags(obj.Channel,1);
            downflags=obj.ChannelValToFlags(obj.Channel,0);
            
            tcycle=1/(obj.clockFreq*obj.timeUnitsToSecond);
            tup=tcycle*obj.dutyCycle;
            tdown=tcycle*obj.dutyCycle;
            
            nestc=4;
            % go to down mode.
            obj.Instruct(downflags,api.INST_CONTINUE,0);
            
            lidx=zeros(1,nestc);
            for i=1:nestc
                lidx(i)=obj.Instruct(0,api.INST_LOOP,1e6);
            end
            
            obj.Instruct(upflags,api.INST_CONTINUE,0,tup);
            obj.Instruct(downflags,api.INST_CONTINUE,0,tdown);
            
            for i=1:nestc
                obj.Instruct(0,api.INST_END_LOOP,lidx(i));
            end
            
            obj.EndInstructions();
        end
    end
end

