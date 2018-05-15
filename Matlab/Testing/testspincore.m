%% Spincore api.
if(~exist('ttl','var'))
    ttl=SpinCoreTTLGenerator;
    ttl.configure();
end
ttl.Channel=[0,1,2,3];
api=ttl.CoreAPI;
ttl.setClockRate(300e6);
ttl.IsContinues=false;
ttl.clear();

% long delay.
crate=1000;
ut=1./(2*crate*ttl.timeUnitsToSecond);
totalTime=200000;
n=floor(totalTime*2/ut);
ttl.PulseTrain(n,ut,ut);
disp(['Total execution time: ',num2str(totalTime)]);
%% Plot what we have.
% disp('Display sequence');
% [data,t]=ttl.getTimebaseTTLData();
% plot(t,data);
%% Prepare and run.
disp('prepare...');
ttl.prepare();
disp('running...');
ttl.run();