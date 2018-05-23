%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize the library
InitZLib;
clear;
daq.reset();

%% Configure

% call stopall() to stop the stream (or clear).
abort=0;
useAnalog=1;

% max 5 minutes.
usePulseBlasterAsClock=0;

% hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (reader 0)->User2 : reader input)

if(useAnalog)
    reader=NI6321AnalogReader('Dev1');
    reader.readchan='ai0';
else
    reader=NI6321Counter('Dev1');
    reader.ctrName='ctr0';
end

clockrate=1e4;
clockFreq=clockrate*2;
if(~usePulseBlasterAsClock)
    clock=NI6321Clock('Dev1'); % loopback clock.
    clock.ctrName='ctr3';
    clockTerm='pfi14';
    clock.setClockRate(clockrate);
    clock.clockFreq=clockFreq;
else
    clock=SpinCoreTTLGenerator(); % loopback clock.
    clock.setClockRate(300e6);
    clock.Channel=[0,1];
    clockTerm='pfi0';
end

triggerTerm=clockTerm;
reader.externalClockTerminal=clockTerm;
reader.setClockRate(clockFreq);

%% configure
reader.configure();
clock.configure();

if(usePulseBlasterAsClock)
    clock.clear();
    clock.Pulse(1,1,1);
    clock.ClockSignal(1000*60*5,clockFreq,0);
end

%% Data colelctor.
streamCol=StreamCollector(reader);
streamCol.setClockRate(clockrate);
%streamCol.IsContinues=true;

%% Stat system
reader.prepare();
clock.prepare();
reader.run();
clock.run();

streamCol.start();
%% reading data.
subplot(1,1,1);
streamCol.addlistener('DataReady',@(s,e)DisplayScanAsStream(streamCol));
stopall=@()multifun(@()reader.stop(),@()clock.stop());

% clock.stop;