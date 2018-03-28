classdef SpinCoreBase < Device & TimeBasedObject
    % Implements a spin core base functionality. Communication with the
    % device and core hardware handles.
    methods
        function obj = SpinCoreBase(LibraryFile,LibraryHeaders,LibraryName)
            if(~exist('LibraryFile','var'))LibraryFile=SpinCoreAPI.DefaultLibFile;end
            if(~exist('LibraryHeader','var'))LibraryHeaders=SpinCoreAPI.DefaultHeaderFiles;end
            if(~exist('LibraryName','var'))LibraryName=SpinCoreAPI.DeafultLibName;end
            
            obj.CoreAPI=SpinCoreAPI(LibraryFile,LibraryHeaders,LibraryName); % redo.
            obj.setClockRate(obj.Rate);
        end
    end
    
    properties (SetAccess = private)
        % to change the spincoreapi functions. Call
        CoreAPI=[];
        MinimalInstructionTime=-1;
    end
    
    properties
        MinimalNumberOfClockCyclesPerInstruction=5;
        IsContinues=false;
    end
    
    methods (Access = protected)
        
        % configure the spincore.
        function configureDevice(obj)
            api=obj.CoreAPI;
            api.Load;
            if(api.IsInitialized)
                api.Reset;
            else
                api.Init;
            end
        end
        
        function [t]=validateInstructionTime(obj,t)
            t=obj.timebaseToSeconds(t);
            if(t<obj.MinimalInstructionTime)
                error(['Minimal instruction time is smaller then the',...
                    ' instruction time given. Please provide instruction times',...
                    'larger then ',num2str(obj.MinimalInstructionTime),'[s]']);
            end
        end
        
        function [idx]=Instruct(obj,flags,type,data,t)
            if(~exist('data','var'))data=0;end
            if(~exist('t','var'))
                t=obj.MinimalInstructionTime;
            else
                t=obj.validateInstructionTime(t);
            end
            idx=obj.CoreAPI.InstructionsCount;
            obj.CoreAPI.Instruct(flags,type,data,t);
        end
        
        function StartInstructions(obj)
            api=obj.CoreAPI;
            api.SetClock(obj.Rate);
            api.Reset;
            api.StartProgramming;          
        end
        
        function EndInstructions(obj)
            if(obj.IsContinues)
                obj.Instruct(0,obj.CoreAPI.INST_BRANCH);
            else
                obj.Instruct(0,obj.CoreAPI.INST_STOP);
            end
            obj.CoreAPI.StopProgramming();            
        end
        
    end
    
    methods
        
        function setClockRate(obj,rate)
            setClockRate@TimeBasedObject(obj,rate);
            obj.MinimalInstructionTime=obj.getSecondsTimebase()*...
                obj.MinimalNumberOfClockCyclesPerInstruction;
        end
        
        function stop(obj)
            api=obj.CoreAPI;
            api.Stop();            
        end
        
        function run(obj)
            api=obj.CoreAPI;
            api.Start();
        end
        
        function [cflags]=ChannelToFlags(obj,c)
            c=sort(c);
            lc=length(c);
            maxc=max(c);
            ci=1;
            n=0;
            bits=[];
            while(ci<=lc && n<=maxc)
                if(c(ci)==n)
                    % same number
                    ci=ci+1; %next.
                    bits(end+1)=1;
                else
                    bits(end+1)=0;
                end
                n=n+1;
            end
            cflags=bi2de(bits);
        end
    end
        
end

