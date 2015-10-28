function varargout = GLW_baseline_combined_harmonics(varargin)
% GLW_BASELINE_COMBINED_HARMONICS M-file for GLW_baseline_combined_harmonics.fig
%      GLW_BASELINE_COMBINED_HARMONICS, by itself, creates a new GLW_BASELINE_COMBINED_HARMONICS or raises the existing
%      singleton*.
%
%      H = GLW_BASELINE_COMBINED_HARMONICS returns the handle to a new GLW_BASELINE_COMBINED_HARMONICS or the handle to
%      the existing singleton*.
%
%      GLW_BASELINE_COMBINED_HARMONICS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_BASELINE_COMBINED_HARMONICS.M with the given input arguments.
%
%      GLW_BASELINE_COMBINED_HARMONICS('Property','Value',...) creates a new GLW_BASELINE_COMBINED_HARMONICS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_baseline_combined_harmonics_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_baseline_combined_harmonics_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_baseline_combined_harmonics

% Last Modified by GUIDE v2.5 28-Oct-2015 11:09:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_baseline_combined_harmonics_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_baseline_combined_harmonics_OutputFcn, ...
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


% --- Executes just before GLW_baseline_combined_harmonics is made visible.
function GLW_baseline_combined_harmonics_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_baseline_combined_harmonics (see VARARGIN)

% Choose default command line output for GLW_baseline_combined_harmonics
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles=varargin{2};
set(handles.filebox,'String',inputfiles);

% UIWAIT makes GLW_baseline_combined_harmonics wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_baseline_combined_harmonics_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Harmonics_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to Harmonics_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Harmonics_textbox as text
%        str2double(get(hObject,'String')) returns contents of Harmonics_textbox as a double


% --- Executes during object creation, after setting all properties.
function Harmonics_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Harmonics_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseFreq_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to baseFreq_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseFreq_textbox as text
%        str2double(get(hObject,'String')) returns contents of baseFreq_textbox as a double


% --- Executes during object creation, after setting all properties.
function baseFreq_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseFreq_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filebox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filebox


% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in process_button.
function process_button_Callback(hObject, eventdata, handles)
% hObject    handle to process_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get x intervals
BaseFreq = eval(sprintf('[%s]',get(handles.baseFreq_textbox,'String')));
Harmonics = eval(sprintf('[%s]',get(handles.Harmonics_textbox,'String')));
freqBins = Harmonics.*BaseFreq;

% Surrounding bins
%dxedit1,dxedit2
dxedit1=fix(str2num(get(handles.dxedit1,'String')));
dxedit2=fix(str2num(get(handles.dxedit2,'String')));

%Get filenames to process
inputfiles=get(handles.filebox,'String');

%method of interval combination
method = 'averageH'; %default
if get(handles.radiobutton_sumH,'Value');
    method = 'sumH';      
end

%operation
operationstrings={'subtract','snr','percent','zscore','percentbootstrap'};
operationindex=get(handles.operationmenu,'Value');


for filepos=1:length(inputfiles);
    %load 
    [header,data]=LW_load(inputfiles{filepos});
    %process
    disp('*** Baseline combined harmonics');
    [header,data]=LW_baseline_combined_harmonics(header,data,freqBins,dxedit1,dxedit2,operationstrings{operationindex}, method);
    %filename
    LW_save(inputfiles{filepos},get(handles.prefixtext,'String'),header,data);    
end;

disp('*** Finished.');



function prefixtext_Callback(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixtext as text
%        str2double(get(hObject,'String')) returns contents of prefixtext as a double



% --- Executes during object creation, after setting all properties.
function prefixtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in radiobutton_averageH.
function radiobutton_averageH_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_averageH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_averageH

set(handles.radiobutton_averageH,'Value',1);
set(handles.radiobutton_sumH,'Value',0);



% --- Executes on button press in radiobutton_sumH.
function radiobutton_sumH_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sumH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sumH
set(handles.radiobutton_averageH,'Value',0);
set(handles.radiobutton_sumH,'Value',1);




function dxedit1_Callback(hObject, eventdata, handles)
% hObject    handle to dxedit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dxedit1 as text
%        str2double(get(hObject,'String')) returns contents of dxedit1 as a double


% --- Executes during object creation, after setting all properties.
function dxedit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dxedit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dxedit2_Callback(hObject, eventdata, handles)
% hObject    handle to dxedit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dxedit2 as text
%        str2double(get(hObject,'String')) returns contents of dxedit2 as a double


% --- Executes during object creation, after setting all properties.
function dxedit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dxedit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in operationmenu.
function operationmenu_Callback(hObject, eventdata, handles)
% hObject    handle to operationmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns operationmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from operationmenu


% --- Executes during object creation, after setting all properties.
function operationmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operationmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
