function varargout = CGLW_SEEG_viewer(varargin)
% CGLW_SEEG_VIEWER MATLAB code for CGLW_SEEG_viewer.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_SEEG_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_SEEG_viewer_OutputFcn, ...
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









% --- Executes just before CGLW_SEEG_viewer is made visible.
function CGLW_SEEG_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_SEEG_viewer (see VARARGIN)
% Choose default command line output for CGLW_SEEG_viewer
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%filenames
inputfiles=varargin{2};
set(handles.files_popup,'Userdata',inputfiles);
for i=1:length(inputfiles);
    [p n e]=fileparts(inputfiles{i});
    st{i}=n;
end;
set(handles.files_popup,'String',st);
set(handles.files_popup,'Value',1);
%epoch_popup
header=CLW_load_header(inputfiles{1});
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_popup,'String',st);
set(handles.epoch_popup,'Value',1);
%axis
axis off;
%load MRI data
load('BEM_standard_mri');
mri_v.data=mri.anatomy;
mri_v.X=1:1:size(mri_v.data,1);
mri_v.Y=1:1:size(mri_v.data,2);
mri_v.Z=1:1:size(mri_v.data,3);
xt=-91;
yt=-126;
zt=-73;
mri_v.X=mri_v.X+xt;
mri_v.Y=mri_v.Y+yt;
mri_v.Z=mri_v.Z+zt;
set(handles.add_btn,'Userdata',mri_v);
%update_mri_data
axes(handles.axes1);
colormap(gray);
axes(handles.axes2);
colormap(gray);
axes(handles.axes3);
colormap(gray);
update_mri_data(handles);
%update_files_popup
update_files_popup(handles);
%update waves_listbox
update_waves_listbox(handles);
%
axis(handles.wave_axes,'on');







function update_mri_data(handles);
%mri
mri=get(handles.add_btn,'Userdata');
%x,y,z
x=str2num(get(handles.mri_x_edit,'String'));
y=str2num(get(handles.mri_y_edit,'String'));
z=str2num(get(handles.mri_z_edit,'String'));
%dx,dy,dz
[a,dx]=min(abs(mri.X-x));
[a,dy]=min(abs(mri.Y-y));
[a,dz]=min(abs(mri.Z-z));
%image1 (Z)
axes(handles.axes1);
imagesc(mri.Y,mri.X,squeeze(mri.data(:,:,dz))',[0 255]);
set(gca,'YDir','normal');
axis(gca,'off');
%image2 (Y)
axes(handles.axes2);
imagesc(mri.Z,mri.X,squeeze(mri.data(:,dy,:))',[0 255]);
set(gca,'YDir','normal');
axis(gca,'off');
%image3 (X)
axes(handles.axes3);
imagesc(mri.Z,mri.Y,squeeze(mri.data(dx,:,:))',[0 255]);
set(gca,'YDir','normal');
axis(gca,'off');
%update_mri_bubbles
update_mri_bubbles(handles);





function update_mri_electrodes(handles);
%datasets
datasets=get(handles.files_listbox,'Userdata');
%mri_x,mri_y,mri_z
mri_x=str2num(get(handles.mri_x_edit,'String'));
mri_y=str2num(get(handles.mri_y_edit,'String'));
mri_z=str2num(get(handles.mri_z_edit,'String'));
%tolerance
tol_x=str2num(get(handles.tol_x_edit,'String'));
tol_y=str2num(get(handles.tol_y_edit,'String'));
tol_z=str2num(get(handles.tol_z_edit,'String'));
%electrodes








% --- Outputs from this function are returned to the command line.
function varargout = CGLW_SEEG_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called









% --- Executes on selection change in files_popup.
function files_popup_Callback(hObject, eventdata, handles)
% hObject    handle to files_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_files_popup(handles);





function update_files_popup(handles);
%filenames
filenames=get(handles.files_popup,'String');
filename=filenames{get(handles.files_popup,'Value')};
%header
header=CLW_load_header(filename);
%update epoch_listbox
epochs=get(handles.epoch_popup,'String');
%update if different number of epochs
if length(epochs)==header.datasize(1);
else
    for i=1:header.datasize(1);
        st{i}=num2str(i);
    end;
    set(handles.epoch_popup,'String',st);
    %update value if greater than the number of epochs
    if get(handles.epoch_popup,'Value')>header.datasize(1);
        set(handles.epoch_popup,'Value',header.datasize(1));
    end;
end;
%index
if header.datasize(3)==1;
    set(handles.index_text,'Visible','off');
    set(handles.index_edit,'Visible','off');
    set(handles.index_edit,'String','1');
else
    set(handles.index_text,'Visible','on');
    set(handles.index_edit,'Visible','on');
end;
%Z
if header.datasize(4)==1;
    set(handles.z_text,'Visible','off');
    set(handles.z_edit,'Visible','off');
    set(handles.z_edit,'String','1');
else
    set(handles.z_text,'Visible','on');
    set(handles.z_edit,'Visible','on');
end;
%Y
if header.datasize(5)==1;
    set(handles.y_text,'Visible','off');
    set(handles.y_edit,'Visible','off');
    set(handles.y_edit,'String','1');
else
    set(handles.y_text,'Visible','on');
    set(handles.y_edit,'Visible','on');
end;
    




% --- Executes during object creation, after setting all properties.
function files_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to files_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);



function mri_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to mri_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);




% --- Executes during object creation, after setting all properties.
function mri_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mri_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mri_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to mri_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);




