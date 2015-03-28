function varargout = GLW_reject_epochs_visual(varargin)
% GLW_REJECT_EPOCHS_VISUAL MATLAB code for GLW_reject_epochs_visual.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_reject_epochs_visual_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_reject_epochs_visual_OutputFcn, ...
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









% --- Executes just before GLW_reject_epochs_visual is made visible.
function GLW_reject_epochs_visual_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_reject_epochs_visual (see VARARGIN)
% Choose default command line output for GLW_reject_epochs_visual
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
%check datasets
if isempty(datasets);
    disp('No datasets selected! Exit.');
    return;
end;
if length(datasets)>1;
    disp('More than one dataset selected! Exit.');
    return;
end;
%epoch_listbox
st={};
for i=1:datasets(1).header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
set(handles.epoch_listbox,'Value',1);
%channel_listbox
st={};
for i=1:datasets(1).header.datasize(2);
    st{i}=datasets(1).header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
set(handles.channel_listbox,'Value',1);
%store header in epoch_listbox 'Userdata'
set(handles.epoch_listbox,'Userdata',datasets(1).header);
%update rejected_listbox
update_rejected_listboxes(handles);
%axis_range
auto_x_axis_range(handles);
auto_y_axis_range(handles);
%update_graphs
update_graphs(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);




function auto_x_axis_range(handles);
%header
header=get(handles.epoch_listbox,'Userdata');
%x_min x_max
x_min=header.xstart;
x_max=((header.datasize(6)-1)*header.xstep)+header.xstart;
%update 
set(handles.x_axis_min_edit,'String',num2str(x_min));
set(handles.x_axis_max_edit,'String',num2str(x_max));
update_graphs(handles);




function auto_y_axis_range(handles);
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%channel_pos
channel_pos=get(handles.channel_listbox,'Value');
%min/max
y_min=min(min(squeeze(datasets(1).data(:,channel_pos(1),1,1,1,:))));
y_max=max(max(squeeze(datasets(1).data(:,channel_pos(1),1,1,1,:))));
%update
set(handles.y_axis_min_edit,'String',num2str(y_min));
set(handles.y_axis_max_edit,'String',num2str(y_max));
update_graphs(handles);






function update_rejected_listboxes(handles);
%configuration
configuration=get(handles.process_btn,'Userdata');
%header
header=get(handles.epoch_listbox,'Userdata');
%rejected_listbox
st={};
rejected_epochs=configuration.parameters.rejected_epochs;
for i=1:length(rejected_epochs);
    st{i}=num2str(rejected_epochs(i));
end;
st
length(rejected_epochs)
rejected_epochs
set(handles.rejected_listbox,'String',st);
if get(handles.rejected_listbox,'Value')>length(rejected_epochs);
    set(handles.rejected_listbox,'Value',length(rejected_epochs));
end;
if get(handles.rejected_listbox,'Value')==0;
    set(handles.rejected_listbox,'Value',1);
end;







function update_graphs(handles);
%channel_pos
channel_pos=get(handles.channel_listbox,'Value');
channel_pos=channel_pos(1);
%selected_epochs
selected_epochs=get(handles.epoch_listbox,'Value');
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%header
header=datasets(1).header;
%tpx
tpx=1:1:header.datasize(6);
tpx=((tpx-1)*header.xstep)+header.xstart;
%axis_range
x_min=str2num(get(handles.x_axis_min_edit,'String'));
x_max=str2num(get(handles.x_axis_max_edit,'String'));
y_min=str2num(get(handles.y_axis_min_edit,'String'));
y_max=str2num(get(handles.y_axis_max_edit,'String'));
%configuration
configuration=get(handles.process_btn,'Userdata');
%rejected_epochs
rejected_epochs=configuration.parameters.rejected_epochs;
%accepted_epochs
accepted_epochs=1:1:header.datasize(1);
accepted_epochs(rejected_epochs)=[];
%plot accepted epochs (if some to plot)
if isempty(accepted_epochs);
else
    if get(handles.accepted_average_chk,'Value')==0;
        plot(handles.accepted_axes,tpx,squeeze(datasets(1).data(accepted_epochs,channel_pos,1,1,1,:)),'Color',[0.6 0.85 0.6]);
    else
        tp=datasets(1).data(accepted_epochs,channel_pos,1,1,1,:);
        plot(handles.accepted_axes,tpx,squeeze(mean(tp,1)),'Color',[0.6 0.85 0.6]);
    end;
    hold(handles.accepted_axes,'on');
