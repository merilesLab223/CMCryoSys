%% Spincore api.
if(~exist('ttl','var'))
    ttl=SpinCoreTTLGenerator;
end
ttl.setClockRate(100e6);
ttl.Down(100);
ttl.PulseTrain(10,100,100);
%% Prepare and run.
ttl.prepare();
ttl.run();