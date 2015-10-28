function varargout = GLW_fastwavelet_multiCF(varargin)
% GLW_FASTWAVELET_MULTICF M-file for GLW_fastwavelet_multiCF.fig
%      GLW_FASTWAVELET_MULTICF, by itself, creates a new GLW_FASTWAVELET_MULTICF or raises the existing
%      singleton*.
%
%      H = GLW_FASTWAVELET_MULTICF returns the handle to a new GLW_FASTWAVELET_MULTICF or the handle to
%      the existing singleton*.
%
%      GLW_FASTWAVELET_MULTICF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_FASTWAVELET_MULTICF.M with the given input arguments.
%
%      GLW_FASTWAVELET_MULTICF('Property','Value',...) creates a new GLW_FASTWAVELET_MULTICF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_fastwavelet_multiCF_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_fastwavelet_multiCF_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_fastwavelet_multiCF

% Last Modified by GUIDE v2.5 28-Oct-2015 13:20:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_fastwavelet_multiCF_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_fastwavelet_multiCF_OutputFcn, ...
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


% --- Executes just before GLW_fastwavelet_multiCF is made visible.
function GLW_fastwavelet_multiCF_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_fastwavelet_multiCF (see VARARGIN)

% Choose default command line output for GLW_fastwavelet_multiCF
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles=varargin{2};
set(handles.filebox,'String',inputfiles);

% UIWAIT makes GLW_fastwavelet_multiCF wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_fastwavelet_multiCF_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in processbutton.
function processbutton_Callback(hObject, eventdata, handles)
% hObject    handle to processbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get filenames of files to process
inputfiles=get(handles.filebox,'String');

%build central frequency vector
minFreq = str2double(get(handles.lofreqedit,'string'));
maxFreq = str2double(get(handles.hifreqedit,'string'));
NbLines = str2double(get(handles.numlinesedit,'string'));
freqVect = linspace(minFreq,maxFreq,NbLines);

CF_minmax = eval(sprintf('[%s]',get(handles.motherfreqedit,'String')));
InvLogSteepness = str2double(get(handles.CentralFreqLinearEdit,'string')); %[0 1000] - steepness of log function - the larger the number the more linear.
centFreq = stretch(log10(InvLogSteepness:length(freqVect)+(InvLogSteepness-1)),[min(CF_minmax) max(CF_minmax)]);

%mother parameters
mothertype={'morlet' 'hanning'};
type=mothertype{get(handles.motherpopup,'Value')};
sigmaW = str2double(get(handles.motherspreadedit,'string'));
mothersize=round(str2num(get(handles.mothersizeedit,'String')));

%postprocess
DownSamp = max(str2double(get(handles.envDownsampleEdit,'string')),1);
postprocesslist={'amplitude' 'power' 'phase' 'real' 'imag'};
postprocess=postprocesslist{get(handles.postprocesspopup,'Value')};

%baseline
baselinelist= {'none','subtract','divide','erpercent','zscore'};
baseline=baselinelist{get(handles.baselinepopup,'Value')};
if strcmpi(baseline,'none');
    baseline_start=0;
    baseline_end=0;
else
    baseline_start=str2num(get(handles.bl1edit,'String'));
    baseline_end=str2num(get(handles.bl2edit,'String'));
end;

%output
if get(handles.averagechk,'Value')==1;
    output='average';
else
    output='single';
end;

for filepos=1:length(inputfiles);
    
[header,data] = LW_load(inputfiles{filepos});

disp('*** Fast CWT');
[header,data] = LW_fastwavelet_multiCF(header,data,freqVect,type,centFreq,sigmaW,mothersize,DownSamp,postprocess,baseline,baseline_start,baseline_end,output);

LW_save(inputfiles{filepos},get(handles.prefixtext,'String'),header,data);

end
disp('*** Finished.');

% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filebox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filebox


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



