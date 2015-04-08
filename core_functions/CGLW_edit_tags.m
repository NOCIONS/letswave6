function varargout = CGLW_edit_tags(varargin)
% CGLW_EDIT_TAGS MATLAB code for CGLW_edit_tags.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_edit_tags_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_edit_tags_OutputFcn, ...
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









% --- Executes just before CGLW_edit_tags is made visible.
function CGLW_edit_tags_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_edit_tags (see VARARGIN)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%filenames
inputfiles=varargin{2};
%store inputfiles
set(handles.process_btn,'Userdata',inputfiles);
%load headers
for i=1:length(inputfiles);
    datasets(i).header=CLW_load_header(inputfiles{i});
end;
set(handles.tag_listbox,'Userdata',datasets);
%find tags
update_tags(handles);





function update_tags(handles);
%datasets
datasets=get(handles.tag_listbox,'Userdata');
%loop through headers
st={};
for i=1:length(datasets);
    if isfield(datasets(i).header,'tags');
        st=[st datasets(i).header.tags];
    end;
end;
if isempty(st);
else
    st=sort(unique(st));
end;
set(handles.tag_listbox,'String',st);







% --- Outputs from this function are returned to the command line.
function varargout = CGLW_edit_tags_OutputFcn(hObject, eventdata, handles) 
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
datasets=get(handles.tag_listbox,'Userdata');
%inputfiles
inputfiles=get(handles.process_btn,'Userdata');
%
for i=1:length(datasets);
    [p,n,e]=fileparts(inputfiles{i});
    CLW_save_header(p,datasets(i).header);
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
    set(handleS.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);






% --- Executes on selection change in tag_listbox.
function tag_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to tag_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function tag_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tag_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function new_tag_edit_Callback(hObject, eventdata, handles)
% hObject    handle to new_tag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function new_tag_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to new_tag_edit (see GCBO)
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
%datasets
datasets=get(handles.tag_listbox,'Userdata');
%tag_name
tag_name=get(handles.new_tag_edit,'String');
%loop
for i=1:length(datasets);
    if isfield(datasets(i).header,'tags');
        datasets(i).header.tags{end+1}=tag_name;
    else
        datasets(i).header.tags{1}=tag_name;
    end;
    datasets(i).header.tags=unique(datasets(i).header.tags);
end;
%update
set(handles.tag_listbox,'Userdata',datasets);
update_tags(handles);






% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%selected_tag
st=get(handles.tag_listbox,'String');
selected_tag=st{get(handles.tag_listbox,'Value')};
if isempty(selected_tag);
    disp('No tag selected. Exit.');
    return;
end;
%datasets
datasets=get(handles.tag_listbox,'Userdata');
%loop
for i=1:length(datasets);
    if isfield(datasets(i).header,'tags');
        a=find(strcmpi(selected_tag,datasets(i).header.tags));
        if isempty(a);
        else
            for j=1:length(a);
                datasets(i).header.tags(a(j))=[];
            end;
        end;
    end;
end;
%
set(handles.tag_listbox,'Userdata',datasets);
update_tags(handles);







% --- Executes on button press in rename_btn.
function rename_btn_Callback(hObject, eventdata, handles)
% hObject    handle to rename_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%selected_tag
st=get(handles.tag_listbox,'String');
selected_tag=st{get(handles.tag_listbox,'Value')};
if isempty(selected_tag);
    disp('No tag selected. Exit.');
    return;
end;
%datasets
datasets=get(handles.tag_listbox,'Userdata');
%new_tag_name
new_tag_name=get(handles.rename_tag_edit,'String');
%loop
for i=1:length(datasets);
    if isfield(datasets(i).header,'tags');
        a=find(strcmpi(selected_tag,datasets(i).header.tags));
        if isempty(a);
        else
            for j=1:length(a);
                datasets(i).header.tags{a(j)}=new_tag_name;
            end;
        end;
        datasets(i).header.tags=unique(datasets(i).header.tags);
    end;
end;
%
set(handles.tag_listbox,'Userdata',datasets);
update_tags(handles);




function rename_tag_edit_Callback(hObject, eventdata, handles)
% hObject    handle to rename_tag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function rename_tag_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rename_tag_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
