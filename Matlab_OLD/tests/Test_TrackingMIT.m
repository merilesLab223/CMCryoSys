% Test_TrackingMIT

% create a new tracker
Tracker = TrackerMIT();


% get handles to all the other hardware

%%%%%%%%%% IMAGE ACQUISITION %%%%%%%%%%%
[hIA] = findall(0,'Name','ImageAcquire');
handIA = guidata(hIA);
IA = handIA.ImageAcquisition;

%%%%%%%%%% PULSE GENERATOR %%%%%%%%%%%
PG = TekPulseGenerator('tcpip','172.16.1.183',4000);
PG.setClockRate(10e6);
PG.init();

%%%%%%%%%% COUNTER ACQUISITION %%%%%%%%%%%
 CA = CounterAcquisition();
 CA.interfaceNIDAQ = IA.interfaceNIDAQ;
 CA.DwellTime = 0.001;
 CA.NumberOfSamples = 500;
 CA.LoopsUntilTimeOut = 100;
 CA.CounterInLine = 1;
 CA.CounterOutLine = 1;

 
%%%%% CONFIGURE TRACKER %%%%%
Tracker.hCounterAcquisition = CA;
Tracker.hwLaserController = PG;
Tracker.hImageAcquisition = IA;
Tracker.InitialStepSize = [0.005,0.005,.002];
Tracker.StepReductionFactor = [.5,.5,.5];
Tracker.MinimumStepSize = [0.0005,0.0005,0.0001];
Tracker.TrackingThreshold = [1500];
Tracker.MaxIterations = [10];
Tracker.LaserControlLine = 2;
Tracker.InitialPosition = IA.CursorPosition;
Tracker.MaxCursorPosition = [0.5,0.5,2.0];
Tracker.MinCursorPosition = [-0.5,-0.5,0];

handles.Tracker = Tracker;


