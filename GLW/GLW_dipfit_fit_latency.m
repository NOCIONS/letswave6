function varargout = GLW_dipfit_fit_latency(varargin)
% GLW_DIPFIT_FIT_LATENCY MATLAB code for GLW_dipfit_fit_latency.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_dipfit_fit_latency_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_dipfit_fit_latency_OutputFcn, ...
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









% --- Executes just before GLW_dipfit_fit_latency is made visible.
function GLW_dipfit_fit_latency_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_dipfit_fit_latency (see VARARGIN)
% Choose default command line output for GLW_dipfit_fit_latency
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
%dipole_model
st={'single','pairX','pairY','pairZ','pair'};
set(handles.dipole_model_popup,'Userdata',st);
a=find(strcmpi(configuration.parameters.dipole_model,st));
if isempty(a);
else
    set(handles.dipole_model_popup,'Value',a(1));
end;
%gridsearch_resolution
set(handles.gridsearch_resolution_edit,'String',num2str(configuration.parameters.gridsearch_resolution));
%dipole_label
set(handles.dipole_label_edit,'String',configuration.parameters.dipole_label);
%latency
set(handles.lower_limit_edit,'String',num2str(configuration.parameters.latency));
%header
header=datasets(1).header;
%dataset 
set(handles.epoch_listbox,'Userdata',datasets(1));
%epoch_listbox
st={};
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
set(handles.epoch_listbox,'Value',configuration.parameters.epoch);
%channel_listbox
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
%index_popup
if header.datasize(3)==1;
    set(handles.index_popup,'Enable','off');
    set(handles.index_popup,'String','1');
    set(handles.index_popup,'Value',1);
else
    if isfield(header,'index_labels');
        set(handles.index_popup,'String',header.index_labels);
        set(handles.index_popup,'Value',1);
    else
        st={};
        for i=1:header.datasize(3);
            st{i}=num2str(i);
        end;
        set(handles.index_popup,'String',st);
    end;
end;
%Y
if header.datasize(5)==1;
    set(handles.Y_edit,'Enable','off');
end;
%Z
if header.datasize(4)==1;
    set(handles.Z_edit,'Enable','off');
end;
%refresh
refresh_cursor_objects(handles);
refresh_graph(handles);
%zoom mode
zoom(handles.axes,'on');
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);



function refresh_cursor_objects(handles);
cursor_mode=get(handles.fit_selection_popup,'Value');
if cursor_mode==1;
    set(handles.lower_limit_rb,'String','Set latency');
    set(handles.upper_limit_rb,'Visible','off');
    set(handles.upper_limit_edit,'Visible','off');
end;
if cursor_mode==2;
    set(handles.lower_limit_rb,'String','Set lower latency limit');
    set(handles.upper_limit_rb,'Visible','on');
    set(handles.upper_limit_edit,'Visible','on');
end;
if cursor_mode==3;
    set(handles.lower_limit_rb,'String','Set lower latency limit');
    set(handles.upper_limit_rb,'Visible','on');
    set(handles.upper_limit_edit,'Visible','on');
end;







function refresh_graph(handles);
%axis
first_time=get(handles.channel_listbox,'Userdata');
if isempty(first_time);
else
    old_axis=axis(handles.axes);
end;
%data
dataset=get(handles.epoch_listbox,'Userdata');
%header
header=dataset.header;
%tpx
tpx=1:1:header.datasize(6);
tpx=((tpx-1)*header.xstep)+header.xstart;
%epochpos,chanpos,indexpos
epochpos=get(handles.epoch_listbox,'Value');
chanpos=get(handles.channel_listbox,'Value');
indexpos=get(handles.index_popup,'Value');
%dy,dz
if header.datasize(5)==1;
    dy=1;
else
    y=str2num(get(handles.Y_edit,'String'));
    dy=round(((y-header.ystart)/header.ystep)+1);
end;
if header.datasize(4)==1;
    dz=1;
else
    z=str2num(get(handles.Z_edit,'String'));
    dz=round(((z-header.zstart)/header.zstep)+1);
end;
%tpy
tpy=squeeze(dataset.data(epochpos,chanpos,indexpos,dy,dz,:));
%plot
plot(handles.axes,tpx,tpy);
%legend?
if get(handles.legend_chk,'Value')==1;
    st=get(handles.channel_listbox,'String');
    st=st(get(handles.channel_listbox,'Value'));
    legend(handles.axes,st);
end;
%axis
if isempty(first_time);
    set(handles.channel_listbox,'Userdata',1);
    old_axis=axis;
    set(handles.lower_limit_edit,'Userdata',[old_axis(3) old_axis(4)]);
else
    axis(handles.axes,old_axis);
