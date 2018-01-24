function varargout = NVCommandCenter(varargin)
% NVCOMMANDCENTER M-file for NVCommandCenter.fig
%      NVCOMMANDCENTER, by itself, creates a new NVCOMMANDCENTER or raises the existing
%      singleton*.
%
%      H = NVCOMMANDCENTER returns the handle to a new NVCOMMANDCENTER or the handle to
%      the existing singleton*.
%
%      NVCOMMANDCENTER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NVCOMMANDCENTER.M with the given input arguments.
%
%      NVCOMMANDCENTER('Property','Value',...) creates a new
%      NVCOMMANDCENTER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NVCommandCenter_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NVCommandCenter_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NVCommandCenter

% Last Modified by GUIDE v2.5 02-Dec-2015 12:26:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @NVCommandCenter_OpeningFcn, ...
    'gui_OutputFcn',  @NVCommandCenter_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before NVCommandCenter is made visible.
function NVCommandCenter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NVCommandCenter (see VARARGIN)

addpath(fullfile(pwd,'Sequences'));

% Choose default command line output for NVCommandCenter
handles.output = hObject;

if ~isfield(handles,'PulseSequence')
    handles.PulseSequence = PulseSequence();
end

% init any default values to the handles structure
handles = InitDefaults(handles);

%
InitEvents(hObject,handles);

%
handles = InitDevices(handles);

