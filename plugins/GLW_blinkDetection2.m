function varargout = GLW_blinkDetection2(varargin)
% GLW_BLINKDETECTION2 M-file for GLW_blinkDetection2.fig
%      GLW_BLINKDETECTION2, by itself, creates a new GLW_BLINKDETECTION2 or raises the existing
%      singleton*.
%
%      H = GLW_BLINKDETECTION2 returns the handle to a new GLW_BLINKDETECTION2 or the handle to
%      the existing singleton*.
%
%      GLW_BLINKDETECTION2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_BLINKDETECTION2.M with the given input arguments.
%
%      GLW_BLINKDETECTION2('Property','Value',...) creates a new GLW_BLINKDETECTION2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_blinkDetection2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_blinkDetection2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_blinkDetection2

% Last Modified by GUIDE v2.5 28-Oct-2015 10:51:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_blinkDetection2_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_blinkDetection2_OutputFcn, ...
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






% --- Executes just before GLW_blinkDetection2 is made visible.
function GLW_blinkDetection2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_blinkDetection2 (see VARARGIN)
% Choose default command line output for GLW_blinkDetection2
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% Fill listbox with inputfiles
set(handles.filebox,'String',varargin{2});
%get channel info and populate popup list
%load header
inputfiles=get(handles.filebox,'String');
header=LW_load_header(inputfiles{1});
set(handles.popupmenu_channel,'string',{header.chanlocs(:).labels});
% UIWAIT makes GLW_blinkDetection2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);




% --- Outputs from this function are returned to the command line.
function varargout = GLW_blinkDetection2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


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





% --- Executes on selection change in popupmenu_method.
function popupmenu_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns popupmenu_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_method






% --- Executes during object creation, after setting all properties.
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_window_Callback(hObject, eventdata, handles)
% hObject    handle to edit_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_window as text
%        str2double(get(hObject,'String')) returns contents of edit_window as a double


% --- Executes during object creation, after setting all properties.
function edit_window_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_window (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold as a double


% --- Executes during object creation, after setting all properties.
function edit_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_channel.
function popupmenu_channel_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_channel contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_channel


% --- Executes during object creation, after setting all properties.
function popupmenu_channel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_process.
function pushbutton_process_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputfiles=get(handles.filebox,'String');

%locutoff1,locutoff2,hicutoff1,hicutoff2,bandpass,bandstop
blinkThreshold=str2num(get(handles.edit_threshold,'String'));

%get channel info and populate popup list
%load header
ChannelNb = get(handles.popupmenu_channel,'Value');

% blink polarity
PolAll=get(handles.popupmenu_polarity,'String');
PolNr = get(handles.popupmenu_polarity,'Value');
Polarity = PolAll{PolNr};

disp('*** Starting.');

c=clock;
fileName = sprintf('BlinkDetection_%i-%02d-%02d_%02dh%02dm%02ds.txt',c(1),c(3),c(2),c(4),c(5),round(c(6)));
fid = fopen(fileName,'wt');
fprintf(fid,'Nbr of blinks for each epoch\n');
fprintf(fid,'Nbr of blinks per second for each epoch\n');
%loop through files
for filepos=1:length(inputfiles);
    [p,n,e]=fileparts(inputfiles{filepos});
    %load header
    disp(['loading ',inputfiles{filepos}]);
    [header,data]=LW_load(inputfiles{filepos});
    AllChannels = {header.chanlocs(:).labels};
    channelName = AllChannels{ChannelNb};    
    [header,data,NbBlinks,blinkPerSec]=LW_blinkDetection2(header,data,blinkThreshold,ChannelNb,Polarity);    
    
    %print results to file
    fprintf(fid,'%s\t',n);
    for bb=1:length(NbBlinks);        
        fprintf(fid,'%f\t',NbBlinks(bb));
    end
    fprintf(fid,'\n'); 
    
    fprintf(fid,'%s\t',n);    
    for bb=1:length(blinkPerSec);        
        fprintf(fid,'%f\t',blinkPerSec(bb));
    end
    fprintf(fid,'\n'); 
      
    %save header
    LW_save(inputfiles{filepos},get(handles.edit_prefix,'String'),header,data);
end;
fclose(fid);

disp('*** Finished.');




function edit_prefix_Callback(hObject, eventdata, handles)
% hObject    handle to edit_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_prefix as text
%        str2double(get(hObject,'String')) returns contents of edit_prefix as a double


% --- Executes during object creation, after setting all properties.
function edit_prefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_prefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_polarity.
function popupmenu_polarity_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_polarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu_polarity contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_polarity


% --- Executes during object creation, after setting all properties.
function popupmenu_polarity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_polarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
