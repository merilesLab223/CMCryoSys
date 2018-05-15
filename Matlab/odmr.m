%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize the library
InitZLib;
clear;
daq.reset();

%% Device preparation.
% devices - time based.
useAnalog=1;
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
measureT=1000; % in ms.
measureN=20000;
mfreq=measureN/(measureT*1e-3);
pulseDelay=1; % ms
freqs=[1:120]*0.5+2840; % mhz
sweepPulseT=0.5; % ms

totalTime=sweepPulseT+pulseDelay+measureT;
%% ODMR configure.
clock.clear();
reader.setClockRate(mfreq);
scol.setClockRate(mfreq);
dcol.setClockRate(mfreq);

clock.Down(sweepPulseT/2);
clock.Up(sweepPulseT/2,1);
%clock.Pulse(0.5,sweepPulseT,1);
clock.wait(pulseDelay);
clock.ClockSignal(measureT,mfreq,0);

totalDelay=0.5+pulseDelay;
dcol.wait(totalDelay);
dcol.Measure(measureT);

%% display what we need to get
subplot(2,1,1);
[ttls,t]=clock.getTimebaseTTLData();
plot(t,ttls);

%% ODMR Run.
rslt={};
subplot(2,1,2);
scol.addlistener('DataReady',@(s,e)DisplayScanAsStream(scol));

data=[];
xf=[];
pause(0.1);
for i=1:length(freqs)
    % prepare.
    f=freqs(i);
    
    clock.prepare();
    reader.prepare();
    dcol.stop();
    dcol.reset();
    scol.stop();
    
    % run
    dcol.start();
    scol.start();
    reader.run();
    clock.run();
    
    pause(totalTime*2/1000);
    reader.stop();
    clock.stop();
    dcol.stop();
    scol.stop();
    
    rslt{i}={};
    rslt{i}.data=scol.getData();
    rslt{i}.avg=sum(rslt{i}.data);
    rslt{i}.f=f;
    subplot(2,1,1);
    data(i)=rslt{i}.avg;
    xf(i)=f;
    plot(xf,data);
    subplot(2,1,2);
end

%% plot odmr.
subplot(2,1,1);
plot(freqs,data);








