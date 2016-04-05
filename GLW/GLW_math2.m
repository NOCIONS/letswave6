function varargout = GLW_math2(varargin)
% GLW_MATH2 MATLAB code for GLW_math2.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_math2_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_math2_OutputFcn, ...
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









% --- Executes just before GLW_math2 is made visible.
function GLW_math2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_math2 (see VARARGIN)
% Choose default command line output for GLW_math2
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
%store datasets
set(handles.datasetA_listbox,'Userdata',datasets);
%datasetA_listbox datasetB_listbox
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.datasetA_listbox,'String',st);
set(handles.datasetB_listbox,'String',st);

%table
if isempty(configuration.parameters.datasetsA);
else
    for i=1:length(configuration.parameters.datasetsA;
        tdata{i,1}=configuration.parameters.datasetsA{i};
        tdata{i,1}=configuration.parameters.datasetsB{i};
    end;
end;
set(handles.dataset_table,'Data',tdata);
%operation_popup
operation_string={'A+B','A-B','B-A','A*B','A/B','B/A'};
set(handles.operation_popup,'Userdata',operation_string);
set(handles.operation_popup,'String',operation_string);
a=find(strcmpi(operation_string,configuration.parameters.operation));
if isempty(a);
else
    set(handles.operation_popup,'Value',a(1));
end;
%update listboxes
for i=1:length(datasets);
    num_index(i)=header.datasize(3);
    num_channels(i)=header.datasize(2);
    num_epochs(i)=header.datasize(
%single_epoch
if configuration.parameters.selected_epoch==0;
    set(handles.single_epoch_chk,'Value',0);
    set(handles.single_epoch_popup,'Value',1);
else
    set(handles.single_epoch_chk,'Value',1);
    st=get(handles.single_epoch_popup,'String');
    if configuration.parameters.selected_epoch>length(st);
        set(handles.single_epoch_popup,'Value',1);
    else
        set(handles.single_epoch_popup,'Value',configuration.parameters.selected_epoch);
    end;
end;
%single_channel
if configuration.parameters.selected_channel==0;
    set(handles.single_channel_chk,'Value',0);
    set(handles.single_channel_popup,'Value',1);
else
    set(handles.single_channel_chk,'Value',1);
    st=get(handles.single_channel_popup,'String');
    if configuration.parameters.selected_channel>length(st);
        set(handles.single_channel_popup,'Value',1);
    else
        set(handles.single_channel_popup,'Value',configuration.parameters.selected_channel);
    end;
end;
%single_index
if configuration.parameters.selected_index==0;
    set(handles.single_index_chk,'Value',0);
    set(handles.single_index_popup,'Value',1);
else
    set(handles.single_index_chk,'Value',1);
    st=get(handles.single_index_popup,'String');
    if configuration.parameters.selected_index>length(st);
        set(handles.single_index_popup,'Value',1);
    else
        set(handles.single_index_popup,'Value',configuration.parameters.selected_index);
    end;
end;
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);





function update_listboxes(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%epoch_popup
st={};
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_popup,'String',st);
if get(handles.epoch_popup,'Value')>length(st);
    set(handles.epoch_popup,'Value',1);
end;
%channel_popup
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_popup,'String',st);
if get(handles.channel_popup,'Value')>length(st);
    set(handles.channel_popup,'Value',1);
end;
%index_popup
if isfield(header,'index_labels');
    set(handles.index_popup,'String',header.index_labels);
else
    st={};
    for i=1:header.datasize(3);
        st{i}=num2str(i);
    end;
    set(handles.index_popup,'String',st);
end;
if get(handles.index_popup,'Value')>length(st);
    set(handles.index_popup,'Value',1);
end;





% --- Outputs from this function are returned to the command line.
function varargout = GLW_math2_OutputFcn(hObject, eventdata, handles) 
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
%reference_dataset_name
st=get(handles.dataset_popup,'String');
configuration.parameters.reference_dataset_name=st{get(handles.dataset_popup,'Value')};
%selected_epoch
if get(handles.single_epoch_chk,'Value')==0;
    configuration.parameters.selected_epoch=0;
else
    configuration.parameters.selected_epoch=get(handles.epoch_popup,'Value');
end;
%selected_channel
if get(handles.single_channel_chk,'Value')==0;
    configuration.parameters.selected_channel=0;
else
    st=get(handles.channel_popup,'String');
    configuration.parameters.selected_channel=st{get(handles.channel_popup,'Value')};
end;
%selected_index
if get(handles.single_index_chk,'Value')==0;
    configuration.parameters.selected_index=0;
else
    configuration.parameters.selected_index=get(handles.index_popup,'Value');
end;
%operation
st=get(handles.operation_popup,'Userdata');
configuration.parameters.operation=st{get(handles.operation_popup,'Value')};
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




% --- Executes on selection change in operation_popup.
function operation_popup_Callback(hObject, eventdata, handles)
% hObject    handle to operation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function operation_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_listboxes(handles);


% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ref_side_popup.
function ref_side_popup_Callback(hObject, eventdata, handles)
% hObject    handle to ref_side_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ref_side_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_side_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in single_epoch_chk.
function single_epoch_chk_Callback(hObject, eventdata, handles)
% hObject    handle to single_epoch_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in epoch_popup.
function epoch_popup_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function epoch_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in single_channel_chk.
function single_channel_chk_Callback(hObject, eventdata, handles)
% hObject    handle to single_channel_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in channel_popup.
function channel_popup_Callback(hObject, eventdata, handles)
% hObject    handle to channel_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function channel_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in single_index_chk.
function single_index_chk_Callback(hObject, eventdata, handles)
% hObject    handle to single_index_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in index_popup.
function index_popup_Callback(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in datasetA_listbox.
function datasetA_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to datasetA_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns datasetA_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from datasetA_listbox


% --- Executes during object creation, after setting all properties.
function datasetA_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datasetA_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in datasetB_listbox.
function datasetB_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to datasetB_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns datasetB_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from datasetB_listbox


% --- Executes during object creation, after setting all properties.
function datasetB_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datasetB_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in single_epoch_chk.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to single_epoch_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of single_epoch_chk


% --- Executes on selection change in single_epoch_popup.
function single_epoch_popup_Callback(hObject, eventdata, handles)
% hObject    handle to single_epoch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns single_epoch_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from single_epoch_popup


% --- Executes during object creation, after setting all properties.
function single_epoch_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to single_epoch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in single_channel_chk.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to single_channel_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of single_channel_chk


% --- Executes on selection change in single_channel_popup.
function single_channel_popup_Callback(hObject, eventdata, handles)
% hObject    handle to single_channel_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns single_channel_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from single_channel_popup


% --- Executes during object creation, after setting all properties.
function single_channel_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to single_channel_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in single_index_chk.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to single_index_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of single_index_chk


% --- Executes on selection change in single_index_popup.
function single_index_popup_Callback(hObject, eventdata, handles)
% hObject    handle to single_index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns single_index_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from single_index_popup


% --- Executes during object creation, after setting all properties.
function single_index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to single_index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
