%% call to test read the counts in the system.
daq.reset;
clear reader;
clear clock;

%% Configure
abort=0;
useAnalog=1;

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

clock=NI6321Clock('Dev1');
clock.ctrName='ctr3';

clockTerm='pfi14';
triggerTerm=clockTerm;
reader.externalClockTerminal=clockTerm;

clockrate=1e4;
clock.setClockRate(clockrate);
clock.clockFreq=clockrate*2;
reader.setClockRate(clock.clockFreq);

%% configure
reader.configure();
clock.configure();

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
% while(abort==0)
%     pause(0.1);
%     [t,strm]=StreamToTimedData(dcol.Results);
%     plot([t,strm]);
% end
%dcol.stop();
subplot(1,1,1);
streamCol.addlistener('DataReady',@(s,e)DisplayScanAsStream(streamCol));
stopall=@()multifun(@()reader.stop(),@()clock.stop());

% clock.stop;