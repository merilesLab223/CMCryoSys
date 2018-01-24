function varargout = NVCommandCenterPP(varargin)
% NVCOMMANDCENTERPP M-file for NVCommandCenterPP.fig
%      NVCOMMANDCENTERPP, by itself, creates a new NVCOMMANDCENTERPP or raises the existing
%      singleton*.
%
%      H = NVCOMMANDCENTERPP returns the handle to a new NVCOMMANDCENTERPP or the handle to
%      the existing singleton*.
%
%      NVCOMMANDCENTERPP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NVCOMMANDCENTERPP.M with the given input arguments.
%
%      NVCOMMANDCENTERPP('Property','Value',...) creates a new NVCOMMANDCENTERPP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NVCommandCenterPP_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NVCommandCenterPP_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NVCommandCenterPP

% Last Modified by GUIDE v2.5 14-Apr-2010 11:15:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NVCommandCenterPP_OpeningFcn, ...
                   'gui_OutputFcn',  @NVCommandCenterPP_OutputFcn, ...
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


% --- Executes just before NVCommandCenterPP is made visible.
function NVCommandCenterPP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NVCommandCenterPP (see VARARGIN)

% Choose default command line output for NVCommandCenterPP
handles.output = hObject;

%Set the default to CW mode
handles.runMode = 'CW';

%Load the instruments
handles = InitDevices(handles);

% Load in the code snipets
W = what('snippets');
if ~isempty(W.m),
    set(handles.popupmenu_codeSnippet,'String',W.m);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NVCommandCenterPP wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NVCommandCenterPP_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_editParams.
function pushbutton_editParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_editParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Call another GUI to edit the params
EditParams(handles.expparams)


% --- Executes on button press in pushbutton_loadParams.
function pushbutton_loadParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_loadParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ispref('nv','SavedSequenceDirectory'),
    paramsPath = getpref('nv','SavedSequenceDirectory');
else
    paramsPath = pwd;
end

[paramsName,paramsPath] = uigetfile([paramsPath '\*.params'],'Select Parameters File:');
if paramsName   
    tmpParams = load(fullfile(paramsPath,paramsName),'-mat','params');
    handles.expparams = tmpParams.params;
    
    %Load the pulse sequence class
    handles.pulseSequence = PulseSequencebis(handles.expparams);
    handles.paramsFile = fullfile(paramsPath,paramsName);
    
    %Update the display
    %Get the pulse seqeunce filename
    [pathstr, name, ext] = fileparts(handles.expparams.ppFile);
    set(handles.text_params,'String',sprintf('Parameters: %s',paramsName));
    
    %Enable the edit/save buttons
    set(handles.pushbutton_editParams,'enable','on');
    set(handles.pushbutton_saveParams,'enable','on');
    
    % Update handles structure
    guidata(hObject, handles);

end

% --- Executes on button press in pushbutton_start.
function pushbutton_start_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Disable the start button and enable the stop button
set(handles.pushbutton_start,'enable','off');
set(handles.pushbutton_stop,'enable','on');

%Set the status line
SetStatus(handles,'Experiment Started...')
set(handles.text_timeRemaining,'String','Estimated Time Remaining: ????');

%Do some initialization stuff common to both CW and Pulsed
% Set the Signal SG
SG = handles.SignalGenerator;
SG.open()
SG.setAmplitude();

% Set the Pulse Generator
PG = handles.PulseGenerator;
PG.init();
PG.setClockRate(handles.expparams.AWGfreq);

% Setup the Counter
myCounter = handles.Counter;
myCounter.AvgIndex = 0;
myCounter.ProcessedData = [];
myCounter.AveragedData = [];

% Clear the average and current scan axes
cla(handles.axesRawData);
cla(handles.axesAveragedData);

