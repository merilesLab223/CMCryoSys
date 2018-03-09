% test arb. digital out

%%
% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%
% add Digital Line
ni = ni.addDIOLine('Dev1/port0/line0',0);

% add Clock Line
ni.addClockLine('Dev1/ctr1','/Dev1/PFI7');

% test output array
data = [];
for k=1:10,
    data = [data,ones(1,100*k),zeros(1,100*k)];
end

data = [ones(1,100),zeros(1,100),ones(1,200),zeros(1,100),ones(1,300),0];

ni.ClockRate = 1e3; %1MHz clock

% cast to uint8
data = uint8(data);

ni = ni.WriteDigitalIO('Dev1/port0/line0',1);
%%
ni = ni.WriteDigitalIO('Dev1/port0/line0',1);

ni.CreateTask('PulseTrain');
ni.ConfigureClockOut('PulseTrain',1,ni.ClockRate,.5);

ni.CreateTask('DigitalOut')
ni.ConfigureDigitalOut('DigitalOut',1,1,data,ni.ClockRate)

ni.StartTask('DigitalOut');
ni.StartTask('PulseTrain');

ni.WaitUntilTaskDone('DigitalOut');

ni.ClearTask('DigitalOut');
ni.ClearTask('PulseTrain');

ni = ni.WriteDigitalIO('Dev1/port0/line0',1);
