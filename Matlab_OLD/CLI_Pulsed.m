%%% CLI_Pulsed
% jhodges
% 2009-09-04
%%
% A bootstrapping way to run experiments before we add the fancy GUI
function [AllData] = CLI_Pulsed(varargin)

%% MAIN LOGIC OF THE FUNCTION
% 0.  Define variables for Experiment
% 1.  Setup the SG
% 2.  Setup the PulseSequence object
% 3.  Setup the AWG
% 4.  Setup the data structure
% 5.  Setup the NI
% 6.  Enter the main loop
%     a.  Parse the pulse sequence
%     b.  Communicate with AWG
%     c.  Start NI Task
%     d.  Software Trigger AWG
%     e.  Readout data
%     f.  Process data
%     g.  Plot data
%     h.  iterate loop
% 7.  Closeup all connections

%% 0.  Define Variables
Pulsed.NumberOfSamples = 50e3;
Pulsed.ClockRate = 100e6; 

%% 1.  Setup SG
disp('Configuring SG...');

SG = AgilentSignalGenerator('tcpip','172.16.1.184',7777);

SG.reset();
SG.setModulationOff();

SG.Frequency = 2.87e9; % Hz
SG.Amplitude = -10; % dBm
SG.FrequencyMode = 'CW';
%SG.SweepStart = 2.77e9;
%SG.SweepStop = 2.97e9;
%SG.SweepMode = 'STEP';
%SG.SweepPoints = 0;
%SG.SweepTrigger = 'IMM';
%SG.SweepPointTrigger = 'EXT';
%SG.SweepDirection = 'UP';
SG.RFState = 0;


% set all
SG.open();

SG.setFrequency();
SG.setAmplitude();
SG.setFrequencyMode();
SG.setRFOn();


SG.close();

%% 2.  Setup PulseSequence Object

% for now, just load in a saved object
Q = load('savedpseq.mat');
PSeq = Q.PSeq;

%% 3.  Setup AWG

        V = TekAWGController('tcpip','172.16.1.183',4000);

        %open the socket
        V.open();

        % reset the device
        V.reset();

        % set marker voltage high/low
        % CH1: MK1
        V.setmarker(1,1,0,2.7);
        % CH1: MK2
        V.setmarker(1,2,0,2.7);
        % CH2: MK1
        V.setmarker(2,1,0,2.7);
        % CH2: MK2
        V.setmarker(2,2,0,2.7);

        % set clock freq of AWG
        V.setSourceFrequency(Pulsed.ClockRate);
              
        % set to sequence mode
        V.sendstr('AWGCONTROL:RMODE SEQUENCE');
               
        V.close();
        
        % wait until the device settles
        pause(2);
        
%% 4. Setup Data Structures
        
        AllData.mean = zeros(PSeq.getSweepIndexMax);
        AllData.std = zeros(PSeq.getSweepIndexMax);
        
        
%% 5. Setup NI

       
        % configure NIDAQ Driver Instance
        LibraryName = 'nidaqmx';
        LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
        HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
        ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
        
        
        % add a counter and clock for raw counting of a center
        ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI0');
        ni.addClockLine('Dev2/ctr1','/Dev2/PFI7');

        % add a counter and and external clockline for pulsed counting
        ni.addClockLine('Ext','/Dev2/PFI0');
        ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI7');  

        ni.ReadTimeout = 100;
  
        ni.CreateTask('Counter');
        % display the task
        uint32(ni.Tasks.get('Counter'))
        
        ClockLine = 2;
        CounterLine = 2;
        % note the off-by-one error of the counter
        ni.ConfigurePulseWidthCounterIn('Counter',CounterLine,ClockLine,Pulsed.NumberOfSamples);
            

        
%% 6. MAIN LOOP

while PSeq.getSweepIndex,
    %% 6.a & b Parse Sequence & Communicate with AWG
  
    [tempPSeq] = SendSequenceToAWG(V,PSeq,Pulssed.ClockRate,Pulsed.NumberOfSamples)

    %% 6.c Start NI Tasks
    
        ni.StartTask('Counter');
        
    %% 6.d Software Trigger AWG
        % HIT THE AWG;
        V.open();
        V.start();
        V.close();
            
    %% 6.e Wait for Task to Finish and readout data
        ni.WaitUntilTaskDone('Counter');
        
        data = ni.ReadCounterBuffer('Counter',Pulsed.NumberOfSamples)+data;
            
        ni.StopTask('Counter');
    %% 6.f Process the data
        ind = PSeq.getSweepIndex();
        AllData.mean(ind) = mean(data);
        AllData.std(ind) = std(data);
        
    %% 6.g Plot the data
    
    %% 6.h Iterate the loop
        PSeq.incrementSweepIndex();
end

%% 7.  Clean up
        