InitGUI(hObject,handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NVCommandCenter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NVCommandCenter_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in buttonStart.
function buttonStart_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

RunExperiment(hObject,eventdata,handles);

% --- Executes on button press in buttonStop.
function buttonStop_Callback(hObject, eventdata, handles)
% hObject    handle to buttonStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
abortRun(hObject, eventdata, handles);

% --- Executes on selection change in popupMode.
function popupMode_Callback(hObject, eventdata, handles)
% hObject    handle to popupMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupMode

contents = get(hObject,'String');
val =contents{get(hObject,'Value')};
if strcmp(val,'CW');
    set(handles.editSequenceSamples,'Enable','off');
else strcmp(val,'Pulsed')
    set(handles.editSequenceSamples,'Enable','on');
end


% --- Executes during object creation, after setting all properties.
function popupMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbTrackEnable.
function cbTrackEnable_Callback(hObject, eventdata, handles)
% hObject    handle to cbTrackEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbTrackEnable


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuConfigSG_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigSG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGenerator(handles.SignalGenerator);


% --------------------------------------------------------------------
function menuConfigPG_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigPG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

answer = inputdlg({'Set ClockRate for Pulse Generator'},...
    sprintf('Set Properties for Pulse Generator: %s',class(handles.PulseGenerator)),...
    1,...
    {sprintf('%.1e',handles.PulseGenerator.ClockRate)});
if ~isempty(answer),
    CR = str2double(answer{1});
    handles.PulseGenerator.ClockRate = CR;
    
    % update the GUI
    InitGUI(hObject,handles);
end

% --------------------------------------------------------------------
function menuConfigCounter_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigCounter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbEditPS.
function pbEditPS_Callback(hObject, eventdata, handles)
% hObject    handle to pbEditPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PulseSequencer(handles.PulseSequence);
InitEvents(hObject,handles);
updatePulseSequence(handles.PulseSequence,[],handles);


function editAverages_Callback(hObject, eventdata, handles)
% hObject    handle to editAverages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editAverages as text
%        str2double(get(hObject,'String')) returns contents of editAverages as a double


% --- Executes during object creation, after setting all properties.
function editAverages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editAverages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function RunExperiment(hObject,eventdata,handles)
% reset specials
handles.specialData = [];
handles.specialVec = [];

SetStatus(handles,'Experiment Started...');

% clear note field?
if get(handles.cbNoteErase,'Value'),
    set(handles.editNotes,'String',{''});
end

% remove any left over listeners
% delete the listener
if isfield(handles,'hListener')
    delete(handles.hListener);
end

if isfield(handles,'hListener2')
    delete(handles.hListener2);
end

GalvoScan = 1;

if(get(handles.GalvoScanEnable,'Value'))
    filePath = uigetdir();
    mkdir(filePath, ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')]);
    filePath = [filePath,'\','Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
    
    res = str2double(get(handles.galvoRes,'String'));
    xMin = str2double(get(handles.xMin,'String'));
    xMax = str2double(get(handles.xMax,'String'));
    yMin = str2double(get(handles.yMin,'String'));
    yMax = str2double(get(handles.yMax,'String'));
    if(get(handles.ImageScan,'Value'))
        GalvoScan = handles.ImageData;
    else
        GalvoScan = CreateGalvoScan(xMin,xMax,yMin,yMax,res);
    end
end

% Set the Signal SG
SG = handles.SignalGenerator;
SG.open();

SG.setFrequency();
SG.setAmplitude();
SG.setRFOn();

SG.close();

% Set the Pulse Generator

PG = handles.PulseGenerator;

PG.init();

% Set up the Counter changes
myCounter = handles.Counter;

myCounter.AvgIndex = 0;
myCounter.RawData = [];
myCounter.ProcessedData = [];
myCounter.AveragedData = [];

% Clear the average and current scan axes
cla(handles.axesRawData);
cla(handles.axesAvgData);

% if Tracking Enabled, get reference counts

if get(handles.cbTrackEnable,'Value'), % if tracking turned on...
    
    % turn laser on
    handles.Tracker.laserOn();
    % get some ref counts
    ReferenceCounts = handles.Tracker.GetCountsCurPos;
    set(handles.textTrackRefCounts,'String',ReferenceCounts);
    % turn the laser off
    handles.Tracker.laserOff();
    
end

if get(handles.cbPumpHack,'Value'), % if tracking turned on...
    
    % turn laser on
    handles.Tracker.laserOn();
    pause(5);
    handles.Tracker.laserOff();
    
end

% loop over the number of averages
Averages = str2double(get(handles.editAverages,'String'));
Samples = str2double(get(handles.editSequenceSamples,'String'));

s = get(handles.popupMode,'String');
Mode = s{get(handles.popupMode,'Value')};


%%%% VERY UGLY HACK
%%%% REMOVE THIS AS SOON AS YOU UNDERSTAND HOW TO SAVE SUBCLASSED OBJECTS

handles.PulseSequence = PulseBlasterPulseSequence(handles.PulseSequence);

switch Mode,
    case 'CW',
        
        % IN CW MODE, can load the sequence just once, then average this
        % way
        % turn on SG sweeping
        SG.open();
        
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
        
        NumberCWPoints = SG.SweepPoints;
        
        % init counter
        myCounter.NSamples = NumberCWPoints;
        myCounter.DataDims = NumberCWPoints;
        myCounter.NAverages = Averages;
        myCounter.NCounterGates = 1;
        myCounter.MaxCounts = 5000;
        
        myCounter.init();
        
        %Create a handle to the RawData plot first so that the listeners
        %know where it is
        handles.hRawDataPlot = plot(linspace(handles.SignalGenerator.SweepStart,handles.SignalGenerator.SweepStop,handles.SignalGenerator.SweepPoints),zeros(NumberCWPoints,1),'b.-','Parent',handles.axesRawData);
        
        % add two event listeners so that streamed data from the
        % counter is plotted
        handles.hListener = addlistener(myCounter,'UpdateCounterData',...
            @(src,eventdata)updateSingleDataPlot(handles,src,eventdata));
        handles.hListener2 = addlistener(myCounter,'UpdateCounterProcData',...
            @(src,eventdata)updateAvgDataPlot(handles,src,eventdata));
        
        guidata(hObject,handles);
        
        % need to change microwave hardware channel
        % jhodges 22 Oct 2011
        %
        % Phase delays are calcuated based on microwave channel, but not
        % relevant for CW ESR, so we change M HW Chan to -1 tempoarilty
        MHWC = handles.PulseSequence.MicrowaveHardwareChannel;
        
        handles.PulseSequence.MicrowaveHardwareChannel = -1;
        
        % Parse Pulse Sequence For CW Experiment
        [BinarySequence,temp] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');
        
        handles.PulseSequence.MicrowaveHardwareChannel = MHWC;
        HWChannels = [handles.PulseSequence.getHardwareChannels]';
        % Load Pulse Sequence and set loops to # of sweeps
        PG.sendSequence(BinarySequence,NumberCWPoints+1,0);
        
    case 'Pulsed',
        % get # of sweeps and # of points
        inds = handles.PulseSequence.getSweepIndexMax();
        
        % get total number of counter gates
        cnts = strfind([handles.PulseSequence.Channels(:).RiseTypes],'Counter');
        CounterGates = sum([cnts{:}]);
        % init counter
        myCounter.NSamples = Samples;
        myCounter.DataDims = inds;
        myCounter.NAverages = Averages;
        myCounter.NCounterGates = CounterGates;
        myCounter.MaxCounts = 10;
        
        myCounter.init();
        
        %Create a handle to the RawData plot first so that the listeners
        %know where it is
        totSamples = Samples*CounterGates;
        handles.hRawDataPlot = plot(1:totSamples,zeros(totSamples,1),'b.-','Parent',handles.axesRawData);
        
        % add a couple event listeners to plot streamed data from the counter
        handles.hListener = addlistener(myCounter,'UpdateCounterData',...
            @(src,eventdata)updateSingleDataPlot(handles,src,eventdata));
        handles.hListener2 = addlistener(myCounter,'UpdateCounterProcData',...
            @(src,eventdata)updateAvgDataPlotPulsed(handles,src,eventdata));
        guidata(hObject,handles);
        
        % setup datastructure for spin noise, raw count acquisition
        if handles.options.spinNoiseAvg,
            M = zeros(myCounter.NSamples,1);
            fn = ['SpinNoise',datestr(now,'yyyymmdd-HHMMSS')];
            fp = handles.options.SpinNoiseDataFolder;
            spinNoiseFilePath = fullfile(fp,fn);
            save(spinNoiseFilePath,'M');
            clear('M');
        end
        
    % WHAT FOLLOWS IS AN AWFUL PATCH
    case 'Pulsed/f-sweep',
        % setup the data structures
        % Assume that this sort of experiment has a 1D pulse sweep and a
        % single frequency sweep
        startF = str2num(get(handles.editStartF,'String'));
        stopF = str2num(get(handles.editStopF,'String'));
        pointsF = str2num(get(handles.editPointsF,'String'));

        freqs = linspace(startF,stopF,pointsF);
        handles.specialVec = freqs;
        % get # of sweeps and # of points
        inds = pointsF;
        
        % get total number of counter gates
        cnts = strfind([handles.PulseSequence.Channels(:).RiseTypes],'Counter');
        CounterGates = sum([cnts{:}]);
        % init counter
        myCounter.NSamples = Samples;
        myCounter.DataDims = inds;
        myCounter.NAverages = Averages;
        myCounter.NCounterGates = CounterGates;
        myCounter.MaxCounts = 10;
        
        myCounter.init();
        
        %Create a handle to the RawData plot first so that the listeners
        %know where it is
        totSamples = Samples*CounterGates;
        handles.hRawDataPlot = plot(1:totSamples,zeros(totSamples,1),'b.-','Parent',handles.axesRawData);
        
        % add a couple event listeners to plot streamed data from the counter
        handles.hListener = addlistener(myCounter,'UpdateCounterData',...
            @(src,eventdata)updateSingleDataPlot(handles,src,eventdata));
        handles.hListener2 = addlistener(myCounter,'UpdateCounterProcData',...
            @(src,eventdata)updateAvgDataPlotPulsedfSweep(handles,src,eventdata));
        guidata(hObject,handles);
        
        
        % get the number of sweep points
        fsweepPoints = str2num(get(handles.editPointsF,'String'));
        
        % special Data will contain a 2D dataset
%         handles.specialData = zeros(myCounter.DataDims,myCounter.NCounterGates,fsweepPoints);
        
end %switch
for m = 1:numel(GalvoScan(:,1))
    if myCounter.hasAborted,
        myCounter.hasAborted = 0;
        break;
    end
    if(get(handles.GalvoScanEnable,'Value'))
        currentGalvoPosition = GalvoScan(m,:);
        handles.hImageAcquisition.CursorPosition = currentGalvoPosition;
        handles.hImageAcquisition.SetCursor();
        disp(handles.hImageAcquisition.CursorPosition);
        pause(.01);
    end
    for k=1:Averages,

        if myCounter.hasAborted,
            myCounter.hasAborted = 0;
            break;
        end

        % if tracking enabled
        if get(handles.cbTrackEnable,'Value'), % if tracking turned on...

            %Do the tracking if we need to
            % get threshold
            Thresh = str2double(get(handles.editTrackThreshold,'String'));
            % get counts
            handles.Tracker.laserOn();
            Counts = handles.Tracker.GetCountsCurPos;
            handles.Tracker.laserOff();

            set(handles.textTrackCounts,'String',Counts);

            %If we are below the threshold then initiate a tracking session
            if Counts < Thresh*ReferenceCounts,
                TrackingViewer(handles.Tracker);
                handles.Tracker.trackCenter();
                close(findobj(0,'name','TrackingViewer'));
                set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
            end

            if strcmp(Mode,'CW'),
                % Parse Pulse Sequence For CW Experiment
                [BinarySequence,temp] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');

                HWChannels = [handles.PulseSequence.getHardwareChannels]';
                % Load Pulse Sequence and set loops to # of sweeps
                PG.sendSequence(BinarySequence,NumberCWPoints+1,0);
            end
        end



        % update text
        set(handles.textAvg,'String',sprintf('(%d/%d)',k,Averages));

        switch Mode,
            case 'CW',
                if get(handles.cbPumpHack,'Value'), % Hack for pumping with green.

                    % turn laser on
                    handles.Tracker.laserOn();
                    pause(.5);
                    % turn the laser off
                    handles.Tracker.laserOff();

                end

                % set the signal generator RF on
                SG.open();
                SG.armSweep();
                SG.setRFOn();
                SG.close();

                %Setup the rawdata array
                myCounter.RawData = zeros(NumberCWPoints,1);
                myCounter.RawDataIndex = 0;

                % arm the counter
                myCounter.arm();

                % ??? Why do we need to pause here?
                %pause(0.5);

                % trigger the pulse sequence via software command
                PG.start();

                % update data while the experiment is running
                a = myCounter.isFinished();
                %tic;
                while ~a
                    myCounter.streamCounts(); % this will trigger the event UpdateCounterData
                    a = myCounter.isFinished();
                end
                %Get the last samples
                myCounter.streamCounts();

                % perform averages, etc
                myCounter.AvgIndex = k;
                myCounter.processRawDataCW();
                % disarm the counter
                myCounter.disarm();

                % set the signal generator RF off
                SG.open();
                SG.setRFOff();
                SG.close();

                % finish the PG
                PG.stop();

                % need to wait between scans to let devices settle
                % ??? which devices
                %pause(1);
                
            case 'Pulsed',

                % turn on SG RF
                SG.open();
                %SG.setRFOn();
                SG.close();

                % reset sweeps
                handles.PulseSequence.SweepIndex = 1;

                while handles.PulseSequence.getSweepIndex > 0,
                    if myCounter.hasAborted,
                        myCounter.hasAborted = 0;
                        break;
                    end

                    % see if we are tracking per sweep point
                    if get(handles.cbTrackEnable,'Value') && get(handles.popupTrackFreq,'Value') == 2,
                        Thresh = str2double(get(handles.editTrackThreshold,'String'));
                        % get counts
                        handles.Tracker.laserOn(1);
                        Counts = handles.Tracker.GetCountsCurPos;
                        handles.Tracker.laserOff(1);

                        set(handles.textTrackCounts,'String',Counts);

                        if Counts < Thresh*ReferenceCounts,
                            TrackingViewer(handles.Tracker);
                            handles.Tracker.trackCenter();
                            close(findobj(0,'name','TrackingViewer'));
                            set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
                        end
                    end
                    if get(handles.cbPumpHack,'Value'), % if pump is turned on...

                        % turn laser on
                        handles.Tracker.laserOn();
                        pause(5);
                        handles.Tracker.laserOff();

                    end

                    % Parse Pulse Sequence For Pulsed Experiment
                    [BinarySequence,tempSequence] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');

                    % update the sequence plot
                    PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);

                    % augment the sequence with nulls at the end
                    %BinarySequence = [BinarySequence,0*BinarySequence];

                    % get HW Channels
                    HWChannels = [handles.PulseSequence.getHardwareChannels]';

                    % Load Pulse Sequence and set loops to # of sweeps
                    PG.sendSequence(BinarySequence,Samples,0);

                    %Setup the rawdata array
                    myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                    myCounter.RawDataIndex = 0;

                    % arm the counter
                    myCounter.arm();

                    %pause(0.5);
                    %toc;
                    % trigger the pulse sequence via software command
                    PG.start();

                    % update data while the experiment is running
                    a = myCounter.isFinished();
                    %MaxTime = handles.PulseSequence.GetMaxRiseTime*50*myCounter.NSamples;
                    MaxTime = 10000;
                    totalSamples = myCounter.NSamples*myCounter.NCounterGates;
                    tic;
                    while ~a

                        myCounter.streamCounts(); % this will trigger the event UpdateCounterData
                        a = myCounter.isFinished();

                        % deal with counter missing a trigger
                        if (toc > MaxTime) && (myCounter.RawDataIndex < totalSamples)
                            disp(sprintf('Error in acquistion: only %d of %d acquired',myCounter.RawDataIndex,totalSamples));
                            SetStatus(handles,sprintf('Error in acquistion: only %d of %d acquired',myCounter.RawDataIndex,totalSamples));
                            break
                        end
                    end
                    PG.stop();
                    if myCounter.isFinished()
                        %Get the last counts
                        myCounter.streamCounts();
                        myCounter.AvgIndex = k;
                        if handles.options.spinNoiseAvg,
                            myCounter.saveRawDataPulsed(spinNoiseFilePath);
                        end
                        myCounter.processRawDataPulsed(handles.PulseSequence.getSweepIndex);
                        myCounter.disarm();
                        handles.PulseSequence.incrementSweepIndex();
                    else
                        disp('Counter Dropped a Pulse. Repeating');
                        SetStatus(handles,'Repeating Sweep.');
                        myCounter.disarm();
                        myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                    end
                    tempSequence = 0;
                    BinarySequence= 0;
                    if get(handles.cbPumpHack,'Value'), % if pump is turned on...

                        % turn laser on
                        handles.Tracker.laserOn();
                        pause(5);
                        handles.Tracker.laserOff();

                    end

                end

            case 'Pulsed/f-sweep',


                startF = str2num(get(handles.editStartF,'String'));
                stopF = str2num(get(handles.editStopF,'String'));
                pointsF = str2num(get(handles.editPointsF,'String'));

                freqs = linspace(startF,stopF,pointsF);
                handles.specialVec = freqs;

                for qq = 1:length(freqs), % loop over the frequencies

                    % turn on SG RF
                    SG.open();
                    % set frequency
                    SG.setFrequencyToValue(freqs(qq));
                    % RF ON
                    SG.setRFOn();
                    % close SG connection for now
                    SG.close();




                    % do all the normal things of a pulsed experiment, but before
                    % doing that, change the frequency of the carrier





                    % reset sweeps
                    handles.PulseSequence.SweepIndex = 1;

                    while handles.PulseSequence.getSweepIndex > 0,

                        if myCounter.hasAborted,
                            myCounter.hasAborted = 0;
                            break;
                        end

                        % see if we are tracking per sweep point
                        if get(handles.cbTrackEnable,'Value') && get(handles.popupTrackFreq,'Value') == 2,
                            Thresh = str2double(get(handles.editTrackThreshold,'String'));
                            % get counts
                            handles.Tracker.laserOn();
                            Counts = handles.Tracker.GetCountsCurPos;
                            handles.Tracker.laserOff();

                            set(handles.textTrackCounts,'String',Counts);

                            if Counts < Thresh*ReferenceCounts,
                                TrackingViewer(handles.Tracker);
                                handles.Tracker.trackCenter();
                                close(findobj(0,'name','TrackingViewer'));
                                set(handles.textLastTrackPos,'String',datestr(now,'yyyy-mm-dd HH:MM:SS'));
                            end
                        end

                        % Parse Pulse Sequence For Pulsed Experiment
                        [BinarySequence,tempSequence] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');

                        % update the sequence plot
                        PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,tempSequence);

                        % augment the sequence with nulls at the end
                        %BinarySequence = [BinarySequence,0*BinarySequence];

                        % get HW Channels
                        HWChannels = [handles.PulseSequence.getHardwareChannels]';

                        % Load Pulse Sequence and set loops to # of sweeps
                        PG.sendSequence(BinarySequence,Samples,0);

                        %Setup the rawdata array
                        myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                        myCounter.RawDataIndex = 0;

                        % arm the counter
                        myCounter.arm();

                        %pause(0.5);

                        % trigger the pulse sequence via software command
                        PG.start();

                        % update data while the experiment is running
                        a = myCounter.isFinished();
                        MaxTime = handles.PulseSequence.GetMaxRiseTime*50*myCounter.NSamples;
                        totalSamples = myCounter.NSamples*myCounter.NCounterGates;
                        tic;
                        while ~a

                            myCounter.streamCounts(); % this will trigger the event UpdateCounterData
                            a = myCounter.isFinished();

                            % deal with counter missing a trigger

                            if (toc > MaxTime) && (myCounter.RawDataIndex < totalSamples)
                                disp(sprintf('Error in acquistion: only %d of %d acquired',myCounter.RawDataIndex,totalSamples));
                                SetStatus(handles,sprintf('Error in acquistion: only %d of %d acquired',myCounter.RawDataIndex,totalSamples));
                                break
                            end
                        end
                        PG.stop();

                        if myCounter.isFinished()
                            %Get the last counts
                            myCounter.streamCounts();
                            myCounter.AvgIndex = k;
                            if handles.options.spinNoiseAvg,
                                myCounter.saveRawDataPulsed(handles.PulseSequence.getSweepIndex,k,spinNoiseFilePath);
                            end
                            myCounter.processRawDataPulsed(qq);
                            myCounter.disarm();
                            handles.PulseSequence.incrementSweepIndex();
                        else
                            disp('Counter Dropped a Pulse. Repeating');
                            SetStatus(handles,'Repeating Sweep.');
                            myCounter.disarm();
                            myCounter.RawData = zeros(myCounter.NSamples*myCounter.NCounterGates,1);
                        end
                    end % end pulse sweep loop

                
                end % end freq sweep loop
        end %Switch on Pulse/CW
    end % end averages
    
    Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence);
    
    if(get(handles.GalvoScanEnable,'Value'))
        saveFilePath = [filePath,'\GalvoPos_','X-',num2str(currentGalvoPosition(1)),'-','Y-',num2str(currentGalvoPosition(2))];
        set(handles.CurrentPosition,'String',['Current X-',num2str(currentGalvoPosition(1)),'-','Y-',num2str(currentGalvoPosition(2))]);
        saveFilePath = strrep(saveFilePath, '.','_');
        save(saveFilePath,'Exp');
    end
    
