function varargout = CGLW_multi_viewer_continuous(varargin)
% CGLW_MULTI_VIEWER_CONTINUOUS MATLAB code for CGLW_multi_viewer_continuous.fig






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
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_multi_viewer_continuous (see VARARGIN)
% Choose default command line output for CGLW_multi_viewer_continuous
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%filenames
inputfiles=varargin{2};
for i=1:length(inputfiles);
    [p n e]=fileparts(inputfiles{i});
    st{i}=n;
end;
%header
header=CLW_load_header(inputfiles{1});
%store header
set(handles.event_listbox,'Userdata',header);
%epoch_listbox
st={};
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
set(handles.epoch_listbox,'Value',1);
%channel_listbox
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
%event_listbox
st={};
if isfield(header,'events');
    for i=1:length(header.events);
        if isnumeric(header.events(i).code);
            code=num2str(header.events(i).code);
        else
            code=header.events(i).code;
        end;
        st{i}=[code ' [E: ' num2str(header.events(i).epoch) ' ] [X : ' num2str(header.events(i).latency) ']'];
    end;
end;
set(handles.event_listbox,'String',st);
set(handles.event_listbox,'Value',1);
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
end;
%y
if header.datasize(5)>1;
    set(handles.y_text,'Visible','on');
    set(handles.y_edit,'Visible','on');
    set(handles.y_edit,'String',num2str(header.ystart));
end;
%z
if header.datasize(4)>1;
    set(handles.z_text,'Visible','on');
    set(handles.z_edit,'Visible','on');
    set(handles.z_edit,'String',num2str(header.zstart));
end;
%figure
f=CGLW_multi_viewer_figure_continuous;
set(handles.forward_btn,'Userdata',f);
%update_listbox
update_listbox(handles);
%initialize data (matObj)
filename=header.name;
matObj=matfile(filename,'Writable',false);
set(handles.epoch_listbox,'Userdata',matObj);
%update_graph
update_graph(handles);






function update_listbox(handles);
%selected_event
selected_event=get(handles.event_listbox,'Value');
%header
header=get(handles.event_listbox,'Userdata');
%event
event=header.events(selected_event);
%set epochpos
set(handles.epoch_listbox,'Value',event.epoch);
%set latency
set(handles.xaxis_position_edit,'String',num2str(event.latency));





function update_graph(handles);
%figure
f=get(handles.forward_btn,'Userdata');
figure(f);
%header
header=get(handles.event_listbox,'Userdata');
%matObj
matObj=get(handles.epoch_listbox,'Userdata');
%epochpos
epochpos=get(handles.epoch_listbox,'Value');
%selected_channels
selected_channels=get(handles.channel_listbox,'Value');
%selected_channels_string
st=get(handles.channel_listbox,'String');
selected_channels_string=st(selected_channels);
%x
x=str2num(get(handles.xaxis_position_edit,'String'));
%foreperiod
foreperiod=str2num(get(handles.foreperiod_edit,'String'));
%adjust x
x=x-foreperiod;
%x_width
x_width=str2num(get(handles.xaxis_width_edit,'String'));
%dx1,dx2
dx1=round((x-header.xstart)/header.xstep)+1;
dx2=round(((x+x_width)-header.xstart)/header.xstep)+1;
%check limits
if dx1<1;
    dx1=1;
    x1=header.xstart;
else
    x1=x;
end;
if dx2>header.datasize(6);
    dx2=header.datasize(6);
    x2=header.xstart+((header.datasize(6)-1)*header.xstep);
else
    x2=x1+x_width;
end;
%x1,x2
x1=x;
x2=x1+x_width;
%indexpos
indexpos=get(handles.index_popup,'Value');
%y > dy
if header.datasize(5)==1;
    dy=1;
else
    y=str2num(get(handles.y_edit,'String'));
    dy=round((y-header.ystart)/header.ystep)+1;
end;
%z > dz
if header.datasize(4)==1;
    dz=1;
else
    z=str2num(get(handles.z_edit,'String'));
    dz=round((z-header.zstart)/header.zstep)+1;
