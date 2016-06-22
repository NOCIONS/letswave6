function varargout = CGLW_multi_viewer_continuous(varargin)
% CGLW_MULTI_VIEWER_CONTINUOUS MATLAB code for CGLW_multi_viewer_continuous.fig


% Last Modified by GUIDE v2.5 01-Nov-2015 07:22:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_multi_viewer_continuous_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_multi_viewer_continuous_OutputFcn, ...
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







% --- Executes just before CGLW_multi_viewer_continuous is made visible.
function CGLW_multi_viewer_continuous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_multi_viewer_continuous (see VARARGIN)
% Choose default command line output for CGLW_multi_viewer_continuous
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes CGLW_multi_viewer_continuous wait for user response (see UIRESUME)
% uiwait(handles.figure1);
%set fonts
%find objects with property FontSize
h=findobj(handles.figure1,'-property','FontSize');
%figure
figure(handles.figure1);
%set_GUI_parameters
%platform-specific
if ispc==1;
    load letswave_config_pc.mat
end;
if ismac==1;
    load letswave_config_mac.mat
end;
if and(isunix==1,ismac==0);
    load letswave_config_unix.mat
end;
%find objects with property FontSize
h=findobj(handles.figure1,'-property','FontSize');
%set fonts
set(h,'FontUnits',letswave_config.FontUnits);
set(h,'FontSize',letswave_config.FontSize);
set(h,'FontName',letswave_config.FontName);
%filenames
inputfiles=varargin{2};
for i=1:length(inputfiles);
    [p n e]=fileparts(inputfiles{i});
    st{i}=n;
end;
%datasets_header, datasets_data
for i=1:length(st);
    [datasets_header(i).header datasets_data(i).data]=CLW_load(inputfiles{i});
end;
set(handles.dataset_popup,'UserData',datasets_header);
set(handles.epoch_popup,'UserData',datasets_data);
%set default y_scale
tp=max(abs(datasets_data(1).data(:)));
set(handles.y_scale_edit,'String',num2str(tp));
%set default DS
SR=1/datasets_header(1).header.xstep;
DS=fix(SR/256);
if DS>1
    set(handles.DS_edit,'String',num2str(DS));
end;
%dataset_listbox
st={};
for i=1:length(datasets_header);
    st{i}=datasets_header(i).header.name;
end;
set(handles.dataset_popup,'String',st);
set(handles.dataset_popup,'Value',1);
update_popups(handles);
fetch_data(handles);
update_graph(handles);
addlistener(handles.axes,'YLim','PostSet',@(hAxes,eventData) axis_was_changed(handles));
grid on;




function axis_was_changed(handles);
a=axis(handles.axes);
set(handles.x_start_edit,'String',num2str(a(1)));
set(handles.x_width_edit,'String',num2str(a(2)-a(1)));
%set(handles.y_scale_edit,'String',num2str(a(4)-a(3)));






function fetch_data(handles);
%dataset_pos
dataset_pos=get(handles.dataset_popup,'Value');
%header
headers=get(handles.dataset_popup,'UserData');
header=headers(dataset_pos).header;
%data
datas=get(handles.epoch_popup,'UserData');
%tpx
data.tpx=1:header.datasize(6);
data.tpx=((data.tpx-1)*header.xstep)+header.xstart;
%downsample?
DS=fix(str2num(get(handles.DS_edit,'String')));
if DS>1;
    data.tpx=downsample(data.tpx,DS);
end;
%epoch_pos
epoch_pos=get(handles.epoch_popup,'Value');
%index_pos
index_pos=get(handles.index_popup,'Value');
%dy
if header.datasize(4)==1;
    dy=1;
else
    y=str2num(get(handles.y_edit,'String'));
    dy=((y-header.ystart)*header.ystep)+1;
end;
%dz
if header.datasize(5)==1;
    dz=1;
else
    z=str2num(get(handles.z_edit,'String'));
    dz=((z-header.zstart)*header.zstep)+1;
end;
%data.tpy
data.tpy=squeeze(datas(dataset_pos).data(epoch_pos,:,index_pos,dy,dz,:));
%filter?
low_chk=get(handles.low_chk,'Value');
high_chk=get(handles.high_chk,'Value');
if and(low_chk,high_chk);
    Fs=1/header.xstep;
    fnyquist=Fs/2;
    low_value=str2num(get(handles.low_filter_edit,'String'));
    high_value=str2num(get(handles.high_filter_edit,'String'));
    [bLow,aLow]=butter(2,high_value/fnyquist,'low');
    [bHigh,aHigh]=butter(2,low_value/fnyquist,'high');
    b=[bLow;bHigh];
    a=[aLow;aHigh];
    for chanpos=1:size(data.tpy,1);
        data.tpy(chanpos,:)=filtfilt(b(1,:),a(1,:),data.tpy(chanpos,:));
        data.tpy(chanpos,:)=filtfilt(b(2,:),a(2,:),data.tpy(chanpos,:));
    end;
