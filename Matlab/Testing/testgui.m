function varargout = testgui(varargin)
% TESTGUI MATLAB code for testgui.fig
%      TESTGUI, by itself, creates a new TESTGUI or raises the existing
%      singleton*.
%
%      H = TESTGUI returns the handle to a new TESTGUI or the handle to
%      the existing singleton*.
%
%      TESTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI.M with the given input arguments.
%
%      TESTGUI('Property','Value',...) creates a new TESTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testgui

% Last Modified by GUIDE v2.5 07-Mar-2018 15:32:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testgui_OpeningFcn, ...
                   'gui_OutputFcn',  @testgui_OutputFcn, ...
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


% --- Executes just before testgui is made visible.
function testgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testgui (see VARARGIN)

% Choose default command line output for testgui
handles.output = hObject;


% UIWAIT makes testgui wait for user response (see UIRESUME)

handles.reader=NI6321AnalogReader('Dev1');
reader=handles.reader;
reader.configure();
disp('Reader configured');
axesHandle = findobj('Tag', 'axes2');
plot(axesHandle,[1 2 3],[1 2 3]);
reader.addlistener('DataReady',@(s,e)plot(axesHandle,e.TimeStamps,e.Data));
guidata(hObject, handles);

% Update handles structure
%uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = testgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnRunReader.
function btnRunReader_Callback(hObject, eventdata, handles)
reader=handles.reader;
reader.prepare();
reader.run();
% hObject    handle to btnRunReader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnStopReader.
function btnStopReader_Callback(hObject, eventdata, handles)
reader=handles.reader;
reader.Stop();
% hObject    handle to btnStopReader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