%Now switch on the mode we are running in for some more setup stuff
switch handles.runMode
    case 'CW'
        
        %Set the magnetic field parameters
        %handles.BFieldController.setCurrent
        
        %Load the sweep parameters into the signal generator
        SG.setSweepAll()
        
        NumberCWPoints = SG.SweepPoints;
        
        % init counter
        myCounter.NSamples = NumberCWPoints;
        myCounter.DataDims = NumberCWPoints;
        myCounter.NAverages = handles.expparams.numAverages;
        myCounter.NCounterGates = 1;
        myCounter.MaxCounts = 5000;
        
        myCounter.init();
        
        %Create a handle to the RawData plot first so that the listeners
        %know where it is
        handles.hRawDataPlot = plot(linspace(handles.SignalGenerator.SweepStart,handles.SignalGenerator.SweepStop,handles.SignalGenerator.SweepPoints),NaN(NumberCWPoints,1),'b.-','Parent',handles.axesRawData);
        
        % add two event listeners so that streamed data from the
        % counter is plotted
        handles.hListener = addlistener(myCounter,'UpdateCounterData',...
            @(src,eventdata)updateSingleDataPlot(handles,src));
        handles.hListener2 = addlistener(myCounter,'UpdateCounterProcData',...
            @(src,eventdata)updateAvgDataPlotCW(handles,src));
        
        guidata(hObject,handles);
        
        %Try to parse the pulse sequence and load it into the AWG
        try 
            handles.pulseSequence.parse();
            handles.pulseSequence.discretize();
            PG.sendPulseSequence(handles.pulseSequence,1);
            %Load the sequence with an extra loop because the SG seems to
            %need it to move back to the starting point and finish the
            %sweep
            PG.loadPulseSequence(NumberCWPoints+1,1,get(handles.checkbox_enableTracking,'Value'),handles.Tracker.LaserControlLine);
        catch ME
            errordlg(ME.message,'Oops!')
            pushbutton_stop_Callback([],[],handles)
            return
        end
        
    case 'Pulsed'
        
        %Try to parse and load the sequences
        %First check that we have something to sweep over
        if(isempty(handles.expparams.sweeps))
            errordlg('No sweeps are defined.','Oops!');
            pushbutton_stop_Callback([],[],handles)
            return
        end
        numSweeps = handles.expparams.sweeps(1).numPoints;
        try
            waitBarHandle = waitbar(0,'Parsing and loading sequences into AWG...');
            runTime = zeros(1,numSweeps);
            for sweepct = 1:numSweeps
                for varct = 1:length(handles.expparams.sweeps)
                    %Figure out what kind of parameter we have
                    %If it is d1,p1,l1 
                    varname = handles.expparams.sweeps(varct).variable;
                    if(~isempty(regexp(varname,'\<(p|d|l)\d{1,2}\>', 'once')))
                        handles.expparams.defines.(varname).value = handles.expparams.sweeps(varct).sweepArray(sweepct);
                    elseif(~isempty(regexp(varname,'\<sp\d{1,2}\>','once')))
                        spnum = str2double(regexp(varname,'sp(\d{1,2})','tokens','once'));
                        handles.expparams.sp(spnum).power = handles.expparams.sweeps(varct).sweepArray(sweepct);
                    end %Need to add more (phase maybe)
                end
                handles.pulseSequence.parse();
                handles.pulseSequence.discretize();
                %Get the total length for the timeout
                runTime(sweepct) = handles.expparams.numShots*(1/handles.expparams.AWGfreq)*handles.pulseSequence.numPoints;
                PG.sendPulseSequence(handles.pulseSequence,sweepct);
                waitbar(sweepct/numSweeps);
            end
            close(waitBarHandle);
            PG.loadPulseSequence(handles.expparams.numShots,numSweeps,get(handles.checkbox_enableTracking,'Value'),handles.Tracker.LaserControlLine);
        catch ME
            errordlg(['Failed to load pulse sequence with error:' ME.message],'Oops!')
            pushbutton_stop_Callback([],[],handles)
            return
        end
        
        %Sort out the total number of counter gates
        numCounterGates = 0;
        for chct = 1:length(handles.pulseSequence.channels)
            tmpChannel = handles.pulseSequence.channels(chct);
            if(strcmp(tmpChannel.logicalName,handles.expparams.counterChannel));
                numCounterGates = sum(diff(tmpChannel.AWGData)>0);
                break
            end
        end
        if(~numCounterGates)
            errordlg('Counter gate not defined or no counter gate.','Oops!');
            pushbutton_stop_Callback([],[],handles)
            return
        end
        
        %Initialize the counter
        myCounter.NSamples = handles.expparams.numShots;
        myCounter.DataDims = numSweeps;
        myCounter.NAverages = handles.expparams.numAverages;
        myCounter.NCounterGates = numCounterGates;
        myCounter.MaxCounts = 10;
        myCounter.init();
        
        %Create a handle to the RawData plot first so that the listeners
        %know where it is
        totSamples = handles.expparams.numShots*numCounterGates;
        handles.hRawDataPlot = plot(1:totSamples,zeros(totSamples,1),'b.-','Parent',handles.axesRawData);
        
        %Add a couple of event listeners to plot streamed data from the counter
        handles.hListener = addlistener(myCounter,'UpdateCounterData',...
            @(src,eventdata)updateSingleDataPlot(handles,src));
        handles.hListener2 = addlistener(myCounter,'UpdateCounterProcData',...
            @(src,eventdata)updateAvgDataPlotPulsed(handles,src));
        guidata(hObject,handles);
