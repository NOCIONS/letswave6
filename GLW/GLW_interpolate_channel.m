function varargout = GLW_interpolate_channel(varargin)
% GLW_INTERPOLATE_CHANNEL MATLAB code for GLW_interpolate_channel.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_interpolate_channel_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_interpolate_channel_OutputFcn, ...
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









% --- Executes just before GLW_interpolate_channel is made visible.
function GLW_interpolate_channel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_interpolate_channel (see VARARGIN)
% Choose default command line output for GLW_interpolate_channel
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
%datasets
if isempty(datasets);
    return;
end;
%header
header=datasets(1).header;
%channel_labels
for i=1:length(header.chanlocs);
    channel_labels{i}=header.chanlocs(i).labels;
end;
%channel_listbox
set(handles.channel_listbox,'String',channel_labels);
if isempty(configuration.parameters.channel_to_interpolate)
else
    a=find(strcmpi(configuration.parameters.channel_to_interpolate,channel_labels));
    if isempty(a);
    else
        set(handles.channel_listbox,'Value',a(1));
    end;
end;
%channel_interpolate_listbox
set(handles.channel_interpolate_listbox,'String',channel_labels);
chan_idx=[];
if isempty(configuration.parameters.channels_to_average);
else
    for i=1:length(configuration.parameters.channels_to_average);
        a=find(strcmpi(configuration.parameters.channels_to_average{i},channel_labels));
        chan_idx=[chan_idx a];
    end;
end;
set(handles.channel_interpolate_listbox,'Value',chan_idx);
%store header
set(handles.find_btn,'Userdata',header);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_interpolate_channel_OutputFcn(hObject, eventdata, handles) 
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
st=get(handles.channel_listbox,'String');
configuration.parameters.channel_to_interpolate=st{get(handles.channel_listbox,'Value')};
configuration.parameters.channels_to_average=st(get(handles.channel_interpolate_listbox,'Value'));
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


% --- Executes on selection change in channel_interpolate_listbox.
function channel_interpolate_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_interpolate_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function channel_interpolate_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_interpolate_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in find_btn.
function find_btn_Callback(hObject, eventdata, handles)
% hObject    handle to find_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%num_electrodes
num_channels=str2num(get(handles.num_electrodes_edit,'String'));
%header
header=get(handles.find_btn,'Userdata');
%channel_to_inteprolate
bad_channel=get(handles.channel_listbox,'Value');
%distances
dist=[];
if header.chanlocs(bad_channel).topo_enabled==1;
    for i=1:length(header.chanlocs);
        if header.chanlocs(i).topo_enabled==1;
            dist(i)=sqrt((header.chanlocs(i).X-header.chanlocs(bad_channel).X)^2+(header.chanlocs(i).Y-header.chanlocs(bad_channel).Y)^2+(header.chanlocs(i).Z-header.chanlocs(bad_channel).Z)^2);
        else
            dist(i)=-1;
        end;
        if i==bad_channel;
            dist(i)=-1;
        end;
    end;
    dist(find(dist==-1))=max(dist);
    [tpv,tpi]=sort(dist);
    closest_channels=tpi(1:num_channels);
    set(handles.channel_interpolate_listbox,'Value',closest_channels);
end;







function num_electrodes_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_electrodes_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function num_electrodes_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_electrodes_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
