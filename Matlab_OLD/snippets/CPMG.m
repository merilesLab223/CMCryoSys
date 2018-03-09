<matlab>
figure;
hAxes = axes;
SWP = handles.expparams.sweeps(1);
x = SWP.sweepArray;
loopTime = 2540e-9;
y = handles.Counter.AveragedData;                   
plot(x*loopTime,y,'.-','Parent',hAxes);
title('CPMG Pulse Train.');
xlabel('Total Time');
ylabel('Counts');
figure;
hAxes = axes;
s = (y(:,3)-y(:,2))./(y(:,1)-y(:,2));                
plot(x*loopTime,s,'.-','Parent',hAxes);
title('Referenced CPMG Train.');
xlabel('Total Time');
ylabel('Counts');
</matlab>