end %stops galvo scan
if handles.options.spinNoiseAvg && ~strcmp(Mode, 'CW');
    load(spinNoiseFilePath);
    M = M/Averages;
    save(spinNoiseFilePath,'M');
end

PG.stop();

PG.close();

% clean up at the end of the experiment
myCounter.close();
SG.setRFOff();

% delete the listeners
if isfield(handles,'hListener')
    delete(handles.hListener);
end

if isfield(handles,'hListener2')
    delete(handles.hListener2);
end
SetStatus(handles,'Experiment Complete.');
guidata(hObject,handles); % update handles object

function updateSingleDataPlot(handles,src,eventdata)
set(handles.hRawDataPlot,'YData',src.RawData);
%plot(src.RawData,'b-','Parent',handles.axesRawData);
drawnow();

function updateAvgDataPlot(handles,src,eventdata)

x = linspace(handles.SignalGenerator.SweepStart,handles.SignalGenerator.SweepStop,handles.SignalGenerator.SweepPoints);
y = src.AveragedData;
plot(x(2:end),y(2:end),'b.-','Parent',handles.axesAvgData);
xlabel(handles.axesAvgData,'Freq');
drawnow();


function updateAvgDataPlotPulsed(handles,src,eventdata)

%ColorOrder = [ [0,0,0];[0,0,1];[1,0,0];[0,1,0]];
%set(handles.axesAvgData,'ColorOrder',ColorOrder,'NextPlot','replacechildren');
if numel(handles.PulseSequence.Sweeps) == 1,
    SWP = handles.PulseSequence.Sweeps(1);
    x = linspace(SWP.StartValue,SWP.StopValue,SWP.SweepPoints);
    
    plot(x,src.AveragedData,'.-','Parent',handles.axesAvgData);
