function varargout = GLW_function(varargin)
% GLW_FUNCTION MATLAB code for GLW_function.fig
%




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_function_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_function_OutputFcn, ...
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




% --- Executes just before GLW_function is made visible.
function GLW_function_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_function (see VARARGIN)
% Choose default command line output for GLW_function
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%fill listbox with inputfiles (the array of input files is stored in varargin{2})
%The 'UserData' field contains the full path+filename of the LW5 datafile
set(handles.filebox,'UserData',varargin{2});
st=get(handles.filebox,'UserData');
for i=1:length(inputfiles);
    [p,n,e]=fileparts(st{i});
    inputfiles{i}=n;
end;
%The 'String' field only contains the name (without path and extension)
set(handles.filebox,'String',inputfiles);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_function_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure





% --- Executes during object creation, after setting all properties.
function figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
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




% --- Executes on button press in processbutton.
function processbutton_Callback(hObject, eventdata, handles)
% hObject    handle to processbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%get the list of inputfiles
inputfiles=get(handles.filebox,'UserData');
%set the parameters used for the process
parameter=1;
disp('*** Starting.');
%loop through files
for filepos=1:length(inputfiles);
    %load header
    [p,n,e]=fileparts(inputfiles{filepos});
    st=[p,filesep,n,'.lw5'];
    disp(['loading ',st]);
    load(st,'-MAT');
    %load data
    st=[p,filesep,n,'.mat'];
    load(st,'-MAT');   
    %process
    disp('*** Process : ');
    [header,data]=LW_function(header,data,parameter);
    %save header
    st=[p,filesep,get(handles.prefixtext,'String'),' ',n,'.lw5'];
    disp(['saving ',st]);
    save(st,'-MAT','header');
    %save data
    st=[p,filesep,get(handles.prefixtext,'String'),' ',n,'.mat'];
    save(st,'-MAT','data');
end;
disp('*** Finished.');