end

%Start up the AWG
PG.hwHandle.setSourceOutput(1,1);
PG.hwHandle.setSourceOutput(2,1);
PG.start();
PG.hwHandle.OPCCheck();

%Now it's safe to turn the RF on
SG.setRFOn();

meanExpTime = 0;
endExpTime = [];
%Loop over the number of averages
for avgct = 1:handles.expparams.numAverages
    
    if(~isempty(endExpTime))
        meanExpTime = (meanExpTime*(avgct-2) + (endExpTime-startExpTime)*24*3600)/(avgct-1);
        remTime = meanExpTime*(handles.expparams.numAverages-avgct+1);
        tmpHour = floor(remTime/3600);
        tmpMin = floor((remTime - 3600*tmpHour)/60);
        tmpSec = floor(remTime - 3600*tmpHour - 60*tmpMin);
        set(handles.text_timeRemaining,'String',sprintf('Estimated Time Remaining: %02d:%02d:%02d',tmpHour,tmpMin,tmpSec));
    end
    startExpTime = now;
    
    %Update the status
    SetStatus(handles,sprintf('Running Average %d of %d',avgct,handles.expparams.numAverages));
            
    %Check to see whether we are stopping early
    if myCounter.hasAborted,
        myCounter.hasAborted = 0;
        break;
    end
    
    %If tracking enabled then check counts and track if necessary
    if get(handles.checkbox_enableTracking,'Value')
        
        %Do the tracking if we need to
        % get threshold
        trackingThreshold = str2double(get(handles.edit_trackingThreshold,'String'));
        %Send a trigger to start the tracking segment
        PG.hwHandle.sendTrigger();
        PG.hwHandle.OPCCheck();
        %Pause to get some sort of steady state
        pause(0.5);
        %Get the counts
        Counts = handles.Tracker.GetCountsCurPos;
        
        %If this is the first average then record this as the reference
        if(avgct == 1)
            trackingRefCounts = Counts;
            set(handles.text_trackingRefCounts,'String',sprintf('Reference: %d',trackingRefCounts));
            if(~isempty(handles.Logger))
                handles.Logger.info(sprintf('Reference Counts: %d',Counts));
            end
        %Otherwise check if we need to to some tracking
        else
            set(handles.text_trackingLastCounts,'String',sprintf('Last Counts: %d',Counts));
            if(~isempty(handles.Logger))
                handles.Logger.info(sprintf('Tracking Counts: %d',Counts));
            end
            
            %If we are belowt the threshold then initiate a tracking session
            if Counts < trackingThreshold*trackingRefCounts
                TrackingViewer(handles.Tracker);
                handles.Tracker.trackCenter(0);
                %Close the window so we don't accumulate listeners
                close(findobj(0,'name','TrackingViewer'));
                set(handles.text_trackingLastTime,'String',['Last tracking: ' datestr(now,'yyyy-mm-dd HH:MM:SS')]);
                if(~isempty(handles.Logger))
                    handles.Logger.info('Tracking performed.');
                end
            end
        end
        %Send an event force to move on
        PG.hwHandle.forceEvent();
    end
    
    switch handles.runMode
        case 'CW'
            
            %Setup the signal generator
            SG.armSweep();
 
            %Setup the rawdata array
            myCounter.RawData = NaN(NumberCWPoints,1);
            myCounter.RawDataIndex = 0;
            
            % arm the counter
            myCounter.arm();
 
            % ??? Why do we need to pause here?
            pause(0.1);
            
            %Trigger the pulse sequence via software command
            PG.hwHandle.sendTrigger();
            
            % update data while the experiment is running
            a = myCounter.isFinished();
            while ~a
                myCounter.streamCounts(); % this will trigger the event UpdateCounterData
                a = myCounter.isFinished();
            end
            %Get the last samples
            myCounter.streamCounts();
            
            % perform averages, etc
            myCounter.AvgIndex = avgct;
            myCounter.processRawDataCW();
            % disarm the counter
            myCounter.disarm();
            
            %Kill the sweep if it missed a trigger so that we can start the next one
            SG.writeToSocket(':ABORT');
      
        case 'Pulsed'
            for sweepct = 1:numSweeps
                
                if myCounter.hasAborted,
                    myCounter.hasAborted = 0;
                    return;
                end
                
                %Setup the rawdata array
                myCounter.RawData = NaN(totSamples,1);
                myCounter.RawDataIndex = 0;
                
                % arm the counter
                myCounter.arm();
                
                pause(0.1);
                
                %Trigger the pulse sequence via software command
                PG.hwHandle.sendTrigger();
                
                % update data while the experiment is running
                a = myCounter.isFinished();
                maxTime = 1.1*runTime(sweepct)+5;
                tic;
                while ~a
                    
                    myCounter.streamCounts(); % this will trigger the event UpdateCounterData
                    a = myCounter.isFinished();
                    
                    % deal with counter missing a trigger
                    if (toc > maxTime) && (myCounter.RawDataIndex < totSamples)
                        warnmsg = sprintf('Error in acquistion: only %d of %d acquired in sweep # %d of average # %d.',myCounter.RawDataIndex,totSamples,sweepct,avgct);
                        SetStatus(handles,warnmsg);
                        if(~isempty(handles.Logger))
                            handles.Logger.warn(warnmsg);
                        end
                        break
                    end
                end
                
                if myCounter.isFinished()
                    %Get the last counts
                    myCounter.streamCounts();
                end
                    myCounter.AvgIndex = avgct;
                    myCounter.processRawDataPulsed(sweepct);
                    myCounter.disarm();
            end
    end
    