else
    plot(src.AveragedData,'.-','Parent',handles.axesAvgData);
end

drawnow();

function updateAvgDataPlotPulsedfSweep(handles,src,eventdata)

%ColorOrder = [ [0,0,0];[0,0,1];[1,0,0];[0,1,0]];
%set(handles.axesAvgData,'ColorOrder',ColorOrder,'NextPlot','replacechildren');
if numel(handles.PulseSequence.Sweeps) == 1,
    SWP = handles.PulseSequence.Sweeps(1);
    x = handles.specialVec;
    
    plot(x,src.AveragedData,'.-','Parent',handles.axesAvgData);
else
    plot(src.AveragedData,'.-','Parent',handles.axesAvgData);
end

drawnow();

% --- Executes on button press in buttonIA.
function buttonIA_Callback(hObject, eventdata, handles)
% hObject    handle to buttonIA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

apps = getappdata(0);
fN = fieldnames(apps);
for k=1:numel(fN),
    if sum(ishandle(getfield(apps,fN{k}))) && isa(getfield(apps,fN{k}),'double'),
        name = get(getfield(apps,fN{k}),'Name');
        if strcmp('ImageAcquire',name),
            hFig = getfield(apps,fN{k});
            figure(hFig);
        end
    end
    
    
end

% --------------------------------------------------------------------
function menuSetDevices_Callback(hObject, eventdata, handles)
% hObject    handle to menuSetDevices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ask user to select init script
W = what('config');
[S,OK] = listdlg('PromptString','Select an initialization script','SelectionMode','single','ListString',[W.m]);
if OK,
    handles.initScript = W.m{S};
    
    % ask to save as default
    button = questdlg('Save Init Script as Default?','Default Init Script','Yes','No','Yes');
    switch button,
        case 'Yes'
            setpref('nv','CCInitScript',handles.initScript);
    end
    
    % evaluate the script
    addpath(fullfile(pwd,'config'));
    [hObject,handles] = feval(handles.initScript(1:end-2),hObject,handles);
    SetStatus(handles,sprintf('Init Script (%s) Run',handles.initScript));
    guidata(hObject,handles);
    rmpath(fullfile(pwd,'config'));
