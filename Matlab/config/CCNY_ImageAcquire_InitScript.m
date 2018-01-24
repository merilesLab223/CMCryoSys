
function [handles] = CCNY_ImageAcquire_InitScript(handles)

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the signal generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   handles.SignalGenerator = RohdeSchwarzSignalGenerator('tcpip','134.74.27.133',5025);
    handles.SignalGenerator = RohdeSchwarzSignalGenerator('tcpip','134.74.27.30',5025);
    %handles.SignalGenerator.reset();
    handles.SignalGenerator.setModulationOff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP NI              %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%


        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        %HeaderFilePath = 'C:\Users\cmeriles\Desktop\NV Software (working)\wittelsbach control software 75 + phase\config\NIDAQmx.h';
        HeaderFilePath = 'C:\Users\MerilesLab3\Desktop\NV Software (working)\wittelsbach control software 75 + phase\config\NIDAQmx.h';
        ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
        %handles.Counter = NICounter(LibraryName,LibraryFilePath,HeaderFilePath);
        %%
        
        % add Counter Line
        ni.addCounterInLine('Dev1/ctr0','/Dev1/PFI0',1);
        % add Counter Line
        %ni.addCounterInLine('Dev1/ctr1','/Dev1/PFI13',2); 
        % add Clock Line
        ni.addClockLine('Dev1/ctr1','/Dev1/PFI13');
        % add Clock Line
        %ni.addClockLine('Ext','/Dev1/PFI0');
        
        
        %ni.ReadTimeout = 1;

        % add AO lines
        ni.addAOLine('Dev1/ao0',0);
        ni.addAOLine('Dev1/ao1',0);

        % Write the AO
        ni.WriteAnalogOutAllLines;

        
        % send to the handles structure
        handles.NI = ni;
        %handles.Counter.hwHandle = ni;
        %handles.Counter.CounterInLine = 2;
        %handles.Counter.CounterClockLine = 2;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init a fast counter for pulsing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        %HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
        HeaderFilePath = 'C:\Program Files (x86)\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

        %%

        handles.Counter = NICounter(LibraryName,LibraryFilePath,HeaderFilePath);

        %%
        %Sets up NI counters
        handles.Counter.hwHandle.addCounterInLine('Dev1/ctr0','/Dev1/PFI0',1);
        % add Counter Line
        handles.Counter.hwHandle.addCounterInLine('Dev1/ctr1','/Dev1/PFI13',2);  

        % add Clock Line
        handles.Counter.hwHandle.addClockLine('Dev1/ctr1','/Dev1/PFI13');
        % add Clock Line
        handles.Counter.hwHandle.addClockLine('Ext','/Dev1/PFI0');
        
        handles.Counter.CounterInLine = 2;
        handles.Counter.CounterClockLine = 2;
        
        % change the readtime to 1s;
        handles.Counter.hwHandle.ReadTimeout = 1;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SETUP ImageAcqusition HANDLES             %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % hookup the NI to the IA
        handles.ImageAcquisition.interfaceNIDAQ = handles.NI;
        %handles.ImageAcquisition.interfaceAPT = [];
        handles.ImageAcquisition.ZController = 'none';

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP CounterAcquisition %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% init Counter
handles.CounterAcquisition = CounterAcquisition();
handles.CounterAcquisition.interfaceNIDAQ = handles.NI;
handles.CounterAcquisition.DwellTime = 0.005;
handles.CounterAcquisition.NumberOfSamples = 10;
handles.CounterAcquisition.LoopsUntilTimeOut = 10000;
handles.CounterAcquisition.CounterInLine = 1;
handles.CounterAcquisition.CounterOutLine = 1;


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETUP Tracking                %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% PULSE GENERATOR %%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%         LibraryFile = 'C:\SpinCore\SpinAPI\dll\spinapi.dll';
%         HeaderFile = 'C:\SpinCore\SpinAPI\dll\spinapi.h';
        LibraryFile = 'C:\SpinCore\SpinAPI\lib\spinapi64.dll';
        HeaderFile = 'C:\SpinCore\SpinAPI\include\spinapi.h';
        LibraryName = 'pb';
        PG = SpinCorePulseGenerator2();
        
        PG.Initialize(LibraryFile,HeaderFile,LibraryName);

        % set PG clock rate to 1MHz
        % for SpinCore, clock rate is in units of MHZ
        PG.setClockRate(3e8);
        
        % init the pg
        PG.init();
 
%%%%% CONFIGURE TRACKER %%%%%
Tracker = TrackerCCNY();
Tracker.hCounterAcquisition = handles.CounterAcquisition;
Tracker.hwLaserController = PG;
Tracker.hImageAcquisition = handles.ImageAcquisition;
Tracker.InitialStepSize = [0.002,0.002];
Tracker.StepReductionFactor = [.2,.2];
Tracker.MinimumStepSize = [0.0002,0.0002];
Tracker.TrackingThreshold = [1500];
Tracker.MaxIterations = [10];
Tracker.LaserControlLine = 1; % AOM is line 1 
Tracker.InitialPosition = handles.ImageAcquisition.CursorPosition;
Tracker.MaxCursorPosition = [5,5];
Tracker.MinCursorPosition = [-5,-5];

handles.Tracker = Tracker;



