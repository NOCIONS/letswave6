function varargout = GLW_chunkepochs_ssvep(varargin)
% GLW_CHUNKEPOCHS_SSVEP MATLAB code for GLW_chunkepochs_ssvep.fig




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_chunkepochs_ssvep_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_chunkepochs_ssvep_OutputFcn, ...
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





% --- Executes just before GLW_chunkepochs_ssvep is made visible.
function GLW_chunkepochs_ssvep_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_chunkepochs_ssvep (see VARARGIN)
% Choose default command line output for GLW_chunkepochs_ssvep
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%fill listbox with inputfiles
set(handles.filebox,'String',varargin{2});
%inputfiles
inputfiles=get(handles.filebox,'String');
%load header of first file
%Lets' not do that and set default start of chunking to zero.
% header=LW_load_header(inputfiles{1});
%set offsetedit
% set(handles.offsetedit,'String',num2str(header.xstart));






% --- Outputs from this function are returned to the command line.
function varargout = GLW_chunkepochs_ssvep_OutputFcn(hObject, eventdata, handles) 
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
inputfiles=get(handles.filebox,'String');
disp('*** Starting.');

%set parameters
baseRate = str2num(get(handles.BaseFrequencyedit,'String'));
cycleDuration = 1/baseRate;
NbCycles = str2num(get(handles.NbCyclesPerChunkedit,'String'));
epochlength = NbCycles * cycleDuration;
epochstep = cycleDuration * str2num(get(handles.epochstepedit,'String'));
offset = cycleDuration * str2num(get(handles.offsetedit,'String'));
% apply correction for missing first photodiode event?
if get(handles.applyCorrectioncheckbox,'Value')
   offset =  offset - cycleDuration;
end

NbChunks2Remove = str2num(get(handles.NbChunkRemoveedit,'String'));
baselineOffset = str2num(get(handles.baselineDurationedit,'String')) * cycleDuration;

if get(handles.numchunkschk,'Value')==1;
    numchunks='max';
else
    numchunks=str2num(get(handles.numchunksedit,'String'));
end;
%loop through files
for filepos=1:length(inputfiles);
    [header,data]=LW_load(inputfiles{filepos});
    %process
    disp('*** Chunking epochs');
    [header,data]=LW_chunkepochs_ssvep(header,data,offset,epochlength,epochstep,numchunks,NbChunks2Remove,baselineOffset);
    LW_save(inputfiles{filepos},get(handles.prefixtext,'String'),header,data);
end;
disp('*** Finished.');




function offsetedit_Callback(hObject, eventdata, handles)
% hObject    handle to offsetedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function offsetedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to offsetedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function BaseFrequencyedit_Callback(hObject, eventdata, handles)
% hObject    handle to BaseFrequencyedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function BaseFrequencyedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BaseFrequencyedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function epochstepedit_Callback(hObject, eventdata, handles)
% hObject    handle to epochstepedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function epochstepedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochstepedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function numchunksedit_Callback(hObject, eventdata, handles)
% hObject    handle to numchunksedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function numchunksedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numchunksedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in numchunkschk.
function numchunkschk_Callback(hObject, eventdata, handles)
% hObject    handle to numchunkschk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.numchunkschk,'Value')==1;
    set(handles.numchunksedit,'Enable','off');
else
    set(handles.numchunksedit,'Enable','on');
end;



function NbCyclesPerChunkedit_Callback(hObject, eventdata, handles)
% hObject    handle to NbCyclesPerChunkedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbCyclesPerChunkedit as text
%        str2double(get(hObject,'String')) returns contents of NbCyclesPerChunkedit as a double


% --- Executes during object creation, after setting all properties.
function NbCyclesPerChunkedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbCyclesPerChunkedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NbChunkRemoveedit_Callback(hObject, eventdata, handles)
% hObject    handle to NbChunkRemoveedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NbChunkRemoveedit as text
%        str2double(get(hObject,'String')) returns contents of NbChunkRemoveedit as a double


% --- Executes during object creation, after setting all properties.
function NbChunkRemoveedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NbChunkRemoveedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in applyCorrectioncheckbox.
function applyCorrectioncheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to applyCorrectioncheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of applyCorrectioncheckbox



function baselineDurationedit_Callback(hObject, eventdata, handles)
% hObject    handle to baselineDurationedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baselineDurationedit as text
%        str2double(get(hObject,'String')) returns contents of baselineDurationedit as a double


% --- Executes during object creation, after setting all properties.
function baselineDurationedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselineDurationedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


