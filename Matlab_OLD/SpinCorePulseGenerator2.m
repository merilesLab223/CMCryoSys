classdef SpinCorePulseGenerator2 < SpinCorePulseGenerator
    properties
    DEBUG_MODE = 1;
    end

    methods
         function [obj] = sendSequence(obj,InstrStruct,NumberPoints,InfLoop)
            
            
           s ={};
                      
           % start programming
           obj.hwHandle.StartProgramming();
          
           if ~InfLoop,
               s{end+1} = sprintf('0x0,100ns,LOOP,%d',NumberPoints);
               obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_LOOP,NumberPoints,100);
           end
           

    
            % process all the instructions
            for k=1:numel(InstrStruct.Length),

                FlagInstr = InstrStruct.Data(k);

                if InstrStruct.Length(k) > 2^8,
                    % LONG_DELAY
                    % # of cycles per LONG_DELAY_TIMESTEP 
                    CyclesPerLD = round(obj.LONG_DELAY_TIMESTEP*obj.ClockRate);

                    % how many long delays do we need to make up the Instr.Length
                    LongDelayInt = floor(InstrStruct.Length(k)/CyclesPerLD);

                    % how much time is remaining?
                    ContinueCycles = InstrStruct.Length(k) - CyclesPerLD*LongDelayInt;

                    if (ContinueCycles < 5) && (ContinueCycles > 0), % 22 March 2011, jhodges, added Cycles>0
                        
                        % 22 March 2011, jhodges
                        % try to change the long delay int to accommodate
                        % Continues of < 5
                        LongDelayInt = LongDelayInt - 1; % take away one LongDelay Period
                        ContinueCycles = ContinueCycles + CyclesPerLD;
                        
                        %REMOVED 22-Mar-2011
                        %ContinueCycles = 0;
                        %disp('Dropped instruction because less than 5 clock cycles');
                    end

                    if LongDelayInt > 1,
                        obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_LONG_DELAY,LongDelayInt,obj.LONG_DELAY_TIMESTEP*1e9);
                         s{end+1} = sprintf('0x%s,%.1f ns,LONG_DELAY,%d',dec2hex(FlagInstr,6),obj.LONG_DELAY_TIMESTEP*1e9,LongDelayInt);
                    else,
                         obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,LongDelayInt*obj.LONG_DELAY_TIMESTEP*1e9);
                         s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,%d',dec2hex(FlagInstr,6),obj.LONG_DELAY_TIMESTEP*1e9,0);
                    end
                    
                    if ContinueCycles > 0,
                        obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,ContinueCycles/obj.ClockRate*1e9);
                        s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,0',dec2hex(FlagInstr,6),ContinueCycles/obj.ClockRate*1e9);
                    end

                elseif InstrStruct.Length(k) > 5 && InstrStruct.Length(k) <= 2^8,

                    LongDelayInt = 0;
                    ContinueCycles = InstrStruct.Length(k);
                    s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,0',dec2hex(FlagInstr,6),ContinueCycles/obj.ClockRate*1e9);
                    obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,ContinueCycles/obj.ClockRate*1e9);
                elseif InstrStruct.Length(k) < 5,
                    LongDelayInt = 0;
                    ContinueCycles = InstrStruct.Length(k);
                    MinimumInstrLength = 5;
                    s{end+1} = sprintf('0x%s,%.1f ns,CONTINUE,0',dec2hex(FlagInstr,6),MinimumInstrLength/obj.ClockRate*1e9);
                    obj.hwHandle.PBInstruction(FlagInstr,obj.hwHandle.INST_CONTINUE,0,MinimumInstrLength/obj.ClockRate*1e9);
                end;

            end % end Instr loop
            
            % add a short 100ns delay to the end
            s{end+1} = '0x0,100 ns,CONTINUE,0';
            obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_CONTINUE,0,100);
            
            % TEST
            %s{end+1} = '0x0,500 ns,LONG_DELAY,40000';
            %obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_LONG_DELAY,4000,500.0);
            
            if InfLoop,
                obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_BRANCH,0,100);
                 s{end+1} = '0x0,100 ns,BRANCH,0';
            else
                obj.hwHandle.PBInstruction(0,obj.hwHandle.INST_END_LOOP,0,100);
                s{end+1} = '0x0,100 ns,END_LOOP,0';
            end


            
            if obj.DEBUG_MODE > 0,
                disp('-------PB INST START-------');
                for k=1:length(s),
                    disp(s{k});
                end
                disp('#######PB INST END  #######');

            end
            
            obj.hwHandle.StopProgramming();
            
        end % sendSequenceInstr
    end
end
