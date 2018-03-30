%% Initialize all devices in the system.
global devices;
global info;

if(isempty(devices))
    devices=DeviceCollection;
end
info=globalInfo;

pos=NI6321Positioner2D('Dev1');
counter=NI6321Counter('Dev1');
clock=NI6321Clock('Dev1'); % loopback clock.

% hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (counter 0)->User2 : counter input)

devices.setDevice('ni2dposition',pos);
devices.setDevice('nicounter',counter);
devices.setDevice('niclock',clock);

devices.setRole('scan_pos','ni2dposition');
devices.setRole('scan_clock','niclock');
devices.setRole('scan_reader','nicounter');
devices.setRole('scan_trigger','niclock');

%% Configure device connections.
pos.xchan='ao0';
pos.ychan='ao1';
counter.ctrName='ctr0';
clock.ctrName='ctr3';
clockTerm='pfi14';
triggerTerm=clockTerm;

pos.triggerTerm=triggerTerm;
counter.externalClockTerminal=clockTerm;

%% configuring the data collector.
info.streamCollector=TimedDataCollector(devices.get('scan_reader'));
info.streamCollector.IsContinues=true;
info.streamCollector.Measure(200);
info.imageCollector=TimedDataCollector(devices.get('scan_reader'));
info.imageCollector.stop();
%% starting stream reader.. (is default)
counter.prepare();
clock.prepare();
counter.run();
clock.run();