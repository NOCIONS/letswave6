function varargout = GLW_ICA_compute(varargin)
% GLW_ICA_COMPUTE MATLAB code for GLW_ICA_compute.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_ICA_compute_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_ICA_compute_OutputFcn, ...
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









% --- Executes just before GLW_ICA_compute is made visible.
function GLW_ICA_compute_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_ICA_compute (see VARARGIN)
% Choose default command line output for GLW_ICA_compute
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
%ICA_algorithm
st={'runica' 'jader'};
set(handles.ICA_algorithm_popup,'Userdata',st);
a=find(strcmpi(configuration.parameters.ICA_algorithm,st)==1);
if isempty(a);
else
    set(handles.ICA_algorithm_popup,'Value',a);
end;
%ICA_mode
st={'square' 'fixed' 'LAP' 'BIC' 'RRN' 'AIC' 'MDL'};
set(handles.ICA_mode_popup,'Userdata',st);
a=find(strcmpi(configuration.parameters.ICA_mode,st)==1);
if isempty(a);
else
    set(handles.ICA_mode_popup,'Value',a);
end;
%num_ICs_edit
set(handles.num_ICs_edit,'String',num2str(configuration.parameters.num_ICs));
%PICA_percentage_edit
set(handles.PICA_percentage_edit,'String',num2str(configuration.parameters.PICA_percentage));
%update_edit_boxes
update_edit_boxes(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_ICA_compute_OutputFcn(hObject, eventdata, handles) 
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
%ICA_algorithm_popup
st=get(handles.ICA_algorithm_popup,'Userdata');
configuration.parameters.ICA_algorithm=st{get(handles.ICA_algorithm_popup,'Value')};
%ICA_mode_popup
st=get(handles.ICA_mode_popup,'Userdata');
configuration.parameters.ICA_mode=st{get(handles.ICA_mode_popup,'Value')};
%num_ICs_edit
configuration.parameters.num_ICs=str2num(get(handles.num_ICs_edit,'String'));
%PICA_percentage_edit
configuration.parameters.PICA_percentage=str2num(get(handles.PICA_percentage_edit,'String'));
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);






function update_edit_boxes(handles)
idx=get(handles.ICA_mode_popup,'Value');
st=get(handles.ICA_mode_popup,'Userdata');
ica_mode=st{idx};
switch ica_mode
    case 'square'
        set(handles.num_ICs_edit,'Visible','off');
        set(handles.PICA_percentage_edit,'Visible','off');
        set(handles.num_ICs_text,'Visible','off');
        set(handles.PICA_percentage_text,'Visible','off');
    case 'fixed'
        set(handles.num_ICs_edit,'Visible','on');
        set(handles.PICA_percentage_edit,'Visible','off');
        set(handles.num_ICs_text,'Visible','on');
        set(handles.PICA_percentage_text,'Visible','off');
    otherwise
        set(handles.num_ICs_edit,'Visible','off');
        set(handles.PICA_percentage_edit,'Visible','on');
        set(handles.num_ICs_text,'Visible','off');
        set(handles.PICA_percentage_text,'Visible','on');
end;




% --- Executes on selection change in ICA_algorithm_popup.
function ICA_algorithm_popup_Callback(hObject, eventdata, handles)
% hObject    handle to ICA_algorithm_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function ICA_algorithm_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ICA_algorithm_popup (see GCBO)
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
    set(handleS.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);



function num_ICs_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_ICs_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function num_ICs_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_ICs_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function PICA_percentage_edit_Callback(hObject, eventdata, handles)
% hObject    handle to PICA_percentage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function PICA_percentage_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PICA_percentage_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in ICA_mode_popup.
function ICA_mode_popup_Callback(hObject, eventdata, handles)
% hObject    handle to ICA_mode_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edit_boxes(handles);




% --- Executes during object creation, after setting all properties.
function ICA_mode_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ICA_mode_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