end;
if or(low_chk,high_chk);
    Fs=1/header.xstep;
    fnyquist=Fs/2;
    if high_chk;
        high_value=str2num(get(handles.high_filter_edit,'String'));
        [b,a]=butter(4,high_value/fnyquist,'low');
    end;
    if low_chk;
        low_value=str2num(get(handles.low_filter_edit,'String'));
        [b,a]=butter(4,low_value/fnyquist,'high');
    end;
    for chanpos=1:size(data.tpy,1);
        data.tpy(chanpos,:)=filtfilt(b,a,data.tpy(chanpos,:));
    end;
end;
%notch filter?
notch=get(handles.notch_popup,'Value');
if notch==2;
    %50 Hz notch
    Fs=1/header.xstep;
    fnyquist=Fs/2;
    [b,a]=butter(4,[48/fnyquist 52/fnyquist],'stop');
    for chanpos=1:size(data.tpy,1);
        data.tpy(chanpos,:)=filtfilt(b,a,data.tpy(chanpos,:));
    end;
end;
if notch==3;
    %60 Hz notch
    Fs=1/header.xstep;
    fnyquist=Fs/2;
    [b,a]=butter(4,[58/fnyquist 62/fnyquist],'stop');
    for chanpos=1:size(data.tpy,1);
        data.tpy(chanpos,:)=filtfilt(b,a,data.tpy(chanpos,:));
    end;
