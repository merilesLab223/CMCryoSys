%% call to test read the counts in the system.
if(exist('stopall','var'))stopall();end;
clear;

%% Configure

counter=NI6321Counter('Dev1');
clock=NI6321Clock('Dev1');
abort=0;

% hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (counter 0)->User2 : counter input)

counter.ctrName='ctr0';
clock.ctrName='ctr3';

clockTerm='pfi14';
triggerTerm=clockTerm;
counter.externalClockTerminal=clockTerm;
clockrate=1e4;
clock.setClockRate(clockrate);
clock.clockFreq=clockrate*2;
counter.setClockRate(clock.clockFreq);

%% configure
counter.configure();
clock.configure();

%% Data colelctor.
dcol=TimedDataCollector(counter);
dcol.Measure(1000);
dcol.IsContinues=true;

%% Stat system
counter.prepare();
clock.prepare();
counter.run();

clock.run();

%% reading data.
% while(abort==0)
%     pause(0.1);
%     [t,strm]=StreamToTimedData(dcol.Results);
%     plot([t,strm]);
% end
%dcol.stop();
tm=timer('TimerFcn',...
    @(s,e)multifun(@()DisplayScanAsStream(dcol.Results)),...
    'Period',0.3,'ExecutionMode','fixedDelay');
stopall=@()multifun(@()counter.stop(),@()clock.stop(),@()stop(tm));

start(tm);
% clock.stop;