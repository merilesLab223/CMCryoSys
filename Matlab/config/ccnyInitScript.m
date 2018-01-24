function [handles] = ccnyInitScript(handles)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the signal generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     handles.SignalGenerator = RohdeSchwarzSignalGenerator('tcpip','134.74.27.133',5025);
    handles.SignalGenerator = RohdeSchwarzSignalGenerator('tcpip','134.74.27.30',5025);
    %handles.SignalGenerator.reset();
    handles.SignalGenerator.setModulationOff();

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%         LibraryFile = 'C:\SpinCore\SpinAPI\dll\spinapi.dll';
%         HeaderFile = 'C:\SpinCore\SpinAPI\dll\spinapi.h';
%         LibraryName = 'pb';
%         handles.PulseGenerator = SpinCorePulseGenerator2();
%         
%         handles.PulseGenerator.Initialize(LibraryFile,HeaderFile,LibraryName);
% 
%         % set PG clock rate to 1MHz
%         % for SpinCore, clock rate is in units of MHZ
%         handles.PulseGenerator.setClockRate(3e8);


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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init a counter for tracking (same hardware, different software object)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         handles.TrackCounter = CounterAcquisition();
%         handles.TrackCounter.interfaceNIDAQ = handles.Counter.hwHandle;
%         handles.TrackCounter.DwellTime = 0.005;
%         handles.TrackCounter.NumberOfSamples = 100;
%         handles.TrackCounter.LoopsUntilTimeOut = 100;
%         handles.TrackCounter.CounterInLine = 1;
%         handles.TrackCounter.CounterOutLine = 1;


%% LOOK FOR ImageAcquire
apps = getappdata(0);
fN = fieldnames(apps);
k=12;%fN's 12 element is always image acquire as of 3/2/2017 at 4:21PM, This may change in the future, uncomment the for loop and check fN in the future.
%for k=1:numel(fN),
    if ishandle(getfield(apps,fN{k})) %&& isa(getfield(apps,fN{k}),'double'), second requirement commented out to work with new matlab
        name = get(getfield(apps,fN{k}),'Name');
        if strcmp('ImageAcquire',name),
            hFig = getfield(apps,fN{k});
            IAHandles = guidata(hFig);
            handles.hImageAcquisition = IAHandles.ImageAcquisition;
            handles.PulseGenerator = IAHandles.Tracker.hwLaserController;
            handles.Tracker = IAHandles.Tracker;
            C = get(IAHandles.imageAxes,'Children');
            copyobj(C,handles.axesConfocal);
            %colormap(handles.axesConfocal,'bone');
            colormap(handles.axesConfocal,'jet');
            colorbar('peer',handles.axesConfocal);
            axis(handles.axesConfocal,'square');
            %break; commententd out to fix crash, inplace so you can close
            %and restart NVCC in the same matlab session
        end
    end
%end

if isfield(handles,'hImageAcquisition'),
   set(handles.textCurPosX,'String',sprintf('X = %.4f',handles.hImageAcquisition.CursorPosition(1)));
  set(handles.textCurPosY,'String',sprintf('Y = %.4f',handles.hImageAcquisition.CursorPosition(2)));
 set(handles.textCurPosZ,'String',sprintf('Z = %.4f',handles.hImageAcquisition.CursorPosition(3)));

end

%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% configure the tracking algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PG = handles.PulseGenerator;

%%%%% CONFIGURE TRACKER %%%%%
% Tracker = TrackerCCNY();
% Tracker.hCounterAcquisition = handles.TrackCounter;
% Tracker.hwLaserController = handles.PulseGenerator;
% Tracker.hImageAcquisition = handles.hImageAcquisition;
% Tracker.InitialStepSize = [0.005,0.005];
% Tracker.StepReductionFactor = [.5,.5];
% Tracker.MinimumStepSize = [0.0005,0.0005];
% Tracker.TrackingThreshold = [1500];
% Tracker.MaxIterations = [10];
% Tracker.LaserControlLine = 1; % AOM is line 1
% Tracker.InitialPosition = handles.hImageAcquisition.CursorPosition;
% Tracker.MaxCursorPosition = [5,5];
% Tracker.MinCursorPosition = [-5,-5];
% 
% handles.Tracker = Tracker;

%%
% fix the path
addpath([pwd,'\','Sequences\']);

% add in hack for spin noise measurements
handles.options.spinNoiseAvg = 1; % turn on spin noise averaging;
%handles.options.SpinNoiseDataFolder = 'C:\Users\cmeriles\Desktop\NV Software (working)\wittelsbach control software 75 + phase\exp_data\Spin Noise data';
handles.options.SpinNoiseDataFolder = 'C:\Users\MerilesLab3\Desktop\NV Software (working)\wittelsbach control software 75 + phase\exp_data\Spin Noise data';
