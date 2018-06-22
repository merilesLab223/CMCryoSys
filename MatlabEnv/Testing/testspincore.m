%% Spincore api.
if(~exist('ttl','var'))
    ttl=SpinCoreTTLGenerator;
    ttl.configure();
end
ttl.Channel=1;
api=ttl.CoreAPI;
ttl.setClockRate(300e6);
ttl.IsContinues=false;
ttl.clear();
ttl.curT=0;

% long delay.
% ttl.Down(0);
% ttl.Up(100);
% ttl.Down(10);
ttl.Pulse(ones(5,1)*25,ones(5,1)*25);
ttl.ClockSignal(50,100);
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
[data,t]=ttl.getTTLVectors();
stairs(t,data);
ylim([0,1.2]);
%% Prepare and run.
disp('prepare...');
ttl.prepare();
disp('running...');
ttl.run();