% --- Executes during object creation, after setting all properties.
function mri_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mri_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mri_z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to mri_z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);




% --- Executes during object creation, after setting all properties.
function mri_z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mri_z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu5.
function popupmenu5_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function popupmenu5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu5 (see GCBO)
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


% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);






% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function index_edit_Callback(hObject, eventdata, handles)
% hObject    handle to index_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function index_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_edit (see GCBO)
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





% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%wavedata
wavedata=get(handles.waves_listbox,'Userdata');
%new_wave
%filename
filenames=get(handles.files_popup,'Userdata');
new_wave.filename=filenames{get(handles.files_popup,'Value')};
%short_filename
short_filenames=get(handles.files_popup,'String');
new_wave.short_filename=short_filenames{get(handles.files_popup,'Value')};
%epoch
new_wave.epoch=get(handles.epoch_popup,'Value');
%index
new_wave.index=str2num(get(handles.index_edit,'String'));
%z,y
new_wave.z=str2num(get(handles.z_edit,'String'));
new_wave.y=str2num(get(handles.y_edit,'String'));
%color
new_wave.color=get(handles.color_text,'BackgroundColor');
%data,header
[header,data]=CLW_load(new_wave.filename);
new_wave.header=header;
new_wave.data=data(new_wave.epoch,:,new_wave.index,new_wave.z,new_wave.y,:);
%update wavedata
if isempty(wavedata);
    wavedata=new_wave;
else
    wavedata(end+1)=new_wave;
end;
set(handles.waves_listbox,'Userdata',wavedata);
update_waves_listbox(handles);




function update_waves_listbox(handles);
%wavedata
wavedata=get(handles.waves_listbox,'Userdata');
if isempty(wavedata);
    st={};
else
    for i=1:length(wavedata);
        st{i}=[wavedata(i).short_filename '(E:' num2str(wavedata(i).epoch) ' I:' num2str(wavedata(i).index) ' Z:' num2str(wavedata(i).z) ' Y:' num2str(wavedata(i).y) ')'];
    end;
end;
set(handles.waves_listbox,'String',st);
%check values
if isempty(st);
    set(handles.waves_listbox,'Value',[]);
else
    v=get(handles.waves_listbox,'Value');
    max_v=length(st);
    if isempty(v);
    else
        v(find(v>max_v))=[];
        set(handles.waves_listbox,'Value',v);
    end;
end;
%update_channels_popup
update_channels_popup(handles);
%update_wave_axes
update_wave_axes(handles);