end;
%superimpose selected epochs
if isempty(selected_epochs);
else
    plot(handles.accepted_axes,tpx,squeeze(datasets(1).data(selected_epochs,channel_pos,1,1,1,:)),'k','LineWidth',2);
end;
hold(handles.accepted_axes,'off');
%axis
axis(handles.accepted_axes,[x_min x_max y_min y_max]);
%plot rejected epochs (if some to plot)
if isempty(rejected_epochs);
else
    if get(handles.rejected_average_chk,'Value')==0;
        plot(handles.rejected_axes,tpx,squeeze(datasets(1).data(rejected_epochs,channel_pos,1,1,1,:)),'Color',[0.85 0.6 0.6]);
    else
        tp=datasets(1).data(rejected_epochs,channel_pos,1,1,1,:);
        plot(handles.rejected_axes,tpx,squeeze(mean(tp,1)),'Color',[0.85 0.6 0.6]);
    end;
    hold(handles.rejected_axes,'on');
end;
%superimpose selected epochs
if isempty(selected_epochs);
else
    plot(handles.rejected_axes,tpx,squeeze(datasets(1).data(selected_epochs,channel_pos,1,1,1,:)),'k','LineWidth',2);
end;
hold(handles.rejected_axes,'off');
%axis
axis(handles.rejected_axes,[x_min x_max y_min y_max]);















% --- Outputs from this function are returned to the command line.
function varargout = GLW_reject_epochs_visual_OutputFcn(hObject, eventdata, handles)
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






% --- Executes on selection change in accepted_listbox.
function accepted_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to accepted_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);






% --- Executes during object creation, after setting all properties.
function accepted_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to accepted_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in max_btn.
function max_btn_Callback(hObject, eventdata, handles)
% hObject    handle to max_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%channel_pos
channel_pos=get(handles.channel_listbox,'Value');
channel_pos=channel_pos(1);
%configuration
configuration=get(handles.process_btn,'Userdata');
%accepted_epochs
accepted_epochs=1:1:datasets(1).header.datasize(1);
accepted_epochs(configuration.parameters.rejected_epochs)=[];
%tp_data
tp_data=squeeze(datasets(1).data(accepted_epochs,channel_pos,1,1,1,:));
if size(accepted_epochs)==1;
    max_epoch=accepted_epochs;
else
    [a,b]=max(max(abs(tp_data),[],2));
    max_epoch=accepted_epochs(b);
end;
set(handles.epoch_listbox,'Value',max_epoch);
update_graphs(handles);







% --- Executes on selection change in epoch_listbox.
function epoch_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);






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
update_graphs(handles);





% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes on selection change in dataset_listbox.
function dataset_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);





% --- Executes during object creation, after setting all properties.
function dataset_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in accept_btn.
function accept_btn_Callback(hObject, eventdata, handles)
% hObject    handle to accept_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%configuration
configuration=get(handles.process_btn,'Userdata');
%header
header=get(handles.epoch_listbox,'Userdata');
%rejected_epochs
rejected_epochs=configuration.parameters.rejected_epochs;
idx=get(handles.epoch_listbox,'Value');
[C,ia,ib]=intersect(idx,rejected_epochs);
rejected_epochs(ib)=[];
configuration.parameters.rejected_epochs=rejected_epochs;
%update configuraiton
set(handles.process_btn,'Userdata',configuration);
%update epoch_pos (if only one epoch is selected)
if length(idx)==1;
    if idx<header.datasize(1);
        set(handles.epoch_listbox,'Value',idx+1);
    end;
else
    set(handles.epoch_listbox,'Value',[]);
end;
%update
update_rejected_listboxes(handles);
update_graphs(handles);
%
set(handles.rejected_listbox,'Value',[]);





