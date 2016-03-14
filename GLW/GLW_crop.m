function varargout = GLW_crop(varargin)
% GLW_CROP MATLAB code for GLW_crop.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_crop_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_crop_OutputFcn, ...
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









% --- Executes just before GLW_crop is made visible.
function GLW_crop_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_crop (see VARARGIN)
% Choose default command line output for GLW_crop
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
%store header in x_panel Userdata
header=datasets(1).header;
set(handles.x_panel,'Userdata',header);
%start,end
set(handles.x_start_edit,'String',num2str(configuration.parameters.x_start));
set(handles.x_size_edit,'String',num2str(configuration.parameters.x_size));
set(handles.y_start_edit,'String',num2str(configuration.parameters.y_start));
set(handles.y_size_edit,'String',num2str(configuration.parameters.y_size));
set(handles.z_start_edit,'String',num2str(configuration.parameters.z_start));
set(handles.z_size_edit,'String',num2str(configuration.parameters.z_size));
set(handles.x_crop_chk,'Value',configuration.parameters.x_crop);
set(handles.y_crop_chk,'Value',configuration.parameters.y_crop);
set(handles.z_crop_chk,'Value',configuration.parameters.z_crop);
%size
size2end_x(handles);
if configuration.parameters.y_crop==1;
    size2end_y(handles);
end;
if configuration.parameters.z_crop==1;
    size2end_z(handles);
end;
%update panels : disable/enable
update_panels(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);





function update_panels(handles);
%X-dimension
if get(handles.x_crop_chk,'Value')==1;
    set(handles.x_start_edit,'Enable','on');
    set(handles.x_end_edit,'Enable','on');
    set(handles.x_size_edit,'Enable','on');
else
    set(handles.x_start_edit,'Enable','off');
    set(handles.x_end_edit,'Enable','off');
    set(handles.x_size_edit,'Enable','off');
end;
%Y-dimension
if get(handles.y_crop_chk,'Value')==1;
    set(handles.y_start_edit,'Enable','on');
    set(handles.y_end_edit,'Enable','on');
    set(handles.y_size_edit,'Enable','on');
else
    set(handles.y_start_edit,'Enable','off');
    set(handles.y_end_edit,'Enable','off');
    set(handles.y_size_edit,'Enable','off');
end;
%Z-dimension
if get(handles.z_crop_chk,'Value')==1;
    set(handles.z_start_edit,'Enable','on');
    set(handles.z_end_edit,'Enable','on');
    set(handles.z_size_edit,'Enable','on');
else
    set(handles.z_start_edit,'Enable','off');
    set(handles.z_end_edit,'Enable','off');
    set(handles.z_size_edit,'Enable','off');
end;




function end2size_x(handles);
%header
header=get(handles.x_panel,'Userdata');
%x_end
x_end=str2num(get(handles.x_end_edit,'String'));
%x_start
x_start=str2num(get(handles.x_start_edit,'String'));
%x_size
x_size=round((x_end-x_start)/header.xstep)+1;
%update
set(handles.x_size_edit,'String',num2str(x_size));

function end2size_y(handles);
%header
header=get(handles.x_panel,'Userdata');
%x_end
y_end=str2num(get(handles.y_end_edit,'String'));
%x_start
y_start=str2num(get(handles.y_start_edit,'String'));
%x_size
y_size=round((y_end-y_start)/header.ystep)+1;
%update
set(handles.y_size_edit,'String',num2str(y_size));

function end2size_z(handles);
%header
header=get(handles.x_panel,'Userdata');
%x_end
z_end=str2num(get(handles.z_end_edit,'String'));
%x_start
z_start=str2num(get(handles.z_start_edit,'String'));
%x_size
z_size=round((z_end-z_start)/header.zstep)+1;
%update
set(handles.z_size_edit,'String',num2str(z_size));



function size2end_x(handles);
%header
header=get(handles.x_panel,'Userdata');
%x_size
x_size=str2num(get(handles.x_size_edit,'String'));
%x_start
x_start=str2num(get(handles.x_start_edit,'String'));
%x_end
x_end=x_start+((x_size-1)*header.xstep);
%update
set(handles.x_end_edit,'String',num2str(x_end));


function size2end_y(handles);
%header
header=get(handles.x_panel,'Userdata');
%x_size
y_size=str2num(get(handles.y_size_edit,'String'));
%x_start
y_start=str2num(get(handles.y_start_edit,'String'));
%x_end
y_end=x_start+((y_size-1)*header.ystep);
%update
set(handles.y_end_edit,'String',num2str(y_end));

function size2end_z(handles);
%header
header=get(handles.x_panel,'Userdata');
%x_size
z_size=str2num(get(handles.z_size_edit,'String'));
%x_start
z_start=str2num(get(handles.z_start_edit,'String'));
%x_end
z_end=x_start+((z_size-1)*header.zstep);
%update
set(handles.z_end_edit,'String',num2str(z_end));






% --- Outputs from this function are returned to the command line.
function varargout = GLW_crop_OutputFcn(hObject, eventdata, handles) 
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
configuration.parameters.x_crop=get(handles.x_crop_chk,'Value');
configuration.parameters.y_crop=get(handles.y_crop_chk,'Value');
configuration.parameters.z_crop=get(handles.z_crop_chk,'Value');
configuration.parameters.x_start=str2num(get(handles.x_start_edit,'String'));
configuration.parameters.y_start=str2num(get(handles.y_start_edit,'String'));
configuration.parameters.z_start=str2num(get(handles.z_start_edit,'String'));
configuration.parameters.x_size=str2num(get(handles.x_size_edit,'String'));
configuration.parameters.y_size=str2num(get(handles.y_size_edit,'String'));
configuration.parameters.z_size=str2num(get(handles.z_size_edit,'String'));
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






function x_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end2size_x(handles);


% --- Executes during object creation, after setting all properties.
function x_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end2size_x(handles);


% --- Executes during object creation, after setting all properties.
function x_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size2end_x(handles);



% --- Executes during object creation, after setting all properties.
function x_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end2size_x(handles);




% --- Executes during object creation, after setting all properties.
function y_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end2size_y(handles);



% --- Executes during object creation, after setting all properties.
function y_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size2end_y(handles);



% --- Executes during object creation, after setting all properties.
function y_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end2size_x(handles);





% --- Executes during object creation, after setting all properties.
function z_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end2size_z(handles);




% --- Executes during object creation, after setting all properties.
function z_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
size2end_z(handles);




% --- Executes during object creation, after setting all properties.
function z_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in x_crop_chk.
function x_crop_chk_Callback(hObject, eventdata, handles)
% hObject    handle to x_crop_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in y_crop_chk.
function y_crop_chk_Callback(hObject, eventdata, handles)
% hObject    handle to y_crop_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in z_crop_chk.
function z_crop_chk_Callback(hObject, eventdata, handles)
% hObject    handle to z_crop_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