function update_wave_axes(handles);
cla(handles.wave_axes);
hold(handles.wave_axes,'on');
channels_idx=[];
%v
v=get(handles.waves_listbox,'Value');
if isempty(v);
else
    %channels
    channel_labels=get(handles.channel_listbox,'String');
    channel_labels=channel_labels(get(handles.channel_listbox,'Value'));
    if isempty(channel_labels);
    else
        %wavedata
        wavedata=get(handles.waves_listbox,'Userdata');
        if isempty(wavedata);
        else
            %select selected wavedata
            wavedata=wavedata(v);
            %loop through wavedata
            for wavepos=1:length(wavedata);
                %header_channel_labels
                for i=1:length(wavedata(wavepos).header.chanlocs);
                    header_channel_labels{i}=wavedata(wavepos).header.chanlocs(i).labels;
                end;
                %channels_idx
                channels_idx=[];
                j=1;
                for i=1:length(channel_labels);
                    a=find(strcmpi(channel_labels{i},header_channel_labels)==1);
                    if isempty(a);
                    else
                        channels_idx(j)=a;
                        j=j+1;
                    end;
                end;
                if isempty(channels_idx);
                else
                    %there are some waves to plot
                    %channels_idx is not empty
                    %header
                    header=wavedata(wavepos).header;
                    %tpx
                    tpx=1:1:header.datasize(6);
                    tpx=((tpx-1)*header.xstep)+header.xstart;
                    %tpy
                    tpy=squeeze(wavedata(wavepos).data(:,channels_idx,:,:,:,:));
                    %c
                    c=wavedata(wavepos).color;
                    plot(handles.wave_axes,tpx,tpy,'Color',c);
                end;
            end;
        end;
    end;
end;
%axis
a=axis(handles.wave_axes);
b=a;
if get(handles.x_axis_chk,'Value')==0;
    b(1)=str2num(get(handles.x_axis_min_edit,'String'));
    b(2)=str2num(get(handles.x_axis_max_edit,'String'));
else
    set(handles.x_axis_min_edit,'String',num2str(a(1)));
    set(handles.x_axis_max_edit,'String',num2str(a(2)));
end;
if get(handles.y_axis_chk,'Value')==0;
    b(3)=str2num(get(handles.y_axis_min_edit,'String'));
    b(4)=str2num(get(handles.y_axis_max_edit,'String'));
else
    set(handles.y_axis_min_edit,'String',num2str(a(3)));
    set(handles.y_axis_max_edit,'String',num2str(a(4)));
end;
if a==b;
else
    axis(handles.wave_axes,b);
end;
hold(handles.wave_axes,'off');
axis(handles.wave_axes,'on');











% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%v
v=get(handles.waves_listbox,'Value');
if isempty(v);
else
    %wavedata
    wavedata=get(handles.waves_listbox,'Userdata');
    wavedata(v)=[];
    %update wavedata
    set(handles.waves_listbox,'Userdata',wavedata);
    set(handles.waves_listbox,'Value',[]);
    update_waves_listbox(handles);
end;
    




% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.waves_listbox,'Userdata',[]);
set(handles.waves_listbox,'Value',[]);
update_waves_listbox(handles);





% --- Executes on button press in color_btn.
function color_btn_Callback(hObject, eventdata, handles)
% hObject    handle to color_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c=uisetcolor(get(handles.color_text,'BackgroundColor'));
set(handles.color_text,'BackgroundColor',c);




% --- Executes on selection change in waves_listbox.
function waves_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to waves_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_channels_popup(handles);
update_wave_axes(handles);
update_mri_data(handles);





function update_channels_popup(handles);
%wavedata
wavedata=get(handles.waves_listbox,'Userdata');
%selected waves
v=get(handles.waves_listbox,'Value');
if isempty(v);
    st={};
else
    header=wavedata(v(1)).header;
    for i=1:length(header.chanlocs);
        st{i}=header.chanlocs(i).labels;
    end;
end;
set(handles.channel_listbox,'String',st);
%check selection
if isempty(st);
    set(handles.channel_listbox,'Value',[]);
else    
    v=get(handles.channel_listbox,'Value');
    max_v=length(st);
    if isempty(v);
    else
        v(find(v>max_v))=[];
        set(handles.channel_listbox,'Value',v);
    end;
end;




