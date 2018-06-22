%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize the library
init;
useAnalog=0;
usePulseBlasterAsClock=1;
if(useAnalog)
    reader=ExpCore.GetDevice('ni_analog_reader');
else
    reader=ExpCore.GetDevice('ni_counter_reader');
end
if(usePulseBlasterAsClock)
    clock=ExpCore.GetDevice('pb_clock'); % read clock.
else
    clock=ExpCore.GetDevice('ni_clock'); % read clock.
end

%% Configure

% call stopall() to stop the stream (or clear).
abort=0;

% hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (reader 0)->User2 : reader input)

if(useAnalog)
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end

clockrate=1e4;
clockFreq=clockrate*2;
if(~usePulseBlasterAsClock)
    clock.ctrName='ctr3';
    clockTerm='pfi14';
    clock.setClockRate(clockrate);
    clock.clockFreq=clockFreq;
else
    clock.setClockRate(300e6);
    clock.Channel=0;
    clockTerm='pfi0';
end

triggerTerm=clockTerm;
reader.externalClockTerminal=clockTerm;
reader.setClockRate(clockFreq);

%% configure
reader.configure();
clock.configure();

if(usePulseBlasterAsClock)
    clock.clockFreq=clockFreq;
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