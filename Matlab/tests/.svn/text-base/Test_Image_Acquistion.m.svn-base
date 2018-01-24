% Test Image Acquistion

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

% Write the AO
ni.WriteAnalogOutAllLines;

%% APT Controller

apt = AptController();

apt.Initialize();

%%

% Create a new scan object

S = ConfocalScan();

S.MinValues = [-0.5 -0.5 0];
S.MaxValues = [0.5 0.5 0];
S.NumPoints = [200 200 1];
S.OffsetValues = [0.100,0.270,0];

% configure the Scan
%ConfigureScan(S);

%% 
% Create a new ImageAcquistion

IA = ImageAcquisition();

IA.CurrentScan = S;
IA.interfaceNIDAQ = ni;
%IA.interfaceAPT = apt;


%%
IA.SetPulseTrain();
IA.SetCounter2D();
IA.SetScan2D();

%%
im = myImage();
im.iaInstance = IA;
im.init();
%%
IA.StartScan2D();


a = ni.IsTaskDone('Counter');
while ~a,
    
    IA.StreamCounterSamples();
    a = ni.IsTaskDone('Counter');
    drawnow();
end
% after the task finishes, clear out the last of the data
IA.StreamCounterSamples();
%%
IA.ReadCounter();

%%
IA.ClearScan2D();

%%
IA.ZeroScan2D();


%% counter
C = CounterAcquisition();
C.interfaceNIDAQ = ni;
C.DwellTime = 0.01;
C.NumberOfSamples = 100;
C.SetPulseTrain();
C.SetCounter2D();
C.GetCountsPerSecond();
C.CountsPerSecond

%% 
%% counter
C = CounterAcquisition();
C.interfaceNIDAQ = ni;
C.DwellTime = 0.01;
C.NumberOfSamples = 100;


V = ViewCounterAcquisition(C);

%%
f = figure('Visible','on','Position',[20,40,200,75],'MenuBar','none','Toolbar','none');
hText = uicontrol('Style','text','String','0',...
         'FontSize',30,'Position',[10,15,190,50]);
      align(hText,'Center','Middle');
      
for k=1:20,
    C.GetCountsPerSecond();
    set(hText,'String',num2str(round(C.CountsPerSecond)));
end

      
