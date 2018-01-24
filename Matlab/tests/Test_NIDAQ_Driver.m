% NIDAQ_Driver Test Suite

LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);

ni = ni.addDIOLine('Dev1/PFI0',0);


ni = ni.addDIOLine('Dev1/PFI1',0);
ni.UpdateDigitalIO_All();

ni = ni.addAOLine('Dev1/ao0',1);
ni.WriteAnalogOutLine(1);


return;

% code for debugging tasks


[a,b,taskhand] = calllib('nidaqmx','DAQmxCreateTask','foo',1);
taskhand
[a] = calllib('nidaqmx','DAQmxClearTask',taskhand);
[a,b] = calllib('nidaqmx','DAQmxGetTaskComplete',taskhand,[]);