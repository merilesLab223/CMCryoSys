classdef SpinCoreTTLGenerator < SpinCoreBase & TTLGenerator
    %SPINCORETTLGENERATOR Summary of this class goes here
    %   Detailed explanation goes her
    
    properties    
        % The maximal loop lenth to send to device.
        MaxLoopLength   = 1000000;
        
        % long delay min time (in timebase). the time where the instruction is split into
        % a long delay instruction. See SpinCore API for help.
        LongDelayMinTime = 60*60*1000; % an hour
    end
    
    % general methods.
    methods 
        function prepare(obj)
            prepare@SpinCoreBase(obj);
            
            % getting the stream.
            [t,strm]=obj.getTimedStream();
            
            % programming the instructions.
            obj.StartInstructions;
            
            % new version.
            lastT=0;
            % default bit structre.
            bi=zeros(1,32);
            obj.m_lastInstrctBits=bi;
            pendingLoopIndexs=[];
            
            for i=1:length(strm)
                % processing instruction si.
                si=strm{i};
                ti=t(i);

                % getting the instructions...
                if(isstruct(si))

                    % this is an instruction struct
                    if(~isfield(si,'type'))
                        continue;
                    end

                    switch(si.type)
                        case TTLGenerator.LOOPStartStruct.type
                            pendingLoopIndexs(end+1)=...
                                obj.InstructStartLoop(si.n);
                        case TTLGenerator.LOOPEndStruct.type
                            if(isempty(pendingLoopIndexs))
                                error('Reached loop end but no loop was started.');
                            end
                            obj.InstructEndLoop(pendingLoopIndexs(end));
                            pendingLoopIndexs(end)=[];
                    end
                    % adding delay if needed.
                    if(ti>lastT)
%                         obj.InstructDelay(ti-lastT);
                        lastT=ti;
                    end 
                    % nothing else here.
                    continue;
                end
                
                % need to add the data.
                data=si(:,2:end);
                durs=si(:,1);
                sdata=size(data);
                for j=1:sdata(1)
                    % adding the rows.
                    bi(1:sdata(2))=data(j,:);
                    obj.InstructBinary(bi,durs(j));
                end
                lastT=lastT+sum(durs);
                
                % adding delay if needed.
                if(ti>lastT)
%                     obj.InstructDelay(ti-lastT);
                    lastT=ti; 
                end       
            end
            
            obj.EndInstructions;
            
            if(~isempty(pendingLoopIndexs))
                error('Reached end of instructions but loop is still open.');
            end
        end
    end
    
    properties(Access = private)
        m_lastInstrctBits=[];
    end
    
    % protected helpers
    methods(Access = protected)
        function InstructDelay(obj,dur)
            obj.InstructBinary(obj.m_lastInstrctBits,dur);
        end
        
        function [idx]=InstructStartLoop(obj,n)
            idx=obj.Instruct(0,obj.CoreAPI.INST_LOOP,n);
        end
        
        function InstructEndLoop(obj,idx)
            obj.Instruct(0,obj.CoreAPI.INST_END_LOOP,idx);
        end 
        
        function InstructBinary(obj,bits,dur)
            
            minIT=obj.MinimalInstructionTime/obj.timeUnitsToSecond;
            
            if(dur<minIT)
                dur=minIT;
            end
            % instructing and delay if needed.
            flags=bi2de(bits);
            obj.m_lastInstrctBits=bits;
            
            if(dur>obj.LongDelayMinTime)
                % case where we need a long delay.
                ldn=floor(dur/obj.LongDelayMinTime);
                dur=rem(dur,obj.LongDelayMinTime);

                % sending instruction.
                obj.Instruct(flags,obj.CoreAPI.INST_LONG_DELAY,ldn,obj.LongDelayMinTime);
                if(dur>=minIT)
                    obj.Instruct(flags,obj.CoreAPI.INST_CONTINUE,0,dur);
                end
            else
                % send nbormal commands.
                obj.Instruct(flags,obj.CoreAPI.INST_CONTINUE,0,dur);
            end
        end        
    end
        
end

