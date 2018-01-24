<matlab>
figure;
hAxes = axes;
x=linspace(handles.SignalGenerator.SweepStart,handles.SignalGenerator.SweepStop,handles.SignalGenerator.SweepPoints);
y = handles.Counter.AveragedData;                   
plot(x,y,'.-','Parent',hAxes);
title('CW ESR');
xlabel('Frequency (Hz)');
ylabel('Counts');
</matlab>