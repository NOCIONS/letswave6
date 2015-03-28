function varargout = GLW_import_MAT_variable(varargin)
% GLW_IMPORT_MAT_VARIABLE MATLAB code for GLW_import_MAT_variable.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_import_MAT_variable_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_import_MAT_variable_OutputFcn, ...
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









% --- Executes just before GLW_import_MAT_variable is made visible.
function GLW_import_MAT_variable_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_import_MAT_variable (see VARARGIN)
% Choose default command line output for GLW_import_MAT_variable
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
%refresh workspace variables
refresh_workspace_variables(handles);
%configuration.parameters.dimension_descriptors={'epochs','channels','Y','X'};
st=get(handles.dim1_popup,'String');
if isempty(configuration.parameters.dimension_descriptors);
else
    %dim1
    a=find(strcmpi(st,configuration.parameters.dimension_descriptors{1})==1);
    if isempty(a);
    else
        set(handles.dim1_popup,'Value',a(1));
    end;
    %dim2?
    if length(configuration.parameters.dimension_descriptors)>1;
        a=find(strcmpi(st,configuration.parameters.dimension_descriptors{2})==1);
        if isempty(a);
        else
            set(handles.dim2_popup,'Value',a(1));
        end;
    end;
    %dim3?
    if length(configuration.parameters.dimension_descriptors)>2;
        a=find(strcmpi(st,configuration.parameters.dimension_descriptors{3})==1);
        if isempty(a);
        else
            set(handles.dim3_popup,'Value',a(1));
        end;
    end;
    %dim4?
    if length(configuration.parameters.dimension_descriptors)>3;
        a=find(strcmpi(st,configuration.parameters.dimension_descriptors{4})==1);
        if isempty(a);
        else
            set(handles.dim4_popup,'Value',a(1));
        end;
    end;
end;
%configuration.parameters.xstart=0;
%configuration.parameters.ystart=0;
set(handles.xstart_edit,'String',num2str(configuration.parameters.xstart));
set(handles.ystart_edit,'String',num2str(configuration.parameters.ystart));
%configuration.parameters.xstep=1;
%configuration.parameters.ystep=1;
set(handles.xstep_edit,'String',num2str(configuration.parameters.xstep));
set(handles.ystep_edit,'String',num2str(configuration.parameters.ystep));
%configuration.parameters.unit
st=get(handles.unit_popup,'String');
a=find(strcmpi(configuration.parameters.unit,st));
if isempty(a);
else
    set(handles.unit_popup,'Value',a(1));
end;
%configuration.parameters.x_unit / y_unit
st=get(handles.x_unit_popup,'String');
a=find(strcmpi(configuration.parameters.x_unit,st));
if isempty(a);
else
    set(handles.x_unit_popup,'Value',a(1));
end;
a=find(strcmpi(configuration.parameters.y_unit,st));
if isempty(a);
else
    set(handles.y_unit_popup,'Value',a(1));
end;
%update
update_dims(handles);
update_edits(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);








% --- Outputs from this function are returned to the command line.
function varargout = GLW_import_MAT_variable_OutputFcn(hObject, eventdata, handles) 
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
%configuration.parameters.variable_names={};
st=get(handles.varbox,'String');
st=st(get(handles.varbox,'Value'));
configuration.parameters.variable_names=st;
configuration.parameters.dimension_descriptors={};
%configuration.parameters.dimension_descriptors={'epochs','channels','Y','X'};
st=get(handles.dim1_popup,'String');
configuration.parameters.dimension_descriptors{1}=st{get(handles.dim1_popup,'Value')};
if strcmpi(get(handles.dim2_popup,'Enable'),'on')==1;
    configuration.parameters.dimension_descriptors{2}=st{get(handles.dim2_popup,'Value')};
end;
if strcmpi(get(handles.dim3_popup,'Enable'),'on')==1;
    configuration.parameters.dimension_descriptors{3}=st{get(handles.dim3_popup,'Value')};
