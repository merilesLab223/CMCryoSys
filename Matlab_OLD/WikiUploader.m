function varargout = WikiUploader(varargin)
% WIKIUPLOADER M-file for WikiUploader.fig
%      WIKIUPLOADER, by itself, creates a new WIKIUPLOADER or raises the existing
%      singleton*.
%
%      H = WIKIUPLOADER returns the handle to a new WIKIUPLOADER or the handle to
%      the existing singleton*.
%
%      WIKIUPLOADER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WIKIUPLOADER.M with the given input arguments.
%
%      WIKIUPLOADER('Property','Value',...) creates a new WIKIUPLOADER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WikiUploader_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WikiUploader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WikiUploader

% Last Modified by GUIDE v2.5 20-Nov-2009 09:13:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WikiUploader_OpeningFcn, ...
                   'gui_OutputFcn',  @WikiUploader_OutputFcn, ...
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


% --- Executes just before WikiUploader is made visible.
function WikiUploader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WikiUploader (see VARARGIN)

% Choose default command line output for WikiUploader
handles.output = hObject;

if numel(varargin) < 1,
    handles.wikiupload = WikiUpload();
else
    handles.wikiupload = varargin{1};
end

if ispref('nv','wikiuploader')
    wup = getpref('nv','wikiuploader');
    handles.wikiupload.url = wup.url;
    handles.wikiupload.login = wup.login;
    handles.wikiupload.password = wup.password;
    handles.wikiupload.project = wup.project;
end

handles.wikiupload.date = datestr(now,'dd_mmmm_yyyy');
handles.wikiupload.time = datestr(now,'HH:MM');

Init(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WikiUploader wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WikiUploader_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editProject_Callback(hObject, eventdata, handles)
% hObject    handle to editProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editProject as text
%        str2double(get(hObject,'String')) returns contents of editProject as a double


% --- Executes during object creation, after setting all properties.
function editProject_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editProject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editDate_Callback(hObject, eventdata, handles)
% hObject    handle to editDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDate as text
%        str2double(get(hObject,'String')) returns contents of editDate as a double


% --- Executes during object creation, after setting all properties.
function editDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTime_Callback(hObject, eventdata, handles)
% hObject    handle to editTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTime as text
%        str2double(get(hObject,'String')) returns contents of editTime as a double


% --- Executes during object creation, after setting all properties.
function editTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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



function editURL_Callback(hObject, eventdata, handles)
% hObject    handle to editURL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editURL as text
%        str2double(get(hObject,'String')) returns contents of editURL as a double


% --- Executes during object creation, after setting all properties.
function editURL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editURL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editLogin_Callback(hObject, eventdata, handles)
% hObject    handle to editLogin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editLogin as text
%        str2double(get(hObject,'String')) returns contents of editLogin as a double
updateWikiUpload(handles)

% --- Executes during object creation, after setting all properties.
function editLogin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLogin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editPass_Callback(hObject, eventdata, handles)
% hObject    handle to editPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editPass as text
%        str2double(get(hObject,'String')) returns contents of editPass as a double
updateWikiUpload(handles)

% --- Executes during object creation, after setting all properties.
function editPass_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editPass (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listboxFiles.
function listboxFiles_Callback(hObject, eventdata, handles)
% hObject    handle to listboxFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listboxFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listboxFiles


% --- Executes during object creation, after setting all properties.
function listboxFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listboxFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAddFile.
function pbAddFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbAddFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,fp] = uigetfile('*.*');
if length(fn),
s = get(handles.listboxFiles,'String');
s{end+1} = fullfile(fp,fn);
set(handles.listboxFiles,'String',s);
end

% --- Executes on button press in pbRemoveFile.
function pbRemoveFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemoveFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = get(handles.listboxFiles,'Value');
s = get(handles.listboxFiles,'String');
s(ind) = [];
set(handles.listboxFiles,'String',s);

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateWikiUpload(handles)
guidata(hObject,handles);
W = handles.wikiupload();
W.initialize();
W.initBotAndLogin();
W.sendFiles();
W.getPage();
W.addText();
close();

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuDefault_Callback(hObject, eventdata, handles)
% hObject    handle to menuDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wikiuploader.url = get(handles.editURL,'String');
wikiuploader.login = get(handles.editLogin,'String');
wikiuploader.password = get(handles.editPass,'String');
wikiuploader.project = get(handles.editProject,'String');
setpref('nv','wikiuploader',wikiuploader);


function Init(handles)
set(handles.editURL,'String',handles.wikiupload.url);
set(handles.editLogin,'String',handles.wikiupload.login);
set(handles.editPass,'String',repmat('*',1,length(handles.wikiupload.password)));
set(handles.editProject,'String',handles.wikiupload.project);
set(handles.editDate,'String',handles.wikiupload.date);
set(handles.editTime,'String',handles.wikiupload.time);
set(handles.listboxFiles,'String',handles.wikiupload.files);
set(handles.editNotes,'String',handles.wikiupload.notes);

function updateWikiUpload(handles)

handles.wikiupload.url = get(handles.editURL,'String');
handles.wikiupload.login = get(handles.editLogin,'String');

%don't update the pass, since it's masked
if strcmp(get(handles.editPass,'String'),repmat('*',1,length(get(handles.editPass,'String')))),
else
    handles.wikiupload.password = get(handles.editPass,'String');
end
% mask the pass
set(handles.editPass,'String',repmat('*',1,length(handles.wikiupload.password)));
handles.wikiupload.project = get(handles.editProject,'String');
handles.wikiupload.title = get(handles.editTitle,'String');
handles.wikiupload.date = get(handles.editDate,'String');
handles.wikiupload.time = get(handles.editTime,'String');
handles.wikiupload.notes = get(handles.editNotes,'String');
handles.wikiupload.files = get(handles.listboxFiles,'String');



function editTitle_Callback(hObject, eventdata, handles)
% hObject    handle to editTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTitle as text
%        str2double(get(hObject,'String')) returns contents of editTitle as a double


% --- Executes during object creation, after setting all properties.
function editTitle_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTitle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


