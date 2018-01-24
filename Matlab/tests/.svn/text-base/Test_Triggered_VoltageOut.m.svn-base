% Test_Triggered_VoltageOut.m
%
% Test of  Triggered AO for NIDAQ_Driver object
%
% Jonathan Hodges <jhodges@mit.edu>
% 2 June 2009
%

%%
% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%

% add Clock Line
ni.addClockLine('Dev1/ctr1','/Dev1/PFI7');

% add AO lines
ni.addAOLine('Dev1/ao0',0);
ni.addAOLine('Dev1/ao1',0);

%%
% create a new task for Pulse Train
ni.CreateTask('PulseTrain');

%ConfigureClockOut(obj,TaskName,CounterOutLines,ClockFrequency,DutyCycle)
ni.ConfigureClockOut('PulseTrain',1,100,0.5);

% start the pulse train
ni.StartTask('PulseTrain');
%%
ni.CreateTask('VoltageOut');

Vx = linspace(-1,1,5000);
Vy = linspace(-1,1,5000);
Dwell = 100;

ni.ConfigureVoltageOut('VoltageOut',[1,2],[Vx,Vy],1/Dwell);
ni.StartTask('VoltageOut');
%%
ni.WaitUntilTaskDone('VoltageOut');


%%
ni.ClearTask('VoltageOut');
ni.ClearTask('PulseTrain'); 