end;
if strcmpi(get(handles.dim4_popup,'Enable'),'on')==1;
    configuration.parameters.dimension_descriptors{4}=st{get(handles.dim4_popup,'Value')};
end;
%configuration.parameters.xstart / xstep
if strcmpi(get(handles.xstart_edit,'Enable'),'on')==1;
    st=get(handles.x_unit_popup,'String');
    configuration.parameters.x_unit=st{get(handles.x_unit_popup,'Value')};
    configuration.parameters.xstart=str2num(get(handles.xstart_edit,'String'));
    configuration.parameters.xstep=str2num(get(handles.xstep_edit,'String'));
else
    configuration.parameters.x_unit={};
    configuration.parameters.xstart=0;
    configuration.parameters.xstep=1;
end;
%configuration.parameters.ystart / ystep;
if strcmpi(get(handles.ystart_edit,'Enable'),'on')==1;
    st=get(handles.y_unit_popup,'String');
    configuration.parameters.y_unit=st{get(handles.y_unit_popup,'Value')};
    configuration.parameters.ystart=str2num(get(handles.ystart_edit,'String'));
    configuration.parameters.ystep=str2num(get(handles.ystep_edit,'String'));
else
    configuration.parameters.y_unit={};
    configuration.parameters.ystart=0;
    configuration.parameters.ystep=1;
end;
%configuration.parameters.unit
st=get(handles.unit_popup,'String');
configuration.parameters.unit=st{get(handles.unit_popup,'Value')};
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
    set(handleS.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);


% --- Executes on selection change in varbox.
function varbox_Callback(hObject, eventdata, handles)
% hObject    handle to varbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_dims(handles);
update_edits(handles);



function update_dims(handles);
var_labels=get(handles.varbox,'String');
selected_vars=get(handles.varbox,'Value');
a_dims=[];
for i=1:length(selected_vars);
    a=load_selected_workspace_var(var_labels{selected_vars(i)});
    a_dims(i)=ndims(a);
end;
a_dims=unique(a_dims);
if length(a_dims)>1;
    disp('Error! All variables must have the same number of dimensions');
    return;
end;
if isempty(a_dims);
    return;
end;
if a_dims==1;
    set(handles.dim2_text,'Enable','off');
    set(handles.dim2_popup,'Enable','off');
    set(handles.dim3_text,'Enable','off');
    set(handles.dim3_popup,'Enable','off');
    set(handles.dim4_text,'Enable','off');
    set(handles.dim4_popup,'Enable','off');
end;
if a_dims==2;
    set(handles.dim2_text,'Enable','on');
    set(handles.dim2_popup,'Enable','on');
    set(handles.dim3_text,'Enable','off');
    set(handles.dim3_popup,'Enable','off');
    set(handles.dim4_text,'Enable','off');
    set(handles.dim4_popup,'Enable','off');
end;
if a_dims==3;
    set(handles.dim2_text,'Enable','on');
    set(handles.dim2_popup,'Enable','on');
    set(handles.dim3_text,'Enable','on');
    set(handles.dim3_popup,'Enable','on');
    set(handles.dim4_text,'Enable','off');
    set(handles.dim4_popup,'Enable','off');
end;
if a_dims==4;
    set(handles.dim2_text,'Enable','on');
    set(handles.dim2_popup,'Enable','on');
    set(handles.dim3_text,'Enable','on');
    set(handles.dim3_popup,'Enable','on');
    set(handles.dim4_text,'Enable','on');
    set(handles.dim4_popup,'Enable','on');
end;
if a_dims>4;
    disp('Error! The maximum number of dimensions is 4');
end;




function update_edits(handles);
st=get(handles.dim1_popup,'String');
%dim1
a{1}=st{get(handles.dim1_popup,'Value')};
%dim2?
if strcmpi(get(handles.dim2_popup,'Enable'),'on');
    a{end+1}=st{get(handles.dim2_popup,'Value')};