end;
%tp_data_y
tp_data_y=matObj.data(epochpos,selected_channels,indexpos,dz,dy,dx1:dx2);
%tp_data_x
tp_data_x=dx1:dx2;
tp_data_x=((tp_data_x-1)*header.xstep)+header.xstart;
%line_colors
line_colors=distinguishable_colors(length(selected_channels));
%display_reverse
display_reverse_y=get(handles.y_reverse_chk,'Value');
%display_events
display_events=get(handles.show_events_chk,'Value');
%ymin ymax
ymin=min(tp_data_y(:));
ymax=max(tp_data_y(:));
%display multiple channels
for chanpos=1:length(selected_channels);
    ax=subaxis(length(selected_channels),1,chanpos,'MarginLeft',0.06,'MarginRight',0.02,'MarginTop',0.04,'MarginBottom',0.08,'SpacingHoriz',0.06,'SpacingVert',0.06);
    all_axis(chanpos)=ax;
    plot(tp_data_x,squeeze(tp_data_y(1,chanpos,1,1,1,:)),'Color',line_colors(chanpos,:));
    set(ax,'FontUnits','pixels');
    set(ax,'FontSize',9);
    set(ax,'Box','off');
    %ydir
    if display_reverse_y==0;
        set(ax,'YDir','normal');
    else
        set(ax,'YDir','reverse');
    end;
    legend(selected_channels_string(chanpos));
    %events?
    if display_events==1;
        hold on;
        %xstart,xend
        for eventpos=1:length(header.events);
            if header.events(eventpos).epoch==epochpos;
                latency=header.events(eventpos).latency;
                if latency>=x1;
                    if latency<=x2;
                        plot([latency latency],[ymin ymax],'r:');
                        %text(latency,mean([ybottom ytop]),dispdata.header.events(eventpos).code);
                        code=header.events(eventpos).code;
                        if isnumeric(code);
                            code=num2str(code);
                        end;
                        if display_reverse_y==0;
                            a=ymax-((ymax-ymin)/20);
                            a=double(a);
                            text(latency,a,code);
                        else
                            a=ymin+((ymax-ymin)/20);
                            a=double(a);
                            text(latency,a,code);
                        end;    
                    end;
                end;
            end;
        end;
        hold off;
    end;
end;
%linkaxes
linkaxes(all_axis);
%xlimits
xlim([x1,x2]);
%ylimits
if get(handles.yaxis_auto_chk,'Value')==1;
    set(handles.yaxis_min_edit,'String',num2str(ymin));
    set(handles.yaxis_max_edit,'String',num2str(ymax));
else
    ymin=str2num(get(handles.yaxis_min_edit,'String'));
    ymax=str2num(get(handles.yaxis_max_edit,'String'));
end;
if ymin==ymax;
    ymin=-1;
    ymax=1;
end;
ylim([ymin,ymax]);
set(gcf,'Color',[1 1 1]);






% --- Outputs from this function are returned to the command line.
function varargout = CGLW_multi_viewer_continuous_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array fo%r returning output args (see VARARGOUT);
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










% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=get(handles.forward_btn,'Userdata');
delete(f);
delete(hObject);







% --- Executes on selection change in epoch_listbox.
function epoch_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



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
update_graph(handles);




% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);




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
update_graph(handles);


% --- Executes during object creation, after setting all properties.
function z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in yaxis_auto_chk.
function yaxis_auto_chk_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_auto_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);






% --- Executes on selection change in index_popup.
function index_popup_Callback(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;









function xaxis_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



% --- Executes during object creation, after setting all properties.
function xaxis_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xaxis_position_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_position_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function xaxis_position_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_position_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yaxis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function yaxis_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yaxis_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);






% --- Executes during object creation, after setting all properties.
function yaxis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






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







% --- Executes on button press in y_reverse_chk.
function y_reverse_chk_Callback(hObject, eventdata, handles)
% hObject    handle to y_reverse_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



% --- Executes on button press in show_legend_chk.
function show_legend_chk_Callback(hObject, eventdata, handles)
% hObject    handle to show_legend_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



% --- Executes on button press in show_events_chk.
function show_events_chk_Callback(hObject, eventdata, handles)
% hObject    handle to show_events_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);






% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_listbox(handles);
update_graph(handles);





% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in forward_btn.
function forward_btn_Callback(hObject, eventdata, handles)
% hObject    handle to forward_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
position=str2num(get(handles.xaxis_position_edit,'String'));
width=str2num(get(handles.xaxis_width_edit,'String'));
set(handles.xaxis_position_edit,'String',num2str(position+width));
update_graph(handles);



% --- Executes on button press in back_btn.
function back_btn_Callback(hObject, eventdata, handles)
% hObject    handle to back_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
position=str2num(get(handles.xaxis_position_edit,'String'));
width=str2num(get(handles.xaxis_width_edit,'String'));
set(handles.xaxis_position_edit,'String',num2str(position-width));
update_graph(handles);




% --- Executes on button press in move_begin_btn.
function move_begin_btn_Callback(hObject, eventdata, handles)
% hObject    handle to move_begin_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%header
header=get(handles.event_listbox,'Userdata');
set(handles.xaxis_position_edit,'String',num2str(header.xstart));
update_graph(handles);




% --- Executes on button press in move_end_btn.
function move_end_btn_Callback(hObject, eventdata, handles)
% hObject    handle to move_end_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%header
header=get(handles.event_listbox,'Userdata');
position=header.xstart+((header.datasize(6)-1)*header.xstep);
position=position-str2num(get(handles.xaxis_width_edit,'String'));
set(handles.xaxis_position_edit,'String',num2str(position));
update_graph(handles);



function foreperiod_edit_Callback(hObject, eventdata, handles)
% hObject    handle to foreperiod_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of foreperiod_edit as text
%        str2double(get(hObject,'String')) returns contents of foreperiod_edit as a double


% --- Executes during object creation, after setting all properties.
function foreperiod_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to foreperiod_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