end;
%DS
if DS>1
    data.tpy=downsample(data.tpy',DS)';
end;
set(handles.event_listbox,'UserData',data);
set(handles.y_scale_edit,'UserData',header);
%selected_channels
selected_channels=get(handles.channel_listbox,'Value');
%plot
a=plot(handles.axes,data.tpx,data.tpy(selected_channels,:));
grid on;
set(handles.x_start_edit,'UserData',a);
pan on;
%plot events
selected_events=get(handles.reposition_btn,'UserData');
if isempty(selected_events);
else
    hold(handles.axes,'on');
    y=str2num(get(handles.y_scale_edit,'String'));
    for i=1:length(selected_events);
        event_plot_handles{i}=plot([selected_events(i).latency selected_events(i).latency],[-y y],'r:','LineWidth',2);
    end;
    hold(handles.axes,'off');
    set(handles.x_width_edit,'Userdata',event_plot_handles);
end;
%update_axis
update_axis(handles);




function update_axis(handles);
%x1,x2
x1=str2num(get(handles.x_start_edit,'String'));
x2=x1+str2num(get(handles.x_width_edit,'String'));
y_scale=str2num(get(handles.y_scale_edit,'String'));
y1=-y_scale;
y2=y_scale;
%events
event_handles=get(handles.x_width_edit,'Userdata');
if isempty(event_handles);
else
    for i=1:length(event_handles);
        set(event_handles{i},'YData',[y1 y2]);
    end;
end;
%axis
axis(handles.axes,[x1 x2 y1 y2]);





function update_graph(handles);
%data
data=get(handles.event_listbox,'UserData');
%header
header=get(handles.y_scale_edit,'UserData');
%yscale
y_scale=str2num(get(handles.y_scale_edit,'String'));
%xaxis
x_start=str2num(get(handles.x_start_edit,'String'));
x_width=str2num(get(handles.x_width_edit,'String'));
%selected_channels
selected_channels=get(handles.channel_listbox,'Value');
%dx1,dx2
[a,dx1]=min(abs(data.tpx-x_start));
[a,dx2]=min(abs(data.tpx-(x_start+x_width)));
%tpy
tpy=data.tpy(selected_channels,:);
%y_offset
num_waves=length(selected_channels);
if num_waves>1;
    y_step=(y_scale*2)/(num_waves);
    for i=1:num_waves;
        y_offset(i)=-y_scale+(y_step/2)+(y_step*(i-1));
    end;
else
    y_offset=0;
end;
y_offset=mean(tpy(:,dx1:dx2),2)+y_offset';
%subtract mean
tpy=bsxfun(@minus,tpy,y_offset);
%axis_handle
axis_handle=get(handles.x_start_edit,'UserData');
%update YData
num_wave_handles=length(axis_handle);
num_waves=size(tpy,1);
for i=1:min([num_wave_handles num_waves]);
    set(axis_handle(i),'YData',tpy(i,:));
end;
if num_wave_handles>num_waves;
    delete(axis_handle(num_waves+1:end));
    axis_handle=axis_handle(1:num_waves);
end;
if num_wave_handles<num_waves;
    hold on;
    for i=num_wave_handles+1:num_waves
        axis_handle(i)=plot(handles.axes,data.tpx,tpy(i,:));
    end;
    hold off;
end;
set(handles.x_start_edit,'UserData',axis_handle);





function update_popups(handles);
%dataset_pos
dataset_pos=get(handles.dataset_popup,'Value');
%header
headers=get(handles.dataset_popup,'UserData');
header=headers(dataset_pos).header;
%epoch_popup
st={};
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
if get(handles.epoch_popup,'Value')>length(st);
    set(handles.epoch_popup,'Value',1);
end;
set(handles.epoch_popup,'String',st);
%index_popup
if header.datasize(3)>1;
    set(handles.index_text,'Visible','on');
    set(handles.index_popup,'Visible','on');
    if isfield(header,'index_labels');
        set(handles.index_popup,'String',header.index_labels);
        set(handles.index_popup,'Value',1);
    else
        st={};
        for i=1:header.datasize(3);
            st{i}=num2str(i);
        end;
        set(handles.index_popup,'String',st);
        set(handles.index_popup,'Value',1);
    end;
else
    set(handles.index_text,'Visible','off');
    set(handles.index_popup,'Visible','off');
    set(handles.index_popup,'Value',1);
end;
%y
if header.datasize(5)>1;
    set(handles.y_text,'Visible','on');
    set(handles.y_edit,'Visible','on');
    set(handles.y_edit,'String',num2str(header.ystart));
else
    set(handles.y_text,'Visible','off');
    set(handles.y_edit,'Visible','off');
    set(handles.y_edit,'String',num2str(header.ystart));
end;
%z
if header.datasize(4)>1;
    set(handles.z_text,'Visible','on');
    set(handles.z_edit,'Visible','on');
    set(handles.z_edit,'String',num2str(header.zstart));
else
    set(handles.z_text,'Visible','off');
    set(handles.z_edit,'Visible','off');
    set(handles.z_edit,'String',num2str(header.zstart));
end;
%channel_listbox
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
a=get(handles.channel_listbox,'Value');
a(find(a>length(st)))=[];
set(handles.channel_listbox,'Value',a);
%event_listbox
event_ok=0;
if isfield(header,'events');
    if isempty(header.events);
    else
        epoch_pos=get(handles.epoch_popup,'Value');
        for i=1:length(header.events);
            event_epochs(i)=header.events(i).epoch;
        end;
        selected_events=find(event_epochs==epoch_pos);
        if isempty(selected_events);
        else
            event_ok=1;
        end;
    end;
end;
st={};
if event_ok==1;
    set(handles.reposition_btn,'UserData',header.events(selected_events));
    for i=1:length(selected_events);
        st{i}=[header.events(selected_events(i)).code ' [' num2str(header.events(selected_events(i)).latency) ']'];
    end;
else
    set(handles.reposition_btn,'UserData',[]);
end;
set(handles.event_listbox,'String',st);
set(handles.event_listbox,'Value',1);










% --- Outputs from this function are returned to the command line.
function varargout = CGLW_multi_viewer_continuous_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;





% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_popups(handles);
fetch_data(handles);
update_graph(handles);






% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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



function y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_axis(handles);
update_graph(handles);



% --- Executes during object creation, after setting all properties.
function x_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_axis(handles);
update_graph(handles);




% --- Executes during object creation, after setting all properties.
function x_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selected_events=get(handles.reposition_btn,'UserData');
if isempty(selected_events);
    return;
end;
a=selected_events(get(handles.event_listbox,'Value')).latency;
x_width=str2num(get(handles.x_width_edit,'String'));
set(handles.x_start_edit,'String',num2str(a-(x_width/2)));
update_axis(handles);



% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);
update_axis(handles);





% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_scale_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_scale_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_axis(handles);
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function y_scale_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_scale_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in reposition_btn.
function reposition_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reposition_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_axis(handles);
%update_graph(handles);


% --- Executes on button press in zoom_btn.
function zoom_btn_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom on;


% --- Executes on button press in pan_btn.
function pan_btn_Callback(hObject, eventdata, handles)
% hObject    handle to pan_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan on;



function DS_edit_Callback(hObject, eventdata, handles)
% hObject    handle to DS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function DS_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DS_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function low_filter_edit_Callback(hObject, eventdata, handles)
% hObject    handle to low_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function low_filter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function high_filter_edit_Callback(hObject, eventdata, handles)
% hObject    handle to high_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function high_filter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in low_chk.
function low_chk_Callback(hObject, eventdata, handles)
% hObject    handle to low_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);





% --- Executes on button press in high_chk.
function high_chk_Callback(hObject, eventdata, handles)
% hObject    handle to high_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);


% --- Executes on selection change in notch_popup.
function notch_popup_Callback(hObject, eventdata, handles)
% hObject    handle to notch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);



% --- Executes during object creation, after setting all properties.
function notch_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
