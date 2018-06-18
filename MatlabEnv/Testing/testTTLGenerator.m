gate=SpinCoreTTLGenerator;
gate.ReduceTTLloops=false;
gate.Channel=[1,2];
totalRep=3;
durs=ones(n,1)*5;
dt=10;
bufferCleanupTime=dt;
crate=4/(dt*1e-3);
pw=dt/10;

crate=400;
bufferCleanupTime=22.5;
dt=20;
gate.clear();
% the cur T.
gate.curT=0;

% first loop is without a pulse.
gate.ClockSignal(bufferCleanupTime,crate,1);
gate.ClockSignal(dt,crate,1);

% now loop de loop.
if(totalRep-1>0)
    loopt=gate.StartLoop(totalRep-1);

    % sequence.
    gate.curT=loopt;
    gate.Pulse(dt/5,2);
    gate.curT=loopt;
    gate.ClockSignal(dt,crate,1);
    % go to the right time.
    gate.curT=loopt;
    gate.wait(dt);
    % stop the external loop.
    gate.EndLoop();
end

curT=gate.curT;
% reset the clock
gate.Pulse(dt/5,2);
%cleanup.
gate.curT=curT;
gate.ClockSignal(dt*2,crate,1);

%%
[ttl,ti]=gate.getTTLVectors(true);
ttl(:,2)=ttl(:,2)+1.1;
stairs(ti,ttl);
ylim([0,2]);