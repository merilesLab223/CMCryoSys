%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.
clear;

%% Device preparation.
% devices - time based.
pos=NI6321Positioner2D('Dev1');
counter=NI6321Counter('Dev1');
clock=NI6321Clock('Dev1');
%trigger=NI6321TTLGenerator('Dev1');

%% Device configuration.
% setting terminals and params.

% hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (counter 0)->User2 : counter input)

pos.xchan='ao0';
pos.ychan='ao1';
counter.ctrName='ctr0';
clock.ctrName='ctr3';

clockTerm='pfi14';
triggerTerm=clockTerm;

pos.triggerTerm=triggerTerm;
counter.externalClockTerminal=clockTerm;

% adding measurement reader.
dcol=TimedDataCollector(counter);
dcol.BatchProcessingWarnMinTime=1000;

%% Configure devices.
% call to configure.
pos.configure();
counter.configure();
clock.configure();

%% Image scan example.
% clearing previous path.
pos.clear();
n=1000;
totalTime=100000;% in ms.
dwellTime=totalTime/(n*n);
pos.interpolationMethod='linear';

% added weights as 1, but can be anything.
disp(['Image scan of ',num2str(n*n),...
    ' pixels, dt[ms]: ',num2str(dwellTime),'. MaxT[ms]: ',num2str(totalTime)]);
ImageScan(pos,-1,-1,2,2,n,n,dwellTime,'Weights',1);
pos.GoTo(0,0);

%% Two nv scan & measurment example
nvp=[0.8,0.3;-0.1,0.8];
nvt=[300,300];
snv=size(nvp);
nvrepeat=1;
for i=1:nvrepeat
    for j=1:snv(2)
        pos.GoTo(nvp(j,1),nvp(j,2));
        pos.wait(nvt(j));
    end
end

% back to origin.
pos.GoTo(0,0);

%% waiting for origin to be resored.
pos.toRounded(1);

%% adjust the clocks.
% find min time.
crate=floor(2/(pos.findMinimalTime()*pos.timeUnitsToSecond));
if(crate>200000)
    warntext=['LOSS OF DATA? The required clock rate, ',num2str(crate),' is above the '...
        ,'maximal rate available. Clock rate reduced to 200K. Possible loss of data.'];
    disp(warntext);
    warning(warntext);
    crate=200000;
elseif(crate<1)
    warntext=['In the current config clock rate will be below 1 [hz]. Clock upgratded to 1 [hz].'];
    disp(warntext);
    crate=1;
end
clockfreqToRate=2;
cfreq=crate*clockfreqToRate;

% adjusted to clock.
counter.setClockRate(cfreq); % uses external clock.
pos.setClockRate(crate);
clock.setClockRate(crate); % clock output can be slower since freq.
clock.clockFreq=cfreq;
dcol.setClockRate(crate);

disp(['Measureing with, clock: ',num2str(crate),' (clockFreq: ',num2str(cfreq),' [hz])']);

%% Measurement example for image
% bin every second.
mbins=totalTime/1000;%1+floor(rand()*19); % the total number of measurement bins
if mbins<10
    mbins=10;
end
disp(['Measureing ',num2str(mbins),' mbins at dcol T=',num2str(dcol.curT)]);
mtdt=totalTime/mbins;
%dcol.MeasureAt(dcol.curT,totalTime);
% we can reduce the clock freq to the rate by 5.
dcol.Measure(ones(mbins,1)*mtdt); % measure by durations.

% without bins (or a single bin)
% dcol.Measure(0,totalTime);

%% Measurement example for the nv.
dcol.toRounded(1);
for i=1:nvrepeat
    for j=1:snv(2)
        dcol.Measure(nvt(j),...
            @(t,d)sum(d)); % adjusted to curT (auto advance).
    end
end


%% Draw final path.
% drawing the generated path (compilated).
subplot(2,1,1);
disp('Compiling path...');
tic;
[x,y,t]=pos.getCompiledPathVectors();
[mt,mdt]=dcol.getMesaurementParams();
plot(t,x,t,y,mt+mdt,zeros(length(mt),1),'*');
comp=toc;
disp(['Path compiled and displayed in [ms]: ',num2str(comp*1000)]);
%% adding helper events.
dcol.addlistener('Complete',@(s,e)disp(['Measurement completed in [ms]: ',...
    num2str(round(e.Data))]));
if(mbins<200)
    %dcol.addlistener('TimebinComplete',@(s,e)...
        %);
end

%% preparing $ running.
disp('Prepare devices..');
pos.prepare();
clock.prepare();
counter.prepare();
%trigger.prepare();
dcol.prepare();

disp('Running devices');
pos.run();
counter.run();

% running the trigger.
disp('Starting clock...');
clock.run();
mstartT=now;

disp('Data collection...');
subplot(2,1,2);
timeDt=500;
lastCompleted=0;
precentDeltaDisp=1;
donet=now;
while(true)
    pause(timeDt/1000); % in sec.
    counterT=dcol.LastCollectedTimestamp; % in ms.
    remainingTime=pos.totalExecutionTime-counterT;
    precComp=100*counterT/pos.totalExecutionTime;
    curCompleted=floor(precComp/precentDeltaDisp)*precentDeltaDisp;
    if(lastCompleted~=curCompleted && curCompleted<=100)
        disp(['Completed ',num2str(curCompleted),...
            '%. Time remaining [ms]: ',num2str(remainingTime)]);    
        lastCompleted=curCompleted;
    end
    
    DisplayScanAsImage(dcol.Results(1:mbins),n,n,dwellTime,0);
    if(remainingTime<=0)
        break;
    end
end
donet=(now-donet)*24*60*60*1000;
disp(['Should be done.(',num2str(donet),' ms)']);
pause(0.1);
disp('Stopping..');
pos.stop();
counter.stop();
clock.stop();

disp('Sequnce Complete');


%% Display data. (only the image).
dcol.finalizePending();
subplot(2,1,2);
if(length(dcol.Results)>0)
    imgrslt=dcol.Results(1:mbins);
    nvrslt=dcol.Results(1+mbins:end);
    
    tic;
    img=RowScanToImageData(imgrslt,n,n,dwellTime,0);
    comp=toc;
    disp(['Created image data in [ms] ',num2str(comp),...
        ' from total image vec len of ',length(img(:))]);
    imagesc(img);
    disp(['Image total counts: ',num2str(sum(img(:)))]);
    disp(['NV collected data:']);
    disp(cell2mat(nvrslt'));
else
    disp('no results found');
end
