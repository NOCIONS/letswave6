function varargout = GLW_splitfiles(varargin)
% GLW_SPLITFILES MATLAB code for GLW_splitfiles.fig
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
                   'gui_OpeningFcn', @GLW_splitfiles_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_splitfiles_OutputFcn, ...
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




% --- Executes just before GLW_splitfiles is made visible.
function GLW_splitfiles_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_splitfiles (see VARARGIN)
% Choose default command line output for GLW_splitfiles
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%fill listbox with inputfiles
set(handles.filebox,'String',varargin{2});




% --- Outputs from this function are returned to the command line.
function varargout = GLW_splitfiles_OutputFcn(hObject, eventdata, handles) 
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
numsplit=str2num(get(handles.numsplit_edit,'String'));
%loop through files
for filepos=1:length(inputfiles);
    [origheader,origdata]=CLW_load(inputfiles{filepos});
    %process
    disp('*** Splitting files');
    %number of epochs
    numepochs=origheader.datasize(1);
    disp(['Number of epochs : ' num2str(numepochs)]);
    for splitpos=1:numsplit;
        di1=floor(((splitpos-1)*(1/numsplit))*numepochs)+1;
        di2=floor(((splitpos)*(1/numsplit))*numepochs);
        disp(['Split ' num2str(splitpos) ' : ' num2str(di1) ' - ' num2str(di2)]);
        [header,data]=RLW_arrange_epochs(origheader,origdata,di1:di2);
        %save
        [p,n,e]=fileparts(inputfiles{filepos});
        st=['split',num2str(splitpos)];
        LW_save(inputfiles{filepos},st,header,data);
    end;
end;
disp('*** Finished.');




% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=get(handles.filebox,'String');
[p,n,e]=fileparts(inputfiles{1});
filterspec=[p,filesep,'*.lw5'];
[filename,pathname]=uigetfile(filterspec);
set(handles.lw5filename,'String',fullfile(pathname,filename));



function numsplit_edit_Callback(hObject, eventdata, handles)
% hObject    handle to numsplit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numsplit_edit as text
%        str2double(get(hObject,'String')) returns contents of numsplit_edit as a double


% --- Executes during object creation, after setting all properties.
function numsplit_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numsplit_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
