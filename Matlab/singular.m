
function varargout = singular(varargin)




% SINGULAR M-file for singular.fig
%      SINGULAR, by itself, creates a new SINGULAR or raises the existing
%      singleton*.
%
%      H = SINGULAR returns the handle to a new SINGULAR or the handle to
%      the existing singleton*.
%
%      SINGULAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGULAR.M with the given input arguments.
%
%      SINGULAR('Property','Value',...) creates a new SINGULAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before singular_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to singular_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Copyright 2002-2003 The MathWorks, Inc.

% Edit the above text to modify the response to help singular

% Last Modified by GUIDE v2.5 27-Jun-2012 17:41:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @singular_OpeningFcn, ...
                   'gui_OutputFcn',  @singular_OutputFcn, ...
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


% --- Executes just before singular is made visible.
function singular_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to singular (see VARARGIN)

% Choose default command line output for singular
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes singular wait for user response (see UIRESUME)
% uiwait(handles.singular);


% --- Outputs from this function are returned to the command line.
function varargout = singular_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%--------------------------------------------------------------------------
%Commands start below----------------------------------------------------


%--Text box to enter the topological charge1 number-------------------------
function charge1_Callback(hObject, eventdata, handles)
% hObject    handle to charge1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge1 as text
%        str2double(get(hObject,'String')) returns contents of charge1 as a double

charge1=str2double(get(hObject, 'String'));
handles.charge1=charge1;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function charge1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function period_Callback(hObject, eventdata, handles)
% hObject    handle to period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of period as text
%        str2double(get(hObject,'String')) returns contents of period as a double

period=str2double(get(hObject, 'String'));
handles.period=period;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function period_CreateFcn(hObject, eventdata, handles)
% hObject    handle to period (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function resolution_Callback(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of resolution as text
%        str2double(get(hObject,'String')) returns contents of resolution as a double

resolution=str2double(get(hObject, 'String'));
handles.resolution=resolution;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function resolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to resolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

% --- Executes during object creation, after setting all properties.

function blaze_Callback(hObject, eventdata, handles)
% hObject    handle to blaze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blaze as text
%        str2double(get(hObject,'String')) returns contents of blaze as a double

blaze=str2double(get(hObject, 'String'));
handles.blaze=blaze;
guidata(hObject,handles)

function blaze_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blaze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.

if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function waist_Callback(hObject, eventdata, handles)
% hObject    handle to waist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of waist as text
%        str2double(get(hObject,'String')) returns contents of waist as a double

waist=str2double(get(hObject, 'String'));
handles.waist=waist;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function waist_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function rotation_Callback(hObject, eventdata, handles)
% hObject    handle to rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotation as text
%        str2double(get(hObject,'String')) returns contents of rotation as a double

rotation=str2double(get(hObject, 'String'));
handles.rotation=rotation;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function rotation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


function charge2_Callback(hObject, eventdata, handles)
% hObject    handle to charge2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge2 as text
%        str2double(get(hObject,'String')) returns contents of charge2 as a double

charge2=str2double(get(hObject, 'String'));
handles.charge2=charge2;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function charge2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end





function charge3_Callback(hObject, eventdata, handles)
% hObject    handle to charge3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of charge3 as text
%        str2double(get(hObject,'String')) returns contents of charge3 as a double

charge3=str2double(get(hObject, 'String'));
handles.charge3=charge3;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function charge3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to charge3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function n = enabledp (handle)
n = get(handle, 'Value');

% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Notes on SLM
% the density is  0.02 mm/px horizontally and negligibly more vertically,
% (0.020052083 mm/px) and the 'screen' is 1280x768, so the largest
% theoretical display size is 768 pixels.

n=768;
N=1:1:n;
x=N-n/2;
y=N-n/2;
[X,Y]=meshgrid(x,y);
[th,r]=cart2pol(X,Y);

%Fork Grating----------------------------------
amp1=(r*sqrt(2)/handles.waist).^abs(handles.charge1).*exp(-r.^2/handles.waist^2); amp1=amp1./max(max(amp1));
amp2=(r*sqrt(2)/handles.waist).^abs(handles.charge2).*exp(-r.^2/handles.waist^2); amp2=amp2./max(max(amp2));
amp3=(r*sqrt(2)/handles.waist).^abs(handles.charge3).*exp(-r.^2/handles.waist^2); amp3=amp3./max(max(amp3));

rot=cos(handles.rotation*2*pi/360)*X+sin(handles.rotation*2*pi/360)*Y;

z1=amp1.*cos(handles.blaze*mod(handles.charge1*th+handles.period*rot,2*pi));
z2=2*amp2.*cos(handles.blaze*mod(handles.charge2*th+handles.period*rot,2*pi));
z3=amp3.*cos(handles.blaze*mod(handles.charge3*th+handles.period*rot,2*pi));

% z1=amp1.*cos(handles.blaze*mod(handles.charge1*th+handles.period*(Y),2*pi));
% z2=amp2.*cos(handles.blaze*mod(handles.charge2*th+handles.period*(Y),2*pi));
% z3=amp3.*cos(handles.blaze*mod(handles.charge3*th+handles.period*(Y),2*pi));

% Superimpose images depending on the state of checkboxes
% enabledp will return a 1 if they are checked and 0 if not
z=z1+enabledp(handles.checkbox2).*z2+enabledp(handles.checkbox3).*z3;

% Inset image
imagesc(z); colormap(gray);


% I think this is just to make the image square instead of distorted
% to the screen aspect ratio
% GRATING=([(s(3)-s(4))*.5+s(3) 0 s(4) s(4)]);
% figure('Position',GRATING);
% imagesc(z); colormap(gray);

% figure ('Menubar', 'none', ...
%         'Units', 'normalized', ...
%         'OuterPosition', [1 0 1 1], ...
%         'Position', [1 0 1 1]);
% imagesc(z); colormap(gray);
% set(gca, 'position', [0 0 1 1]);
% s=get(0,'screensize');
% %set(gcf, 'position', [(s(3)-s(4))*.5+s(3) 0 s(4) s(4)]);
% axis image;

set(handles.waist_size, 'String', sprintf('Waist size is now %gmm', handles.waist*0.02));








