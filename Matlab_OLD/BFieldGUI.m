function varargout = BFieldGUI(varargin)
% BFIELDGUI M-file for BFieldGUI.fig
%      BFIELDGUI, by itself, creates a new BFIELDGUI or raises the existing
%      singleton*.
%
%      H = BFIELDGUI returns the handle to a new BFIELDGUI or the handle to
%      the existing singleton*.
%
%      BFIELDGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BFIELDGUI.M with the given input arguments.
%
%      BFIELDGUI('Property','Value',...) creates a new BFIELDGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BFieldGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BFieldGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BFieldGUI

% Last Modified by GUIDE v2.5 01-Apr-2010 15:18:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BFieldGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BFieldGUI_OutputFcn, ...
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


% --- Executes just before BFieldGUI is made visible.
function BFieldGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BFieldGUI (see VARARGIN)

% Choose default command line output for BFieldGUI
handles.output = hObject;

%Load the Field Controller class
handles.BFieldController = varargin{1};

%If we have a connection then try to populate the fields
if(~isempty(handles.BFieldController.Supplies))
    %Populate the edit fields with the current values
    set(handles.edit_XSupplyVoltage,'String',num2str(handles.BFieldController.getVoltage(1)));
    set(handles.edit_YSupplyVoltage,'String',num2str(handles.BFieldController.getVoltage(2)));
    set(handles.edit_ZSupplyVoltage,'String',num2str(handles.BFieldController.getVoltage(3)));
    set(handles.edit_XSupplyCurrent,'String',num2str(handles.BFieldController.getCurrent(1)));
    set(handles.edit_YSupplyCurrent,'String',num2str(handles.BFieldController.getCurrent(2)));
    set(handles.edit_ZSupplyCurrent,'String',num2str(handles.BFieldController.getCurrent(3)));
    
    %Update the output radio buttons
    updateOutputButtons(handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BFieldGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BFieldGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton_SuppliesOn.
function pushbutton_SuppliesOn_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SuppliesOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setOutputsOn();

%Update the radio buttons
updateOutputButtons(handles);

% --- Executes on button press in pushbutton_SuppliesOff.
function pushbutton_SuppliesOff_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_SuppliesOff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setOutputsOff();

%Update the radio buttons
updateOutputButtons(handles);

function updateOutputButtons(handles)

%Get the X output state
Xstate = str2double(handles.BFieldController.queryStr(1,'OUTPUT:STATE?'));
%Update the radio button
set(handles.radiobutton_XSupplyOff,'Value',~Xstate);
set(handles.radiobutton_XSupplyOn,'Value',Xstate);

%Get the Y output state
Ystate = str2double(handles.BFieldController.queryStr(2,'OUTPUT:STATE?'));
%Update the radio button
set(handles.radiobutton_YSupplyOff,'Value',~Ystate);
set(handles.radiobutton_YSupplyOn,'Value',Ystate);

%Get the Z output state
Zstate = str2double(handles.BFieldController.queryStr(3,'OUTPUT:STATE?'));
%Update the radio button
set(handles.radiobutton_ZSupplyOff,'Value',~Zstate);
set(handles.radiobutton_ZSupplyOn,'Value',Zstate);


% --- Executes when selected object is changed in uipanel_XSupplyOutput.
function uipanel_XSupplyOutput_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_XSupplyOutput 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setOutput(1,get(handles.radiobutton_XSupplyOn,'Value'));

% --- Executes when selected object is changed in uipanel_YSupplyOutput.
function uipanel_YSupplyOutput_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_YSupplyOutput 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setOutput(2,get(handles.radiobutton_YSupplyOn,'Value'));

% --- Executes when selected object is changed in uipanel_ZSupplyOutput.
function uipanel_ZSupplyOutput_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_ZSupplyOutput 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setOutput(3,get(handles.radiobutton_ZSupplyOn,'Value'));



function edit_XSupplyVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to edit_XSupplyVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setVoltage(1,str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function edit_XSupplyVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_XSupplyVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_YSupplyVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to edit_YSupplyVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setVoltage(2,str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function edit_YSupplyVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_YSupplyVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ZSupplyVoltage_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ZSupplyVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setVoltage(3,str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function edit_ZSupplyVoltage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ZSupplyVoltage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_XSupplyCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to edit_XSupplyCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setCurrent(1,str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function edit_XSupplyCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_XSupplyCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_YSupplyCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to edit_YSupplyCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setCurrent(2,str2double(get(hObject,'String')));


% --- Executes during object creation, after setting all properties.
function edit_YSupplyCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_YSupplyCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit_ZSupplyCurrent_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ZSupplyCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.setCurrent(3,str2double(get(hObject,'String')));

% --- Executes during object creation, after setting all properties.
function edit_ZSupplyCurrent_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ZSupplyCurrent (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_XSupplyConnection_Callback(hObject, eventdata, handles)
% hObject    handle to edit_XSupplyConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_XSupplyConnection as text
%        str2double(get(hObject,'String')) returns contents of edit_XSupplyConnection as a double


% --- Executes during object creation, after setting all properties.
function edit_XSupplyConnection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_XSupplyConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_YSupplyConnection_Callback(hObject, eventdata, handles)
% hObject    handle to edit_YSupplyConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_YSupplyConnection as text
%        str2double(get(hObject,'String')) returns contents of edit_YSupplyConnection as a double


% --- Executes during object creation, after setting all properties.
function edit_YSupplyConnection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_YSupplyConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_ZSupplyConnection_Callback(hObject, eventdata, handles)
% hObject    handle to edit_ZSupplyConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_ZSupplyConnection as text
%        str2double(get(hObject,'String')) returns contents of edit_ZSupplyConnection as a double


% --- Executes during object creation, after setting all properties.
function edit_ZSupplyConnection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_ZSupplyConnection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_openConnections.
function pushbutton_openConnections_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_openConnections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Setup the serial connections
%Remove any old ones (obviously this doensn't play nice with other
%programs)
delete(instrfind('Type','serial'))

%Baudrate shouldn't be hardcoded.  Must match supply or connection will
%fail.
baudRate = 38400;

XSupply = serial(get(handles.edit_XSupplyConnection,'String'),'BaudRate',baudRate);
YSupply = serial(get(handles.edit_XSupplyConnection,'String'),'BaudRate',baudRate);
ZSupply = serial(get(handles.edit_XSupplyConnection,'String'),'BaudRate',baudRate);

handles.BFieldController.Supplies = [XSupply YSupply ZSupply];
handles.BFieldController.openConnections();
handles.BFieldController.setVoltages([10 10 10]);


% --- Executes on button press in pushbutton_closeConnections.
function pushbutton_closeConnections_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_closeConnections (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.BFieldController.closeConnections();