endExpTime = now;

end


%Close up shop by calling the stop button callback
pushbutton_stop_Callback([],[],handles)

%Update the status line
SetStatus(handles,'Experiment Complete.');
set(handles.text_timeRemaining,'String',sprintf('Estimated Time Remaining: Finished!'));
    

    
% --- Executes on button press in pushbutton_stop.
function pushbutton_stop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_stop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.SignalGenerator.setRFOff();
handles.SignalGenerator.close();
handles.Counter.abort();
handles.PulseGenerator.abort();
SetStatus(handles,'Experiment Stopped.');

% delete the listeners
if isfield(handles,'hListener')
    delete(handles.hListener);
end

if isfield(handles,'hListener2')
    delete(handles.hListener2);
end
%Re-enable the start button
set(handles.pushbutton_start,'enable','on');
set(handles.pushbutton_stop,'enable','off');



% --- Executes on button press in checkbox_enableTracking.
function checkbox_enableTracking_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_enableTracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_enableTracking


% --- Executes on selection change in popupmenu_trackingFreq.
function popupmenu_trackingFreq_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_trackingFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_trackingFreq contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_trackingFreq


% --- Executes during object creation, after setting all properties.
function popupmenu_trackingFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_trackingFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_trackingThreshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_trackingThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_trackingThreshold as text
%        str2double(get(hObject,'String')) returns contents of edit_trackingThreshold as a double


% --- Executes during object creation, after setting all properties.
function edit_trackingThreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_trackingThreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_enableRawData.
function checkbox_enableRawData_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_enableRawData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_enableRawData


% --- Executes on button press in pushbutton_updatePulseSeqeuencePlot.
function pushbutton_updatePulseSeqeuencePlot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_updatePulseSeqeuencePlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear the current axes
cla(handles.axesPulseSequence);
%Try to parse and disretize the pulse sequence and then plot it
try
    handles.pulseSequence.parse();
    handles.pulseSequence.discretize();
    handles.pulseSequence.plot(handles.axesPulseSequence);
