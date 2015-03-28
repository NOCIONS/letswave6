function varargout = GLW_rereference_advanced(varargin)
% GLW_REREFERENCE_ADVANCED MATLAB code for GLW_rereference_advanced.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_rereference_advanced_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_rereference_advanced_OutputFcn, ...
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









% --- Executes just before GLW_rereference_advanced is made visible.
function GLW_rereference_advanced_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_rereference_advanced (see VARARGIN)
% Choose default command line output for GLW_rereference_advanced
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
if isempty(datasets);
    return;
end;
%header
header=datasets(1).header;
%fill listboxes
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.active_channel_listbox,'String',st);
set(handles.reference_channel_listbox,'String',st);
%montage listbox
%configuration.parameters.active_channels
%configuration.parameters.reference_channels
mtg.active_channel_labels=configuration.parameters.active_channel_labels;
mtg.reference_channel_labels=configuration.parameters.reference_channel_labels;
set(handles.montage_listbox,'Userdata',mtg);
update_montage_listbox(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






function update_montage_listbox(handles);
%mtg
mtg=get(handles.montage_listbox,'Userdata');
%channel_labels
st={};
if isempty(mtg.active_channel_labels);
else
    for i=1:length(mtg.active_channel_labels);
        st{i}=[mtg.active_channel_labels{i} ' - ' mtg.reference_channel_labels{i}];
    end;
end;
set(handles.montage_listbox,'String',st);





% --- Outputs from this function are returned to the command line.
function varargout = GLW_rereference_advanced_OutputFcn(hObject, eventdata, handles) 
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
%configuration.parameters.active_channels
%configuration.parameters.reference_channels
mtg=get(handles.montage_listbox,'Userdata');
configuration.parameters.active_channel_labels=mtg.active_channel_labels;
configuration.parameters.reference_channel_labels=mtg.reference_channel_labels;
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
    set(handleS.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on selection change in active_channel_listbox.
function active_channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to active_channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function active_channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to active_channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in reference_channel_listbox.
function reference_channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to reference_channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function reference_channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reference_channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in insert_btn.
function insert_btn_Callback(hObject, eventdata, handles)
% hObject    handle to insert_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%selected row
selected_row=get(handles.montage_listbox,'Value');
%mtg
mtg=get(handles.montage_listbox,'Userdata');
%channel_labels
channel_labels=get(handles.active_channel_listbox,'String');
%shift
mtg.active_channel_labels(selected_row+1:end+1)=mtg.active_channel_labels(selected_row:end);
mtg.reference_channel_labels(selected_row+1:end+1)=mtg.reference_channel_labels(selected_row:end);
%insert
mtg.active_channel_labels{selected_row}=channel_labels{get(handles.active_channel_listbox,'Value')};
mtg.reference_channel_labels{selected_row}=channel_labels{get(handles.reference_channel_listbox,'Value')};
%
set(handles.montage_listbox,'Userdata',mtg);
%update table
update_montage_listbox(handles);








% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%mtg
mtg=get(handles.montage_listbox,'Userdata');
%channel_labels
channel_labels=get(handles.active_channel_listbox,'String');
mtg.active_channel_labels{end+1}=channel_labels{get(handles.active_channel_listbox,'Value')};
mtg.reference_channel_labels{end+1}=channel_labels{get(handles.reference_channel_listbox,'Value')};
set(handles.montage_listbox,'Userdata',mtg);
update_montage_listbox(handles);







% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%mtg
mtg=get(handles.montage_listbox,'UserData');
%selected row
selected_row=get(handles.montage_listbox,'Value');
%delete
mtg.active_channel_labels(selected_row)=[];
mtg.reference_channel_labels(selected_row)=[];
set(handles.montage_listbox,'Userdata',mtg);
update_montage_listbox(handles);








% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%mtg
mtg=get(handles.montage_listbox,'Userdata');
mtg.active_channel_labels=[];
mtg.reference_channel_labels=[];
set(handles.montage_listbox,'Userdata',[]);
update_montage_listbox(handles);
set(handles.montage_listbox,'Value',[]);





% --- Executes on button press in move_up_btn.
function move_up_btn_Callback(hObject, eventdata, handles)
% hObject    handle to move_up_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%mtg
mtg=get(handles.montage_listbox,'Userdata');
%selected row
selected_row=get(handles.montage_listbox,'Value');
%permute
if selected_row>1;
    tp_active=mtg.active_channel_labels{selected_row};
    tp_reference=mtg.reference_channel_labels{selected_row};
    mtg.active_channel_labels{selected_row}=mtg.active_channel_labels{selected_row-1};
    mtg.reference_channel_labels{selected_row}=mtg.reference_channel_labels{selected_row-1};
    mtg.active_channel_labels{selected_row-1}=tp_active;
    mtg.reference_channel_labels{selected_row-1}=tp_reference;
end;
set(handles.montage_listbox,'Userdata',mtg);
update_montage_listbox(handles);
%update selection
set(handles.montage_listbox,'Value',selected_row-1);






% --- Executes on button press in move_down_btn.
function move_down_btn_Callback(hObject, eventdata, handles)
% hObject    handle to move_down_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%mtg
mtg=get(handles.montage_listbox,'Userdata');
%selected row
selected_row=get(handles.montage_listbox,'Value');
%permute
if selected_row<length(mtg.active_channel_labels);
    tp_active=mtg.active_channel_labels{selected_row};
    tp_reference=mtg.reference_channel_labels{selected_row};
    mtg.active_channel_labels{selected_row}=mtg.active_channel_labels{selected_row+1};
    mtg.reference_channel_labels{selected_row}=mtg.reference_channel_labels{selected_row+1};
    mtg.active_channel_labels{selected_row+1}=tp_active;
    mtg.reference_channel_labels{selected_row+1}=tp_reference;
end;
set(handles.montage_listbox,'Userdata',mtg);
update_montage_listbox(handles);
%update selection
set(handles.montage_listbox,'Value',selected_row+1);










% --- Executes on selection change in montage_listbox.
function montage_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to montage_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function montage_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to montage_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function delete_btn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
