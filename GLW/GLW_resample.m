function varargout = GLW_resample(varargin)
% GLW_RESAMPLE MATLAB code for GLW_resample.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_resample_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_resample_OutputFcn, ...
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









% --- Executes just before GLW_resample is made visible.
function GLW_resample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_resample (see VARARGIN)
% Choose default command line output for GLW_resample
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%function('dummy',configuration,datasets);
%configuration
configuration=varargin{2};
set(handles.process_btn,'Userdata',configuration);
%datasets
datasets=varargin{3};
set(handles.prefix_edit,'Userdata',datasets);
%axis
axis off;
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%overwrite_chk Userdata stores status of ProcessBtn
set(handles.overwrite_chk,'Userdata',[]);
%ajust GUI according to configuration_mode
switch configuration.gui_info.configuration_mode
    case 'direct';
        set(handles.overwrite_chk,'Visible','on');
        set(handles.prefix_text,'Visible','on');
        set(handles.prefix_edit,'Visible','on');
        set(handles.process_btn,'String','Process');
    case 'script';
        set(handles.overwrite_chk,'Visible','off');
        set(handles.prefix_text,'Visible','off');
        set(handles.prefix_edit,'Visible','off');
        set(handles.process_btn,'String','Save');
    case 'history'
        set(handles.overwrite_chk,'Visible','off');
        set(handles.prefix_text,'Visible','off');
        set(handles.prefix_edit,'Visible','off');
        set(handles.process_btn,'Visible','off');
end;
%update prefix_edit
set(handles.prefix_edit,'String',configuration.gui_info.process_filename_string);
%update overwrite_chk
if strcmpi(configuration.gui_info.process_overwrite,'yes');
    set(handles.overwrite_chk,'Value',1);
else
    set(handles.overwrite_chk,'Value',0);
end;
%!!!!!!!!!!!!!!!!!!!!!!!!
%update GUI configuration
%!!!!!!!!!!!!!!!!!!!!!!!!
set(handles.resample_x_chk,'Value',configuration.parameters.resample_x);
set(handles.resample_y_chk,'Value',configuration.parameters.resample_y);
set(handles.resample_z_chk,'Value',configuration.parameters.resample_z);
set(handles.x_sampling_rate_edit,'String',num2str(configuration.parameters.x_sampling_rate));
set(handles.y_sampling_rate_edit,'String',num2str(configuration.parameters.y_sampling_rate));
set(handles.z_sampling_rate_edit,'String',num2str(configuration.parameters.z_sampling_rate));
st=get(handles.interpolation_method_popup);
a=find(strcmpi(st,configuration.parameters.interpolation_method));
if isempty(a);
else
    set(handles.interpolation_method_popup,'Value',a(1));
end;
%hide unused dimensions
header=datasets(1).header;
%Z
if header.datasize(4)==1;
    set(handles.resample_z_chk,'Visible','off');
    set(handles.resample_z_chk,'Value',0);
    set(handles.z_sampling_rate_edit,'Visible','off');
end;
%Y
if header.datasize(5)==1;
    set(handles.resample_y_chk,'Visible','off');
    set(handles.resample_y_chk,'Value',0);
    set(handles.y_sampling_rate_edit,'Visible','off');
end;
%X
if header.datasize(6)==1;
    set(handles.resample_x_chk,'Visible','off');
    set(handles.resample_x_chk,'Value',0);
    set(handles.x_sampling_rate_edit,'Visible','off');
end;
update_edits(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);




function update_edits(handles);
if get(handles.resample_x_chk,'Value')==1;
    set(handles.x_sampling_rate_edit,'Enable','on');
else
    set(handles.x_sampling_rate_edit,'Enable','off');
end;
if get(handles.resample_y_chk,'Value')==1;
    set(handles.y_sampling_rate_edit,'Enable','on');
else
    set(handles.y_sampling_rate_edit,'Enable','off');
end;
if get(handles.resample_z_chk,'Value')==1;
    set(handles.z_sampling_rate_edit,'Enable','on');
else
    set(handles.z_sampling_rate_edit,'Enable','off');
end;



% --- Outputs from this function are returned to the command line.
function varargout = GLW_resample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
%configuration
configuration=get(handles.process_btn,'UserData');
if isempty(get(handles.overwrite_chk,'Userdata'))
    varargout{2}=[];
else
   varargout{2}=configuration;
end;
delete(hObject);




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%fetch configuration
configuration=get(handles.process_btn,'Userdata');
%notify that process_btn has been pressed
set(handles.overwrite_chk,'Userdata',1);
%prefix_edit
configuration.gui_info.process_filename_string=get(handles.prefix_edit,'String');
%overwrite_chk
if get(handles.overwrite_chk,'Value')==0;
    configuration.gui_info.process_overwrite='no';
else
    configuration.gui_info.process_overwrite='yes';
end;
%!!!!!!!!!!!!!!!!!!!!
%UPDATE CONFIGURATION
%!!!!!!!!!!!!!!!!!!!!
configuration.parameters.x_sampling_rate=str2num(get(handles.x_sampling_rate_edit,'String'));
configuration.parameters.y_sampling_rate=str2num(get(handles.y_sampling_rate_edit,'String'));
configuration.parameters.z_sampling_rate=str2num(get(handles.z_sampling_rate_edit,'String'));
configuration.parameters.resample_x=get(handles.resample_x_chk,'Value');
configuration.parameters.resample_y=get(handles.resample_y_chk,'Value');
configuration.parameters.resample_z=get(handles.resample_z_chk,'Value');
st=get(handles.interpolation_method_popup,'String');
configuration.parameters.interpolation_method=st{get(handles.interpolation_method_popup,'Value')};
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);








% --- Executes on button press in overwrite_chk.
function overwrite_chk_Callback(hObject, eventdata, handles)
% hObject    handle to overwrite_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.overwrite_chk,'Value')==1;
    set(handles.prefix_text,'Visible','off');
    set(handles.prefix_edit,'Visible','off');
else
    set(handles.prefix_text,'Visible','on');
    set(handles.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);





% --- Executes on button press in resample_x_chk.
function resample_x_chk_Callback(hObject, eventdata, handles)
% hObject    handle to resample_x_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);



function x_sampling_rate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x_sampling_rate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resample_y_chk.
function resample_y_chk_Callback(hObject, eventdata, handles)
% hObject    handle to resample_y_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);




function y_sampling_rate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function y_sampling_rate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in resample_z_chk.
function resample_z_chk_Callback(hObject, eventdata, handles)
% hObject    handle to resample_z_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);




function z_sampling_rate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function z_sampling_rate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in interpolation_method_popup.
function interpolation_method_popup_Callback(hObject, eventdata, handles)
% hObject    handle to interpolation_method_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function interpolation_method_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interpolation_method_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
