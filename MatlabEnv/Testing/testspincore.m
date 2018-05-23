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
ttl.Down(1);
ttl.Up(100);
ttl.Down(1);
%ttl.Pulse(0.01,0.01);
% ttl.Down(10);
% ttl.PulseTrain(4,5,5);
% ttl.Down(10);
% ttl.PulseTrain(4,5,5);
% ttl.Down(10);


% ttl.Down(1);
%ttl.MaxLoopLength=4;
%ttl.PulseTrain(100000,2e-5,2e-5);

% ttl.Down(1);

% mul=1e2;
% ttl.curT=10;
% fend=60*mul;
% fstart=fend/10;
% dur=10/fstart*1000;
% PulseSweep(ttl,dur,fstart,fend,0.5);

% ttl.Up(10);
% ttl.Down(10);
% ttl.Up(5);
% ttl.Down(5);
%% Plot what we have.
disp('Display sequence');
[data,t]=ttl.getTimebaseTTLData();
plot(t,data);
%% Prepare and run.
disp('prepare...');
ttl.prepare();
disp('running...');
ttl.run();