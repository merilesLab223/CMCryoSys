function [s] = bintest()

% test of binary
[f,p] = uigetfile();
if f,
    load(fullfile(p,f));
else
    return;
end
ClockRate = 300.0e6;
[BinarySequence,tmp] = ProcessPulseSequence(PSeq,ClockRate);

HWChannels = [PSeq.Channels(:).HWChannel]';

PG = SpinCorePulseGenerator();

Instr = PG.ConvertToHex(BinarySequence);

LONG_DELAY_TIMESTEP = 500e-9;

%% DO PB TEST
LibraryFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.dll';
HeaderFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.h';
LibraryName = 'pb';

SCPB = SpinCorePulseBlaster(LibraryFile,HeaderFile,LibraryName);

% our version of example 1

%%
% Init object

SCPB.Initialize();

%% init the pulseblaster

Clock = ClockRate/1e6;
SCPB.PBInit();

  %% Set PB Clock
  SCPB.SetClock(Clock);
  

%% stop in case any sequence was running
  SCPB.PBStop();

  %% set to start prog.
  SCPB.StartProgramming();
    s = {};

for k=1:numel(Instr),

    Temp = Instr(k).Data;
    IntOrdered = Temp.*(2.^HWChannels);
    FlagInstr = sum(IntOrdered);
    
  %% send instruction of 40ns, all lines high


    if Instr(k).Length > 2^8,
        % LONG_DELAY
        % # of cycles per LONG_DELAY_TIMESTEP 
        CyclesPerLD = round(LONG_DELAY_TIMESTEP*ClockRate);
        
        % how many long delays do we need to make up the Instr.Length
        LongDelayInt = floor(Instr(k).Length/CyclesPerLD);
        
        % how much time is remaining?
        ContinueCycles = Instr(k).Length - CyclesPerLD*LongDelayInt;
        
        if ContinueCycles < 5,
            ContinueCycles = 0;
        end
        
        s{end+1} = sprintf('0x%s,%.1f,LONG_DELAY,%d',dec2hex(FlagInstr,6),LONG_DELAY_TIMESTEP*1e9,LongDelayInt);
        SCPB.PBInstruction(FlagInstr,SCPB.INST_LONG_DELAY,LongDelayInt,LONG_DELAY_TIMESTEP*1e9);
        if ContinueCycles > 0,
            SCPB.PBInstruction(FlagInstr,SCPB.INST_CONTINUE,0,ContinueCycles/ClockRate*1e9);
            s{end+1} = sprintf('0x%s,%.1f,CONTINUE,0',dec2hex(FlagInstr,6),ContinueCycles/ClockRate*1e9);
        end
        
    else
        
        LongDelayInt = 0;
        ContinueCycles = Instr(k).Length;
        SCPB.PBInstruction(FlagInstr,SCPB.INST_CONTINUE,0,ContinueCycles/ClockRate*1e9);
        s{end+1} = sprintf('0x%s,%.1f,CONTINUE,0',dec2hex(FlagInstr,6),ContinueCycles/ClockRate*1e9);
    end;
    
end

%  add delay at end
SCPB.PBInstruction(0,SCPB.INST_CONTINUE,0,100);

%%
  SCPB.StopProgramming();
  %%
  SCPB.PBStart();

 