function varargout = TekLines(varargin)
% TekLines M-file for TekLines.fig
%      TekLines, by itself, creates a new TekLines or raises the existing
%      singleton*.
%
%      H = TekLines returns the handle to a new TekLines or the handle to
%      the existing singleton*.
%
%      TekLines('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TekLines.M with the given input arguments.
%
%      TekLines('Property','Value',...) creates a new TekLines or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TekLines_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TekLines_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TekLines

% Last Modified by GUIDE v2.5 10-Feb-2010 16:03:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TekLines_OpeningFcn, ...
                   'gui_OutputFcn',  @TekLines_OutputFcn, ...
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


% --- Executes just before TekLines is made visible.
function TekLines_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TekLines (see VARARGIN)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% init the pulse generator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.PulseGenerator = TekPulseGenerator('tcpip','172.16.1.183',4000);

% set PG clock rate to 1MHz
handles.PulseGenerator.setClockRate(1e6);

guidata(hObject, handles);

% UIWAIT makes TekLines wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TekLines_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure



% --- Executes on button press in p0l0.
function p0l0_Callback(hObject, eventdata, handles)
% hObject    handle to p0l0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l0


% --- Executes on button press in p0l1.
function p0l1_Callback(hObject, eventdata, handles)
% hObject    handle to p0l1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l1


% --- Executes on button press in p0l2.
function p0l2_Callback(hObject, eventdata, handles)
% hObject    handle to p0l2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l2


% --- Executes on button press in p0l3.
function p0l3_Callback(hObject, eventdata, handles)
% hObject    handle to p0l3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l3


% --- Executes on button press in p0l4.
function p0l4_Callback(hObject, eventdata, handles)
% hObject    handle to p0l4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l4


% --- Executes on button press in p0l5.
function p0l5_Callback(hObject, eventdata, handles)
% hObject    handle to p0l5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l5


% --- Executes on button press in p0l6.
function p0l6_Callback(hObject, eventdata, handles)
% hObject    handle to p0l6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l6


% --- Executes on button press in p0l7.
function p0l7_Callback(hObject, eventdata, handles)
% hObject    handle to p0l7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0l7


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

a(1) = get(handles.p0l0,'Value');
a(2) = get(handles.p0l1,'Value');
a(3) = get(handles.p0l2,'Value');
a(4) = get(handles.p0l3,'Value');
a(5) = get(handles.p0l4,'Value');
a(6) = get(handles.p0l5,'Value');
a(7) = get(handles.p0l6,'Value');
a(8) = get(handles.p0l7,'Value');
a(9) = get(handles.p0lmarker1,'Value');
a(10) = get(handles.p0lmarker2,'Value');



handles.PulseGenerator.init();

handles.PulseGenerator.setLines(a',[0:7 14 15]');

handles.PulseGenerator.start();


% --- Executes on button press in pbStop.
function pbStop_Callback(hObject, eventdata, handles)
% hObject    handle to pbStop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.PulseGenerator.sendSequence(0*[0:7 14 15]',[0:7 14 15]',1,1);
handles.PulseGenerator.stop();


% --- Executes on button press in p0lmarker1.
function p0lmarker1_Callback(hObject, eventdata, handles)
% hObject    handle to p0lmarker1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0lmarker1


% --- Executes on button press in p0lmarker2.
function p0lmarker2_Callback(hObject, eventdata, handles)
% hObject    handle to p0lmarker2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of p0lmarker2


