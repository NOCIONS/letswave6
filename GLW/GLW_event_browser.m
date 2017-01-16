function varargout = GLW_event_browser(varargin)
% GLW_EVENT_BROWSER MATLAB code for GLW_event_browser.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_event_browser_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_event_browser_OutputFcn, ...
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









% --- Executes just before GLW_event_browser is made visible.
function GLW_event_browser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_event_browser (see VARARGIN)
% Choose default command line output for GLW_event_browser
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
%header
header=datasets(1).header;
%fill event_listbox
event_string=search_events(handles,header);
set(handles.event_listbox,'String',event_string);
%event_table
if isempty(event_string);
else
    event_string=get(handles.event_listbox,'String');
    event_string=event_string{get(handles.event_listbox,'Value')};
end;
table=make_table(handles,header,event_string);
set(handles.event_table,'Data',table);
%datasets
set(handles.event_listbox,'Userdata',datasets);
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









function table=make_table(handles,header,event_string);
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
        table{tablepos,2}=num2str(header.events(eventpos).epoch);
        table{tablepos,3}=num2str(header.events(eventpos).latency);
        tablepos=tablepos+1;
    end;
end;








% --- Outputs from this function are returned to the command line.
function varargout = GLW_event_browser_OutputFcn(hObject, eventdata, handles) 
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
%datasets
datasets=get(handles.event_listbox,'Userdata');
%loop through inputfiles
for i=1:length(datasets);
    CLW_save_header(pwd,datasets(i).header);
end;










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
    










% --- Executes on button press in send_workspace_btn.
function send_workspace_btn_Callback(hObject, eventdata, handles)
% hObject    handle to send_workspace_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%varname
varname=get(handles.varname_edit,'String');
disp(['Event table sent to : ' varname]);
%datasets
datasets=get(handles.event_listbox,'Userdata');
%events
if isfield(datasets(1).header,'events');
    events=datasets(1).header.events;
else
    events=[];
end;
%convert events structure to matrix
tp={};
for i=1:length(events);
    tp{i,1}=events(i).code;
    tp{i,2}=events(i).epoch;
    tp{i,3}=events(i).latency;
end;
disp('Column 1 = code');
disp('Column 2 = epoch');
disp('Column 3 = latency');
assignin('base',varname,tp);








% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.event_listbox,'Userdata');
%header
header=datasets(1).header;
%
event_string=get(handles.event_listbox,'String');
event_string=event_string{get(handles.event_listbox,'Value')};
table=make_table(handles,header,event_string);
set(handles.event_table,'Data',table);








% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
event_pos=fix(str2num(get(handles.position_edit,'String')));
table_data=get(handles.event_table,'Data');
table_data(event_pos,:)=[];
set(handles.event_table,'Data',table_data);



function position_edit_Callback(hObject, eventdata, handles)
% hObject    handle to position_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function position_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to position_edit (see GCBO)
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
event_pos=fix(str2num(get(handles.position_edit,'String')));
table_data=get(handles.event_table,'Data');
newline={table_data{1,1} '1' '0'};
tp1=table_data(1:event_pos,:);
tp2=table_data(event_pos+1:end,:);
table_data=vertcat(tp1,newline,tp2);
set(handles.event_table,'Data',table_data);






% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%table_data
table_data=get(handles.event_table,'Data');
%selected_event_code
selected_event_code=table_data{1,1};
%datasets
datasets=get(handles.event_listbox,'Userdata');
%header
header=datasets(1).header;
%event_codes
for i=1:length(header.events);
    if isnumeric(header.events(i).code)
        code=num2str(header.events(i).code);
    else
        code=header.events(i).code;
    end;
    event_codes{i}=code;
end;
%find event_codes corresponding to table event code
a=find(strcmpi(selected_event_code,event_codes));
%delete event codes
header.events(a)=[];
%add events in table_data
for i=1:size(table_data,1);
    event.code=table_data{i,1};
    event.epoch=fix(str2num(table_data{i,2}));
    event.latency=str2num(table_data{i,3});
    header.events(end+1)=event;