% --- Executes during object creation, after setting all properties.
function waves_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waves_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('CLICKED')

% --- Executes on button press in x_left_btn.
function x_left_btn_Callback(hObject, eventdata, handles)
% hObject    handle to x_left_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=str2num(get(handles.mri_x_edit,'String'));
set(handles.mri_x_edit,'String',num2str(x-1));
update_mri_data(handles);



% --- Executes on button press in x_right_btn.
function x_right_btn_Callback(hObject, eventdata, handles)
% hObject    handle to x_right_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x=str2num(get(handles.mri_x_edit,'String'));
set(handles.mri_x_edit,'String',num2str(x+1));
update_mri_data(handles);





% --- Executes on button press in y_left_btn.
function y_left_btn_Callback(hObject, eventdata, handles)
% hObject    handle to y_left_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
y=str2num(get(handles.mri_y_edit,'String'));
set(handles.mri_y_edit,'String',num2str(y-1));
update_mri_data(handles);




% --- Executes on button press in y_right_btn.
function y_right_btn_Callback(hObject, eventdata, handles)
% hObject    handle to y_right_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
y=str2num(get(handles.mri_y_edit,'String'));
set(handles.mri_y_edit,'String',num2str(y+1));
update_mri_data(handles);




% --- Executes on button press in z_left_btn.
function z_left_btn_Callback(hObject, eventdata, handles)
% hObject    handle to z_left_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
z=str2num(get(handles.mri_z_edit,'String'));
set(handles.mri_z_edit,'String',num2str(z-1));
update_mri_data(handles);





% --- Executes on button press in z_right_btn.
function z_right_btn_Callback(hObject, eventdata, handles)
% hObject    handle to z_right_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
z=str2num(get(handles.mri_z_edit,'String'));
set(handles.mri_z_edit,'String',num2str(z+1));
update_mri_data(handles);



function x_tol_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_tol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);



% --- Executes during object creation, after setting all properties.
function x_tol_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_tol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_tol_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_tol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);



% --- Executes during object creation, after setting all properties.
function y_tol_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_tol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_tol_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_tol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);


% --- Executes during object creation, after setting all properties.
function z_tol_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_tol_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in read_btn.
function read_btn_Callback(hObject, eventdata, handles)
% hObject    handle to read_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%v
v=get(handles.waves_listbox,'Value');
if isempty(v);
else
    %update selection to single item if more than one item selected
    if length(v)>1;
        v=v(1);
        set(handles.waves_listbox,'Value',v);
        update_waves_listbox(handles);
    end;
    %wavedata
    wavedata=get(handles.waves_listbox,'Userdata');
    %files_popup
    filenames=get(handles.files_popup,'Userdata');
    set(handles.files_popup,'Value',find(strcmpi(wavedata(v).filename,filenames)==1));
    %epoch_popup
    set(handles.epoch_popup,'Value',wavedata(v).epoch);
    %index_edit
    set(handles.index_edit,'String',num2str(wavedata(v).index));
    %z_edit
    set(handles.z_edit,'String',num2str(wavedata(v).z));
    %y_edit
    set(handles.y_edit,'String',num2str(wavedata(v).y));
    %color_text
    set(handles.color_text,'BackgroundColor',wavedata(v).color);
end;



% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%v
v=get(handles.waves_listbox,'Value');
if isempty(v);
else
    %update selection to single item if more than one item selected
    if length(v)>1;
        v=v(1);
        set(handles.waves_listbox,'Value',v);
        update_waves_listbox(handles);
    end;
    %wavedata
    wavedata=get(handles.waves_listbox,'Userdata');
    %files_popup
    filenames=get(handles.files_popup,'Userdata');
    wavedata(v).filename=filenames{get(handles.files_popup,'Value')};
    %epoch_popup
    wavedata(v).epoch=get(handles.epoch_popup,'Value');
    %index_edit
    wavedata(v).index=str2num(get(handles.index_edit,'String'));
    %z_edit
    wavedata(v).z=str2num(get(handles.z_edit,'String'));
    %y_edit
    wavedata(v).y=str2num(get(handles.y_edit,'String'));
    %color_text
    wavedata(v).color=get(handles.color_text,'BackgroundColor');
    %data,header
    [header,data]=CLW_load(wavedata(v).filename);
    wavedata(v).header=header;
    wavedata(v).data=data(wavedata(v).epoch,:,wavedata(v).index,wavedata(v).z,wavedata(v).y,:);
    %
    set(handles.waves_listbox,'Userdata',wavedata);
    %
    update_waves_listbox(handles);
    update_channels_popup(handles);
    update_mri_data(handles);
