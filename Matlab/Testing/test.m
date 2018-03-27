%% Making the new procedure and devices.
clear all;
newobjs=0;
measureBins=0;
n=1000;
if(~exist('pos','var'))
    NewProcedure;
    
    % hard connections.
    % port0/line1 ->USER1 ->PFI0 : Trigger.
    % pfi15->pfi14 : Clock loopback.
    % pfi8 (counter 0)->User2 : counter input)
    % setting terminals and params.
    
    % devices.
    pos=NI6321Positioner2D('Dev1');
    counter=NI6321Counter('Dev1');
    clock=NI6321Clock('Dev1');
    %trigger=NI6321TTLGenerator('Dev1');
    
    % data collector.
    dcol=TimedDataCollector(counter);
    externalClockTerm='pfi14';
    triggerTerm=externalClockTerm;

    pos.xchan='ao0';
    pos.ychan='ao1';
    counter.ctrName='ctr0';
    clock.ctrName='ctr3';
    %trigger.ttlchan='port0/line1';
    
    % set connections.
    pos.triggerTerm=triggerTerm;
    %pos.externalClockTerminal=externalClockTerm;
    counter.externalClockTerminal=externalClockTerm;

    % setting rates (in hz);
    %trigger.setClockRate(50000);
    clock.setClockRate(200000);
    clock.clockFreq=1e6;
    counter.setClockRate(clock.clockFreq); % uses external clock.
    pos.setClockRate(200000);
    
    devices.setDevice('positioner',pos);
    devices.setDevice('counter',counter);
    %devices.setDevice('nitrigger',trigger);
    devices.setDevice('niclock',clock);
    
    % setting the roles.
    %devices.setRole('trigger','nitrigger');
    devices.setRole('reader','counter');
    devices.setRole('position','positioner');
    devices.setRole('clock','niclock');

    newobjs=1;
end

% configure the roles if needed.
devices.configureAllRoles();
plotn=2;
s=pos.niSession;
dev=s.Channels(1).Device;

%% Creating position info (and display).
dcol.clear();
totalTime=2000;% in ms.
dwellTime=totalTime/(n*n);
pos.clear();
pos.interpolationMethod='linear';
tic;
[~,~,t]=ImageScan(pos,-1,-1,2,2,n,n,dwellTime);
compt=toc;
disp(['Scan procedure generation time: ',num2str(compt)]);
tic;
if(measureBins<1)
    dcol.Measure(0,totalTime);    
else
    % measure by bins.
    mtdt=totalTime/measureBins;
    mt=((1:measureBins)-1)*mtdt;
    dcol.Measure(mt,ones(1,measureBins)*mtdt);
end

compt=toc;
disp(['Measure procedure generation time: ',num2str(compt)]);

nv1=[0.8,0.3];
nv2=[-0.1,0.8];
for(i=1:2)
    pos.GoTo(nv1(1),nv1(2));
    pos.wait(50);
    pos.GoTo(nv2(1),nv2(2));
    pos.wait(100);
end
%ImageScan(pos,-1,-1,2,2,n,n,0.01);
pos.GoTo(0,0);
tic;
[x,y,t]=pos.getCompiledPathVectors();
compt=toc;
disp(['Procedure compliation time: ',num2str(compt)]);
subplot(plotn,1,1);
plot(t,x,t,y);
% subplot(plotn,1,3);
% % [mt,mdwell]=dcol.getMesaurementParams();
% % plot(mt,mdwell);

%% Reader tester
strm=[];
if(newobjs)
    subplot(plotn,1,2);
%     counter.addlistener('DataReady',...
%         @(s,e)strm(end+1:end+length(e.TimeStamps),:)=[e.TimeStamps,e.Data-e.Data(1)]);
    %dcol.addlistener('TimebinComplete',@(s,e)RowScanToImageData(dcol.Results,n,n,dwellTime));
end

%% preapre.
%subplot(plotn,1,2);
pos.prepare();
clock.prepare();
counter.prepare();
%trigger.prepare();
dcol.prepare();
 
disp('Prepared');

%% run
disp('Running procedures');
counter.run();
pos.run();

% running the trigger.
disp('Starting clock...');
%trigger.run();
clock.run();

disp('Data collection...');
pause(pos.totalExecutionTime/1000);

disp('Stopping..');
counter.stop();
clock.stop();
pos.stop();

disp('Complete');

%% collecting results.
tic;
disp(['finalizing pending,#',num2str(dcol.getRawPendingTickCount())]);
dcol.finalizePending();
compt=toc;
disp(['Pon distructive comparsion: ',num2str(compt)]);

tic;
img=RowScanToImageData(dcol.Results,n,n,dwellTime,1);
comp=toc;
disp(['DataImage calculated in: ',num2str(comp)]);

subplot(plotn,1,2);
imagesc(img);
disp(sum(img(:)));
disp('Complete');

