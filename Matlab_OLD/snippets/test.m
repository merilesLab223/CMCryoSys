<matlab>
figure;
hAxes = axes;
SWP = handles.expparams.sweeps(1);
x = SWP.sweepArray;
y = handles.Counter.AveragedData;                   
plot(x,y,'.-','Parent',hAxes);
title('Microwave Pulse Delay');
xlabel('Pulse Delay');
ylabel('Counts');
</matlab>
