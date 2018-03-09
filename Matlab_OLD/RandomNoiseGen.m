%%%% CONFIG PORTS

PULSE_OUTPUT = '/Dev1/ctr0';

TRIG_INPUT = '/Dev1/PFI5';



% function to test COPulseTime functions

%% init the NI Driver
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     THIS IS DIFFERENT   %%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';


% create daq driver
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);

%% create a new task
ni.CreateTask('randpulse');


%% Create CouterOut Pulse Channel, Time specified
args = {};
args{1} = ni.Tasks.get('randpulse'); % TaskHandle
args{2} = PULSE_OUTPUT; % output channel
args{3} = []; % name -> null
args{4} = ni.DAQmx_Val_Seconds; %units = seconds
args{5} = ni.DAQmx_Val_Low; % idle state
args{6} = 200e-6; % initial delay
args{7} = 10e-6; % 10us low
args{8} = 100e-6; % 100us high
ni.LibraryFunction('DAQmxCreateCOPulseChanTime',args);



%% Hook up a rising edge trigger
args = {};
args{1} = ni.Tasks.get('randpulse'); %TaskHandle
args{2} = TRIG_INPUT; % look for trigger pulse on PFI0
args{3} = ni.DAQmx_Val_Rising; % rising edge trigger

ni.LibraryFunction('DAQmxCfgDigEdgeStartTrig',args);

%% Configure Single Shot, Implicit Timing
args = {};
args{1} = ni.Tasks.get('randpulse'); % TaskHandle
args{2} = ni.DAQmx_Val_FiniteSamps; % finite number of samples
args{3} = 1; % single sample
ni.LibraryFunction('DAQmxCfgImplicitTiming',args);


%% now, loop through an array
lows = ones(6,1)*1e-3;
highs = [1 2 3 4 5 6] * 1e-3;

ni.ReadTimeout = 60; % 60s for WaitUntiltaskDone
%%% loop through the high/low values you want to output

for k=1:length(lows),
            
            %% WRITE the Low time to the task
            args = {};
            args{1} = ni.Tasks.get('randpulse'); % TaskHandle
            args{2} = PULSE_OUTPUT;
            args{3} = lows(k); % single sample
            ni.LibraryFunction('DAQmxSetCOPulseLowTime',args);
            
            %% WRITE the high time to the task
            args = {};
            args{1} = ni.Tasks.get('randpulse'); % TaskHandle
            args{2} = PULSE_OUTPUT;
            args{3} = highs(k); % single sample
            ni.LibraryFunction('DAQmxSetCOPulseHighTime',args);
            
            %% Start the task
            ni.StartTask('randpulse');

            %% wait until you get a pulse from the PB
            ni.WaitUntilTaskDone('randpulse');

            %% Stop the Task
            ni.StopTask('randpulse');
               
end
%Clear
ni.ClearTask('randpulse');

