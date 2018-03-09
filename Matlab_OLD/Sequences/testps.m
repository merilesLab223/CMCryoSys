PSeq = PulseSequence;

PulseSequencer(PSeq);

PS = PulseSweep;
PS.Channels = 1;
PS.SweepClass = 'Rise';
PS.SweepType = 'T';
PS.SweepRises = 2;
PS.StartValue = 0;
PS.StopValue = 100e-9;
PS.SweepPoints = 101;
PS.SweepShifts = 1;
PS.SweepAdd = 1;
PSeq.Sweeps = PS;


PSeq.SweepIndex = [];
PSeq.getSweepIndex();

hAxes = axes();

while PSeq.getSweepIndex,
    
    
    
    [S,PS] = ProcessPulseProgramTekAWG(PSeq,[],1e9)
    PulseSequencerFunctions('DrawSequenceExternal',hAxes,PS);
    PSeq.incrementSweepIndex();
    pause
    
end