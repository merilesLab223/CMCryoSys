% Test_SignalGenerator

%% CONFIGURE AGILENT SIGNAL GENERATOR
disp('Configuring SG...');

% put your IP address and port here
SG = AgilentSignalGenerator('tcpip','172.16.1.184',7777);

SG.reset();
SG.setModulationOff();

SG.Frequency = 2.87e9; % Hz
SG.Amplitude = -15; % dBm
SG.SweepStart = 2.67e9;
SG.SweepStop = 3.07e9;
SG.SweepMode = 'STEP';
SG.SweepPoints = NumberOfPoints;
SG.SweepTrigger = 'IMM';
SG.SweepPointTrigger = 'EXT';
SG.SweepDirection = 'UP';
SG.RFState = 0;


% set all
SG.open();

SG.setFrequency();
SG.setAmplitude();
SG.setSweepStart();
SG.setSweepStop();
SG.setSweepPoints();
SG.setSweepMode();
SG.setSweepTrigger();
SG.setSweepPointTrigger();
SG.setSweepDirection();
SG.setSweepContinuous();
SG.setRFOff();


SG.close();


%%