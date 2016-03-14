function varargout = GLW_butterworth_filter(varargin)
% GLW_BUTTERWORTH_FILTER MATLAB code for GLW_butterworth_filter.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_butterworth_filter_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_butterworth_filter_OutputFcn, ...
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









% --- Executes just before GLW_butterworth_filter is made visible.
function GLW_butterworth_filter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_butterworth_filter (see VARARGIN)
% Choose default command line output for GLW_butterworth_filter
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
%operation
st={'bandpass' 'lowpass' 'highpass' 'notch'};
set(handles.filter_type_popup,'Userdata',st);
a=find(strcmpi(configuration.parameters.filter_type,st)==1);
if isempty(a);
else
    set(handles.filter_type_popup,'Value',a);
end;
%low_cutoff_edit
set(handles.low_cutoff_edit,'String',num2str(configuration.parameters.low_cutoff));
%high_cutoff_edit
set(handles.high_cutoff_edit,'String',num2str(configuration.parameters.high_cutoff));
%filter_order_edit
set(handles.filter_order_edit,'String',num2str(configuration.parameters.filter_order));
%update_edit_boxes
update_edit_boxes(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_butterworth_filter_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1}=handles.output;
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
%filter_type_popup
st=get(handles.filter_type_popup,'Userdata');
configuration.parameters.filter_type=st{get(handles.filter_type_popup,'Value')};
%low_cutoff
configuration.parameters.low_cutoff=str2num(get(handles.low_cutoff_edit,'String'));
%high_cutoff
configuration.parameters.high_cutoff=str2num(get(handles.high_cutoff_edit,'String'));
%filter_order
configuration.parameters.filter_order=str2num(get(handles.filter_order_edit,'String'));
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);






function update_edit_boxes(handles)
filter_idx=get(handles.filter_type_popup,'Value');
filter_types=get(handles.filter_type_popup,'Userdata');
filter_type=filter_types{filter_idx};
switch filter_type
    case 'bandpass'
        set(handles.low_cutoff_edit,'Visible','on');
        set(handles.low_cutoff_text,'Visible','on');
        set(handles.high_cutoff_edit,'Visible','on');
        set(handles.high_cutoff_text,'Visible','on');
    case 'lowpass'
        set(handles.low_cutoff_edit,'Visible','off');
        set(handles.low_cutoff_text,'Visible','off');
        set(handles.high_cutoff_edit,'Visible','on');
        set(handles.high_cutoff_text,'Visible','on');
    case 'highpass'
        set(handles.low_cutoff_edit,'Visible','on');
        set(handles.low_cutoff_text,'Visible','on');
        set(handles.high_cutoff_edit,'Visible','off');
        set(handles.high_cutoff_text,'Visible','off');
    case 'notch'
        set(handles.low_cutoff_edit,'Visible','on');
        set(handles.low_cutoff_text,'Visible','on');
        set(handles.high_cutoff_edit,'Visible','on');
        set(handles.high_cutoff_text,'Visible','on');
end;




% --- Executes on selection change in filter_type_popup.
function filter_type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to filter_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edit_boxes(handles);





% --- Executes during object creation, after setting all properties.
function filter_type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





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



function low_cutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to low_cutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function low_cutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_cutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function low_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to low_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function low_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function high_cutoff_edit_Callback(hObject, eventdata, handles)
% hObject    handle to high_cutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function high_cutoff_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_cutoff_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function high_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to high_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function high_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_order_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filter_order_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_order_edit as text
%        str2double(get(hObject,'String')) returns contents of filter_order_edit as a double


% --- Executes during object creation, after setting all properties.
function filter_order_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_order_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
