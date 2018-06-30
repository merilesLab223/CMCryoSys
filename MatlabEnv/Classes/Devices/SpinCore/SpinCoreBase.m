classdef SpinCoreBase < Device & TimeBasedObject
    % Implements a spin core base functionality. Communication with the
    % device and core hardware handles.
    methods
        function obj = SpinCoreBase()
            obj.setDeviceRate(obj.DeviceRate);
            obj.setClockRate(obj.DeviceRate);
        end
    end
    
    properties (SetAccess = private)
        % to change the spincoreapi functions. Call
        CoreAPI=[];
        MinimalInstructionTime=-1;
        TimebaseMultiplier=1;
        DeviceRate=300e6; % 300 mhz.
    end
    
    properties
        % if true the device execution will continue forever.
        IsContinues=false;
        
        % the minimal clock cycles for each device instruction.
        MinInstructionClockTicks=5;
        
        % Static output max time.(Function SetOutput).
        MaxStaticOutputTime=60*60*1000;
    end
    
    % property getters
    methods
        % returns the cire api.
        function [api]=get.CoreAPI(obj)
            api=obj.GetCoreAPI();
        end
    end
     
    properties (Constant)
        % the offset between matlab matrix position and 
        % channel number.
        ChannelOffset   =1;  
        
        % the maximal time for normal instructions. If over this time the
        % instruction will be divided into two instruction sets. The first
        % is a long delay instructiob abd then the instruction itself.
        MaxRegularInstructionTime = 5*1000; % 5 seconds.
    end
    
    methods (Access = protected)
        
        % configure the spincore.
        function []=configureDevice(obj)
            api=obj.CoreAPI;
            api.Load;
            if(api.IsInitialized)
                api.Reset;
            else
                api.Init;
            end
        end
        
        function [t]=validateInstructionTime(obj,t)
            t=obj.timebaseToSeconds(t)*obj.TimebaseMultiplier;
            if(t<obj.MinimalInstructionTime)
                error(['Minimal instruction time is smaller then the',...
                    ' instruction time given (',num2str(t),...
                    '). Please provide instruction times',...
                    'larger then ',num2str(obj.MinimalInstructionTime),'[s]']);
            end
        end

        function []=StartInstructions(obj)
            api=obj.CoreAPI;
            api.SetClock(obj.Rate);
            api.Reset;
            api.StartProgramming;          
        end
        
        function []=EndInstructions(obj)
            if(obj.IsContinues)
                obj.Instruct(0,obj.CoreAPI.INST_BRANCH);
            else
                obj.Instruct(0,obj.CoreAPI.INST_STOP);
            end
            obj.CoreAPI.StopProgramming();            
        end
    end
    
    methods        
        function []=setClockRate(obj,rate)
            setClockRate@TimeBasedObject(obj,rate);
            obj.MinimalInstructionTime=...
                obj.MinInstructionClockTicks/obj.DeviceRate;            
            obj.TimebaseMultiplier=obj.DeviceRate/obj.Rate;
        end
        
        function []=setDeviceRate(obj,rate)
            obj.DeviceRate=rate;
        end
        
        function []=stop(obj)
            api=obj.CoreAPI;
            api.Stop();
            stop@Device(obj);
        end
        
        function []=prepare(obj)
            prepare@Device(obj);
            api=obj.CoreAPI;
            api.Reset();
        end
        
        function []=run(obj)
            api=obj.CoreAPI;
            api.Start();
            run@Device(obj);
        end
        
        function [cflags]=ChannelValToFlags(obj,c,val)
            c=sort(c)+1;
            sval=size(val);
            cflags=zeros(sval(1));
            for i=1:sval(1)
                bi=zeros(1,32);
                bi(c)=val(i,:);
                cflags(i)=bi2de(bi);
            end
        end
        
        function SetOutput(obj,c,bit,doRun,dur)
            if(~exist('doRun','var'))
                doRun=1;
            end
            if(~exist('dur','var'))
                dur=obj.MaxStaticOutputTime;
            end
            % sets the current output for the devices. Uses last bits
            % written to determine the current bits.
            obj.stop();
            obj.CoreAPI.Reset();
            
            obj.StartInstructions();
            obj.InstructBinary(c,bit,dur);
            obj.EndInstructions();
            
            if(doRun)
                obj.CoreAPI.Start();
            end
        end  
        
        function InstructDelay(obj,dur)
            % delay is just an isntruction with current bits.
            obj.InstructBinary([],[],dur);
        end
        
        function [idx]=InstructStartLoop(obj,n)
            idx=obj.Instruct(0,obj.CoreAPI.INST_LOOP,n);
        end
        
        function InstructEndLoop(obj,idx)
            obj.Instruct(0,obj.CoreAPI.INST_END_LOOP,idx);
        end 
        
        function InstructBinary(obj,chans,val,dur)
            
            minIT=obj.MinimalInstructionTime/obj.timeUnitsToSecond;
            
            if(~exist('dur','var') || dur<minIT)
                dur=minIT;
            end
            
            if(length(chans)>1 && length(val)==1)
                val=ones(size(chans))*bits;
            end
            
            % instructing and delay if needed.
            bits=obj.m_lastInstructBits;
            if(~isempty(chans))
                bits(chans)=val;
            end
            flags=bi2de(bits);
            obj.m_lastInstructBits=bits;
            
            if(dur>obj.MaxRegularInstructionTime)
                % case where we need a long delay.
                ldn=floor(dur/obj.MaxRegularInstructionTime);
                dur=rem(dur,obj.MaxRegularInstructionTime);

                % sending instruction.
                obj.Instruct(flags,obj.CoreAPI.INST_LONG_DELAY,ldn,...
                    obj.MaxRegularInstructionTime);
                if(dur>=minIT)
                    obj.Instruct(flags,obj.CoreAPI.INST_CONTINUE,0,dur);
                end
            else
                % send nbormal commands.
                obj.Instruct(flags,obj.CoreAPI.INST_CONTINUE,0,dur);
            end
        end          
    end
    
    
    properties(Access = private)
        m_lastInstructBits=zeros(1,32);
    end
    
    % protected helpers
    methods(Access = protected)
        
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
    end
    
    % core api static getters and setters
    methods (Static)
        function api=GetCoreAPI(varargin)
            persistent coreapi;
            if(isempty(coreapi))                
                coreapi=SpinCoreAPI(varargin{:}); % redo.
            end
            api=coreapi;
        end
    end
end

