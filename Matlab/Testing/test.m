%% Making the new procedure and devices.
newobjs=0;
if(~exist('pos','var'))
    NewProcedure;
    
    pos=NI6321Positioner2D('Dev1');
    counter=NI6321Counter('Dev1');
    clock=NI6321Clock('Dev1');
    trigger=NI6321TTLGenerator('Dev1');
    
    % setting terminals and params.
    pos.xchan='ao0';
    pos.ychan='ao1';
    counter.ctrName='ctr0';
    counter.clockTerm='pfi14';
    clock.ctrName='ctr3';
    
    % hard connections.
    % port0/line1 ->USER1 ->PFI0 : Trigger.
    % pfi15->pfi14 : Clock loopback.
    % pfi8 (counter 0)->User2 : counter input)

    % setting trrigers.
    pos.triggerTerm='pfi0';
    %counter.triggerTerm='pfi0';
    clock.triggerTerm='pfi0';
    trigger.ttlchan='port0/line1';
    
    % setting rates (in hz);
    trigger.Rate=50000;
    counter.Rate=200000; 
    clock.Rate=50000;
    pos.Rate=50000;
    
    devices.setDevice('positioner',pos);
    devices.setDevice('counter',counter);
    devices.setDevice('nitrigger',trigger);
    devices.setDevice('niclock',clock);
    
    % setting the roles.
    devices.setRole('trigger','nitrigger');
    devices.setRole('reader','counter');
    devices.setRole('position','positioner');
    devices.setRole('clock','niclock');
    
    % data collector.
    dcol=TimedDataCollector(counter);
    
    newobjs=1;
end

% configure the roles if needed.
devices.configureAllRoles();
plotn=4;
s=pos.niSession;

%% testing trigger.
subplot(plotn,1,1);
trigger.clear();
trigger.Pulse(10,10);
trigger.Pulse(10,10);
[ttl,t]=trigger.getTimebaseTTLData();
plot(t,ttl);

%% Creating position info (and display).
n=100;
dcol.clear();
totalTime=5000;% in ms.
dwellTime=totalTime/(n*n);
pos.clear();
pos.interpolationMethod='linear';
tic;
[~,~,t]=ImageScan(pos,-1,-1,2,2,n,n,dwellTime);
compt=toc;
disp(['Scan procedure generation time: ',num2str(compt)]);
tic;
dcol.Measure(t,ones(1,length(t))*dwellTime);
compt=toc;
disp(['Measure procedure generation time: ',num2str(compt)]);

nv1=[0.8,0.3];
nv2=[-0.1,0.8];
for(i=1:2)
    pos.GoTo(nv1(1),nv1(2));
    pos.wait(500);
    pos.GoTo(nv2(1),nv2(2));
    pos.wait(1000);
end
%ImageScan(pos,-1,-1,2,2,n,n,0.01);
pos.GoTo(0,0);
tic;
[x,y,t]=pos.getCompiledPathVectors();
compt=toc;
disp(['Procedure compliation time: ',num2str(compt)]);
subplot(plotn,1,1);
plot(t,x,t,y);
subplot(plotn,1,3);
[mt,mdwell]=dcol.getMesaurementParams();
plot(mt,mdwell);

%% Reader tester
if(newobjs)
    counter.addlistener('DataReady',@(s,e)plot(e.TimeStamps,e.Data-e.Data(1)));
    %dcol.addlistener('TimebinComplete',@(s,e)disp(e));
end

%% preapre.
subplot(plotn,1,2);
pos.prepare();
clock.prepare();
counter.prepare();
trigger.prepare();
 
disp('Prepared');

%% run
disp('Running procedures');
counter.run();
clock.run();
pos.run();

% running the trigger.
disp('Triggering...');
trigger.run();

disp('Data collection...');
pause(pos.totalExecutionTime/1000);

disp('Stopping..');
counter.stop();
clock.stop();

disp('Complete');

%% collecting results.
subplot(plotn,1,3);
rslts=cell2mat(dcol.Results);
img=rslts(:,2);
img=reshape(img,n+1,n+1);
imagesc(img);
subplot(plotn,1,4);
plot(rslts(:,1),rslts(:,2));
disp(sum(rslts(:,2)));
% converting to 

