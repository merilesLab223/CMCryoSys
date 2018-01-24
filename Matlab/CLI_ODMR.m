
% CLI ODMR
function [] = CLI_ODMR()
global stopit;

%% GLOBALS
NumberOfPoints = 301;
NS = 100;
stopit = 0;

%% CONFIGURE AWG PULSES

        disp('Configuring AWG...');

        PTS = 2e6;
        V = TekAWGController('tcpip','172.16.1.183',4000);

        % create null shape
        Shape = ones(PTS,1);
        Marker1 = zeros(PTS,1);
        Marker2 = zeros(PTS,1);

        % add some structure to the markers
        %
        % Actual pulse sequence for ODMR
        Marker1(1:1000)= 1;  % pulse for triggering source
        Marker2((PTS/2):end-1) = 1; % pulse for triggering counter buffer 1
        Marker2(end)=0;
        
        % NOTE when the sequence is finished, it writes the last Marker
        % Value to the default state of the line (e.g. High or Low).  Thus,
        % we must make sure to have the last points LOW.

        %open the socket
        V.open();

        % reset the device
        V.reset();

        % load the waveform
        V.create_waveform('ODMR',Shape,Marker1,Marker2)

        % set marker voltage high/low
        % CH1: MK1
        V.setmarker(1,1,0,2.7);
        % CH1: MK2
        V.setmarker(1,2,0,2.7);

        % set clock freq of AWG
        V.setSourceFrequency(1e7);
        
        % assign waveform to channel 1
        V.setSourceWaveForm(1,'ODMR');

        % turn on the output to channel 1
        V.setSourceOutput(1,1);
        
        % Make a Sequence
        V.initialize_sequence(1);
        
        % assign sequence waveform names
        waveforms{1} = 'ODMR';
        
        V.set_segment(1,waveforms,NumberOfPoints,[],[]);
        
        % set to sequence mode
        V.sendstr('AWGCONTROL:RMODE SEQUENCE');
               
        V.close();
        
        % wait until the device settles
        pause(2);
        
%% CONFIGURE AGILENT SIGNAL GENERATOR
disp('Configuring SG...');

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

disp('Configuring NI...');
% configure NIDAQ Driver Instance
LibraryName = 'nidaqmx';
LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

%%
ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
%%

ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI0');
% add Counter Line
ni.addCounterInLine('Dev2/ctr0','/Dev2/PFI7');  

% add Clock Line
ni.addClockLine('Dev2/ctr1','/Dev2/PFI7');

%% 
% add Clock Line
ni.addClockLine('Ext','/Dev2/PFI0');

ni.ReadTimeout = 100;


%% NB!
% For regular counting, the SOURCE (i.e. edges you want to count) goes to
% PFI0 and the clock (triggering writing counts to buffer) goes to PFI7
%
% For PulseWidth mode, the SOURCE is the pulse whose width you are trying
% to measure.  This is actually the gating pulse and should be on PFI7.
% The Clock is the aperiodic pulsing by the APD and is thus PFI0


%% set the sampling rate of the clock
ni.ClockRate = 80e6; %probably not kosher


NSamples = NumberOfPoints;
data = zeros(1,NSamples);
data = uint32(data);


Scrn = get(0,'ScreenSize');
winH = 300;
winW = 500;
borderX = 10;
borderY = 25;
hFig = figure('Position',[borderX, Scrn(4)-borderY-winH,winW,winH],'MenuBar','figure','Toolbar','figure');
hAxes = axes('Position',[.1 .2 .88 .65]);
uicontrol(hFig,'Style','pushbutton','Position',[10 10 70 20],'String','Stop','callback',{@stop});
x = linspace(SG.SweepStart,SG.SweepStop,SG.SweepPoints);


hFig2 = figure('Position',[borderX, Scrn(4)-borderY-winH-400,winW,winH],'MenuBar','none','Toolbar','none');
hAxes2 = axes('Position',[.1 .2 .88 .65]);

%%


CounterInLine = 2;
NSamples = NumberOfPoints;

Ref = [];



disp('Running ESR...');

%% setup counter

Counter = CounterAcquisition();
Counter.interfaceNIDAQ = ni;
Counter.DwellTime = 0.05;
Counter.NumberOfSamples = 100;
Counter.LoopsUntilTimeOut = 100;
Counter.CounterInLine = 1;
Counter.CounterOutLine = 1;
for k=1:NS,
%% create a task

            Counter.GetCountsPerSecond();
            Ref = [Ref,Counter.CountsPerSecond];

            ni.CreateTask('Counter');
            uint32(ni.Tasks.get('Counter'))
            
            % note the off-by-one error of the counter
            ni.ConfigurePulseWidthCounterIn('Counter',CounterInLine,2,NSamples);
            
            disp(sprintf('Scan %d/%d',k,NS));
            if stopit,
                disp('ODMR aborted');
                break;
            end
            
            % ARM THE SG;
            SG.setRFOn();
            SG.armSweep();
            pause(.1);
 
            
            ni.StartTask('Counter');
            
            pause(.2);
            
            % HIT THE AWG;
            V.open();
            V.start();
            V.close();
            
            ni.WaitUntilTaskDone('Counter');
            
            

            

            
            data = ni.ReadCounterBuffer('Counter',NumberOfPoints)+data;
            
            ni.StopTask('Counter');
            ni.ClearTask('Counter');
   
            plot(hAxes,x,data)
            title(hAxes,sprintf('Scan %d/%d',k,NS));
            
            plot(hAxes2,Ref,'bx-');
            drawnow();
            
            % need to wait between scans to let all devices settle
            pause(1);
            
            
end


SG.setRFOff();
disp('ODMR finished');
end % main function

function [] = stop(obj,evnt)

global stopit;
stopit = 1;
end
            
%% POST PROCESSING FOR EDGE COUNT MODE
%J = data(3:2:end);
%J2 = data(2:2:end);
%S = J-J2; % counts inside each of the windows