%% Spincore api.
if(~exist('ttl','var'))
    ttl=SpinCoreTTLGenerator;
    ttl.configure();
end
ttl.Channel=[0,1,2,3];
ttl.setClockRate(100e6);
ttl.IsContinues=false;
ttl.clear();

% %ttl.Pulse(0.01,0.01);
% ttl.Down(100);
% ttl.PulseTrain(10,5,5);
% ttl.Down(100);
% ttl.PulseTrain(3,5,5);
ttl.Up(100);
ttl.Down(100);
ttl.Up(50);
ttl.Down(50);
%% Prepare and run.
ttl.prepare();
ttl.run();