function prefixtext_Callback(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixtext as text
%        str2double(get(hObject,'String')) returns contents of prefixtext as a double


% --- Executes during object creation, after setting all properties.
function prefixtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bl1edit_Callback(hObject, eventdata, handles)
% hObject    handle to bl1edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bl1edit as text
%        str2double(get(hObject,'String')) returns contents of bl1edit as a double


% --- Executes during object creation, after setting all properties.
function bl1edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bl1edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bl2edit_Callback(hObject, eventdata, handles)
% hObject    handle to bl2edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bl2edit as text
%        str2double(get(hObject,'String')) returns contents of bl2edit as a double


% --- Executes during object creation, after setting all properties.
function bl2edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bl2edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in averagechk.
function averagechk_Callback(hObject, eventdata, handles)
% hObject    handle to averagechk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of averagechk


% --- Executes on selection change in baselinepopup.
function baselinepopup_Callback(hObject, eventdata, handles)
% hObject    handle to baselinepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns baselinepopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from baselinepopup


% --- Executes during object creation, after setting all properties.
function baselinepopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baselinepopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in postprocesspopup.
function postprocesspopup_Callback(hObject, eventdata, handles)
% hObject    handle to postprocesspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns postprocesspopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from postprocesspopup


% --- Executes during object creation, after setting all properties.
function postprocesspopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to postprocesspopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function envDownsampleEdit_Callback(hObject, eventdata, handles)
% hObject    handle to envDownsampleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of envDownsampleEdit as text
%        str2double(get(hObject,'String')) returns contents of envDownsampleEdit as a double


% --- Executes during object creation, after setting all properties.
function envDownsampleEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to envDownsampleEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function numlinesedit_Callback(hObject, eventdata, handles)
% hObject    handle to numlinesedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numlinesedit as text
%        str2double(get(hObject,'String')) returns contents of numlinesedit as a double


% --- Executes during object creation, after setting all properties.
function numlinesedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numlinesedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hifreqedit_Callback(hObject, eventdata, handles)
% hObject    handle to hifreqedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hifreqedit as text
%        str2double(get(hObject,'String')) returns contents of hifreqedit as a double


% --- Executes during object creation, after setting all properties.
function hifreqedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hifreqedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function lofreqedit_Callback(hObject, eventdata, handles)
% hObject    handle to lofreqedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lofreqedit as text
%        str2double(get(hObject,'String')) returns contents of lofreqedit as a double


% --- Executes during object creation, after setting all properties.
function lofreqedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lofreqedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CentralFreqLinearEdit_Callback(hObject, eventdata, handles)
% hObject    handle to CentralFreqLinearEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CentralFreqLinearEdit as text
%        str2double(get(hObject,'String')) returns contents of CentralFreqLinearEdit as a double


% --- Executes during object creation, after setting all properties.
function CentralFreqLinearEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CentralFreqLinearEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DisplaycentralFreq.
function DisplaycentralFreq_Callback(hObject, eventdata, handles)
% hObject    handle to DisplaycentralFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

minFreq = str2double(get(handles.lofreqedit,'string'));
maxFreq = str2double(get(handles.hifreqedit,'string'));
NbLines = str2double(get(handles.numlinesedit,'string'));
freqVect = linspace(minFreq,maxFreq,NbLines);

CF_minmax = eval(sprintf('[%s]',get(handles.motherfreqedit,'String')));
InvLogSteepness = str2double(get(handles.CentralFreqLinearEdit,'string')); %[0 1000] - steepness of log function - the larger the number the more linear.
centFreq = stretch(log10(InvLogSteepness:length(freqVect)+(InvLogSteepness-1)),[min(CF_minmax) max(CF_minmax)]);

disp('    Line   Frequency   Wavelet Frequency');
disp([[1:NbLines]' freqVect' centFreq']);

figure('color',[1 1 1]);
plot(freqVect,centFreq);
xlabel('Frequency (hz)');
ylabel('Number of cycles / central frequency (Hz)');


function motherfreqedit_Callback(hObject, eventdata, handles)
% hObject    handle to motherfreqedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motherfreqedit as text
%        str2double(get(hObject,'String')) returns contents of motherfreqedit as a double


% --- Executes during object creation, after setting all properties.
function motherfreqedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motherfreqedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function motherspreadedit_Callback(hObject, eventdata, handles)
% hObject    handle to motherspreadedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of motherspreadedit as text
%        str2double(get(hObject,'String')) returns contents of motherspreadedit as a double


% --- Executes during object creation, after setting all properties.
function motherspreadedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motherspreadedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mothersizeedit_Callback(hObject, eventdata, handles)
% hObject    handle to mothersizeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mothersizeedit as text
%        str2double(get(hObject,'String')) returns contents of mothersizeedit as a double


% --- Executes during object creation, after setting all properties.
function mothersizeedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mothersizeedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in motherpopup.
function motherpopup_Callback(hObject, eventdata, handles)
% hObject    handle to motherpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns motherpopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from motherpopup


% --- Executes during object creation, after setting all properties.
function motherpopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to motherpopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
