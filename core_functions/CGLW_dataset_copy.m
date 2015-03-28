function varargout = CGLW_dataset_copy(varargin)
% CGLW_DATASET_COPY MATLAB code for CGLW_dataset_copy.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_dataset_copy_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_dataset_copy_OutputFcn, ...
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









% --- Executes just before CGLW_dataset_copy is made visible.
function CGLW_dataset_copy_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_dataset_copy (see VARARGIN)
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
set(handles.dataset_listbox,'Userdata',inputfiles);
set(handles.dataset_listbox,'String',st);








% --- Outputs from this function are returned to the command line.
function varargout = CGLW_dataset_copy_OutputFcn(hObject, eventdata, handles) 
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
st=get(handles.dataset_listbox,'Userdata');
p2=get(handles.folder_text,'String');
for i=1:length(st);
    st1=st{i};
    [p n e]=fileparts(st{i});
    st2=[p2 filesep n e];
    disp(['Copy : ' st1 ' > ' st2]);
    copyfile(st1,st2);
    st1=[p filesep n '.mat'];
    st2=[p2 filesep n '.mat'];
    disp(['Copy : ' st1 ' > ' st2]);
    copyfile(st1,st2);
end;
close; 
 








% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);






function new_path_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to new_path_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function new_path_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to new_path_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in folder_listbox.
function folder_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to folder_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function folder_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to folder_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_folder_btn.
function select_folder_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_folder_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=uigetdir(pwd);
if st==0;
else
    if exist(st)==7;
        set(handles.original_path_name_edit,'String',st);
    end;
end;



function original_path_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to original_path_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function original_path_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to original_path_name_edit (see GCBO)
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



% --- Executes during object creation, after setting all properties.
function dataset_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in folder_btn.
function folder_btn_Callback(hObject, eventdata, handles)
% hObject    handle to folder_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=uigetdir(pwd);
if st==0;
else
    if exist(st)==7;
        set(handles.folder_text,'String',st);
    end;
end;
set(handles.process_btn,'Enable','on');
