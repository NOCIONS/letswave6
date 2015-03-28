function varargout = GLW_dipfit_fit_ICs(varargin)
% GLW_DIPFIT_FIT_ICS MATLAB code for GLW_dipfit_fit_ICs.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_dipfit_fit_ICs_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_dipfit_fit_ICs_OutputFcn, ...
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









% --- Executes just before GLW_dipfit_fit_ICs is made visible.
function GLW_dipfit_fit_ICs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_dipfit_fit_ICs (see VARARGIN)
% Choose default command line output for GLW_dipfit_fit_ICs
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
%IC_listbox
k=1;
if isempty(datasets);
    return;
end;
header=datasets(1).header;
%store header
set(handles.IC_topo_btn,'Userdata',header);
%find IC matrix
ICA=[];
history=header.history;
for j=1:length(history);
    switch history(j).configuration.gui_info.function_name
        case 'LW_ICA_compute';
            ICA.um=history(j).configuration.parameters.ICA_um;
            ICA.mm=history(j).configuration.parameters.ICA_mm;
        case 'LW_ICA_compute_merged';
            ICA.um=history(j).configuration.parameters.ICA_um;
            ICA.mm=history(j).configuration.parameters.ICA_mm;
        case 'LW_ICA_assign'
            ICA.um=history(j).configuration.parameters.ICA_um;
            ICA.mm=history(j).configuration.parameters.ICA_mm;
    end;
end;
if isempty(ICA);
    disp('No ICA matrix found in the dataset.');
    return;
end;
%store ICA
set(handles.IC_listbox,'Userdata',ICA);
%generate list of ICs
st={};
for i=1:size(ICA.mm,2);
    st{i}=['IC ' num2str(i)];
end;
set(handles.IC_listbox,'String',st);
%selected ICs
if isempty(configuration.parameters.IC_list);
else
    set(handles.IC_listbox,'Value',configuration.parameters.IC_list);
end;
%dipole_model
st={'single','pairX','pairY','pairZ','pair'};
set(handles.dipole_model_popup,'Userdata',st);
a=find(strcmpi(configuration.parameters.dipole_model,st));
if isempty(a);
else
    set(handles.dipole_model_popup,'Value',a(1));
end;
%gridsearch_resolution
set(handles.gridsearch_resolution_edit,'String',num2str(configuration.parameters.gridsearch_resolution));
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_dipfit_fit_ICs_OutputFcn(hObject, eventdata, handles) 
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
%IC_list
configuration.parameters.IC_list=get(handles.IC_listbox,'Value');
%dipole_model
st=get(handles.dipole_model_popup,'Userdata');
configuration.parameters.dipole_model=st{get(handles.dipole_model_popup,'Value')};
%gridsearch_resolution
configuration.parameters.gridsearch_resolution=str2num(get(handles.gridsearch_resolution_edit,'String'));
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


% --- Executes on selection change in dipole_model_popup.
function dipole_model_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dipole_model_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function dipole_model_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipole_model_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IC_listbox.
function IC_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to IC_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function IC_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IC_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gridsearch_resolution_edit_Callback(hObject, eventdata, handles)
% hObject    handle to gridsearch_resolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function gridsearch_resolution_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gridsearch_resolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function process_btn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in IC_topo_btn.
function IC_topo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to IC_topo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%header
header=get(handles.IC_topo_btn,'Userdata');
%chanlocs
chanlocs=header.chanlocs;
%selected_ICs
selected_ICs=get(handles.IC_listbox,'Value');
if isempty(selected_ICs);
    return;
end;
%ICA
ICA=get(handles.IC_listbox,'Userdata');
%figure
figure;
%loop through selected ICs
for IC_pos=1:length(selected_ICs);
    %subplot
    subplot(1,length(selected_ICs),IC_pos)
    %topo
    topo=squeeze(ICA.mm(:,selected_ICs(IC_pos)));
    %topoplot
    topoplot(topo,chanlocs,'shading','interp','whitebk','on');
end;
