% make the counter.ctr
% if(exist('ctr','var'))
%     ctr.stop();
%     trigger.stop();
%     clear ctr;
%     clear trigger;
% end
clear all;

ctr=NI6321Counter('Dev1');
clock=NI6321Clock('Dev1');
trigger=NI6321TTLGenerator('Dev1');

triggerTerm='PFI0';
clockTerm='PFI14';

clock.ctrName='ctr3'; % always running.
clock.triggerTerm=triggerTerm;

ctr.ctrName='ctr0';
ctr.externalClockTerminal=clockTerm;
%ctr.triggerTerm=triggerTerm;

trigger.ttlchan='port0/line1';
%trigger.externalClockTerminal=clockTerm;
% port0/line1 ->USER1 ->PFI0;

%% configure and run.
%ctr.Rate=ctr.clockFreq=1e5;
% ctr.cchan='';
% ctr.clockterm='';
ctr.configure();
clock.configure();
trigger.configure();
disp('Configured');
dev=clock.niSession.Channels.Device;

%% Make trigger output.
trigger.clear();
trigger.Pulse(10,10);

%% add input channel.
ctr.addlistener('DataReady',@(s,e)plot(e.TimeStamps,e.Data));

%% prepare the counters.
ctr.prepare();
clock.prepare();
trigger.prepare();
disp('Prepared');

%% run.
ctr.run();
clock.run();
trigger.run();
disp('Running...');

pause(2);
ctr.stop();
clock.stop();
disp('Complete');