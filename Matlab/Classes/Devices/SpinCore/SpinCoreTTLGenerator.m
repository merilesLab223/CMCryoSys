classdef SpinCoreTTLGenerator < SpinCoreBase & TTLGenerator
    %SPINCORETTLGENERATOR Summary of this class goes here
    %   Detailed explanation goes her
    methods
        function [sq]=compileSequence(obj,t,data)
            % sorting the data by T, and identifying pulse trains.
            [t,sidxs]=unique(t,'last');
            data(:)=data(sidxs);
            
            % sending pulse commands.
            api=obj.CoreAPI;
            
            api.Reset;
            api.StartProgramming;
            
            % start the programming.
            for i=1:length(t)
                d=data{i};
                if(isfield(d,'isPulse') && d.isPulse==1)
                    % write a pulse or pulse train.
                    if(d.n>1)
                        api.Instruct(0,api.INST_LOOP,d.n,obj.getSecondsTimebase());
                    end
                    
                    upflags=obj.ChannelToFlags(d.c);
                    
                    api.Instruct(upflags,api.INST_CONTINUE,0,d.tup*obj.timeUnitsToSecond);
                    api.Instruct(0,api.INST_CONTINUE,0,d.tdown*obj.timeUnitsToSecond);
                    
                    if(d.n>1)
                        api.Instruct(0,api.INST_END_LOOP,d.n,obj.getSecondsTimebase());
                    end  
                else
                    upflags=0;
                    if(d.v~=0)
                        upflags=obj.ChannelToFlags(d.c);
                    end
                    api.Instruct(upflags,api.INST_CONTINUE,0,d.t*obj.timeUnitsToSecond);
                end
            end
            
            api.StopProgramming();
            sq=1;
        end
    end
    
    methods
        function prepare(obj)
            prepare@SpinCoreBase(obj);
            obj.CoreAPI.SetClock(obj.Rate);
            obj.compile();
        end
    end
end

