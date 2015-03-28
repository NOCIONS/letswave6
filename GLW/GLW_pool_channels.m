function varargout = GLW_pool_channels(varargin)
% GLW_POOL_CHANNELS MATLAB code for GLW_pool_channels.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_pool_channels_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_pool_channels_OutputFcn, ...
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









% --- Executes just before GLW_pool_channels is made visible.
function GLW_pool_channels_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_pool_channels (see VARARGIN)
% Choose default command line output for GLW_pool_channels
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
%header > channel labels
header=datasets(1).header;
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
%update channels_listbox
set(handles.channel_listbox,'String',st(:));
table={};
%find channels in channel_labels
if isempty(configuration.parameters.channel_labels);
    channel_info=[];
else
    j=1;
    channel_info=[];
    for i=1:length(configuration.parameters.channel_labels);
        a=find(strcmpi(configuration.parameters.channel_labels{i},st(:))==1);
        if isempty(a);
        else
            table{j,1}=a(1);
            table{j,2}=configuration.parameters.channel_weights(i);
            j=j+1;
        end;
    end;
end;
set(handles.chan_table,'Data',table);
set(handles.keep_original_channels_chk,'Value',configuration.parameters.keep_original_channels);
set(handles.mixed_channel_label_edit,'String',configuration.parameters.mixed_channel_label);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_pool_channels_OutputFcn(hObject, eventdata, handles) 
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
%fetch table
table=get(handles.chan_table,'Data');
configuration.parameters.channel_labels=table(:,1)';
configuration.parameters.channel_weights=cell2mat(table(:,2)');
configuration.parameters.keep_original_channels=get(handles.keep_original_channels_chk,'Value');
configuration.parameters.mixed_channel_label=get(handles.mixed_channel_label_edit,'String');
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


% --- Executes on button press in all_1_btn.
function all_1_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_1_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=get(handles.chan_table,'Data');
if isempty(data);
else
    for i=1:length(data);
        data{i,2}=1;
    end;
end;
set(handles.chan_table,'Data',data);






% --- Executes during object creation, after setting all properties.
function all_1_btn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to all_1_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in all_0_btn.
function all_0_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_0_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data=get(handles.chan_table,'Data');
if isempty(data);
else
    for i=1:length(data);
        data{i,2}=0;
    end;
end;
set(handles.chan_table,'Data',data);






% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%data
data=get(handles.chan_table,'Data');
%v
st=get(handles.channel_listbox,'String');
v=get(handles.channel_listbox,'Value');
if isempty(v);
else
    for j=1:length(v);
        if isempty(data);
            data{1,1}=st{v(j)};
            data{1,2}=1;
        else
            data{end+1,1}=st{v(j)};
            data{end,2}=1;
        end;
    end;
end;
set(handles.chan_table,'Data',data);






% --- Executes on button press in add_all_btn.
function add_all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%data
data={};
%v
st=get(handles.channel_listbox,'String');
for j=1:length(st);
    if isempty(data);
        data{1,1}=st{j};
        data{1,2}=1;
    else
        data{end+1,1}=st{j};
        data{end,2}=1;
    end;
end;
set(handles.chan_table,'Data',data);





% --- Executes on button press in remove_all_btn.
function remove_all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to remove_all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.chan_table,'Data',{});





function mixed_channel_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to mixed_channel_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function mixed_channel_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mixed_channel_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
