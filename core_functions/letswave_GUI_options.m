function varargout = letswave_GUI_options(varargin)
% LETSWAVE_GUI_OPTIONS MATLAB code for letswave_GUI_options.fig
%      LETSWAVE_GUI_OPTIONS, by itself, creates a new LETSWAVE_GUI_OPTIONS or raises the existing
%      singleton*.
%
%      H = LETSWAVE_GUI_OPTIONS returns the handle to a new LETSWAVE_GUI_OPTIONS or the handle to
%      the existing singleton*.
%
%      LETSWAVE_GUI_OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LETSWAVE_GUI_OPTIONS.M with the given input arguments.
%
%      LETSWAVE_GUI_OPTIONS('Property','Value',...) creates a new LETSWAVE_GUI_OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before letswave_GUI_options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to letswave_GUI_options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help letswave_GUI_options

% Last Modified by GUIDE v2.5 04-Oct-2014 10:49:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @letswave_GUI_options_OpeningFcn, ...
                   'gui_OutputFcn',  @letswave_GUI_options_OutputFcn, ...
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


% --- Executes just before letswave_GUI_options is made visible.
function letswave_GUI_options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to letswave_GUI_options (see VARARGIN)
% Choose default command line output for letswave_GUI_options
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes letswave_GUI_options wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%load configuration > config
load letswave_config.mat
set(handles.save_btn,'Userdata',letswave_config);
%font list
t=listfonts;
set(handles.font_popup,'String',t);
%find font in list
a=find(strcmpi(t,letswave_config.FontName)==1);
if isempty(a);
else
    set(handles.font_popup,'Value',a(1));
end;
%FontSize
set(handles.FontSize_edit,'String',num2str(letswave_config.FontSize));
%FontUnits
st=get(handles.FontUnits_popup,'String');
a=find(strcmpi(st,letswave_config.FontUnits));
if isempty(a);
else
    set(handles.FontUnits_popup,'Value',a(1));
end;
%proportional
set(handles.proportional_chk,'Value',letswave_config.proportional);
%size
if letswave_config.proportional==1;
    set(handles.size_edit,'Enable','on');
else
    set(handles.size_edit,'Enable','off');
end;
set(handles.size_edit,'String',num2str(letswave_config.size));









% --- Outputs from this function are returned to the command line.
function varargout = letswave_GUI_options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varargout{1} = handles.output;


% --- Executes on selection change in font_popup.
function font_popup_Callback(hObject, eventdata, handles)
% hObject    handle to font_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function font_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to font_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_btn.
function save_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%config
letswave_config=get(handles.save_btn,'Userdata');
st=get(handles.font_popup,'String');
letswave_config.FontName=st{get(handles.font_popup,'Value')};
letswave_config.FontSize=str2num(get(handles.FontSize_edit,'String'));
st=get(handles.FontUnits_popup,'String');
letswave_config.FontUnits=st{get(handles.FontUnits_popup,'Value')};
letswave_config.proportional=get(handles.proportional_chk,'Value');
letswave_config.size=str2num(get(handles.size_edit,'String'));
a=which('letswave_config.mat');
save(a,'letswave_config');





% --- Executes on button press in cancel_btn.
function cancel_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FontSize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FontSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function FontSize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FontSize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FontUnits_popup.
function FontUnits_popup_Callback(hObject, eventdata, handles)
% hObject    handle to FontUnits_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function FontUnits_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FontUnits_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in proportional_chk.
function proportional_chk_Callback(hObject, eventdata, handles)
% hObject    handle to proportional_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.proportional_chk,'Value')==1;
    set(handles.size_edit,'Enable','on');
else
    set(handles.size_edit,'Enable','off');
end;



function size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
