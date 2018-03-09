function myInitScript(hObject,handles)


% init the signal generator
handles.SignalGenerator = AgilentSignalGenerator('tcpip','172.16.1.184',7777);
handles.SignalGenerator.reset();
handles.SignalGenerator.setModulationOff();


% init the pulse generator
handles.PulseGenerator = TekPulseGenerator()
