function varargout = GLW_edit_electrodes_info(varargin)
% GLW_EDIT_ELECTRODES_INFO MATLAB code for GLW_edit_electrodes_info.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_edit_electrodes_info_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_edit_electrodes_info_OutputFcn, ...
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









% --- Executes just before GLW_edit_electrodes_info is made visible.
function GLW_edit_electrodes_info_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_edit_electrodes_info (see VARARGIN)
% Choose default command line output for GLW_edit_electrodes_info
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
%header
header=datasets(1).header;
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.chan_listbox,'String',st);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_edit_electrodes_info_OutputFcn(hObject, eventdata, handles) 
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
%clear_idx
clear_idx=get(handles.clear_btn,'Userdata');
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%chanlocs
chanlocs=datasets(1).header.chanlocs;
%clear selected chanlocs
cleared_chanloc.labels='';
cleared_chanloc.topo_enabled=0;
cleared_chanloc.theta=0;
cleared_chanloc.radius=0;
cleared_chanloc.sph_theta=0;
cleared_chanloc.sph_phi=0;
cleared_chanloc.sph_theta_besa=0;
cleared_chanloc.sph_phi_besa=0;
cleared_chanloc.X=0;
cleared_chanloc.Y=0;
cleared_chanloc.Z=0;
cleared_chanloc.SEEG_enabled=0;
%loop through clear_idx
if isempty(clear_idx);
else
    for i=1:length(clear_idx);
        chanlocs(i)=cleared_chanloc;
        chanlocs(i).labels=datasets(1).header.chanlocs(clear_idx(i)).labels;
    end;
end;
configuration.parameters.chanlocs=chanlocs;
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






% --- Executes on selection change in chan_listbox.
function chan_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to chan_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_info(handles);






function update_info(handles);
%v
v=get(handles.chan_listbox,'Value');
if isempty(v);
else
    v=v(1);
    %datasets
    datasets=get(handles.prefix_edit,'Userdata');
    %chanloc
    chanloc=datasets(1).header.chanlocs(v);
    st=fieldnames(chanloc);
    %clear_idx
    clear_idx=get(handles.clear_btn,'Userdata');
    if isempty(find(clear_idx==v));
    else
        st='<cleared>';
    end;
    set(handles.info_text,'String',st);
end;




% --- Executes during object creation, after setting all properties.
function chan_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chan_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in all_btn.
function all_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%v
v=get(handles.chan_listbox,'Value');
st=get(handles.chan_listbox,'String');
if isempty(v);
    v=1:1:length(st);
    set(handles.chan_listbox,'Value',v);
else
    set(handles.chan_listbox,'Value',[]);
end;
update_info(handles);




% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%v
v=get(handles.chan_listbox,'Value');
%clear_idx
clear_idx=get(handles.clear_btn,'Userdata');
clear_idx=[clear_idx v];
clear_idx=sort(unique(clear_idx));
set(handles.clear_btn,'Userdata',clear_idx);
update_info(handles);




% --- Executes on button press in reset_btn.
function reset_btn_Callback(hObject, eventdata, handles)
% hObject    handle to reset_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.clear_btn,'Userdata',[]);
update_info(handles);
