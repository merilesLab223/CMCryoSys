%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize and get the devices.
init;
useAnalog=0;
if(useAnalog)
    reader=ExpCore.GetDevice('ni_analog_reader');
else
    reader=ExpCore.GetDevice('ni_counter_reader');
end
fg=ExpCore.GetDevice('pn_fg'); % read fg.

%% Device preparation.
% devices - time based.
fg.setClockRate(300e6);
fg.Channel=[0,1];
fgTerm='pfi0';

% sweeper=SpinCoreTTLGenerator(); % loopback fg.
% sweeper.Channel=[1];

% setting to trigger from the spin core ttl generator.
triggerTerm=fgTerm;

if(useAnalog)
    reader.triggerTerm=triggerTerm;
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end
reader.externalClockTerminal=fgTerm;
reader.setClockRate(10000);

dcol=TimedDataCollector(reader);
scol=StreamCollector(reader);

%% ODMR parameters.
measureT=200; % in ms. the time to measure each freq.
measureN=100; % the number of reads per freq. (Dose not matter for counter).

pulseDelay=10; % ms delay before we start the pulse.
fstart=2.8*1000;
fend=2.9*1000;
nstep=101;
fstep=(fend-fstart)/(nstep-1);
freqs=[fstart:fstep:fend]; % mhz, the frequencies to measure.
%freqs=[1];
sweepPulseT=1; % ms

%% ODMR configure.
mfreq=measureN/(measureT*1e-3); % the measure freq.
counterClearPulses=2;
counterClearTime=1e3*counterClearPulses/mfreq;
totalTime=sweepPulseT+pulseDelay+measureT;
fg.clear();
reader.setClockRate(mfreq);
scol.setClockRate(mfreq);
dcol.setClockRate(mfreq);

% setting up the fg channel.
fg.Up(sweepPulseT*4/5,1);
fg.Down(sweepPulseT,0);
fg.Down(sweepPulseT/5,1);
fg.wait(pulseDelay);
fgTime=counterClearTime+measureT;
fg.ClockSignal(fgTime,mfreq,0);

% setting up the mesaurement.
totalDelay=sweepPulseT+pulseDelay+counterClearTime;
dcol.wait(totalDelay);
dcol.Measure(measureT);

%% display what we need to get
subplot(2,1,1);
[ttls,t]=fg.getTimebaseTTLData();
plot(t,ttls);

%% ODMR Run.
rslt={};
subplot(2,1,2);
scol.addlistener('DataReady',@(s,e)DisplayScanAsStream(scol,counterClearPulses+1));

data=[];
xf=[];
pause(0.1);
for i=1:length(freqs)
    % prepare.
    f=freqs(i);
    
    fg.prepare();
    reader.prepare();
    reader.niSession.NotifyWhenDataAvailableExceeds=...
        counterClearPulses+measureN-3;
    
    dcol.stop();
    dcol.reset();
    scol.stop();
    
    % run
    dcol.start();
    scol.start();
    reader.run();
    fg.run();
    
    pause(totalTime*2/1000);
    fg.stop();
    reader.stop();
    
    dcol.stop();
    scol.stop();
    
    rslt{i}={};
    sdat=d.getData();
    sdat=sdat(counterClearPulses+1:end);
    rslt{i}.data=sdat;
    
    rslt{i}.avg=sum(rslt{i}.data)./(length(rslt{i}.data));
    rslt{i}.f=f;
    subplot(2,1,1);
    data(i)=rslt{i}.avg;
    xf(i)=f;
    plot(xf,data);
    subplot(2,1,2);
    
    disp(['Completed ',num2str(f),'[MHz] with ',num2str(length(rslt{i}.data))...
        ' datapoints, avg: ',num2str(rslt{i}.avg)]);
end

%% plot odmr.
subplot(2,1,1);
plot(freqs,data);