catch ME
    axesLimits = get(handles.axesPulseSequence,{'XLim','YLim'});
    text(0.1*diff(axesLimits{1})+axesLimits{1}(1),0.5*diff(axesLimits{2})+axesLimits{2}(1),ME.message,'Parent',handles.axesPulseSequence)
end


% --- Executes when selected object is changed in uipanel_runMode.
function uipanel_runMode_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_runMode 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'Tag')
    case 'radiobutton_CW'
        handles.runMode = 'CW';
    case 'radiobutton_pulsed'
        handles.runMode = 'Pulsed';
end
    
% Update handles structure
guidata(hObject, handles);


%Helper function to update status line
function SetStatus(handles,statusText)
set(handles.text_status,'String',['Status: ' statusText]);

%Helper function to run the initialization script
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

%Check that a logger was initialized
if(~isfield(handles,'Logger'))
    handles.Logger = [];
end

%Helper functions to update plots
function updateSingleDataPlot(handles,src)
if(get(handles.checkbox_enableRawData,'Value'))
    set(handles.hRawDataPlot,'YData',src.RawData);
    drawnow();
end

function updateAvgDataPlotCW(handles,src)
x = linspace(handles.SignalGenerator.SweepStart,handles.SignalGenerator.SweepStop,handles.SignalGenerator.SweepPoints);
if(get(handles.checkbox_enableErrorBars,'Value'))
    errorbar(src.AveragedData,sqrt(src.AveragedData/src.AvgIndex),'.-','Parent',handles.axesAveragedData);
else
    plot(x/1e9,src.AveragedData,'b.-','Parent',handles.axesAveragedData);
end
xlabel(handles.axesAveragedData,'Frequency (GHz)');
drawnow();


function updateAvgDataPlotPulsed(handles,src)
if(get(handles.checkbox_enableErrorBars,'Value'))
    errorbar(src.AveragedData,sqrt(src.AveragedData/(src.NSamples*src.AvgIndex)),'.-','Parent',handles.axesAveragedData);
else
    plot(handles.axesAveragedData,src.AveragedData,'.-');
end
drawnow();


% --------------------------------------------------------------------
function menuFile_Callback(hObject, eventdata, handles)
% hObject    handle to menuFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuConfigure_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuConfigureSignalGenerator_Callback(hObject, eventdata, handles)
% hObject    handle to menuConfigureSignalGenerator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ConfigureSignalGenerator(handles.SignalGenerator);


