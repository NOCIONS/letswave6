function varargout = GLW_properties(varargin)
% GLW_PROPERTIES MATLAB code for GLW_properties.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_properties_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_properties_OutputFcn, ...
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









% --- Executes just before GLW_properties is made visible.
function GLW_properties_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_properties (see VARARGIN)
% Choose default command line output for GLW_properties
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
set(handles.filetype_edit,'String',configuration.parameters.filetype);
set(handles.xstart_edit,'String',num2str(configuration.parameters.xstart));
set(handles.ystart_edit,'String',num2str(configuration.parameters.ystart));
set(handles.zstart_edit,'String',num2str(configuration.parameters.zstart));
set(handles.xstep_edit,'String',num2str(configuration.parameters.xstep));
set(handles.ystep_edit,'String',num2str(configuration.parameters.ystep));
set(handles.zstep_edit,'String',num2str(configuration.parameters.zstep));
set(handles.xsrate_edit,'String',num2str(1/configuration.parameters.xstep));
set(handles.ysrate_edit,'String',num2str(1/configuration.parameters.ystep));
set(handles.zsrate_edit,'String',num2str(1/configuration.parameters.zstep));
set(handles.change_filetype_chk,'Value',configuration.parameters.change_filetype);
set(handles.change_x_chk,'Value',configuration.parameters.change_x);
set(handles.change_y_chk,'Value',configuration.parameters.change_y);
set(handles.change_z_chk,'Value',configuration.parameters.change_z);
%
header=datasets(1).header;
set(handles.numepochs_text,'String',num2str(header.datasize(1)));
set(handles.numchannels_text,'String',num2str(header.datasize(2)));
set(handles.numindex_text,'String',num2str(header.datasize(3)));
set(handles.xsize_text,'String',num2str(header.datasize(6)));
set(handles.ysize_text,'String',num2str(header.datasize(5)));
set(handles.zsize_text,'String',num2str(header.datasize(4)));
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_properties_OutputFcn(hObject, eventdata, handles) 
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
configuration.parameters.filetype=get(handles.filetype_edit,'String');
configuration.parameters.xstart=str2num(get(handles.xstart_edit,'String'));
configuration.parameters.ystart=str2num(get(handles.ystart_edit,'String'));
configuration.parameters.zstart=str2num(get(handles.zstart_edit,'String'));
configuration.parameters.xstep=str2num(get(handles.xstep_edit,'String'));
configuration.parameters.ystep=str2num(get(handles.ystep_edit,'String'));
configuration.parameters.zstep=str2num(get(handles.zstep_edit,'String'));
configuration.parameters.change_filetype=get(handles.change_filetype_chk,'Value');
configuration.parameters.change_x=get(handles.change_x_chk,'Value');
configuration.parameters.change_y=get(handles.change_y_chk,'Value');
configuration.parameters.change_z=get(handles.change_z_chk,'Value');
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


% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function filetype_edit_Callback(hObject, eventdata, handles)
% hObject    handle to filetype_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function filetype_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filetype_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function xstart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function xstart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xstep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp=1/str2num(get(handles.xstep_edit,'String'));
set(handles.xsrate_edit,'String',num2str(tp));


% --- Executes during object creation, after setting all properties.
function xstep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xsrate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xsrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp=1/str2num(get(handles.xsrate_edit,'String'));
set(handles.xstep_edit,'String',num2str(tp));




% --- Executes during object creation, after setting all properties.
function xsrate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xsrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ystart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ystart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ystart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ystart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ystep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ystep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp=1/str2num(get(handles.ystep_edit,'String'));
set(handles.ysrate_edit,'String',num2str(tp));



% --- Executes during object creation, after setting all properties.
function ystep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ystep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ysrate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ysrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp=1/str2num(get(handles.ysrate_edit,'String'));
set(handles.ystep_edit,'String',num2str(tp));



% --- Executes during object creation, after setting all properties.
function ysrate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ysrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to zstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function zstart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to zstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp=1/str2num(get(handles.zstep_edit,'String'));
set(handles.zsrate_edit,'String',num2str(tp));




% --- Executes during object creation, after setting all properties.
function zstep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zsrate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to zsrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tp=1/str2num(get(handles.zsrate_edit,'String'));
set(handles.zstep_edit,'String',num2str(tp));




% --- Executes during object creation, after setting all properties.
function zsrate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zsrate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in change_x_chk.
function change_x_chk_Callback(hObject, eventdata, handles)
% hObject    handle to change_x_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in change_y_chk.
function change_y_chk_Callback(hObject, eventdata, handles)
% hObject    handle to change_y_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in change_z_chk.
function change_z_chk_Callback(hObject, eventdata, handles)
% hObject    handle to change_z_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in change_filetype_chk.
function change_filetype_chk_Callback(hObject, eventdata, handles)
% hObject    handle to change_filetype_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
