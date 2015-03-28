function varargout = GLW_dipfit_assign_headmodel(varargin)
% GLW_DIPFIT_ASSIGN_HEADMODEL MATLAB code for GLW_dipfit_assign_headmodel.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_dipfit_assign_headmodel_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_dipfit_assign_headmodel_OutputFcn, ...
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









% --- Executes just before GLW_dipfit_assign_headmodel is made visible.
function GLW_dipfit_assign_headmodel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_dipfit_assign_headmodel (see VARARGIN)
% Choose default command line output for GLW_dipfit_assign_headmodel
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
%hdm_filename
set(handles.hdm_filename_edit,'String',configuration.parameters.hdm_filename);
%header
header=datasets(1).header;
%find dipfit channel locations
if isfield(header,'history');
else
    disp('No History. Exit.');
end;
if isempty(header.history);
    disp('No History. Exit.');
end;
for i=1:length(header.history);
    st{i}=header.history(i).configuration.gui_info.function_name;
end;
a=find(strcmpi(st,'LW_dipfit_assign_chanlocs'));
if isempty(a);
    disp('No dipfit channel locations found in history. Exit.');
    return;
end;
%chanlocs
chanlocs=header.history(a(end)).configuration.parameters.chanlocs;
%chanloc_labels
for i=1:length(chanlocs);
    chanloc_labels{i}=chanlocs(i).labels;
end;
%find matching labels
j=1;
chanlocs2=[];
for i=1:length(header.chanlocs);
    a=find(strcmpi(header.chanlocs(i).labels,chanloc_labels));
    if isempty(a);
    else
        chanlocs2_idx(j)=a(1);
        chanlocs2_labels{j}=chanlocs(a(1)).labels;
        j=j+1;
    end;
end;
if isempty(chanlocs2_idx);
    disp('No matching channels found. Exit.');
    return;
end;
chanlocs2=chanlocs(chanlocs2_idx);
%elec
elec=[];
for chanpos=1:length(chanlocs2);
    elec.pnts(chanpos,1)=chanlocs2(chanpos).X;
    elec.pnts(chanpos,2)=chanlocs2(chanpos).Y;
    elec.pnts(chanpos,3)=chanlocs2(chanpos).Z;
    elec.label{chanpos}=chanlocs2(chanpos).labels;
end;
%store elec
set(handles.channels_listbox,'Userdata',elec);
%store labels
set(handles.channels_listbox,'String',chanlocs2_labels);
%
refresh_headmodel_plot(handles);
%rotate_3D
rotate3d(handles.axes,'on');
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);




function refresh_headmodel_plot(handles);
%clear figure
cla(handles.axes);
hold on;
%vol
vol=get(handles.hdm_filename_edit,'UserData');
if isempty(vol);
else
    %draw volumes
    hs.hdm(1)=ft_plot_mesh(vol.bnd(1),'facealpha',0.3,'facecolor',[0.9 0.6 0.6],'edgecolor','none');
    hs.hdm(2)=ft_plot_mesh(vol.bnd(2),'facealpha',0.3,'facecolor',[0.3 0.3 0.7],'edgecolor','none');
    hs.hdm(3)=ft_plot_mesh(vol.bnd(3),'facealpha',0.3,'facecolor',[0.3 0.7 0.3],'edgecolor','none');
end;
%elec
elec=get(handles.channels_listbox,'UserData');
if isempty(elec);
else;
    selected=get(handles.channels_listbox,'Value');
    unselected=1:1:size(elec.pnts,1);
    unselected(selected)=[];
    if length(selected)>0;
        red_elec.pnts=elec.pnts(selected,:);
    else
        red_elec=[];
    end;
    if length(unselected)>0;
        blue_elec.pnts=elec.pnts(unselected,:);
    else
        blue_elec=[];
    end;
    diameter=3;
    s=[];
    [s.x,s.y,s.z]=sphere(20);
    s.x=s.x*diameter;
    s.y=s.y*diameter;
    s.z=s.z*diameter;
    if isempty(red_elec);
    else
        for i=1:size(red_elec.pnts,1);
            hs_electrodes=surf(s.x+red_elec.pnts(i,1),s.y+red_elec.pnts(i,2),s.z+red_elec.pnts(i,3));
            set(hs_electrodes,'FaceColor',[1 0 0],'FaceAlpha',0.5,'edgecolor','none');
        end;
    end;
    if isempty(blue_elec);
    else
        for i=1:size(blue_elec.pnts,1);
            hs_electrodes=surf(s.x+blue_elec.pnts(i,1),s.y+blue_elec.pnts(i,2),s.z+blue_elec.pnts(i,3));
            set(hs_electrodes,'FaceColor',[0 0 1],'FaceAlpha',0.5,'edgecolor','none');
        end;
    end;
end;
hold off;
camlight;
lighting GOURAUD




% --- Outputs from this function are returned to the command line.
function varargout = GLW_dipfit_assign_headmodel_OutputFcn(hObject, eventdata, handles)
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
configuration.parameters.hdm_filename=get(handles.hdm_filename_edit,'String');
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





% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec={'*.mat; *.MAT'};
[filename,pathname]=uigetfile(filterspec);
filename=fullfile(pathname,filename);
set(handles.hdm_filename_edit,'String',filename);
load(filename);
if exist('vol');
    set(handles.hdm_filename_edit,'UserData',vol);
    refresh_headmodel_plot(handles);
else
    msgbox('Error : no volume found in selected MAT file');
end;








% --- Executes on selection change in channels_listbox.
function channels_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
refresh_headmodel_plot(handles);






% --- Executes during object creation, after setting all properties.
function channels_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in standard_btn.
function standard_btn_Callback(hObject, eventdata, handles)
% hObject    handle to standard_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename='BEM_standard_3shell_vol.mat';
set(handles.hdm_filename_edit,'String',filename);
load(filename);
if exist('vol');
    set(handles.hdm_filename_edit,'UserData',vol);
    refresh_headmodel_plot(handles);
else
    msgbox('Error : no volume found in selected MAT file');
end;
