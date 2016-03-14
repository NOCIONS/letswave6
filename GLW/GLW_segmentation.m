function varargout = GLW_segmentation(varargin)
% GLW_SEGMENTATION MATLAB code for GLW_segmentation.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_segmentation_OutputFcn, ...
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









% --- Executes just before GLW_segmentation is made visible.
function GLW_segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_segmentation (see VARARGIN)
% Choose default command line output for GLW_segmentation
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%function('dummy',configuration,datasets);
%configuration
configuration=varargin{2};
set(handles.process_btn,'Userdata',configuration);
%datasets
datasets=varargin{3};
set(handles.prefix_edit,'Userdata',datasets);
%axis
axis off;
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%overwrite_chk Userdata stores status of ProcessBtn
set(handles.overwrite_chk,'Userdata',[]);
%ajust GUI according to configuration_mode
switch configuration.gui_info.configuration_mode
    case 'direct';
        set(handles.overwrite_chk,'Visible','on');
        set(handles.prefix_text,'Visible','on');
        set(handles.prefix_edit,'Visible','on');
        set(handles.process_btn,'String','Process');
    case 'script';
        set(handles.overwrite_chk,'Visible','off');
        set(handles.prefix_text,'Visible','off');
        set(handles.prefix_edit,'Visible','off');
        set(handles.process_btn,'String','Save');
    case 'history'
        set(handles.overwrite_chk,'Visible','off');
        set(handles.prefix_text,'Visible','off');
        set(handles.prefix_edit,'Visible','off');
        set(handles.process_btn,'Visible','off');
end;
%update prefix_edit
set(handles.prefix_edit,'String',configuration.gui_info.process_filename_string);
%update overwrite_chk
if strcmpi(configuration.gui_info.process_overwrite,'yes');
    set(handles.overwrite_chk,'Value',1);
else
    set(handles.overwrite_chk,'Value',0);
end;
%!!!!!!!!!!!!!!!!!!!!!!!!
%update GUI configuration
%!!!!!!!!!!!!!!!!!!!!!!!!
%find event_codes in datasets
%loop through datasets
st={};
k=1;
for dataset_pos=1:length(datasets);
    %loop through events
    events=datasets(dataset_pos).header.events;
    for event_pos=1:length(events);
        st{k}=events(event_pos).code;
        k=k+1;
    end;
end;
st=unique(st);
st=sort(st);
set(handles.event_code_listbox,'String',st);
%selected event_labels
b=[];
for i=1:length(configuration.parameters.event_labels);
    a=find(strcmpi(configuration.parameters.event_labels{i},st));
    b=[b a]
end;
b=unique(b);
b=sort(b);
set(handles.event_code_listbox,'Value',b);
%configuration.parameters.x_start
set(handles.x_start_edit,'String',num2str(configuration.parameters.x_start));
%configuration.parameters.x_duration
x_duration=configuration.parameters.x_duration;
set(handles.x_duration_edit,'String',num2str(x_duration));
%x_size
x_size=fix(x_duration/datasets(1).header.xstep);
set(handles.x_size_edit,'String',num2str(x_size));
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
%configuration
configuration=get(handles.process_btn,'UserData');
if isempty(get(handles.overwrite_chk,'Userdata'))
    varargout{2}=[];
else
   varargout{2}=configuration;
end;
delete(hObject);




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
%fetch configuration
configuration=get(handles.process_btn,'Userdata');
%notify that process_btn has been pressed
set(handles.overwrite_chk,'Userdata',1);
%prefix_edit
configuration.gui_info.process_filename_string=get(handles.prefix_edit,'String');
%overwrite_chk
if get(handles.overwrite_chk,'Value')==0;
    configuration.gui_info.process_overwrite='no';
else
    configuration.gui_info.process_overwrite='yes';
end;
%!!!!!!!!!!!!!!!!!!!!
%UPDATE CONFIGURATION
%!!!!!!!!!!!!!!!!!!!!
%event_labels
st=get(handles.event_code_listbox,'String');
st_idx=get(handles.event_code_listbox,'Value');
%event_labels
configuration.parameters.event_labels=st(st_idx);
%x_start
configuration.parameters.x_start=str2num(get(handles.x_start_edit,'String'));
%x_duration
configuration.parameters.x_duration=str2num(get(handles.x_duration_edit,'String'));
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);









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
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);





% --- Executes on selection change in event_code_listbox.
function event_code_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_code_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function event_code_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_code_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in select_all_btn.
function select_all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
idx=get(handles.event_code_listbox,'Value');
st=get(handles.event_code_listbox,'String');
if isempty(idx);
    a=1:1:length(st);
    set(handles.event_code_listbox,'Value',a);
else
    set(handles.event_code_listbox,'Value',[]);
end;
    





function x_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function x_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_duration_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_duration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%update x_size_edit
x_duration=str2num(get(handles.x_duration_edit,'String'));
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%x_size
x_size=fix(x_duration/datasets(1).header.xstep);
%update x__size_edit
set(handles.x_size_edit,'String',num2str(x_size));




% --- Executes during object creation, after setting all properties.
function x_duration_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_duration_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%update x_duration_edit
x_size=str2num(get(handles.x_size_edit,'String'));
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%x_duration
x_duration=(x_size)*datasets(1).header.xstep;
%update x_duration_edit
set(handles.x_duration_edit,'String',num2str(x_duration));





% --- Executes during object creation, after setting all properties.
function x_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
