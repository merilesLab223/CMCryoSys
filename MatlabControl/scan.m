%% Examples docment for lecture.
% the examples document shows simple commands to be sent to the system.

% Initialize the library
InitZLib;
clear pos;
clear reader;
clear clock;
%daq.reset();

%% Image scan example.
% devices - time based.
useAnalog=0;
usePulseBlasterAsClock=1;

% what to do?
multidir=1;
doMultiScan=0;

% calibration.
VoltToUm=172;
whratio=1.56;

% image parameters.
n=250; % number of pixels.
dt=1000;%5*60000;% in ms.
asDwellTime=0; % if 1, then dt is a signle pixel time. Otherwise dt/n^2.
if(~exist('x0','var')||~exist('scan_skipcurpos','var')||~scan_skipcurpos)
    x0=0;
    y0=0;
    dist=100; %[um] (= Width,Height) square image.
end    

%% Device preparation.

pos=NI6321Positioner2D('Dev1');
if(useAnalog)
    reader=NI6321AnalogReader('Dev1');
else
    reader=NI6321Counter('Dev1');
end

if(~usePulseBlasterAsClock)
    clock=NI6321Clock('Dev1'); % loopback clock.
    clock.ctrName='ctr3';
else
    clock=SpinCoreClock(); % loopback clock.
    clock.setClockRate(300e6);
    clock.Channel=0;
end


%% Device configuration.
% setting terminals and params.

% NI hard connections.
% port0/line1 ->USER1 ->PFI0 : Trigger.
% pfi15->pfi14 : Clock loopback.
% pfi8 (counter 0)->User2 : counter input)

pos.xchan='ao0';
pos.ychan='ao1';
if(~usePulseBlasterAsClock)
    clock.ctrName='ctr3';
    clockTerm='pfi14';
else
    clockTerm='pfi0';
end

triggerTerm=clockTerm;
pos.triggerTerm=triggerTerm;

if(useAnalog)
    reader.triggerTerm=triggerTerm;
    reader.readchan='ai0';
else
    reader.ctrName='ctr0';
end

reader.externalClockTerminal=clockTerm;
pos.externalClockTerminal=clockTerm;

% adding measurement reader.
dcol=TimedDataCollector(reader);
scol=StreamCollector(reader);

%% Configure devices.
% call to configure.
pos.configure();
reader.configure();
clock.configure();

%% Find measurment rates.
if(asDwellTime)
    totalTime=dt.*n^2;
else
    totalTime=dt;
end
dwellTime=totalTime/(n*n);

crate=floor(2/(dwellTime*pos.timeUnitsToSecond));
maxClockFreq=100000;
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
readerTOffset=0.19+pos.secondsToTimebase(1/crate);
%% Do converions.
% convert back to volts.
dist=dist./VoltToUm;
x0=x0./VoltToUm;
y0=y0./VoltToUm;

width=dist;
height=dist;

%posOffset=0;%pos.secondsToTimebase(1/crate);
%mOffset=0*multidir;

pos.interpolationMethod='linear';
imgRange=[x0-width/2,y0-height/2,width/n,height/n]*VoltToUm;

% correction  for x;
width=width*whratio;

%pos.wait(tOffset);
% added weights as 1, but can be anything.
disp(['Image scan of ',num2str(n*n),...
    ' pixels, dt[ms]: ',num2str(dwellTime),'. MaxT[ms]: ',num2str(totalTime)]);
WriteImageScan(pos,x0-width/2,y0-height/2,width,height,n,n,dwellTime,...
    'multidirectional',multidir,'interpMethod','linear');

% goto 0,0 and wait 100;
disp(pos.curT);
pos.GoTo(0,0,100);
%pos.GoTo(0,0,100);
%goto(0,0);

%% waiting for origin to be resored.
%pos.toRounded(1);

%% adjust the clocks.
% find min time.
clockfreqToRate=1;
cfreq=crate*clockfreqToRate;

% adjusted to clock. (cfreq>crate)
pos.setClockRate(cfreq); % uses external clock.
reader.setClockRate(cfreq); % uses external clock.

% If pulseblaster is clock, need to configure the sequnce.
if(usePulseBlasterAsClock)
    clock.clockFreq=cfreq;
else
    clock.setClockRate(cfreq);
    clock.clockFreq=cfreq;
end
dcol.setClockRate(cfreq);
scol.setClockRate(cfreq);
scol.CollectDT=totalTime*2+3000;

disp(['Measureing with, sampling rate: ',num2str(crate),' (clock freq: ',num2str(cfreq),' [hz])']);
%% Measurement example for image
% bin every second.
mbins=round(totalTime/1000);%1+floor(rand()*19); % the total number of measurement bins
if mbins<10
    mbins=10;
end
disp(['Measureing ',num2str(mbins),' mbins at dcol T=',num2str(dcol.curT)]);
mtdt=totalTime/mbins;
tickTime=reader.secondsToTimebase(1/cfreq);
reader.SetMaxReadChunkSize(mtdt/(2*tickTime));
%dcol.MeasureAt(dcol.curT,totalTime);
% we can reduce the clock freq to the rate by 5.
dcol.Measure(ones(mbins,1)*mtdt); % measure by durations.

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
    scol.stop();
    dcol.stop();
    dcol.reset();
    scol.reset();
    
    disp('Prepare devices..');
    pos.prepare();
    clock.prepare();
    reader.prepare();
    %trigger.prepare();
    dcol.prepare();
    scol.prepare();
    
    disp('Running devices');
    pos.run();
    reader.run();
    dcol.start();
    scol.start();

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

        lastimg=DisplayScanAsImage(dcol.Results,n,n,dwellTime,multidir,readerTOffset,lastimg,imgRange);
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
dcol.stop();
scol.stop();

disp('Sequnce Complete');


%% Display data. (only the image).
dcol.finalizePending();

if(~isempty(dcol.Results))
    imgrslt=dcol.Results(1:mbins);
    nvrslt=dcol.Results(1+mbins:end);
    
    tic;
    subplot(1,1,1);
    [img]=DisplayScanAsImage(dcol.Results,n,n,dwellTime,multidir,readerTOffset,lastimg,imgRange);
%     subplot(1,2,2);
%     %plot(t,x,t,y,mt+mdt,zeros(length(mt),1),'*');
%     rmat=scol.getResultsMatrix();
%     toff=0.19+pos.secondsToTimebase(1/cfreq);
%     [img]=StreamToImageData(rmat,n,n,dwellTime,multidir,toff);
    %imagesc(img);
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
