%% Tesing timed data stream.
ds=TimedDataStream;
n=1000000;
data=ones(n,1);
t=[1:n]';
tic;
ds.SetTimedData(t,data,1);
disp(['Set timed data[ms]: ',num2str(toc())]);
t=t+0.1;
tic;
ds.SetTimedData(t,data,2);
disp(['Set timed data[ms]: ',num2str(toc())]);
t=t+0.1;
data=rand(n,1);
tic;
ds.SetTimedData(t,data,3);
disp(['Set timed data[ms]: ',num2str(toc())]);
% overriding the first vector locations.
data=rand(n,1);
tic;
ds.SetTimedData(t,data,1);
disp(['Set timed data[ms]: ',num2str(toc())]);

ds.SetTimedEvent(0,'ev1');
ds.SetTimedEvent(n/2,'ev2');
ds.SetTimedEvent(n+1,'ev3');

tic;
[t,strm]=ds.getTimedStream();
disp(['Get Stream[ms]: ',num2str(toc())]);

tic;
[t,strm]=ds.getTimedStream();
disp(['Get Stream[ms]: ',num2str(toc())]);
