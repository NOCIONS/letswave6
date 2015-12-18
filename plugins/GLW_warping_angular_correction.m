function varargout = GLW_warping_angular_correction(varargin)
% GLW_WARPING_ANGULAR_CORRECTION M-file for GLW_warping_angular_correction.fig
%      GLW_WARPING_ANGULAR_CORRECTION, by itself, creates a new GLW_WARPING_ANGULAR_CORRECTION or raises the existing
%      singleton*.
%
%      H = GLW_WARPING_ANGULAR_CORRECTION returns the handle to a new GLW_WARPING_ANGULAR_CORRECTION or the handle to
%      the existing singleton*.
%
%      GLW_WARPING_ANGULAR_CORRECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_WARPING_ANGULAR_CORRECTION.M with the given input arguments.
%
%      GLW_WARPING_ANGULAR_CORRECTION('Property','Value',...) creates a new GLW_WARPING_ANGULAR_CORRECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_warping_angular_correction_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_warping_angular_correction_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_warping_angular_correction

% Last Modified by GUIDE v2.5 18-Dec-2015 10:24:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_warping_angular_correction_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_warping_angular_correction_OutputFcn, ...
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






% --- Executes just before GLW_warping_angular_correction is made visible.
function GLW_warping_angular_correction_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_warping_angular_correction (see VARARGIN)
% Choose default command line output for GLW_warping_angular_correction
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%inputfiles
inputfiles=varargin{2};
% Fill listbox with inputfiles
set(handles.filebox,'String',inputfiles);
%load header of first file
header=LW_load_header(inputfiles{1});
%find events
event_list={};
for i=1:length(header.events);
    event_list{i}=header.events(i).event_code; 
end;
event_list=sort(unique(event_list));
set(handles.eventcode_popup,'String',event_list);
% UIWAIT makes GLW_warping_angular_correction wait for user response (see UIRESUME)
% uiwait(handles.figure1);





% --- Outputs from this function are returned to the command line.
function varargout = GLW_warping_angular_correction_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;




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






% --- Executes on button press in pushbutton_process.
function pushbutton_process_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=get(handles.filebox,'String');
%get parameters
f0_chk=get(handles.f0_chk,'Value');
event_code_list=get(handles.eventcode_popup,'String');
event_code=event_code_list(get(handles.eventcode_popup,'Value'));
steps=str2num(get(handles.steps_edit,'String'));
%loop through files
for filepos=1:length(inputfiles);
    [header,data]=LW_load(inputfiles{filepos});
    if f0_chk=1;
        f0=str2num(get(handles.f0_edit,'String'));
        [header,data]=LW_warping_angular_correction(header,data,'f0',f0,'event_code',event_code,'steps',steps);
    else
        [header,data]=LW_warping_angular_correction(header,data,'event_code',event_code,'steps',steps);
    end;
    if isempty(header);
    else
        %save 
        LW_save(inputfiles{filepos},get(handles.edit_prefix,'String'),header,data);
    end;
end;
    
    



function edit_prefix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function edit_prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in eventcode_popup.
function eventcode_popup_Callback(hObject, eventdata, handles)
% hObject    handle to eventcode_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function eventcode_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventcode_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function f0_edit_Callback(hObject, eventdata, handles)
% hObject    handle to f0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of f0_edit as text
%        str2double(get(hObject,'String')) returns contents of f0_edit as a double


% --- Executes during object creation, after setting all properties.
function f0_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to f0_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in f0_chk.
function f0_chk_Callback(hObject, eventdata, handles)
% hObject    handle to f0_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function steps_edit_Callback(hObject, eventdata, handles)
% hObject    handle to steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function steps_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to steps_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
