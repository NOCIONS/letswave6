function varargout = GLW_view_epochdata(varargin)
% GLW_VIEW_EPOCHDATA MATLAB code for GLW_view_epochdata.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_view_epochdata_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_view_epochdata_OutputFcn, ...
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









% --- Executes just before GLW_view_epochdata is made visible.
function GLW_view_epochdata_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_view_epochdata (see VARARGIN)
% Choose default command line output for GLW_view_epochdata
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
%dataset_listbox
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_popup,'String',st);
%epochs
update_epochs(handles);
%epochdata
update_epochdata(handles);
%!!!
%END
%!!!



function update_epochdata(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%epochdata
if isfield(header,'epochdata');
    if isfield(header.epochdata(1),'data');
    else
        return;
    end;
else
    return;
end;
%selected_epoch
selected_epoch=get(handles.epoch_popup,'Value');
%selected_epochdata
data=header.epochdata(selected_epoch).data;
names=fieldnames(data);
for i=1:length(names);
    tdata{i,1}=names{i};
    value=getfield(data,names{i});
    tdata{i,2}=value;
end;
set(handles.epochdata_table,'Data',tdata);
%epochdata_popup
set(handles.epochdata_popup,'String',names);







function update_epochs(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%epoch_string
st={};
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_popup,'String',st);
if get(handles.epoch_popup,'Value')>length(st);
    set(handles.epoch_popup,'Value',1);
end;






% --- Outputs from this function are returned to the command line.
function varargout = GLW_view_epochdata_OutputFcn(hObject, eventdata, handles) 
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
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%epochdata
if isfield(header,'epochdata');
    if isfield(header.epochdata(1),'data');
    else
        return;
    end;
else
    return;
end;
%selected_epochdata field
st=get(handles.epochdata_popup,'String');
selected_epochdata_field=st{get(handles.epochdata_popup,'Value')};
%
ep_data={};
for i=1:header.datasize(1);
    if isfield(header.epochdata(i).data,selected_epochdata_field);
        ep_data{i}=getfield(header.epochdata(i).data,selected_epochdata_field);
    else
        ep_data{i}=NaN;
    end;
end;
%figure
figure;
plot(cell2mat(ep_data));
    














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
update_epochs(handles);
update_epochdata(handles);



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
update_epochdata(handles);



% --- Executes during object creation, after setting all properties.
function epoch_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in workspace_btn.
function workspace_btn_Callback(hObject, eventdata, handles)
% hObject    handle to workspace_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%epochdata
if isfield(header,'epochdata');
    if isfield(header.epochdata(1),'data');
    else
        return;
    end;
else
    return;
end;
%selected_epochdata field
st=get(handles.epochdata_popup,'String');
selected_epochdata_field=st{get(handles.epochdata_popup,'Value')};
%
ep_data={};
for i=1:header.datasize(1);
    if isfield(header.epochdata(i).data,selected_epochdata_field);
        ep_data{i}=getfield(header.epochdata(i).data,selected_epochdata_field);
    else
        ep_data{i}=NaN;
    end;
end;
%send to workspace
assignin('base','ep_data',ep_data);








% --- Executes on selection change in epochdata_popup.
function epochdata_popup_Callback(hObject, eventdata, handles)
% hObject    handle to epochdata_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns epochdata_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from epochdata_popup


% --- Executes during object creation, after setting all properties.
function epochdata_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochdata_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