end

% --------------------------------------------------------------------
function menuBField_Callback(hObject, eventdata, handles)
% hObject    handle to menuBField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function InitEvents(hObject,handles)

if isfield(handles,'nvccEvents'),
    delete(handles.nvccEvents);
end
handles.nvccEvents = addlistener(handles.PulseSequence,'PulseSeqeunceChangedState',@(src,event)updatePulseSequence(src,event,handles));




function updatePulseSequence(src,event,handles)

PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,src);
set(handles.textSeqName,'String',src.SequenceName);


% --- Executes on button press in pbLoadPS.
function pbLoadPS_Callback(hObject, eventdata, handles)
% hObject    handle to pbLoadPS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[PSeq,fn,fp] = PulseSequencerFunctions('LoadExternal');
if fn,
    feval(class(handles.PulseSequence),PSeq); % if handles.PulseSequnce is a different class than PSeq, due to saving between version, cast to correct class
    handles.PulseSequence.copy(feval(class(handles.PulseSequence),PSeq));
    InitEvents(hObject,handles);
    updatePulseSequence(handles.PulseSequence,[],handles);
    guidata(hObject,handles);
end


function SetStatus(handles,statusText)
set(handles.textStatus,'String',statusText);

function handles = InitDevices(handles)

if ispref('nv','CCInitScript'),
    script = getpref('nv','CCInitScript');
    addpath('./config');
    handles = feval(script(1:end-2),handles);
    SetStatus(handles,sprintf('Init Script (%s) Run',script));
    rmpath('./config');
