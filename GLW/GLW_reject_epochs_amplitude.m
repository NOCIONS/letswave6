function varargout = GLW_reject_epochs_amplitude(varargin)
% GLW_REJECT_EPOCHS_AMPLITUDE MATLAB code for GLW_reject_epochs_amplitude.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_reject_epochs_amplitude_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_reject_epochs_amplitude_OutputFcn, ...
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









% --- Executes just before GLW_reject_epochs_amplitude is made visible.
function GLW_reject_epochs_amplitude_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_reject_epochs_amplitude (see VARARGIN)
% Choose default command line output for GLW_reject_epochs_amplitude
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
%chk
set(handles.x_limits_chk,'Value',configuration.parameters.x_limits);
set(handles.y_limits_chk,'Value',configuration.parameters.y_limits);
set(handles.z_limits_chk,'Value',configuration.parameters.z_limits);
set(handles.select_channels_chk,'Value',configuration.parameters.select_channels);
%edits
set(handles.x_start_edit,'String',num2str(configuration.parameters.x_start));
set(handles.x_end_edit,'String',num2str(configuration.parameters.x_start));
set(handles.y_start_edit,'String',num2str(configuration.parameters.y_start));
set(handles.y_end_edit,'String',num2str(configuration.parameters.y_start));
set(handles.z_start_edit,'String',num2str(configuration.parameters.z_start));
set(handles.z_end_edit,'String',num2str(configuration.parameters.z_start));
set(handles.criterion_edit,'String',num2str(configuration.parameters.criterion));
%check header
header=datasets(1).header;
if header.datasize(4)==1;
    set(handles.z_start_edit,'Enable','off');
    set(handles.z_end_edit,'Enable','off');
    set(handles.z_limits_chk,'Enable','off');
    set(handles.z_limits_chk,'Value',0);
end;
if header.datasize(5)==1;
    set(handles.y_start_edit,'Enable','off');
    set(handles.y_end_edit,'Enable','off');
    set(handles.y_limits_chk,'Enable','off');
    set(handles.y_limits_chk,'Value',0);
end;
if header.datasize(6)==1;
    set(handles.x_start_edit,'Enable','off');
    set(handles.x_end_edit,'Enable','off');
    set(handles.x_limits_chk,'Enable','off');
    set(handles.x_limits_chk,'Value',0);
end;
%channel labels
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channels_listbox,'String',st);
if isempty(configuration.parameters.selected_channel_labels);
else
    j=1;
    for i=1:length(configuration.parameters.selected_channel_labels);
        a=find(strcmpi(configuration.parameters.selected_channel_labels(i),st)==1);
        if isempty(a);
        else
            idx(j)=a(1);
            j=j+1;
        end;
    end;
    set(handles.channels_listbox,'Value',idx);
end;
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_reject_epochs_amplitude_OutputFcn(hObject, eventdata, handles) 
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
%chk
configuration.parameters.x_limits=get(handles.x_limits_chk,'Value');
configuration.parameters.y_limits=get(handles.y_limits_chk,'Value');
configuration.parameters.z_limits=get(handles.z_limits_chk,'Value');
configuration.parameters.select_channels=get(handles.select_channels_chk,'Value');
%edits
configuration.parameters.x_start=str2num(get(handles.x_start_edit,'String'));
configuration.parameters.y_start=str2num(get(handles.y_start_edit,'String'));
configuration.parameters.z_start=str2num(get(handles.z_start_edit,'String'));
configuration.parameters.x_end=str2num(get(handles.x_end_edit,'String'));
configuration.parameters.y_end=str2num(get(handles.y_end_edit,'String'));
configuration.parameters.z_end=str2num(get(handles.z_end_edit,'String'));
%amplitude
configuration.parameters.criterion=str2num(get(handles.criterion_edit,'String'));
%channels
st=get(handles.channels_listbox,'String');
st=st(get(handles.channels_listbox,'Value'));
configuration.parameters.selected_channel_labels=st;
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


% --- Executes on selection change in channels_listbox.
function channels_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function channels_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in all_btn.
function all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.channels_listbox,'String');
v=get(handles.channels_listbox,'Value');
if isempty(v);
    idx=1:1:length(st);
    set(handles.channels_listbox,'Value',idx);
else
    set(handles.channels_listbox,'Value',[]);
end;


function x_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function criterion_edit_Callback(hObject, eventdata, handles)
% hObject    handle to criterion_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function criterion_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to criterion_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function y_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function y_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function z_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function z_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
