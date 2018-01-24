function varargout = WikiUploader_MindTouch(varargin)
% WIKIUPLOADER_MINDTOUCH M-file for WikiUploader_MindTouch.fig
%      WIKIUPLOADER_MINDTOUCH, by itself, creates a new WIKIUPLOADER_MINDTOUCH or raises the existing
%      singleton*.
%
%      H = WIKIUPLOADER_MINDTOUCH returns the handle to a new WIKIUPLOADER_MINDTOUCH or the handle to
%      the existing singleton*.
%
%      WIKIUPLOADER_MINDTOUCH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WIKIUPLOADER_MINDTOUCH.M with the given input arguments.
%
%      WIKIUPLOADER_MINDTOUCH('Property','Value',...) creates a new WIKIUPLOADER_MINDTOUCH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WikiUploader_MindTouch_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WikiUploader_MindTouch_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WikiUploader_MindTouch

% Last Modified by GUIDE v2.5 07-Mar-2010 17:19:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WikiUploader_MindTouch_OpeningFcn, ...
                   'gui_OutputFcn',  @WikiUploader_MindTouch_OutputFcn, ...
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


% --- Executes just before WikiUploader_MindTouch is made visible.
function WikiUploader_MindTouch_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WikiUploader_MindTouch (see VARARGIN)

% Choose default command line output for WikiUploader_MindTouch
handles.output = hObject;

%Look to see if we have any input for file or images
fileIndex = find(strcmp('files',varargin));
if(~isempty(fileIndex))
    handles.files = varargin{fileIndex+1};
else
    handles.files = {};
end

imageIndex = find(strcmp('figures',varargin));
if(~isempty(imageIndex))
    handles.figures = varargin{imageIndex+1};
else
    handles.figures = [];
end

wikiIndex = find(strcmp('WikiUpload',varargin));
if(~isempty(wikiIndex))
    handles.WikiUpload = varargin{wikiIndex+1};
else
    handles.WikiUpload = WikiUpload_MindTouch();
end

notesIndex = find(strcmp('notes',varargin));
if(~isempty(notesIndex))
    tmpNotes = varargin{notesIndex+1};
else
    tmpNotes = '';
end

if ispref('nv','wikiuploader')
    wup = getpref('nv','wikiuploader');
    handles.WikiUpload.URL = wup.url;
    handles.username = wup.login;
    handles.password = wup.password;
    handles.project = wup.project;
else
    handles.username = '';
    handles.password = '';
    handles.project = '';
end


%Setup the fields
set(handles.editURL,'String',handles.WikiUpload.URL);
set(handles.editUsername,'String',handles.username);
set(handles.editPass,'String',repmat('*',1,length(handles.password)));
set(handles.editProject,'String',handles.project);
set(handles.editDate,'String',datestr(now,'dd mmmm yyyy'));
set(handles.editTime,'String',datestr(now,'HH:MM'));
set(handles.listboxFiles,'String',handles.files);
set(handles.editNotes,'String',tmpNotes);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WikiUploader_MindTouch wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = WikiUploader_MindTouch_OutputFcn(hObject, eventdata, handles) 
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
handles.WikiUpload.URL = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);


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



function editUsername_Callback(hObject, eventdata, handles)
% hObject    handle to editUsername (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editUsername as text
%        str2double(get(hObject,'String')) returns contents of editUsername as a double
handles.username = get(hObject,'String');

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function editUsername_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editUsername (see GCBO)
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
%don't update the pass, since it's masked
if strcmp(get(hObject,'String'),repmat('*',1,length(get(hObject,'String')))),
else
    handles.password = get(hObject,'String');
end
% mask the pass
set(hObject,'String',repmat('*',1,length(handles.password)));

% Update handles structure
guidata(hObject, handles);



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
if ~isempty(fn)
    s = get(handles.listboxFiles,'String');
    s{end+1} = fullfile(fp,fn);
    set(handles.listboxFiles,'String',s);
end
handles.files = s;
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pbRemoveFile.
function pbRemoveFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbRemoveFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind = get(handles.listboxFiles,'Value');
s = get(handles.listboxFiles,'String');
s(ind) = [];
set(handles.listboxFiles,'String',s);
handles.files = s;
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbuttonOK.
function pushbuttonOK_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Authorize the wiki client
handles.WikiUpload.authenticate(handles.username,handles.password);

%Make the notebook entry
wikipage = [get(handles.editProject,'String') '/' datestr(now,'yyyy/mmmm') '/' datestr(now,'dd mmmm yyyy')];
datestamp = datenum([get(handles.editDate,'String') get(handles.editTime,'String')]);
handles.WikiUpload.addLabBookEntry(wikipage,get(handles.editTitle,'String'),get(handles.editNotes,'String'),handles.figures,handles.files,datestamp);
            
close();

% --- Executes on button press in pushbuttonCancel.
function pushbuttonCancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonCancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menuSaveAsDefault_Callback(hObject, eventdata, handles)
% hObject    handle to menuSaveAsDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wikiuploader.url = handles.WikiUpload.URL;
wikiuploader.login = handles.username;
wikiuploader.password = handles.password;
wikiuploader.project = get(handles.editProject,'String');
setpref('nv','wikiuploader',wikiuploader);

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


        