else
    SetStatus(handles,'Please run init script.');
end



% --------------------------------------------------------------------
function uitoggletool1_OnCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode on;


% --------------------------------------------------------------------
function uitoggletool1_OffCallback(hObject, eventdata, handles)
% hObject    handle to uitoggletool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datacursormode off;


% --------------------------------------------------------------------
function menuSave_Callback(hObject, eventdata, handles)
% hObject    handle to menuSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence);
Exp.Notes = get(handles.editNotes,'String');
Exp.SpecialData = handles.specialData;
Exp.SpecialVec = handles.specialVec;

SaveExp(Exp);


function [fn] = SaveExp(Exp)

if ispref('nv','DefaultExpSavePath');
    fp = getpref('nv','DefaultExpSavePath');
else
    fp = '';
end

fn = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
[fn,fp] = uiputfile(fullfile(fp,fn));
if ~isempty(fn),
    fn = fullfile(fp,fn);
    save(fn,'Exp');
end


function abortRun(hObject,eventdata,handles)

handles.SignalGenerator.setRFOff();
handles.Counter.abort();
handles.PulseGenerator.abort();
SetStatus(handles,'Experiment Aborted.');



function editSequenceSamples_Callback(hObject, eventdata, handles)
% hObject    handle to editSequenceSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editSequenceSamples as text
%        str2double(get(hObject,'String')) returns contents of editSequenceSamples as a double


% --- Executes during object creation, after setting all properties.
function editSequenceSamples_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSequenceSamples (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function menuDebug_Callback(hObject, eventdata, handles)
% hObject    handle to menuDebug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('debug');


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuHWLines_Callback(hObject, eventdata, handles)
% hObject    handle to menuHWLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'HWLineFunction')
    feval(handles.HWLineFunction);
end