% --- Executes on button press in reject_btn.
function reject_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reject_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%configuration
configuration=get(handles.process_btn,'Userdata');
%header
header=get(handles.epoch_listbox,'Userdata');
%rejected_epochs
rejected_epochs=configuration.parameters.rejected_epochs;
idx=get(handles.epoch_listbox,'Value');
rejected_epochs=[rejected_epochs idx]
rejected_epochs=unique(rejected_epochs);
rejected_epochs=sort(rejected_epochs);
configuration.parameters.rejected_epochs=rejected_epochs;
%update configuraiton
set(handles.process_btn,'Userdata',configuration);
%update epoch_pos (if only one epoch is selected) else, unselect all epochs
if length(idx)==1;
    if idx<header.datasize(1);
        set(handles.epoch_listbox,'Value',idx+1);
    end;
else
    set(handles.epoch_listbox,'Value',[]);
end;
%update
update_rejected_listboxes(handles);
update_graphs(handles);
%
set(handles.rejected_listbox,'Value',[]);






% --- Executes on selection change in rejected_listbox.
function rejected_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to rejected_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%selection
selection=get(handles.rejected_listbox,'Value');
%configuration
configuration=get(handles.process_btn,'Userdata');
%selected_epochs
selected_epochs=configuration.parameters.rejected_epochs(selection);
%update epochs selected in epoch_listbox
set(handles.epoch_listbox,'Value',selected_epochs);
%update_graphs
update_graphs(handles);







% --- Executes during object creation, after setting all properties.
function rejected_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rejected_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







function x_axis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_axis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);





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
update_graphs(handles);





% --- Executes during object creation, after setting all properties.
function x_axis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_axis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in auto_x_axis_btn.
function auto_x_axis_btn_Callback(hObject, eventdata, handles)
% hObject    handle to auto_x_axis_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
auto_x_axis_range(handles);
update_graphs(handles);








function amplitude_threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to amplitude_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function amplitude_threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to amplitude_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in apply_criterion_btn.
function apply_criterion_btn_Callback(hObject, eventdata, handles)
% hObject    handle to apply_criterion_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%x_min
x_min=str2num(get(handles.x_axis_min_edit,'String'));
%x_max
x_max=str2num(get(handles.x_axis_max_edit,'String'));
%channel_pos
channel_pos=get(handles.channel_listbox,'Value');
%dx1,dx2
dx1=fix((x_min-datasets(1).header.xstart)/datasets(1).header.xstep)+1;
dx2=fix((x_max-datasets(1).header.xstart)/datasets(1).header.xstep)+1;
%tp_data
tp_data=squeeze(datasets(1).data(:,channel_pos,1,1,1,dx1:dx2));
%max
if datasets(1).header.datasize(1)==1;
    sel_epoch=1;
else
    [a,b]=max(abs(tp_data),[],2);
    max_epoch_values=a;
    threshold=str2num(get(handles.amplitude_threshold_edit,'String'));
    sel_epoch=find(max_epoch_values>threshold);
end;
set(handles.epoch_listbox,'Value',sel_epoch);
update_graphs(handles);











% --- Executes on button press in rejected_average_chk.
function rejected_average_chk_Callback(hObject, eventdata, handles)
% hObject    handle to rejected_average_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);






% --- Executes on button press in reset_btn.
function reset_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reset_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%configuration
configuration=get(handles.process_btn,'Userdata');
%reset
configuration.parameters.rejected_epochs=[];
set(handles.process_btn,'Userdata');
%update_graphs
update_graphs(handles);





% --- Executes on button press in auto_y_axis_btn.
function auto_y_axis_btn_Callback(hObject, eventdata, handles)
% hObject    handle to auto_y_axis_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
auto_y_axis_range(handles);
update_graphs(handles);





function y_axis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_axis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);





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
update_graphs(handles);





% --- Executes during object creation, after setting all properties.
function y_axis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_axis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in accepted_average_chk.
function accepted_average_chk_Callback(hObject, eventdata, handles)
% hObject    handle to accepted_average_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);
