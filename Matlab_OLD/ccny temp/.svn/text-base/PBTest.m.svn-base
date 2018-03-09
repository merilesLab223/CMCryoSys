% Test of PulseBlaster
%
% TEST WORKS!

LibraryFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.dll';
HeaderFile = 'C:\Program Files\SpinCore\SpinAPI\dll\spinapi.h';
LibraryName = 'pb';

SCPB = SpinCorePulseBlaster(LibraryFile,HeaderFile,LibraryName);


% our version of example 1

%%
% Init object

SCPB.Initialize();

%% init the pulseblaster

Clock = 400.0;
SCPB.PBInit();

  %% Set PB Clock
  SCPB.SetClock(Clock);
  
  %% set to start prog.
  SCPB.StartProgramming();
 
  %% send instruction of 40ns, all lines high
  SCPB.PBInstruction(16777215,SCPB.INST_CONTINUE,0,400.0);
  
  %%
  SCPB.StopProgramming();
  %%
  SCPB.PBStart();

  
  return
  %%
  SCPB.PBStop();
  %%
  SCPB.PBClose();