end;
%limits
cursor_mode=get(handles.fit_selection_popup,'Value');
y=get(handles.lower_limit_edit,'Userdata');
x1=str2num(get(handles.lower_limit_edit,'String'));
hold(handles.axes,'on');
plot(handles.axes,[x1 x1],y,'b:');
if cursor_mode==1;
else
    x2=str2num(get(handles.upper_limit_edit,'String'));
    plot(handles.axes,[x2 x2],y,'r:');
end;
hold(handles.axes,'off');









% --- Outputs from this function are returned to the command line.
function varargout = GLW_dipfit_fit_latency_OutputFcn(hObject, eventdata, handles) 
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
st=get(handles.dipole_model_popup,'Userdata');
configuration.parameters.dipole_model=st{get(handles.dipole_model_popup,'Value')};
configuration.parameters.gridsearch_resolution=str2num(get(handles.gridsearch_resolution_edit,'String'));
configuration.parameters.dipole_label=get(handles.dipole_label_edit,'String');
configuration.parameters.epoch=get(handles.epoch_listbox,'Value');
%latency
cursor_mode=get(handles.fit_selection_popup,'Value');
if cursor_mode==1;
    lat=str2num(get(handles.lower_limit_edit,'String'));
else
    lat1=str2num(get(handles.lower_limit_edit,'String'));
    lat2=str2num(get(handles.upper_limit_edit,'String'));
    %dataset
    dataset=get(handles.epoch_listbox,'Userdata');
    %header
    header=dataset.header;
    %dx,x
    dx=1:1:header.datasize(6);
    x=((dx-1)*header.xstep)+header.xstart;
    %dlat1, dlat2
    [a,b]=min(abs(x-lat1));
    dlat1=b;
    [a,b]=min(abs(x-lat2));
    dlat2=b;
    %epochpos
    epochpos=get(handles.epoch_listbox,'Value');
    %chanpos
    chanpos=get(handles.channel_listbox,'Value');
    %indexpos
    indexpos=get(handles.index_popup,'Value');
    %dy,dz
    if header.datasize(5)==1;
        dy=1;
    else
        y=str2num(get(handles.Y_edit,'String'));
        dy=round(((y-header.ystart)/header.ystep)+1);
    end;
    if header.datasize(4)==1;
        dz=1;
    else
        z=str2num(get(handles.Z_edit,'String'));
        dz=round(((z-header.zstart)/header.zstep)+1);
    end;
    %tp
    tp=squeeze(dataset.data(epochpos,chanpos,indexpos,dz,dy,dlat1:dlat2));
    if length(chanpos)>1;
        tp=mean(tp,1);
    end;
    if cursor_mode==2;
        [a,b]=max(tp);
    end;
    if cursor_mode==3;
        [a,b]=min(tp);
    end;
    %dlat
    dlat=(b+dlat1)-1;
    %lat
    lat=x(dlat);
end;
configuration.parameters.latency=lat;
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


% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in epoch_listbox.
function epoch_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_graph(handles);



% --- Executes during object creation, after setting all properties.
function epoch_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
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
refresh_graph(handles);



% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
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
refresh_graph(handles);



% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_graph(handles);



% --- Executes during object creation, after setting all properties.
function Y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to Z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_graph(handles);


% --- Executes during object creation, after setting all properties.
function Z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in legend_chk.
function legend_chk_Callback(hObject, eventdata, handles)
% hObject    handle to legend_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_graph(handles);




% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in lower_limit_rb.
function lower_limit_rb_Callback(hObject, eventdata, handles)
% hObject    handle to lower_limit_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y]=ginput(1);
set(handles.lower_limit_edit,'String',num2str(x));
set(handles.lower_limit_rb,'Value',0);
zoom(handles.axes,'on');
refresh_graph(handles);




% --- Executes on button press in upper_limit_rb.
function upper_limit_rb_Callback(hObject, eventdata, handles)
% hObject    handle to upper_limit_rb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[x,y]=ginput(1);
set(handles.upper_limit_edit,'String',num2str(x));
set(handles.upper_limit_rb,'Value',0);
zoom(handles.axes,'on');
refresh_graph(handles);





function lower_limit_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lower_limit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function lower_limit_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lower_limit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function upper_limit_edit_Callback(hObject, eventdata, handles)
% hObject    handle to upper_limit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function upper_limit_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upper_limit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in fit_selection_popup.
function fit_selection_popup_Callback(hObject, eventdata, handles)
% hObject    handle to fit_selection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_cursor_objects(handles);
refresh_graph(handles);




% --- Executes during object creation, after setting all properties.
function fit_selection_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fit_selection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dipole_model_popup.
function dipole_model_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dipole_model_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function dipole_model_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipole_model_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridsearch_resolution_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gridsearch_resolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function gridsearch_resolution_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridsearch_resolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dipole_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dipole_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function dipole_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipole_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset_axis_btn.
function reset_axis_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reset_axis_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axis(handles.axes,'tight');
