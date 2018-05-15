%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize the library
InitZLib;
clear pos;
clear reader;
clear clock;
daq.reset();

%% Device preparation.
% devices - time based.
useAnalog=1;
if(useAnalog)
    reader=NI6321AnalogReader('Dev1');
else
    reader=NI6321Counter('Dev1');
end
clock=SpinCoreTTLGenerator('Dev1'); % loopback clock.
clock.Channel=[0];

% setting to trigger from the spin core ttl generator.
clockTerm='pfi0';
triggerTerm=clockTerm;

if(useAnalog)
    reader.triggerTerm=triggerTerm;
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end
reader.externalClockTerminal=clockTerm;

% adding measurement reader.
dcol=TimedDataCollector(reader);

% configure devices.
reader.configure();
clock.configure();