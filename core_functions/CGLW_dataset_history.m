function varargout = CGLW_dataset_history(varargin)
% CGLW_DATASET_HISTORY MATLAB code for CGLW_dataset_history.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_dataset_history_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_dataset_history_OutputFcn, ...
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









% --- Executes just before CGLW_dataset_history is made visible.
function CGLW_dataset_history_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_dataset_history (see VARARGIN)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%inputfiles
inputfiles=varargin{2};
%overwrite_chk Userdata stores status update_status
set(handles.process_btn,'Userdata',varargin{3});
%check that inputfiles is not empty
if isempty(inputfiles);
    return;
end;
%load datasets
for i=1:length(inputfiles);
    [datasets(i).header datasets(i).data]=CLW_load(inputfiles{i});
end;
%store datasets
set(handles.dataset_popup,'Userdata',datasets);
%dataset_names
st={};
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_popup,'String',st);
set(handles.dataset_popup,'Value',1);
%
update_history_listbox(handles);





function update_history_listbox(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%history_string
history_string={};
if isfield(header,'history');
    for i=1:length(header.history);
        history_string{i}=header.history(i).configuration.gui_info.name;
    end;
end;
set(handles.history_listbox,'String',history_string);






% --- Outputs from this function are returned to the command line.
function varargout = CGLW_dataset_history_OutputFcn(hObject, eventdata, handles) 
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






% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%dataset
dataset=datasets(get(handles.dataset_popup,'Value'));
%selected_item
selected_item=get(handles.history_listbox,'Value');
%configuration
configuration=dataset.header.history(selected_item).configuration;
%update_pointers
update_pointers=get(handles.process_btn,'Userdata');
%configuration
configuration.gui_mode.configuration_mode='history';
%process function
eval_st=[configuration.gui_info.function_name '(''configure'',configuration,dataset,update_pointers)'];
[configuration,dataset]=eval(eval_st);









% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);






function filename_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function filename_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in history_listbox.
function history_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to history_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function history_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to history_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in config_param_btn.
function config_param_btn_Callback(hObject, eventdata, handles)
% hObject    handle to config_param_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%dataset
dataset=datasets(get(handles.dataset_popup,'Value'));
%selected_item
selected_item=get(handles.history_listbox,'Value');
%configuration
configuration=dataset.header.history(selected_item).configuration;
%parameters
parameters=configuration.parameters
fn=fieldnames(parameters);
for i=1:length(fn);
    table_data{i,1}=fn{i};
    tp=getfield(parameters,fn{i});
    if iscell(tp);
        tp=char(tp);
    end;
    if isnumeric(tp);
        tp=num2str(tp);
    end;
    table_data{i,2}=tp;
end;
h2=figure;
col_headers{1}='parameter';
col_headers{2}='value';
uitable(h2,'Data',table_data,'ColumnName',col_headers,'Units','normalized','Position', [0 0 1 1]);


