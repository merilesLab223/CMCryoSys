%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize the library
InitZLib;
clear;
daq.reset();

%% Device preparation.
% devices - time based.
useAnalog=0;
if(useAnalog)
    reader=NI6321AnalogReader('Dev1');
else
    reader=NI6321Counter('Dev1');
end
clock=SpinCoreTTLGenerator(); % loopback clock.
clock.setClockRate(300e6);
clock.Channel=[0,1];
clockTerm='pfi0';

% sweeper=SpinCoreTTLGenerator(); % loopback clock.
% sweeper.Channel=[1];

% setting to trigger from the spin core ttl generator.
triggerTerm=clockTerm;

if(useAnalog)
    reader.triggerTerm=triggerTerm;
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end
reader.externalClockTerminal=clockTerm;
reader.setClockRate(10000);

dcol=TimedDataCollector(reader);
scol=StreamCollector(reader);

% configure devices.
reader.configure();
clock.configure();
%% ODMR parameters.
measureT=2000; % in ms. the time to measure each freq.
measureN=100; % the number of reads per freq. (Dose not matter for counter).

pulseDelay=10; % ms delay before we start the pulse.
fstart=2.825*1000;
fend=2.837*1000;
fstep=0.2;
freqs=[fstart:fstep:fend]; % mhz, the frequencies to measure.
%freqs=[1];
sweepPulseT=1; % ms

%% ODMR configure.
mfreq=measureN/(measureT*1e-3); % the measure freq.
counterClearPulses=2;
counterClearTime=1e3*counterClearPulses/mfreq;
totalTime=sweepPulseT+pulseDelay+measureT;
clock.clear();
reader.setClockRate(mfreq);
scol.setClockRate(mfreq);
dcol.setClockRate(mfreq);

% setting up the clock channel.
clock.Up(sweepPulseT*4/5,1);
clock.Down(sweepPulseT,0);
clock.Down(sweepPulseT/5,1);
clock.wait(pulseDelay);
clockTime=counterClearTime+measureT;
clock.ClockSignal(clockTime,mfreq,0);

% setting up the mesaurement.
totalDelay=sweepPulseT+pulseDelay+counterClearTime;
dcol.wait(totalDelay);
dcol.Measure(measureT);

%% display what we need to get
subplot(2,1,1);
[ttls,t]=clock.getTimebaseTTLData();
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
    
    clock.prepare();
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
    clock.run();
    
    pause(totalTime*2/1000);
    clock.stop();
    reader.stop();
    
    dcol.stop();
    scol.stop();
    
    rslt{i}={};
    sdat=scol.getData();
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