end;
    



function x_axis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);




% --- Executes during object creation, after setting all properties.
function x_axis_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_axis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_axis_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);





% --- Executes during object creation, after setting all properties.
function x_axis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_axis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_axis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_axis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);





% --- Executes during object creation, after setting all properties.
function y_axis_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_axis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_axis_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_axis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);





% --- Executes during object creation, after setting all properties.
function y_axis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_axis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in x_axis_chk.
function x_axis_chk_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);


% --- Executes on mouse press over axes background.
function wave_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to wave_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton25.
function pushbutton25_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton25 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure1 background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over figure1 background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=get(handles.wave_axes,'CurrentPoint');
x=a(1,1);
y=a(1,2);
if (x>=str2num(get(handles.x_axis_min_edit,'String')))&(x<=str2num(get(handles.x_axis_max_edit,'String')));
    if (y>=str2num(get(handles.y_axis_min_edit,'String')))&(y<=str2num(get(handles.y_axis_max_edit,'String')));
        set(handles.x_pos_text,'String',num2str(x));
        update_mri_data(handles);
    end;
end;




function update_mri_bubbles(handles);
%v
v=get(handles.waves_listbox,'Value');
if isempty(v);
else
    %x
    x=str2num(get(handles.x_pos_text,'String'));
    %wavedata
    wavedata=get(handles.waves_listbox,'Userdata');
    if isempty(wavedata);
    else
        %selected wavedata
        wavedata=wavedata(v);
        %loop through wavedata (for scaling)
        tp=0;
        for wavepos=1:length(wavedata);
            %header
            header=wavedata(wavepos).header;
            %find SEEG channels
            chan_X=[];
            chan_Y=[];
            chan_Z=[];
            chan_idx=[];
            j=1;
            if isfield(header.chanlocs,'SEEG_enabled');
                %dx
                dx=fix(((x-header.xstart)/header.xstep)+1);
                %loop through channels
                for chanpos=1:length(header.chanlocs);
                    if header.chanlocs(chanpos).SEEG_enabled==1;
                        tp=max([tp abs(wavedata(wavepos).data(1,chanpos,1,1,1,dx))]);
                    end;
                end;
            end;
        end;
        data_scale=str2num(get(handles.max_bubble_size_edit,'String'))/tp;
        %MRI
        mri_x=str2num(get(handles.mri_x_edit,'String'));
        mri_y=str2num(get(handles.mri_y_edit,'String'));
        mri_z=str2num(get(handles.mri_z_edit,'String'));
        %TOLERANCE
        tol_x=str2num(get(handles.x_tol_edit,'String'));
        tol_y=str2num(get(handles.y_tol_edit,'String'));
        tol_z=str2num(get(handles.z_tol_edit,'String'));
        %loop through wavedata (for bubble plot)
        for wavepos=1:length(wavedata);
            %header
            header=wavedata(wavepos).header;
            %find SEEG channels
            chan_X=[];
            chan_Y=[];
            chan_Z=[];
            chan_idx=[];
            j=1;
            if isfield(header.chanlocs,'SEEG_enabled');
                for chanpos=1:length(header.chanlocs);
                    if header.chanlocs(chanpos).SEEG_enabled==1;
                        chan_X(j)=header.chanlocs(chanpos).X;
                        chan_Y(j)=header.chanlocs(chanpos).Y;
                        chan_Z(j)=header.chanlocs(chanpos).Z;
                        chan_idx(j)=chanpos;
                        j=j+1;
                    end;
                end;
            end;
            %check if there is some data to display
            if isempty(chan_idx);
            else
                %color
                c=wavedata(wavepos).color;
                %
                %dx
                dx=fix(((x-header.xstart)/header.xstep)+1);
                %chan_value
                chan_value=[];
                for i=1:length(chan_idx);
                    chan_value(i)=wavedata(wavepos).data(1,chan_idx(i),1,1,1,dx);
                end;
                %scale chan_value
                chan_value=chan_value*data_scale;
                %hold on
                hold(handles.axes1,'on');
                hold(handles.axes2,'on');
                hold(handles.axes3,'on');
                %positive values (filled)
                pos_v=find(chan_value>0);
                neg_v=find(chan_value<0);
                zero_v=find(chan_value==0);
                if isempty(pos_v);
                else
                    tp_X=chan_X(pos_v);
                    tp_Y=chan_Y(pos_v);
                    tp_Z=chan_Z(pos_v);
                    tp_V=chan_value(pos_v);
                    %bubble plot 1
                    scatter(handles.axes1,tp_X(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),tp_Y(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),tp_V(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),c,'filled');
                    %bubble plot 2
                    scatter(handles.axes2,tp_X(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),tp_Z(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),tp_V(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),c,'filled');
                    %bubble plot 3
                    scatter(handles.axes3,tp_Y(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),tp_Z(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),tp_V(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),c,'filled');
                end;
                if isempty(neg_v);
                else
                    tp_X=chan_X(neg_v);
                    tp_Y=chan_Y(neg_v);
                    tp_Z=chan_Z(neg_v);
                    tp_V=chan_value(neg_v);
                    %bubble plot 1
                    scatter(handles.axes1,tp_X(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),tp_Y(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),-tp_V(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),c);
                    %bubble plot 2
                    scatter(handles.axes2,tp_X(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),tp_Z(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),-tp_V(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),c);
                    %bubble plot 3
                    scatter(handles.axes3,tp_Y(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),tp_Z(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),-tp_V(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),c);
                end;
                if isempty(zero_v);
                else
                    tp_X=chan_X(zero_v);
                    tp_Y=chan_Y(zero_v);
                    tp_Z=chan_Z(zero_v);
                    tp_V=chan_value(zero_v);
                    %bubble plot 1
                    plot(handles.axes1,tp_X(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),tp_Y(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),tp_V(find((tp_Z>(mri_z-tol_z))&(tp_Z<(mri_z+tol_z)))),'.','Color',c);
                    %bubble plot 2
                    plot(handles.axes2,tp_X(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),tp_Z(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),tp_V(find((tp_Y>(mri_y-tol_y))&(tp_Y<(mri_y+tol_y)))),'.','Color',c);
                    %bubble plot 3
                    plot(handles.axes3,tp_Y(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),tp_Z(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),tp_V(find((tp_X>(mri_x-tol_x))&(tp_X<(mri_x+tol_x)))),'.','Color',c);
                end;
                %hold off
                hold(handles.axes1,'off');
                hold(handles.axes2,'off');
                hold(handles.axes3,'off');
            end;
        end;
    end;        
end;



function max_bubble_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to max_bubble_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_mri_data(handles);







% --- Executes during object creation, after setting all properties.
function max_bubble_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_bubble_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in F1_btn.
function F1_btn_Callback(hObject, eventdata, handles)
% hObject    handle to F1_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;
h2=gca;
copyobj(get(handles.axes1,'children'),h2);
colormap(gray);
axis tight;





% --- Executes on button press in F2_btn.
function F2_btn_Callback(hObject, eventdata, handles)
% hObject    handle to F2_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;
h2=gca;
copyobj(get(handles.axes2,'children'),h2);
colormap(gray);
axis tight;


% --- Executes on button press in F3_btn.
function F3_btn_Callback(hObject, eventdata, handles)
% hObject    handle to F3_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
figure;
h2=gca;
copyobj(get(handles.axes3,'children'),h2);
colormap(gray);
axis tight;


% --- Executes on button press in y_axis_chk.
function y_axis_chk_Callback(hObject, eventdata, handles)
% hObject    handle to y_axis_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_wave_axes(handles);