% --- Executes on button press in pbTestRun.
function pbTestRun_Callback(hObject, eventdata, handles)
% hObject    handle to pbTestRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s = get(hObject,'String');
PG = handles.PulseGenerator;

handles.PulseSequence.SweepIndex = 1;

if strfind(s,'Test');
    set(hObject,'String','Stop Run');
    
    PG.init();
    
    Samples = str2double(get(handles.editSequenceSamples,'String'));
    
    [BinarySequence,tempSequence] = ProcessPulseSequence(handles.PulseSequence,PG.ClockRate,'Instruction');
    
    % update the sequence plot
    PulseSequencerFunctions('DrawSequenceExternal',handles.axesPulseSequence,handles.PulseSequence);
    
    
    % get HW Channels
    HWChannels = [handles.PulseSequence.getHardwareChannels]';
    
    PG.sendSequence(BinarySequence,Samples,0);
    PG.start();
elseif strfind(s,'Stop')
    set(hObject,'String','Test Run');
    PG.stop();
end
%PG.close();



function editNotes_Callback(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editNotes as text
%        str2double(get(hObject,'String')) returns contents of editNotes as a double


% --- Executes during object creation, after setting all properties.
function editNotes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on editNotes and none of its controls.
function editNotes_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editNotes (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cbNoteErase.
function cbNoteErase_Callback(hObject, eventdata, handles)
% hObject    handle to cbNoteErase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbNoteErase



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to textClockRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of textClockRate as text
%        str2double(get(hObject,'String')) returns contents of textClockRate as a double


% --- Executes during object creation, after setting all properties.
function textClockRate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textClockRate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [] = InitGUI(hObject,handles);

if isfield(handles,'PulseGenerator'),
    % display the clock rate in MHz
    % clock rate in Pulsegenerator always given in Hz.
    set(handles.textClockRate,'String',sprintf('%.3f MHz',handles.PulseGenerator.ClockRate/1e6));
end

% load in the code snipets
W = what('snippets');
if ~isempty(W.m),
    set(handles.popupCodeSnipet,'String',W.m);
end

% check for spin noise enabled
if handles.options.spinNoiseAvg,
    set(handles.menuSpinNoise,'checked','on');
end

% --- Executes on button press in pbEvalNotes.
function pbEvalNotes_Callback(hObject, eventdata, handles)
% hObject    handle to pbEvalNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this function evalutes the notes field, parsing anything between
% <matlab></matlab> and evaluating it using eval();

s = get(handles.editNotes,'String');
st = cellstr(s);

% [st{:}] converts the cellarray of strings to a single string for regexp
%Use lazy matching so we grab each portion
myTokens = regexp([st{:}],'<matlab>(.*?)</matlab>','tokens');

if ~isempty(myTokens),
    for k = 1:length(myTokens),
        eval(myTokens{k}{1});
    end
end


% --- Executes during object creation, after setting all properties.
function popupCodeSnipet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupCodeSnipet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupCodeSnipet.
function popupCodeSnipet_Callback(hObject, eventdata, handles)
% hObject    handle to popupCodeSnipet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupCodeSnipet contents as cell array
%        contents{get(hObject,'Value')} returns selected item from
%        popupCodeSnipet
contents = get(hObject,'String');
filename = contents{get(hObject,'Value')};
fpfn = fullfile(pwd,'snipets',filename);
fid = fopen(fpfn);
s = {};
while 1
    tline = fgetl(fid);
    if ~ischar(tline),   break,   end;
    s{end+1} = tline;
end
fclose(fid);
Sold = get(handles.editNotes,'String');
set(handles.editNotes,'String',[cellstr(Sold)',char(13),s]);


% --------------------------------------------------------------------
function menuSavePostExperiment_Callback(hObject, eventdata, handles)
% hObject    handle to menuSavePostExperiment (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.PulseSequence);
Exp.Notes = get(handles.editNotes,'String');
fn = SaveExp(Exp);

if isfield(handles,'ExperimentPost'),
    lp = [pwd,'\','java\'];
    javaclasspath({[lp,'jwbf-core-1.3.0.jar'],[lp,'jwbf-mediawiki-1.3.0.jar'],...
        [lp,'log4j-1.2.14.jar'],...
        [lp,'jdom-1.1.jar'],...
        [lp,'commons-httpclient-3.1.jar'],...
        [lp,'commons-logging-1.0.4.jar'],...
        [lp,'commons-codec-1.2.jar'],[lp,'junit-4.5.jar'],...
        [lp]});
    W = WikiUpload();
    W.initialize();
    W.notes = Exp.Notes;
    imgfiles = W.processMatlabImageFiles(handles);
    
    % check to see if we need to add the extension
    [a,b,c,d] = fileparts(fn);
    if isempty(c),
        fn = [fn,'.mat'];
    end
    
    W.files = {[fn],imgfiles{:}};
    WikiUploader(W);
end


% --- Executes on selection change in popupTrackFreq.
function popupTrackFreq_Callback(hObject, eventdata, handles)
% hObject    handle to popupTrackFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupTrackFreq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupTrackFreq


% --- Executes during object creation, after setting all properties.
function popupTrackFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupTrackFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = InitDefaults(handles)

% define spin noise options as false
handles.options.spinNoiseAvg = 0;
handles.specialData = [];
handles.specialVec = [];


% --------------------------------------------------------------------
function menuSpinNoise_Callback(hObject, eventdata, handles)
% hObject    handle to menuSpinNoise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.options.spinNoiseAvg == 0;
    handles.options.spinNoiseAvg = 1;
    set(handles.menuSpinNoise,'checked','on');
else
    handles.options.spinNoiseAvg = 0;
    set(handles.menuSpinNoise,'checked','off');
end

guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function axesConfocal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesConfocal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesConfocal



function editStartF_Callback(hObject, eventdata, handles)
% hObject    handle to editStartF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStartF as text
%        str2double(get(hObject,'String')) returns contents of editStartF as a double


% --- Executes during object creation, after setting all properties.
function editStartF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStopF_Callback(hObject, eventdata, handles)
% hObject    handle to editStopF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editStopF as text
%        str2double(get(hObject,'String')) returns contents of editStopF as a double


% --- Executes during object creation, after setting all properties.
function editStopF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStopF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function GalvoScan = CreateGalvoScan(xMin,xMax,yMin,yMax,res)
    res = res + 1;
    if xMax == xMin || yMax == yMin
        GalvoScan = zeros(res,2);
    else
        GalvoScan = zeros(res*res,2);
    end
    xVec = linspace(xMin,xMax,res)';
    yVec = linspace(yMin,yMax,res)';
    
    for i = 1:2:res
        if xMax == xMin || yMax == yMin
            GalvoScan = [xVec,yVec];
        else
        GalvoScan((1 + (i-1)*res):i*res,:) = [xVec,yVec(i)*ones(res,1)];
        GalvoScan(i*res+1:(i+1)*res,:) = [xVec(end:-1:1), yVec(i+1)*ones(res,1)];
        end
    end


function editPointsF_Callback(hObject, eventdata, handles)
% hObject    handle to editPointsF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPointsF as text
%        str2double(get(hObject,'String')) returns contents of editPointsF as a double


% --- Executes during object creation, after setting all properties.
function editPointsF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPointsF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cbPumpHack.
function cbPumpHack_Callback(hObject, eventdata, handles)
% hObject    handle to cbPumpHack (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbPumpHack



function xMin_Callback(hObject, eventdata, handles)
% hObject    handle to xMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMin as text
%        str2double(get(hObject,'String')) returns contents of xMin as a double


% --- Executes during object creation, after setting all properties.
function xMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xMax_Callback(hObject, eventdata, handles)
% hObject    handle to xMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xMax as text
%        str2double(get(hObject,'String')) returns contents of xMax as a double


% --- Executes during object creation, after setting all properties.
function xMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMin_Callback(hObject, eventdata, handles)
% hObject    handle to yMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMin as text
%        str2double(get(hObject,'String')) returns contents of yMin as a double


% --- Executes during object creation, after setting all properties.
function yMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yMax_Callback(hObject, eventdata, handles)
% hObject    handle to yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yMax as text
%        str2double(get(hObject,'String')) returns contents of yMax as a double


% --- Executes during object creation, after setting all properties.
function yMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function galvoRes_Callback(hObject, eventdata, handles)
% hObject    handle to galvoRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of galvoRes as text
%        str2double(get(hObject,'String')) returns contents of galvoRes as a double


% --- Executes during object creation, after setting all properties.
function galvoRes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to galvoRes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in GalvoScanEnable.
function GalvoScanEnable_Callback(hObject, eventdata, handles)
% hObject    handle to GalvoScanEnable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of GalvoScanEnable


% --- Executes on button press in LoadImage.
function LoadImage_Callback(hObject, eventdata, handles)
% hObject    handle to LoadImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[baseName, folder] = uigetfile();
fullFileName = fullfile(folder, baseName);

res = str2double(get(handles.galvoRes,'String'));
xMin = str2double(get(handles.xMin,'String'));
xMax = str2double(get(handles.xMax,'String'));
% yMin = str2double(get(handles.yMin,'String'));
% yMax = str2double(get(handles.yMax,'String'));

I = imread(fullFileName);
I = imcomplement(I);
J = im2bw(I,0.15);            
K = imresize(J,[res,res]);      
K = im2double(K);           
K(1:2:end,:) = fliplr(K(1:2:end,:));


Step = (xMax-xMin)/(res-1);

clearvars GalvoIn;

m = 0;
for row = drange(1:1:res)
    for col = drange(1:1:res)
        if K(row,col) == 1
           m = m+1;
           GalvoIn (m,2) = xMin+(row-1)*Step;
           if mod(row,2) == 0
              GalvoIn (m,1) = xMax-(col-1)*Step;
           else
              GalvoIn (m,1) = xMin+(col-1)*Step; 
           end
        end
    end
end
GalvoIn(m+1,1) = 5;
GalvoIn(m+1,2) = 5;
handles.ImageData = GalvoIn;
guidata(hObject,handles);


% --- Executes on button press in ImageScan.
function ImageScan_Callback(hObject, eventdata, handles)
% hObject    handle to ImageScan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ImageScan
