% Test_Counting_Clocking.m
%
% Test of Counting, Clocking and Triggered AO for NIDAQ_Driver object
%
% Jonathan Hodges <jhodges@mit.edu>
% 6 May 2009
%

%%
% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%
% add Counter Line
ni.addCounterInLine('Dev1/ctr0','/Dev1/PFI0');

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
ni.CreateTask('Counter');


ni.ConfigureCounterIn('Counter',1,100);

ni.StartTask('Counter');

%%
ni.WaitUntilTaskDone('Counter');

C=ni.ReadCounterBuffer('Counter',100);

%%
ni.ClearTask('Counter');
ni.ClearTask('PulseTrain'); 
