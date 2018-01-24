function [varargout] = GalvoControl_(varargin)

switch varargin{1}
    case 'Initialize'
        hObject = varargin{2};
        eventdata = varargin{3}
        handles = varargin{4};
        [varargout{1}] = Initialize(hObject,eventdata,handles);
end


function [handles] = Initialize(hObject,eventdata,handles)

    % configure the libs
    LibraryName = 'nidaqmx';
    LibraryFilePath = 'C:\WINDOWS\system32\nicaiu.dll';
    HeaderFilePath = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';

    % instantiate the driver
    ni = NIDAQ_Driver(LibraryName,LibraryFilePath,HeaderFilePath);
    
    % add analog out lines
    ni = ni.addAOLine('Dev2/ao0',0.000); % default 0.000V
    ni = ni.addAOLine('Dev2/ao1',0.000); % default 0.000V
    
    % update the A0 voltages
    ni.WriteAnalogOutAllLines;
    
    % set the max and min values of sliders to those of the NI card
    set(handles.sliderX,'Min',ni.AnalogOutMinVoltage,'Max',ni.AnalogOutMaxVoltage);
    set(handles.sliderY,'Min',ni.AnalogOutMinVoltage,'Max',ni.AnalogOutMaxVoltage);
    
    % update the X and Y edit boxes
    set(handles.editX,'String',sprintf('%1.3f',ni.AnalogOutVoltages(1)));
    set(handles.editY,'String',sprintf('%1.3f',ni.AnalogOutVoltages(2)));
    
    handles.ni = ni;
end