end;
%dim3?
if strcmpi(get(handles.dim3_popup,'Enable'),'on');
    a{end+1}=st{get(handles.dim3_popup,'Value')};
end;
%dim4?
if strcmpi(get(handles.dim4_popup,'Enable'),'on');
    a{end+1}=st{get(handles.dim4_popup,'Value')};
end;
%X?
if find(strcmpi(a,'X')==1);
    set(handles.x_unit_popup,'Enable','on');
    set(handles.xstart_edit,'Enable','on');
    set(handles.xstep_edit,'Enable','on');
else
    set(handles.x_unit_popup,'Enable','off');
    set(handles.xstart_edit,'Enable','off');
    set(handles.xstep_edit,'Enable','off');
end;
%Y?
if find(strcmpi(a,'Y')==1);
    set(handles.y_unit_popup,'Enable','on');
    set(handles.ystart_edit,'Enable','on');
    set(handles.ystep_edit,'Enable','on');
else
    set(handles.y_unit_popup,'Enable','off');
    set(handles.ystart_edit,'Enable','off');
    set(handles.ystep_edit,'Enable','off');
end;






function a=load_selected_workspace_var(varname);
a=evalin('base',varname);




function refresh_workspace_variables(handles)
%load workspace variables
vars = evalin('base','who');
set(handles.varbox,'String',vars);
%check selection
v=get(handles.varbox,'Value');
if isempty(v);
else
    v(find(v>length(vars)))=[];
    set(handles.varbox,'Value',v);
end;




% --- Executes during object creation, after setting all properties.
function varbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to varbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_files_btn.
function select_files_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_files_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec='*.lw5;*.LW5';
st={};
[st,pathname]=uigetfile(filterspec,'select datafiles','MultiSelect','on');
if isempty(st);
else
    if iscell(st);
    else
        st2{1}=st;
        st=st2;
    end;
    for i=1:length(st);
        filename{i}=[pathname,st{i}];
    end;
end;
set(handles.varbox,'String',st);
set(handles.varbox,'Userdata',filename);







function prefix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function prefix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function xstep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function xstep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstep_edit (see GCBO)
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


% --- Executes on selection change in dim1_popup.
function dim1_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dim1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);



% --- Executes during object creation, after setting all properties.
function dim1_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dim2_popup.
function dim2_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dim2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);



% --- Executes during object creation, after setting all properties.
function dim2_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dim4_popup.
function dim4_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dim4_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);



% --- Executes during object creation, after setting all properties.
function dim4_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim4_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dim3_popup.
function dim3_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dim3_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);



% --- Executes during object creation, after setting all properties.
function dim3_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim3_popup (see GCBO)
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



function ystep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ystep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function ystep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ystep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zstep_edit_Callback(hObject, eventdata, handles)
% hObject    handle to zstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function zstep_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zstep_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_workspace_variables(handles);


% --- Executes on selection change in x_unit_popup.
function x_unit_popup_Callback(hObject, eventdata, handles)
% hObject    handle to x_unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x_unit_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in y_unit_popup.
function y_unit_popup_Callback(hObject, eventdata, handles)
% hObject    handle to y_unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function y_unit_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in unit_popup.
function unit_popup_Callback(hObject, eventdata, handles)
% hObject    handle to unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function unit_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unit_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec='*.mat;*.MAT';
st={};
[st,pathname]=uigetfile(filterspec,'select datafiles','MultiSelect','on');
if isempty(st);
else
    if iscell(st);
    else
        st2{1}=st;
        st=st2;
    end;
    for i=1:length(st);
        filename{i}=[pathname,st{i}];
    end;
end;
if isempty(filename);
else
    for i=1:length(filename);
        st=['load ''' filename{i} '''']
        evalin('base',st);
    end;
end;
