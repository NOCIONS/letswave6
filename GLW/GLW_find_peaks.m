function varargout = GLW_find_peaks(varargin)
% GLW_FIND_PEAKS MATLAB code for GLW_find_peaks.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_find_peaks_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_find_peaks_OutputFcn, ...
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









% --- Executes just before GLW_find_peaks is made visible.
function GLW_find_peaks_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_find_peaks (see VARARGIN)
% Choose default command line output for GLW_find_peaks
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%function('dummy',configuration,datasets);
%configuration
configuration=varargin{2};
set(handles.process_btn,'Userdata',configuration);
%datasets
datasets=varargin{3};
%axis
axis off;
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%!!!!!!!!!!!!!!!!!!!!!!!!
%update GUI configuration
%!!!!!!!!!!!!!!!!!!!!!!!!
%datasets
set(handles.dataset_popup,'Userdata',datasets);
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_popup,'String',st);
set(handles.dataset_popup,'Value',1);
%header
header=datasets(1).header;
%event_popup
update_event_popup(handles);
read_event_listbox(handles);
%xaxis
set(handles.xaxis_min_edit,'String',num2str(header.xstart));
set(handles.xaxis_max_edit,'String',num2str(header.xstart+((header.datasize(6)-1)*header.xstep)));
%channel_popup
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_popup,'String',st);
set(handles.channel_popup,'Value',1);
%index_popup
st={};
if isfield(header,'index_labels');
    st=header.index_labels;
else
    for i=1:header.datasize(3);
        st{i}=num2str(i);
    end;
end;
set(handles.index_popup,'String',st);
set(handles.index_popup,'Value',1);
%y_edit
set(handles.y_edit,'String',num2str(header.ystart));
%z_edit
set(handles.z_edit,'String',num2str(header.zstart));
%x2_edit
set(handles.x1_edit,'String',num2str(header.xstart));
set(handles.x2_edit,'String',num2str(header.xstart+((header.datasize(6)-1)*header.xstep)));
%update_graph
update_graph(handles);
%
%!!!
%END
%!!!





function event_string=search_events(header);
%event_string
event_string={};
%check for event field
if isfield(header,'events');
else
    return;
end;
%loop through events > event_string
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    event_string{eventpos}=code;
end;
event_string=unique(event_string);





