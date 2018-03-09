<matlab>
figure;
hAxes = axes;
SWP = handles.expparams.sweeps(1);
x = SWP.sweepArray;
y = handles.Counter.AveragedData;                   
plot(x,y,'.-','Parent',hAxes);
title('Hahn Echo.');
xlabel('Echo Pulse Spacing (s)');
ylabel('Counts');
figure;
hAxes = axes;
s = (y(:,3)-y(:,2))./(y(:,1)-y(:,2));               
plot(x,s,'.-','Parent',hAxes);
title('Referenced Hahn Echo.');
xlabel('Echo Pulse Spacing (s)');
ylabel('Counts');
</matlab>