end;
%datasets
datasets(1).header=header;
set(handles.event_listbox,'Userdata',datasets);
%update
event_string=search_events(handles,header);
set(handles.event_listbox,'String',event_string);
set(handles.event_listbox,'Value',1);
%get eventlist
event_string=get(handles.event_listbox,'String');
if isempty(event_string);
    set(handles.event_listbox,'Data',[]);
else
    event_string=event_string{get(handles.event_listbox,'Value')};
    table=make_table(handles,header,event_string);
    set(handles.event_table,'Data',table);
end;






% --- Executes on button press in delete_cat_btn.
function delete_cat_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_cat_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%event_string
event_string=get(handles.event_listbox,'String');
%selected_event
selected_event=event_string{get(handles.event_listbox,'Value')};
%datasets
datasets=get(handles.event_listbox,'Userdata');
header=datasets(1).header;
%event_codes
event_codes={};
for i=1:length(header.events);
    if isnumeric(header.events(i).code)
        code=num2str(header.events(i).code);
    else
        code=header.events(i).code;
    end;
    event_codes{i}=code;
end;
%find events
idx=find(strcmpi(event_codes,selected_event));
%update header
header.events(idx)=[];
datasets(1).header=header;
set(handles.event_listbox,'UserData',datasets);
%update
event_string=search_events(handles,header);
set(handles.event_listbox,'String',event_string);
set(handles.event_listbox,'Value',1);
%get eventlist
event_string=get(handles.event_listbox,'String');
if isempty(event_string);
    set(handles.event_table,'Data',[]);
else
    event_string=event_string{get(handles.event_listbox,'Value')};
    table=make_table(handles,header,event_string);
    set(handles.event_table,'Data',table);
end;







% --- Executes on button press in read_workspace_btn.
function read_workspace_btn_Callback(hObject, eventdata, handles)
% hObject    handle to read_workspace_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%varname
varname=get(handles.varname_edit,'String');
%datasets
datasets=get(handles.event_listbox,'Userdata');
%header
header=datasets(1).header;
%
disp(['Variable name : ' varname]);
disp('Column 1 = code');
disp('Column 2 = epoch');
disp('Column 3 = latency');
%fetch cell matrix
tp=evalin('base',varname);
%convert matrix to events structure
events=[];
for i=1:size(tp,1);
    events(i).code=tp{i,1};
    events(i).epoch=tp{i,2};
    events(i).latency=tp{i,3};
end;
datasets(1).header.events=events;
set(handles.event_listbox,'Userdata',datasets);
%update
event_string=search_events(handles,datasets(1).header);
set(handles.event_listbox,'String',event_string);
set(handles.event_listbox,'Value',1);
%get eventlist
event_string=get(handles.event_listbox,'String');
if isempty(event_string);
    set(handles.event_table,'Data',[]);
else
    event_string=event_string{get(handles.event_listbox,'Value')};
    table=make_table(handles,header,event_string);
    set(handles.event_table,'Data',table);
end;










% --- Executes on button press in rename_cat_btn.
function rename_cat_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rename_cat_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
event_string=get(handles.event_listbox,'String');
selected_event=event_string{get(handles.event_listbox,'Value')};
datasets=get(handles.event_listbox,'Userdata');
header=datasets(1).header;
%dialog box
new_name=cellstr(inputdlg('Enter new code name :','Rename category'));
for i=1:length(header.events);
    if strcmpi(header.events(i).code,selected_event);
        header.events(i).code=new_name{1};
    end;
end;
datasets(1).header=header;
set(handles.event_listbox,'UserData',datasets);
%update
event_string=search_events(handles,header);
set(handles.event_listbox,'String',event_string);
set(handles.event_listbox,'Value',1);
%get eventlist
event_string=get(handles.event_listbox,'String');
if isempty(event_string);
    set(handles.event_listbox,'Data',[]);
else
    event_string=event_string{get(handles.event_listbox,'Value')};
    table=make_table(handles,header,event_string);
    set(handles.event_table,'Data',table);
end;




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
try
    eventpos=eventdata.Indices(1);
    set(handles.position_edit,'String',num2str(eventpos));
end;







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