function update_event_popup(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%event_string
event_string=search_events(header);
set(handles.event_popup,'String',event_string);
if get(handles.event_popup,'Value')>length(event_string);
    set(handles.event_popup,'Value',1);
end;






function read_event_listbox(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%event_string
st=get(handles.event_popup,'String');
event_string=st{get(handles.event_popup,'Value')};
%init tdata
for epochpos=1:header.datasize(1);
    tdata(epochpos)=NaN;
end;
%find events with corresponding event_string
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    if strcmpi(code,event_string);
        %this event matches with event_string
        tdata(header.events(eventpos).epoch)=header.events(eventpos).latency;
    end;
end;
set(handles.event_listbox,'Userdata',tdata);
st={};
for i=1:length(tdata);
    st{i}=[num2str(i) ' : ' num2str(tdata(i))];
end;
set(handles.event_listbox,'String',st);




function update_graph(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%selected_dataset
selected_dataset=get(handles.dataset_popup,'Value');
%selected_epochs
selected_epochs=get(handles.event_listbox,'Value');
%chanpos
chanpos=get(handles.channel_popup,'Value');
%indexpos
indexpos=get(handles.index_popup,'Value');
%header
header=datasets(selected_dataset).header;
%dy
y=str2num(get(handles.y_edit,'String'));
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
%dz
z=str2num(get(handles.z_edit,'String'));
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
%tpy
tpy=squeeze(datasets(selected_dataset).data(selected_epochs,chanpos,indexpos,dz,dy,:));
%tpx
tpx=1:1:length(tpy);
tpx=((tpx-1)*header.xstep)+header.xstart;
%linecolors
linecolors=varycolor(length(selected_epochs));
%cla
cla(handles.axes,'reset');
%hold on
hold(handles.axes,'on');
%plot
if length(selected_epochs)==1;
    plot(handles.axes,tpx,tpy,'Color',linecolors(1,:));
else
    for i=1:length(selected_epochs);
        plot(handles.axes,tpx,tpy(i,:),'Color',linecolors(i,:));
    end;
end;
%xlim
x_limits=[str2num(get(handles.xaxis_min_edit,'String')) str2num(get(handles.xaxis_max_edit,'String'))];
xlim(handles.axes,x_limits);
%ylim
if get(handles.autoy_chk,'Value')==0;
    y_limits=[str2num(get(handles.yaxis_min_edit,'String')) str2num(get(handles.yaxis_max_edit,'String'))];
    ylim(handles.axes,y_limits);
end;
%ydir
if get(handles.reverse_chk,'Value')==1;
    set(handles.axes,'YDir','reverse');
else
    set(handles.axes,'YDir','normal');
end;
%legend_string
for i=1:length(selected_epochs);
    legend_string{i}=num2str(selected_epochs(i));
end;
%legend
legend(handles.axes,legend_string);
%tdata
tdata=get(handles.event_listbox,'Userdata');
peak_latencies=tdata(selected_epochs);
%
%plot peaks
y_limits=ylim(handles.axes);
for i=1:length(peak_latencies);
    if isnan(peak_latencies(i));
    else
        plot([peak_latencies(i) peak_latencies(i)],y_limits,':','Color',linecolors(i,:));
    end;
end;
hold(handles.axes,'off');









% --- Outputs from this function are returned to the command line.
function varargout = GLW_find_peaks_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
%configuration
configuration=get(handles.process_btn,'UserData');
varargout{2}=configuration;




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called






% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%loop through datasets
for i=1:length(datasets);
    %header
    header=datasets(i).header;
    %filename
    filename=[pwd filesep header.name];
    disp(['Saving : ' filename]);
    %save header
    CLW_save_header(filename,[],header);
end;
%close
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
delete(hObject);





% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
button=questdlg('Are you sure? Latencies that have not been stored as an event will be lost.');
if strcmpi(button,'Yes');
    update_event_popup(handles);
    read_event_listbox(handles);
end;





% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
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
%new_event_code
new_event_code=inputdlg('Name of peak','Event Code');
new_event_code=new_event_code{1};
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%selected_dataset
selected_dataset=get(handles.dataset_popup,'Value');
%header
header=datasets(selected_dataset).header;
%loop through events > event_string
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    event_string{eventpos}=code;
end;
%delete events with code corresponding to selected_event_code
a=find(strcmpi(new_event_code,event_string));
if isempty(a);
else
    header.events(a)=[];
end;
%tdata
tdata=get(handles.event_listbox,'Userdata');
for i=1:length(tdata);
    if isnan(tdata(i));
    else
        k=length(header.events)+1;
        header.events(k).code=new_event_code;
        header.events(k).latency=tdata(i);
        header.events(k).epoch=i;
    end;
end;
%store event in datasets
datasets(selected_dataset).header=header;
set(handles.dataset_popup,'Userdata',datasets);
%update
update_event_popup(handles);
%
st=get(handles.event_popup,'String');
a=find(strcmpi(st,new_event_code));
set(handles.event_popup,'Value',a);
read_event_listbox(handles);







% --- Executes on button press in read_btn.
function read_btn_Callback(hObject, eventdata, handles)
% hObject    handle to read_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_event_popup(handles);
read_event_listbox(handles);



% --- Executes on button press in scalpmap_btn.
function scalpmap_btn_Callback(hObject, eventdata, handles)
% hObject    handle to scalpmap_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%selected_dataset
selected_dataset=get(handles.dataset_popup,'Value');
%header
header=datasets(selected_dataset).header;
%tdata
tdata=get(handles.event_listbox,'Userdata');
%tepoch
tepoch=1:length(tdata);
%selected_epochs
selected_epochs=get(handles.event_listbox,'Value');
tdata=tdata(selected_epochs);
tepoch=tepoch(selected_epochs);
%remove NaN
tepoch(find(isnan(tdata)))=[];
tdata(find(isnan(tdata)))=[];
%check that there is something to display
if isempty(tdata);
    return;
end;
%CLim
CLim=ylim(handles.axes);
%indexpos
indexpos=get(handles.index_popup,'Value');
%dy
y=str2num(get(handles.y_edit,'String'));
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
%dz
z=str2num(get(handles.z_edit,'String'));
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
%figure
f=figure;
%loop through tdata
j=1;
for i=1:length(tdata);
    subplot(1,length(tdata),i);
    %dx
    x=tdata(i);
    dx=round(((x-header.xstart)/header.xstep))+1;
    %vector
    vector=squeeze(datasets(selected_dataset).data(tepoch(i),:,indexpos,dz,dy,dx));
    %chanlocs
    chanlocs=header.chanlocs;
    %parse data and chanlocs according to topo_enabled
    k=1;
    for chanpos=1:size(chanlocs,2);
        if chanlocs(chanpos).topo_enabled==1
            vector2(k)=double(vector(chanpos));
            chanlocs2(k)=chanlocs(chanpos);
            k=k+1;
        end;
    end;
    h=topoplot(vector2,chanlocs2,'maplimits',CLim);
    set(f,'color',[1 1 1]);
    title(num2str(tepoch(i)));
end;








% --- Executes on button press in average_scalpmap_btn.
function average_scalpmap_btn_Callback(hObject, eventdata, handles)
% hObject    handle to average_scalpmap_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%selected_dataset
selected_dataset=get(handles.dataset_popup,'Value');
%header
header=datasets(selected_dataset).header;
%tdata
tdata=get(handles.event_listbox,'Userdata');
%tepoch
tepoch=1:length(tdata);
%remove NaN
tepoch(find(isnan(tdata)))=[];
tdata(find(isnan(tdata)))=[];
%check that there is something to display
if isempty(tdata);
    return;
end;
%CLim
CLim=ylim(handles.axes);
%indexpos
indexpos=get(handles.index_popup,'Value');
%dy
y=str2num(get(handles.y_edit,'String'));
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
%dz
z=str2num(get(handles.z_edit,'String'));
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
%loop through tdata
j=1;
vector=[];
for i=1:length(tdata);
    %dx
    x=tdata(i);
    dx=round(((x-header.xstart)/header.xstep))+1;
    %vector
    vector(:,i)=squeeze(datasets(selected_dataset).data(tepoch(i),:,indexpos,dz,dy,dx));
end;
vector=mean(vector,2);
%figure
f=figure;
%chanlocs
chanlocs=header.chanlocs;
%parse data and chanlocs according to topo_enabled
k=1;
for chanpos=1:size(chanlocs,2);
    if chanlocs(chanpos).topo_enabled==1
        vector2(k)=double(vector(chanpos));
        chanlocs2(k)=chanlocs(chanpos);
        k=k+1;
    end;
end;
h=topoplot(vector2,chanlocs2,'maplimits',CLim);
set(f,'color',[1 1 1]);









function xaxis_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);




% --- Executes during object creation, after setting all properties.
function xaxis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xaxis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



% --- Executes during object creation, after setting all properties.
function xaxis_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function x1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in find_selected_btn.
function find_selected_btn_Callback(hObject, eventdata, handles)
% hObject    handle to find_selected_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



% --- Executes on selection change in peakdir_popup.
function peakdir_popup_Callback(hObject, eventdata, handles)
% hObject    handle to peakdir_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function peakdir_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakdir_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_popup.
function channel_popup_Callback(hObject, eventdata, handles)
% hObject    handle to channel_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);


% --- Executes during object creation, after setting all properties.
function channel_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_popup (see GCBO)
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


% --- Executes on selection change in event_popup.
function event_popup_Callback(hObject, eventdata, handles)
% hObject    handle to event_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function event_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in replace_btn.
function replace_btn_Callback(hObject, eventdata, handles)
% hObject    handle to replace_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%selected_event_code
st=get(handles.event_popup,'String');
selected_dataset=get(handles.dataset_popup,'Value');
selected_event_code=st{get(handles.event_popup,'Value')};
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(selected_dataset).header;
%loop through events > event_string
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    event_string{eventpos}=code;
end;
%delete events with code corresponding to selected_event_code
a=find(strcmpi(selected_event_code,event_string));
if isempty(a);
else
    header.events(a)=[];
end;
%tdata
tdata=get(handles.event_listbox,'Userdata');
for i=1:length(tdata);
    if isnan(tdata(i));
    else
        k=length(header.events)+1;
        header.events(k).code=selected_event_code;
        header.events(k).latency=tdata(i);
        header.events(k).epoch=i;
    end;
end;
%store event in datasets
datasets(selected_dataset).header=header;
set(handles.dataset_popup,'Userdata',datasets);
%update
update_event_popup(handles);
read_event_listbox(handles);







% --- Executes on button press in find_btn.
function find_btn_Callback(hObject, eventdata, handles)
% hObject    handle to find_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%selected_dataset
selected_dataset=get(handles.dataset_popup,'Value');
%epochpos
selected_epochs=get(handles.event_listbox,'Value');
%chanpos
chanpos=get(handles.channel_popup,'Value');
%indexpos
indexpos=get(handles.index_popup,'Value');
%header
header=datasets(selected_dataset).header;
%dy
y=str2num(get(handles.y_edit,'String'));
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
%dz
z=str2num(get(handles.z_edit,'String'));
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
%tdata
tdata=get(handles.event_listbox,'Userdata');
%tpx
tpx=1:1:header.datasize(6);
tpx=((tpx-1)*header.xstep)+header.xstart;
%x1,x2
x1=str2num(get(handles.x1_edit,'String'));
x2=str2num(get(handles.x2_edit,'String'));
%dx1,dx2
[m,dx1]=min(abs(tpx-x1))
[m,dx2]=min(abs(tpx-x2))
if dx1<1;
    dx1=1;
end;
if dx2>header.datasize(6);
    dx2=header.datasize(6);
end;
%peakdir (1=maximum,2=minimum)
peakdir=get(handles.peakdir_popup,'Value');
%loop through selected epochs
for epochpos=1:length(selected_epochs);
    %tpy
    tpy=squeeze(datasets(selected_dataset).data(selected_epochs(epochpos),chanpos,indexpos,dz,dy,:));
    %find peak
    if peakdir==1;
        [m,peak_dx]=max(tpy(dx1:dx2));
    else
        [m,peak_dx]=min(tpy(dx1:dx2));
    end;
    peak_dx=(peak_dx-1)+dx1;
    %peak_x
    peak_x=header.xstart+((peak_dx-1)*header.xstep);
    tdata(selected_epochs(epochpos))=peak_x;
end;
set(handles.event_listbox,'Userdata',tdata);
st={};
for i=1:length(tdata);
    st{i}=[num2str(i) ' : ' num2str(tdata(i))];
end;
set(handles.event_listbox,'String',st);
update_graph(handles);



% --- Executes on button press in find_all_btn.
function find_all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to find_all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%selected_dataset
selected_dataset=get(handles.dataset_popup,'Value');
%chanpos
chanpos=get(handles.channel_popup,'Value');
%indexpos
indexpos=get(handles.index_popup,'Value');
%header
header=datasets(selected_dataset).header;
%dy
y=str2num(get(handles.y_edit,'String'));
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
%dz
z=str2num(get(handles.z_edit,'String'));
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
%tdata
tdata=get(handles.event_listbox,'Userdata');
%tpx
tpx=1:1:header.datasize(6);
tpx=((tpx-1)*header.xstep)+header.xstart;
%x1,x2
x1=str2num(get(handles.x1_edit,'String'));
x2=str2num(get(handles.x2_edit,'String'));
%dx1,dx2
[m,dx1]=min(abs(tpx-x1))
[m,dx2]=min(abs(tpx-x2))
if dx1<1;
    dx1=1;
end;
if dx2>header.datasize(6);
    dx2=header.datasize(6);
end;
%peakdir (1=maximum,2=minimum)
peakdir=get(handles.peakdir_popup,'Value');
%loop through selected epochs
for epochpos=1:header.datasize(1);
    %tpy
    tpy=squeeze(datasets(selected_dataset).data(epochpos,chanpos,indexpos,dz,dy,:));
    %find peak
    if peakdir==1;
        [m,peak_dx]=max(tpy(dx1:dx2));
    else
        [m,peak_dx]=min(tpy(dx1:dx2));
    end;
    peak_dx=(peak_dx-1)+dx1;
    %peak_x
    peak_x=header.xstart+((peak_dx-1)*header.xstep);
    tdata(epochpos)=peak_x;
end;
set(handles.event_listbox,'Userdata',tdata);
st={};
for i=1:length(tdata);
    st{i}=[num2str(i) ' : ' num2str(tdata(i))];
end;
set(handles.event_listbox,'String',st);
update_graph(handles);







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


% --- Executes on button press in reverse_chk.
function reverse_chk_Callback(hObject, eventdata, handles)
% hObject    handle to reverse_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);






% --- Executes on button press in autoy_chk.
function autoy_chk_Callback(hObject, eventdata, handles)
% hObject    handle to autoy_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);



% --- Executes on mouse press over axes background.
function axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in update_x_btn.
function update_x_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_x_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x_limits=xlim(handles.axes);
set(handles.xaxis_min_edit,'String',num2str(x_limits(1)));
set(handles.xaxis_max_edit,'String',num2str(x_limits(2)));
update_graph(handles);


% --- Executes on button press in zoom_mode_chk.
function zoom_mode_chk_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_mode_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.zoom_mode_chk,'Value')==1;
    zoom(handles.axes,'on');
else
    zoom(handles.axes,'off');
end;


% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);




% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
