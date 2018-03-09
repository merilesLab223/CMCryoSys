<matlab>
figure;
hAxes = axes;
SWP = handles.expparams.sweeps(1);
x = SWP.sweepArray;
y = handles.Counter.AveragedData;                   
plot(x,y,'.-','Parent',hAxes);
title('Ramsey Fringes @4MHz off-resonance.');
xlabel('Ramsey Pulse Spacing (s)');
ylabel('Counts');
figure;
hAxes = axes;
s = (y(:,3)-y(:,2))./(y(:,1)-y(:,2));               
plot(x,s,'.-','Parent',hAxes);
title('Referenced Ramsey Fringes @4MHz off-resonance.');
xlabel('Ramsey Pulse Spacing (s)');
ylabel('Counts');
figure;
hAxes = axes;
[spec,freqs] = positiveFFT(s-mean(s),1/(x(2)-x(1)));
plot(freqs/1e6,abs(spec));
xlabel('Frequency (MHz)');
title('Ramsey Fringes Power Spectrum');
</matlab>