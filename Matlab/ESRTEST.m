disp('Configuring NI...');
% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

%%
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%

ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI7');  

%% 
% add Clock Line
ni.addClockLine('/Dev2/ctr1','/Dev2/PFI0');

ni.ReadTimeout = 1000;
NSamples = 10000;
%%

ni.CreateTask('Counter');
uint32(ni.Tasks.get('Counter'))
            

ni.CreateTask('PulseTrain');

% note the off-by-one error of the counter
ni.ConfigurePulseWidthCounterIn('Counter',1,1,NSamples);

ni.ConfigureClockOut('PulseTrain',1,1e3,.5)

ni.StartTask('Counter');
ni.StartTask('PulseTrain');

%%
data = ni.ReadCounterBuffer('Counter',NSamples)

%%
ni.ClearTask('Counter');
ni.ClearTask('PulseTrain');



