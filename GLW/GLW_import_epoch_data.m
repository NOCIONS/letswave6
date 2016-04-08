function varargout = GLW_import_epoch_data(varargin)
% GLW_IMPORT_EPOCH_DATA MATLAB code for GLW_import_epoch_data.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_import_epoch_data_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_import_epoch_data_OutputFcn, ...
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









% --- Executes just before GLW_import_epoch_data is made visible.
function GLW_import_epoch_data_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_import_epoch_data (see VARARGIN)
% Choose default command line output for GLW_import_epoch_data
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
%refresh_workspace_variables
refresh_workspace_variables(handles);
%store epoch data
header=datasets(1).header;
if isfield(header,'epochdata');
    set(handles.epochdata_listbox,'Userdata',header.epochdata);
else
    for i=1:header.datasize(1);
        epochdata(i).data=[];
    end;
    set(handles.epochdata_listbox,'Userdata',epochdata);
end;
%refresh_epochdata_listbox
refresh_epochdata_listbox(handles);
    
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






function a=load_selected_workspace_var(varname);
a=evalin('base',varname);






function refresh_workspace_variables(handles)
%load workspace variables
vars = evalin('base','who');
set(handles.workspace_listbox,'String',vars);
%check selection
v=get(handles.workspace_listbox,'Value');
if isempty(v);
else
    v(find(v>length(vars)))=[];
    set(handles.workspace_listbox,'Value',v);
end;





function refresh_epochdata_listbox(handles);
%epochdata
epochdata=get(handles.epochdata_listbox,'Userdata');
st={};
if isempty(epochdata);
else
    if isempty(epochdata(1).data);
    else
        st=fieldnames(epochdata(1).data);
    end;
end;
set(handles.epochdata_listbox,'String',st);
%check selection
v=get(handles.epochdata_listbox,'Value');
if v>length(st);
    set(handles.epochdata_listbox,'Value',1);
end;
if isempty(v);
    set(handles.epochdata_listbox,'Value',1);
end;








% --- Outputs from this function are returned to the command line.
function varargout = GLW_import_epoch_data_OutputFcn(hObject, eventdata, handles) 
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
epochdata=get(handles.epochdata_listbox,'Userdata');
configuration.parameters.epoch_data=epochdata;
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


% --- Executes on selection change in workspace_listbox.
function workspace_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to workspace_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function workspace_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workspace_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_MAT_btn.
function load_MAT_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_MAT_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec='*.mat;*.MAT';
st={};
[st,pathname]=uigetfile(filterspec,'select datafiles','MultiSelect','on');
if isempty(st);
else
    if iscell(st);
    else
        st2{1}=st;
        st=st2;
    end;
    for i=1:length(st);
        filename{i}=[pathname,st{i}];
    end;
end;
for i=1:length(filename);
    if isstr(filename{i});
        st=['load ''' filename{i} '''']
        try
            evalin('base',st);
        catch
        end;
    end;
end;
refresh_workspace_variables(handles);




% --- Executes on button press in load_CSV_btn.
function load_CSV_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_CSV_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec='*.csv;*.CSV;*.txt;*.TXT;*.asc;*.ASC';
st={};
[st,pathname]=uigetfile(filterspec,'select datafiles','MultiSelect','on');
if isempty(st);
else
    if iscell(st);
    else
        st2{1}=st;
        st=st2;
    end;
    for i=1:length(st);
        filename{i}=[pathname,st{i}];
    end;
end;
for i=1:length(filename);
    if isstr(filename{i});
        st=['csv_import=csvread(''' filename{i} ''')']
        try
            evalin('base',st);
        catch
        end;
    end;
end;
refresh_workspace_variables(handles);




% --- Executes on selection change in epochdata_listbox.
function epochdata_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to epochdata_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function epochdata_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochdata_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in import_btn.
function import_btn_Callback(hObject, eventdata, handles)
% hObject    handle to import_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%epochdata
epochdata=get(handles.epochdata_listbox,'Userdata');
%selected_fieldname
st=get(handles.epochdata_listbox,'String');
v=get(handles.epochdata_listbox,'Value');
if isempty(v);
    return;
else  
    selected_fieldname=st{v};
end;
%var_name
st=get(handles.workspace_listbox,'String');
if isempty(st);
    return;
end;
v=get(handles.workspace_listbox,'Value');
if isempty(v);
    return;
end;
var_name=st{v};
disp(['field name : ' selected_fieldname]);
disp(['var name : ' var_name]);
%check length of var_name
a=load_selected_workspace_var(var_name);
if length(a)==length(epochdata);
    disp('Variable length corresponds to the number of epochs in the dataset.');
else
    disp('Variable length does not correspond to the number of epochs in the dataset.');
    disp('There is probably a mistake!');
    return;
end;
%import
max_idx=min([length(epochdata) length(a)]);
disp(['Importing ' num2str(max_idx) ' values.']);
for i=1:max_idx;
    epochdata(i).data=setfield(epochdata(i).data,selected_fieldname,a(i));
end;
%update
set(handles.epochdata_listbox,'Userdata',epochdata);
refresh_epochdata_listbox(handles);
    



% --- Executes on button press in new_btn.
function new_btn_Callback(hObject, eventdata, handles)
% hObject    handle to new_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%epochdata
epochdata=get(handles.epochdata_listbox,'Userdata');
%field name
field_name=inputdlg('field name','name of new field');
field_name=field_name{1};
if isempty(field_name);
    return;
end;
%update epochdata
for i=1:length(epochdata);
    epochdata(i).data=setfield(epochdata(i).data,field_name,[]);
end;
%update epochdata
set(handles.epochdata_listbox,'Userdata',epochdata);
refresh_epochdata_listbox(handles);






% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%epochdata
epochdata=get(handles.epochdata_listbox,'Userdata');
%v
v=get(handles.epochdata_listbox,'Value');
if isempty(v);
    return;
end;
%field_name
st=get(handles.epochdata_listbox,'String');
if isempty(st);
    return;
end;
field_name=st{v};
%delete field
for i=1:length(epochdata);
    epochdata(i).data=rmfield(epochdata(i).data,field_name);
end;
%update epochdata
set(handles.epochdata_listbox,'Userdata',epochdata);
refresh_epochdata_listbox(handles);





% --- Executes on button press in rename_btn.
function rename_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rename_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%epochdata
epochdata=get(handles.epochdata_listbox,'Userdata');
%old_name
st=get(handles.epochdata_listbox,'String');
if isempty(st);
    return;
end;
v=get(handles.epochdata_listbox,'Value');
if isempty(v);
    return;
end;
old_name=st(v);
%field name
field_name=inputdlg('field name','rename field',1,old_name);
field_name=field_name{1};
if isempty(field_name);
    return;
end;
%update epochdata
old_name=st{v};
for i=1:length(epochdata);
    epochdata(i).data=setfield(epochdata(i).data,field_name,getfield(epochdata(i).data,old_name));
end;
for i=1:length(epochdata);
    epochdata(i).data=rmfield(epochdata(i).data,old_name);
end;
%update epochdata
set(handles.epochdata_listbox,'Userdata',epochdata);
refresh_epochdata_listbox(handles);




% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
% hObject    handle to refresh_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_workspace_variables(handles);
