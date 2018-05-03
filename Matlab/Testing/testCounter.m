% make the counter.reader
% if(exist('reader','var'))
%     reader.stop();
%     trigger.stop();
%     clear reader;
%     clear trigger;
% end
clear all;
useAnalog=1;

% pos.xchan='ao0';
% pos.ychan='ao1';
clock.ctrName='ctr3';
clockTerm='pfi14';
triggerTerm=clockTerm;

% pos.triggerTerm=triggerTerm;

if(useAnalog)
    reader.triggerTerm=triggerTerm;
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end

reader.externalClockTerminal=clockTerm;

% adding measurement reader.
dcol=TimedDataCollector(reader);

%% configure and run.
%reader.Rate=reader.clockFreq=1e5;
% reader.cchan='';
% reader.clockterm='';
reader.configure();
clock.configure();
trigger.configure();
disp('Configured');
dev=clock.niSession.Channels.Device;

%% Make trigger output.
trigger.clear();
trigger.Pulse(10,10);

%% add input channel.
reader.addlistener('DataReady',@(s,e)plot(e.TimeStamps,e.Data));

%% prepare the counters.
reader.prepare();
clock.prepare();
trigger.prepare();
disp('Prepared');

%% run.
reader.run();
clock.run();
trigger.run();
disp('Running...');

pause(2);
reader.stop();
clock.stop();
disp('Complete');