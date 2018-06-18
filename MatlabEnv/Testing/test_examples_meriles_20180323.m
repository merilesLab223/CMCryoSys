%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.
clear;
useAnalog=1;
%% Device preparation.
% devices - time based.
pos=NI6321Positioner2D('Dev1');
if(useAnalog)
    reader=NI6321AnalogReader('Dev1');
else
    reader=NI6321Counter('Dev1');
end
clock=NI6321Clock('Dev1'); % loopback clock.
%trigger=NI6321TTLGenerator('Dev1');

%% Device configuration.
% setting terminals and params.

% hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (counter 0)->User2 : counter input)

pos.xchan='ao0';
pos.ychan='ao1';
clock.ctrName='ctr3';
clockTerm='pfi14';
triggerTerm=clockTerm;

pos.triggerTerm=triggerTerm;

if(useAnalog)
    reader.triggerTerm=triggerTerm;
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end

reader.externalClockTerminal=clockTerm;

% adding measurement reader.
dcol=TimedDataCollector(reader);

%% Configure devices.
% call to configure.
pos.configure();
reader.configure();
clock.configure();

%% Image scan example.
% clearing previous path.
doMultiScan=0;
multidir=1;
VoltToUm=172;
n=100;
x0=0;
y0=0;
dist=100;
dt=1;% in ms.
asDwellTime=1;

% convert back to volts.
dist=dist./VoltToUm;
x0=x0./VoltToUm;
y0=y0./VoltToUm;

width=dist;
height=dist;
whratio=1.5;
posOffset=10*multidir;
mOffset=0.21*multidir;

if(asDwellTime)
    totalTime=dt.*n^2;
else
    totalTime=dt;
end
dwellTime=totalTime/(n*n);
pos.interpolationMethod='linear';
imgRange=[x0-width/2,y0-height/2,width/n,height/n]*VoltToUm;

% correction  for x;
width=width*whratio;

%pos.wait(tOffset);
% added weights as 1, but can be anything.
disp(['Image scan of ',num2str(n*n),...
    ' pixels, dt[ms]: ',num2str(dwellTime),'. MaxT[ms]: ',num2str(totalTime)]);
WriteImageScan(pos,x0-width/2,y0-height/2,width,height,n,n,dwellTime,...
    'multidirectional',multidir,'timeOffset',posOffset);

% goto 0,0 and wait 100;
pos.GoTo(0,0,1);

%% Two nv scan & measurment example
% nvp=[0.8,0.3;-0.1,0.8];
% nvt=[300,300];
% snv=size(nvp);
% nvrepeat=1;
% for i=1:nvrepeat
%     for j=1:snv(2)
%         pos.GoTo(nvp(j,1),nvp(j,2));
%         pos.wait(nvt(j));
%     end
% end
% 
% % back to origin.
% pos.GoTo(0,0);

%% waiting for origin to be resored.
pos.toRounded(1);

%% adjust the clocks.
% find min time.
crate=floor(2/(pos.getMinDuration()*pos.timeUnitsToSecond));
maxClockFreq=50000;
if(crate>maxClockFreq)
    warntext=['LOSS OF DATA? The required clock rate, ',num2str(crate),' is above the '...
        ,'maximal rate available. Clock rate reduced to 200K. Possible loss of data.'];
    disp(warntext);
    warning(warntext);
    crate=maxClockFreq;
elseif(crate<1)
    warntext=['In the current config clock rate will be below 1 [hz]. Clock upgratded to 1 [hz].'];
    disp(warntext);
    crate=1;
end
clockfreqToRate=2;
cfreq=crate*clockfreqToRate;

% adjusted to clock.
reader.setClockRate(cfreq); % uses external clock.
pos.setClockRate(crate);
clock.setClockRate(crate); % clock output can be slower since freq.
clock.clockFreq=cfreq;
dcol.setClockRate(crate);

