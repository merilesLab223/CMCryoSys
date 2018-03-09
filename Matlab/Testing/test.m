%% Making the new procedure and devices.
if(~exist('pos','var'))
    NewProcedure;
    pos=NI6321Positioner2D('Dev1');
    reader=NI6321AnalogReader('Dev1');
    trigger=NI6321TTLGenerator('Dev1');
    
    devices.setDevice('positioner',pos);
    devices.setDevice('areader',reader);
    devices.setDevice('nitrigger',trigger);
    
    % setting the roles.
    devices.setRole('reader','areader');
    devices.setRole('position','positioner');
    devices.setRole('trigger','nitrigger');
end

% setting triggers.
pos.trigger='pfi10';
reader.trigger='pfi10';
trigger.ttlchan='port0/line1';

% configure the roles if needed.
devices.configureAllRoles();

reader.Rate=200000; % in hz.
pos.Rate=50000; % in hz.

s=pos.niSession;
%% adding trigger.
trigger.Clear();
trigger.Pulse();

%% Test positioner
n=50;
pos.clearPath();
pos.interpolationMethod='linear';
pos.ScanImage(-1,-1,2,2,n,n,0.1);
ranmps=0:0.01:1;
nv1=[0.8,0.3];
nv2=[-0.1,0.8];
for(i=1:4)
    pos.GoTo(nv1(1),nv1(2));
    pos.Hold(100);
    pos.GoTo(nv2(1),nv2(2));
    pos.Hold(150);
end
pos.ScanImage(-1,-1,2,2,n,n,0.1);
pos.GoTo(0,0);
[x,y,t]=pos.getPathVectors();
subplot(2,1,1);
plot(t,x,t,y);

%% Reader tester
subplot(2,1,2);
reader.addlistener('DataReady',@(s,e)plot(e.TimeStamps,e.Data));

%% Preparing & running last config.
pos.prepare();
reader.prepare();
trigger.prepare();
 
disp('Prepared');

disp('Running procedures');
reader.run();
pos.run();

% running the trigger.
disp('Triggering...');
trigger.run();
disp('Running');
pause(pos.totalExecutionTime/1000);
reader.Stop();

disp('Complete');
