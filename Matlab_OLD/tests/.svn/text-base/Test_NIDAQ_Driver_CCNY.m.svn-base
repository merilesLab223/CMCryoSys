% NIDAQ_Driver Test Suite for CCNY
% jhodges@mit.edu

%%
% Setup Library's and Paths
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

%%
% create the object
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%
% add Counter Line
ni.addCounterInLine('Dev1/ctr0','/Dev1/PFI0');

% add Clock Line
ni.addClockLine('Dev1/ctr1','/Dev1/PFI7');

% add AO lines
ni.addAOLine('Dev1/ao0',0);
ni.addAOLine('Dev1/ao1',0);

% Write the AO, set to 0
ni.WriteAnalogOutAllLines;


%% TEST FOR COUNTER
% Create a Counter object and point it to the NI object
Counter = CounterAcquisition();
Counter.interfaceNIDAQ = ni;
Counter.DwellTime = 0.005;
Counter.NumberOfSamples = 100;
Counter.LoopsUntilTimeOut = 100;
ViewCounterAcquisition(Counter);


return;

% code for debugging tasks
[a,b,taskhand] = calllib('nidaqmx','DAQmxCreateTask','foo',1);
[a] = calllib('nidaqmx','DAQmxClearTask',taskhand);
[a,b] = calllib('nidaqmx','DAQmxGetTaskComplete',taskhand,[]);