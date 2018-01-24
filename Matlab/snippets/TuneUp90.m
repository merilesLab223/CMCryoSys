<matlab>
figure;
hAxes = axes;
SWP = handles.expparams.sweeps(1);
x = SWP.sweepArray;
y = handles.Counter.AveragedData;
plot(hAxes,x,y,'.-');
title('Tune-Up 90 32ns @0dBm');
xlabel('Number of 90s');
ylabel('Counts');
figure;
hAxes = axes;
s = (y(:,3)-y(:,2))./(y(:,1)-y(:,2));
plot(hAxes,x,s,'*');
hold on;
plot(hAxes,x(2:2:end),s(2:2:end),'r');
title('Referenced Tune-Up 90');
xlabel('Number of 90s');
ylabel('Counts');
</matlab>
