gate=SpinCoreTTLGenerator;
gate.ReduceTTLloops=false;
gate.Channel=[1,2];
totalRep=3;
dt=10;
bufferCleanupTime=dt;
crate=4/(dt*1e-3);
pw=dt/10;

crate=400;
bufferCleanupTime=22.5;
dt=20;
gate.clear();
% the cur T.

dtRequired=1;
if(totalRep>1)
    dtRequired=2;
end

% setting the total clock.
% loop required.
gate.curT=0;
% start buffer cleanup.
gate.ClockSignal(bufferCleanupTime,crate,1);
% measurement clock.
gate.ClockSignal(dt,crate,1);
gate.ClockSignal(dt,crate,1);
% end buffer cleanup.
gate.ClockSignal(bufferCleanupTime,crate,1);

% set the laser.
% back to zero.
gate.curT=0;
gate.wait(bufferCleanupTime);
gate.Pulse(dtRequired*dt,[],4);

%set the rf gate. (should be only within the range of the pulse /2
gate.curT=0;
gate.wait(bufferCleanupTime);
for i=1:dtRequired
    gate.wait(dt/4);
    gate.Pulse(dt/2,[],3);
    gate.wait(dt/4);
end

% adding the pulse.
gate.curT=0;
gate.wait(bufferCleanupTime);
gate.wait(dt);
gate.Pulse(pw/2,pw/2,2);

% setting the loop.
gate.curT=0;
gate.wait(bufferCleanupTime);
gate.wait(dt);
if(totalRep>1)
    gate.StartLoop(totalRep-1);
    gate.wait(dt);
    gate.EndLoop();
end

%%
[ttl,ti]=gate.getTTLVectors(false);

sttl=size(ttl);
for i=1:sttl(2)
    ttl(:,i)=ttl(:,i)+(i);
end

stairs(ti,ttl);




