function varargout = CGLW_dataset_rename(varargin)
% CGLW_DATASET_RENAME MATLAB code for CGLW_dataset_rename.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_dataset_rename_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_dataset_rename_OutputFcn, ...
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









% --- Executes just before CGLW_dataset_rename is made visible.
function CGLW_dataset_rename_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_dataset_rename (see VARARGIN)
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%folder_names
inputfiles=varargin{2};
inputfiles=inputfiles{1};
set(handles.filename_edit,'Userdata',inputfiles);
[p n e]=fileparts(inputfiles);
set(handles.filename_edit,'String',n);







% --- Outputs from this function are returned to the command line.
function varargout = CGLW_dataset_rename_OutputFcn(hObject, eventdata, handles) 
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
st=get(handles.filename_edit,'String');
[p n2 e]=fileparts(st);
inputfile=get(handles.filename_edit,'Userdata');
[p n e]=fileparts(inputfile);
st1=[p filesep n e];
st2=[p filesep n2 e];
disp(['Rename : ' st1 ' > ' st2]);
movefile(st1,st2);   
st1=[p filesep n '.mat'];
st2=[p filesep n2 '.mat'];
disp(['Rename : ' st1 ' > ' st2]);
movefile(st1,st2);   

close;








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
