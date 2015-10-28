function varargout = GLW_copyevents(varargin)
% GLW_COPYEVENTS MATLAB code for GLW_copyevents.fig
%
% Author : 
% Andr Mouraux
% Institute of Neurosciences (IONS)
% Universit catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 5
% See http://nocions.webnode.com/letswave for additional information
%




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_copyevents_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_copyevents_OutputFcn, ...
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




% --- Executes just before GLW_copyevents is made visible.
function GLW_copyevents_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_copyevents (see VARARGIN)
% Choose default command line output for GLW_copyevents
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%fill listbox with inputfiles
set(handles.filebox,'String',varargin{2});




% --- Outputs from this function are returned to the command line.
function varargout = GLW_copyevents_OutputFcn(hObject, eventdata, handles) 
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
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in processbutton.
function processbutton_Callback(hObject, eventdata, handles)
% hObject    handle to processbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
inputfiles=get(handles.filebox,'String');
disp('*** Starting.');
disp('Loading header with events');
st=get(handles.lw5filename,'String');
disp(st);
header=LW_load_header(st);
disp([num2str(length(header.events)) ' events found.']);
events=header.events;
%loop through files
for filepos=1:length(inputfiles);
    header=LW_load(inputfiles{filepos});
    %load header
    header=CLW_load_header(inputfiles{filepos});
    %process
    disp('*** Assigning events');
    header.events=events;
    %save header
    disp(['saving ',inputfiles{filepos}]);
    LW_save(inputfiles{filepos},[],header,data);
end;
disp('*** Finished.');




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=get(handles.filebox,'String');
[p,n,e]=fileparts(inputfiles{1});
filterspec=[p,filesep,'*.lw6'];
[filename,pathname]=uigetfile(filterspec);
set(handles.lw5filename,'String',fullfile(pathname,filename));
