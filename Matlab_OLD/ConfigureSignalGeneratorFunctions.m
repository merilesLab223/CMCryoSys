function ConfigureSignalGeneratorFunctions(varargin)

    action = varargin{1};


    switch action,

        case 'SetAll',
            hObject = varargin{2};
            eventdata = varargin{3};
            handles = varargin{4};

            SetAll(hObject,eventdata,handles);
        case 'Query'
            hObject = varargin{2};
            handles = varargin{3};
            Query(hObject,handles);
        case 'Initialize',
            hObject = varargin{2};
            handles = varargin{3};
            Initialize(hObject,handles);
    end
end

function [] = SetAll(hObject,eventdata,handles)
    
    % get all componets from the gui
    Freq = get(handles.editFrequency,'String');
    Amp = get(handles.editAmplitude,'String');
    
    if (get(handles.rfOn,'Value') == get(hObject,'Max'))
        RF = 1;
    else
        RF = 0;
    end
   
    v = get(handles.sweepType,'Value');
    s = get(handles.sweepType,'String');
    SweepMode = s{v};
    
    v = get(handles.freqMode,'Value');
    s = get(handles.freqMode,'String');
    FrequencyMode = s{v};
    
    StartFreq = get(handles.editStartFrequency,'String');
    StopFreq = get(handles.editStopFrequency,'String');
    Points = get(handles.editPoints,'String');
    v = get(handles.sweepTrigger,'Value');
    s = get(handles.sweepTrigger,'String');
    SweepTrigger = s{v};
    v = get(handles.sweepDirection,'Value');
    s = get(handles.sweepDirection,'String');
    SweepDirection = s{v};

    % set the handles object values
            
        
    handles.hSignalGenerator.Frequency = str2num(Freq);
    handles.hSignalGenerator.Amplitude = str2num(Amp);
    handles.hSignalGenerator.SweepStart = str2num(StartFreq);
    handles.hSignalGenerator.SweepStop = str2num(StopFreq);
    handles.hSignalGenerator.SweepPoints = str2num(Points);
    handles.hSignalGenerator.SweepMode = SweepMode;
    handles.hSignalGenerator.FrequencyMode = FrequencyMode;
    handles.hSignalGenerator.SweepTrigger = SweepTrigger;
    handles.hSignalGenerator.SweepDirection = SweepDirection;
    handles.hSignalGenerator.RFState = RF;
    
    
    % call the set functions
    handles.hSignalGenerator.open();
    handles.hSignalGenerator.setFrequency();
    handles.hSignalGenerator.setAmplitude();
    handles.hSignalGenerator.setSweepStart();
    handles.hSignalGenerator.setSweepStop();
    handles.hSignalGenerator.setSweepPoints();
    handles.hSignalGenerator.setSweepMode();
    handles.hSignalGenerator.setFrequencyMode();
    handles.hSignalGenerator.setSweepTrigger();
    handles.hSignalGenerator.setSweepDirection();
    handles.hSignalGenerator.close();
    
    if handles.hSignalGenerator.RFState,
        handles.hSignalGenerator.setRFOn();
    else,
        handles.hSignalGenerator.setRFOff();
    end
end %SetAll

function [] = Initialize(hObject,handles)
       % call the set functions
    handles.hSignalGenerator.getFrequency();
    handles.hSignalGenerator.getFrequencyMode();
    handles.hSignalGenerator.getAmplitude();
    handles.hSignalGenerator.getSweepStart();
    handles.hSignalGenerator.getSweepStop();
    handles.hSignalGenerator.getSweepPoints();
    handles.hSignalGenerator.getSweepMode();
    handles.hSignalGenerator.getSweepTrigger();
    handles.hSignalGenerator.getSweepDirection();
    
        % get all componets from the gui
    set(handles.editFrequency,'String',sprintf('%.4g',handles.hSignalGenerator.Frequency));
    set(handles.editAmplitude,'String',sprintf('%.4g',handles.hSignalGenerator.Amplitude));
    set(handles.editStartFrequency,'String',sprintf('%.4g',handles.hSignalGenerator.SweepStart));
    set(handles.editStopFrequency,'String',sprintf('%.4g',handles.hSignalGenerator.SweepStop));
    set(handles.editPoints,'String',sprintf('%d',handles.hSignalGenerator.SweepPoints));
                    
    set(handles.editAmplitude,'String',sprintf('%.4g',handles.hSignalGenerator.Amplitude));
                        set(handles.editAmplitude,'String',sprintf('%.4g',handles.hSignalGenerator.Amplitude));

    s = get(handles.sweepType,'String');
    v = handles.hSignalGenerator.SweepMode;
    b = strfind(s,v);
    for k=1:length(b),
        if ~isempty(b{k}),
            set(handles.sweepType,'Value',k);
            break;
        end
    end
    
    s = get(handles.freqMode,'String');
    v = handles.hSignalGenerator.FrequencyMode;
    b = strfind(s,v);
    for k=1:length(b),
        if ~isempty(b{k}),
            set(handles.freqMode,'Value',k);
            break;
        end
    end
    
    s = get(handles.sweepTrigger,'String');
    v = handles.hSignalGenerator.SweepTrigger;
    b = strfind(s,v);
    for k=1:length(b),
        if ~isempty(b{k}),
            set(handles.sweepTrigger,'Value',k);
            break;
        end
    end
    
    s = get(handles.sweepDirection,'String');
    v = handles.hSignalGenerator.SweepDirection;
    b = strfind(s,v);
    for k=1:length(b),
        if ~isempty(b{k}),
            set(handles.sweepType,'Value',k);
            break;
        end
    end
    
    if  handles.hSignalGenerator.RFState > 0,
        set(handles.rfOn,'Value',get(handles.rfOn,'Max'));
    else
        set(handles.rfOff,'Value',get(handles.rfOff,'Max'));
    end
   
%     v = get(handles.sweepType,'Value');

%     SweepType = s{v};
%     StartFreq = get(handles.editStartFrequency,'String');
%     StopFreq = get(handles.editStopFrequency,'String');
%     Points = get(handles.editPoints,'String');
%     v = get(handles.sweepTrigger,'Value');
%     s = get(handles.sweepTrigger,'String');
%     SweepTrigger = s{v};
%     v = get(handles.sweepDirection,'Value');
%     s = get(handles.sweepDirection,'String');
%     SweepDirection = s{v};
    
end

function Query(hObject,handles);

    handles.hSignalGenerator.queryState;
    set(handles.textQuery,'String',handles.hSignalGenerator.QueryString);
end