disp(['Measureing with, sampling rate: ',num2str(crate),' (clock freq: ',num2str(cfreq),' [hz])']);

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
dcol.wait(posOffset+mOffset);
dcol.Measure(ones(mbins,1)*mtdt); % measure by durations.

% without bins (or a single bin)
% dcol.Measure(0,totalTime);

%% Measurement example for the nv.
% dcol.toRounded(1);
% for i=1:nvrepeat
%     for j=1:snv(2)
%         dcol.Measure(nvt(j),...
%             @(t,d)sum(d)); % adjusted to curT (auto advance).
%     end
% end


%% Draw final path.
% drawing the generated path (compilated).
subplot(2,1,1);
disp('Compiling path...');
tic;
[x,y,t]=pos.getPathVectors();
[mt,mdt]=dcol.getMesaurementParams();
plot(t,x,t,y,mt+mdt,zeros(length(mt),1),'*');
comp=toc;
disp(['Path compiled and displayed in [ms]: ',num2str(comp*1000)]);
%% adding helper events.
mcomplete=0;
dcol.addlistener('Complete',@(s,e)disp(['Measurement completed in [ms]: ',...
    num2str(round(e.Data))]));
%% preparing $ running.

lastimg=[];
firstScan=1;
while(doMultiScan || firstScan)
    
       
    firstScan=0;
    pos.stop();
    clock.stop();
    reader.stop();
    dcol.stop();
    dcol.reset();
    
    disp('Prepare devices..');
    pos.prepare();
    clock.prepare();
    reader.prepare();
    %trigger.prepare();
    dcol.prepare();

    disp('Running devices');
    dcol.start();
    pos.run();
    reader.run();

    % running the trigger.
    disp('Starting clock...');
    clock.run();
    mstartT=now;

    disp('Data collection...');
    subplot(1,1,1);
    timeDt=500;
    lastCompleted=0;
    precentDeltaDisp=1;
    donet=now;
    
    disp(['Expected compleation time: ',datestr(now+totalTime./(24*60*60*1000)),' ',...
        num2str(totalTime./(60*1000)),' [mins]']);
    disp(['dx: ',num2str(imgRange(3)),' dy: ',num2str(imgRange(4))]); 
    
    while(dcol.IsRunning)
        pause(timeDt/1000); % in sec.
        readerT=dcol.LastCollectedTimestamp; % in ms.
        remainingTime=pos.totalExecutionTime-readerT;
        precComp=100*readerT/pos.totalExecutionTime;
        curCompleted=floor(precComp/precentDeltaDisp)*precentDeltaDisp;
        if(lastCompleted~=curCompleted && curCompleted<=100)
            disp(['Completed ',num2str(curCompleted),...
                '%. Time remaining [ms]: ',num2str(remainingTime)]);    
            lastCompleted=curCompleted;
        end

        lastimg=DisplayScanAsImage(dcol.Results,n,n,dwellTime,lastimg,multidir,imgRange);
        if(remainingTime<=0)
            break;
        end
    end
end
donet=(now-donet)*24*60*60*1000;
disp(['Should be done.(',num2str(donet),' ms)']);
pause(0.1);
disp('Stopping..');
pos.stop();
reader.stop();
clock.stop();

disp('Sequnce Complete');


%% Display data. (only the image).
dcol.finalizePending();
subplot(1,1,1);
if(~isempty(dcol.Results))
    imgrslt=dcol.Results(1:mbins);
    nvrslt=dcol.Results(1+mbins:end);
    
    tic;
    [img]=DisplayScanAsImage(dcol.Results,n,n,dwellTime,lastimg,multidir,imgRange);
    %img=StreamToImageData(imgrslt,n,n,dwellTime,multidir);
    comp=toc;
    disp(['Created image data in [ms] ',num2str(comp),...
        ' from total image vec len of ',num2str(length(img(:)))]);
%     imagesc(img);
    disp(['Image total counts: ',num2str(sum(img(:)))]);
%     disp(['NV collected data:']);
%     disp(cell2mat(nvrslt'));
else
    disp('no results found');
end
