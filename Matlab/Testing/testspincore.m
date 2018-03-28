%% Spincore api.
if(~exist('ttl','var'))
    ttl=SpinCoreTTLGenerator;
    ttl.configure();
end
ttl.IsContinues=false;
ttl.clear();
ttl.Pulse(0.01,0.01);
ttl.setClockRate(100e6);
ttl.Down(100);
ttl.PulseTrain(10,10,5);
ttl.Down(100);
ttl.PulseTrain(3,10,5);
%% Prepare and run.
ttl.prepare();
ttl.run();