% --- Executes on button press in pushbutton_saveParams.
function pushbutton_saveParams_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_saveParams (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Use the uiputfile to get the location
if ispref('nv','SavedSequenceDirectory'),
    paramsPath = getpref('nv','SavedSequenceDirectory');
else
    paramsPath = pwd;
end

[filename, pathname] = uiputfile([paramsPath '/*.params'],'Save Parameters File',handles.paramsFile);

%If they chose a good filename
if(filename)
    %Save the params file
    params = handles.expparams;
    save(fullfile(pathname,filename),'params');
    %Update the string
    set(handles.text_params,'String',sprintf('Parameters: %s',filename));
    %Update the handles
    handles.paramsFile = fullfile(pathname,filename);
    guidata(hObject,handles);
end


function edit_notes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_notes as text
%        str2double(get(hObject,'String')) returns contents of edit_notes as a double


% --- Executes during object creation, after setting all properties.
function edit_notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_codeSnippet.
function popupmenu_codeSnippet_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_codeSnippet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = get(hObject,'String');
snippetFile = fullfile(pwd,'snippets',contents{get(hObject,'Value')});
snippetFID = fopen(snippetFile);
snippetLines = textscan(snippetFID,'%s','delimiter','\n'); snippetLines = snippetLines{1};
fclose(snippetFID);
oldNotes = cellstr(get(handles.edit_notes,'String'));
set(handles.edit_notes,'String',[oldNotes; char(13); snippetLines]);


% --- Executes during object creation, after setting all properties.
function popupmenu_codeSnippet_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_codeSnippet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_evaluateNotes.
function pushbutton_evaluateNotes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_evaluateNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this function evalutes the notes field, parsing anything between
% <matlab></matlab> and evaluating it using eval();

s = get(handles.edit_notes,'String');
st = cellstr(s);

% [st{:}] converts the cellarray of strings to a single string for regexp
%Use lazy matching so we grab each portion
myTokens = regexp([st{:}],'<matlab>(.*?)</matlab>','tokens');

if ~isempty(myTokens),
    for k = 1:length(myTokens),
        eval(myTokens{k}{1});
    end
end



% --- Executes on button press in pushbutton_uploadToWiki.
function pushbutton_uploadToWiki_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_uploadToWiki (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear the AWG data (with long sequences this can fill the memory and prevent saving)
handles.pulseSequence.clearAWGData();

Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.pulseSequence);
Exp.Notes = get(handles.edit_notes,'String');
fn = SaveExp(Exp);

%Make an array of figure handles
%We need handles so that the matlab code can be evaluated
s = Exp.Notes;
% convert lines of text to cell array
s = cellstr(s);
% find text between matlab tags
s = regexp([s{:}],'<matlab>(.*?)</matlab>','tokens');
% first, add the blank handle array
s = {'figureHandles = [];',s{:}{:}};

% now find anything that looks like a figure command and change it
t = regexprep([s{:}],'($|;|;\s*?)figure;','$1figureHandles(end+1)=figure;');

%Evaluate the code to create the figures
eval(t);

WikiUploader_MindTouch('notes',Exp.Notes,'figures',figureHandles,'files',{[fn '.mat']});

%Helper function to save an experiment
function [fn] = SaveExp(Exp)

if ispref('nv','DefaultExpSavePath');
    fp = getpref('nv','DefaultExpSavePath');
else
    fp = '';
end

fn = ['Exp_',datestr(now,'yyyymmdd_HH-MM-SS')];
[fn,fp] = uiputfile(fullfile(fp,fn));
if  fn~=0
    fn = fullfile(fp,fn);
    save(fn,'Exp');
end


% --- Executes on button press in pushbutton_clearNotes.
function pushbutton_clearNotes_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_clearNotes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.edit_notes,'String','');

%Method to process image file for display on wiki
 function imgfiles = processMatlabImageFiles(handles,notes)
 %We need handles so that the matlab code can be evaluated
 %First find things between the <matlab? tags
 notes = regexp(notes,'<matlab>(.*?)</matlab>','tokens');
 % first, add the blank handle array
 notes = {'h = [];',notes{:}{:}};
       
 % now find anything that looks like a figure command and change
 % it to save the figure handle to the array
 s = regexprep([notes{:}],'($|;|;\s*?)figure;','$1h(end+1)=figure;');
 eval(s);
 close(h);


% --- Executes on button press in checkbox_enableErrorBars.
function checkbox_enableErrorBars_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_enableErrorBars (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_enableErrorBars


% --------------------------------------------------------------------
function menuBField_Callback(hObject, eventdata, handles)
% hObject    handle to menuBField (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

BFieldGUI(handles.BFieldController);


% --------------------------------------------------------------------
function menu_SaveExptoWorkspace_Callback(hObject, eventdata, handles)
% hObject    handle to menu_SaveExptoWorkspace (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Create the experiment class
Exp = Experiment(handles.PulseGenerator,handles.SignalGenerator,handles.Counter,handles.pulseSequence);

%Ask for the variable 
dlgAnswer = inputdlg('Variable Name in Workspace:',1);

%Assign it to the workspace if we got an answer
if(~isempty(dlgAnswer))
    assignin('base',dlgAnswer{1},Exp);
end


% --------------------------------------------------------------------
function menuTools_Callback(hObject, eventdata, handles)
% hObject    handle to menuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuRunScript_Callback(hObject, eventdata, handles)
% hObject    handle to menuRunScript (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Choose which script to run
if ispref('nv','SavedSequenceDirectory'),
    scriptPath = getpref('nv','SavedSequenceDirectory');
else
    scriptPath = pwd;
end

[scriptName,scriptPath] = uigetfile([scriptPath '\*.m'],'Select Script File:');

%Try to run the script
if(scriptName)
    addpath(scriptPath)
    eval(scriptName(1:end-2));
    rmpath(scriptPath)
end

    

