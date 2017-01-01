function varargout = GLW_event_viewer(varargin)
% GLW_EVENT_VIEWER MATLAB code for GLW_event_viewer.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_event_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_event_viewer_OutputFcn, ...
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









% --- Executes just before GLW_event_viewer is made visible.
function GLW_event_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_event_viewer (see VARARGIN)
% Choose default command line output for GLW_event_viewer
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
if length(datasets)>1;
    disp('Only one dataset can be edited.');
    return;
end;
%datasets
set(handles.event_listbox,'Userdata',datasets);
%header
header=datasets(1).header;
%fill event_listbox
event_string=search_events(handles,header);
if isempty(event_string);
    return;
end;
set(handles.event_listbox,'String',event_string);
%event_table
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
%initialize y_edit,z_edit
set(handles.y_edit,'String',num2str(header.ystart));
set(handles.z_edit,'String',num2str(header.zstart));
%initialize channel_popup
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_popup,'String',st);
set(handles.channel_popup,'Value',1);
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
%initialize index_popup
table=make_table(handles,event_string);
set(handles.event_table,'Data',table);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
%uiwait(handles.figure1);










function event_string=search_events(handles,header);
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









function table=make_table(handles,event_string);
%datasets
datasets=get(handles.event_listbox,'Userdata');
%header
header=datasets(1).header;
%dy,dz
y=str2num(get(handles.y_edit,'String'));
z=str2num(get(handles.z_edit,'String'));
if header.datasize(5)==1;
    dy=1;
else
    dy=round(((y-header.ystart)/header.ystep))+1;
end;
if header.datasize(4)==1;
    dz=1;
else
    dz=round(((z-header.zstart)/header.zstep))+1;
end;
%indexpos
if header.datasize(3)==1;
    indexpos=1;
else
    indexpos=get(handles.index_popup,'Value');
end;
%chanpos
if header.datasize(2)==1;
    chanpos=1;
else
    chanpos=get(handles.channel_popup,'Value');
end;
%initialize table
table={};
%loop through events
tablepos=1;
for eventpos=1:length(header.events);
    %check if the eventcode is in the eventlist
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    if strcmpi(code,event_string);
        table{tablepos,1}=header.events(eventpos).code;
        table{tablepos,2}=header.events(eventpos).epoch;
        table{tablepos,3}=header.events(eventpos).latency;
        %epochpos
        epochpos=header.events(eventpos).epoch;
        %dx
        x=header.events(eventpos).latency;
        dx=round(((x-header.xstart)/header.xstep))+1;
        %value?
        v=datasets(1).data(epochpos,chanpos,indexpos,dz,dy,dx);
        table{tablepos,4}=v;
        tablepos=tablepos+1;
    end;
end;






% --- Outputs from this function are returned to the command line.
function varargout = GLW_event_viewer_OutputFcn(hObject, eventdata, handles) 
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
% handles    structure with handles and user data (see GUIDATA)
%varname
varname=get(handles.varname_edit,'String');
disp(['Event table sent to : ' varname]);
%fetch table
tp=get(handles.event_table,'Data');
disp('Column 1 = code');
disp('Column 2 = epoch');
disp('Column 3 = latency');
disp('Column 4 : amplitude');
assignin('base',varname,tp);








% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
table=make_table(handles,event_string);
set(handles.event_table,'Data',table);








% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function varname_edit_Callback(hObject, eventdata, handles)
% hObject    handle to varname_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes during object creation, after setting all properties.
function varname_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varname_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes when selected cell(s) is changed in event_table.
function event_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to event_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)







% --- Executes when entered data in editable cell(s) in event_table.
function event_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to event_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)





% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: delete(hObject) closes the figure
delete(hObject);





% --- Executes on button press in exit_btn.
function exit_btn_Callback(hObject, eventdata, handles)
% hObject    handle to exit_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.figure1);



function y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
table=make_table(handles,event_string);
set(handles.event_table,'Data',table);



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
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
table=make_table(handles,event_string);
set(handles.event_table,'Data',table);





% --- Executes during object creation, after setting all properties.
function z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
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
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
table=make_table(handles,event_string);
set(handles.event_table,'Data',table);




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
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
table=make_table(handles,event_string);
set(handles.event_table,'Data',table);






% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in graph_btn.
function graph_btn_Callback(hObject, eventdata, handles)
% hObject    handle to graph_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fetch table
tp=get(handles.event_table,'Data');
%Column 1 = code
%Column 2 = epoch
%Column 3 = latency
%Column 4 : amplitude
figure;
%latencies
subplot(2,1,1);
tp2=cell2mat(tp(:,3));
plot(tp2);
%amplitudes
subplot(2,1,2);
tp2=cell2mat(tp(:,4));
plot(tp2);


% --- Executes on button press in topo_btn.
function topo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to topo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
dataset=get(handles.event_listbox,'Userdata');
dataset=dataset(1);
%header
header=dataset(1).header;
%selected_event
event_string=get(handles.event_listbox,'String');
selected_event_string=event_string{get(handles.event_listbox,'Value')};
%event_latencies
j=1;
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    if strcmpi(code,selected_event_string);
        if isnumeric(header.events(eventpos).latency);
            if isnan(header.events(eventpos).latency);
            else
                event_latencies(j)=header.events(eventpos).latency;
                event_epochs(j)=header.events(eventpos).epoch;
                j=j+1;
            end;
        end;
    end;
end;
%check that there is something to display
if isempty(event_latencies);
    return;
end;
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
%loop through event_latencies
j=1;
for i=1:length(event_latencies);
    subplot(1,length(event_latencies),i);
    %dx
    x=event_latencies(i);
    dx=round(((x-header.xstart)/header.xstep))+1;
    %vector
    vector=squeeze(dataset.data(event_epochs(i),:,indexpos,dz,dy,dx));
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
    h=topoplot(vector2,chanlocs2);
    set(f,'color',[1 1 1]);
    title([num2str(event_epochs(i)) ' : ' num2str(event_latencies(i))]);
end;








% --- Executes on button press in average_topo_btn.
function average_topo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to average_topo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
dataset=get(handles.event_listbox,'Userdata');
dataset=dataset(1);
%header
header=dataset(1).header;
%selected_event
event_string=get(handles.event_listbox,'String');
selected_event_string=event_string{get(handles.event_listbox,'Value')};
%event_latencies
j=1;
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    if strcmpi(code,selected_event_string);
        if isnumeric(header.events(eventpos).latency);
            if isnan(header.events(eventpos).latency);
            else
                event_latencies(j)=header.events(eventpos).latency;
                event_epochs(j)=header.events(eventpos).epoch;
                j=j+1;
            end;
        end;
    end;
end;
%check that there is something to display
if isempty(event_latencies);
    return;
end;
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
%loop through event_latencies
j=1;
for i=1:length(event_latencies);
    %dx
    x=event_latencies(i);
    dx=round(((x-header.xstart)/header.xstep))+1;
    %vector
    vector(:,i)=squeeze(dataset.data(event_epochs(i),:,indexpos,dz,dy,dx));
end;
vector=mean(vector,2);
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
h=topoplot(vector2,chanlocs2);
set(f,'color',[1 1 1]);
