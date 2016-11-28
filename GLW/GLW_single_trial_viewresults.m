function varargout = GLW_single_trial_viewresults(varargin)
% GLW_SINGLE_TRIAL_VIEWRESULTS MATLAB code for GLW_single_trial_viewresults.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_single_trial_viewresults_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_single_trial_viewresults_OutputFcn, ...
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









% --- Executes just before GLW_single_trial_viewresults is made visible.
function GLW_single_trial_viewresults_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_single_trial_viewresults (see VARARGIN)
% Choose default command line output for GLW_single_trial_viewresults
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
st={};
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_popup,'String',st);
set(handles.dataset_popup,'Value',1);
peak_estimates=fetch_peak_estimates(datasets(1).header);
if isempty(peak_estimates);
    set(handles.peak_popup,'String','');
else
    st={};
    for i=1:length(peak_estimates);
        st{i}=['peak ' num2str(i)];
    end;
    set(handles.peak_popup,'String',st);
end;
set(handles.peak_popup,'Userdata',peak_estimates);
update_table_peaks(handles)
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);







function peak_estimates=fetch_peak_estimates(header);
peak_estimates=[];
idx=0;
for i=1:length(header.history);
    if strcmpi(header.history(i).configuration.gui_info.function_name,'LW_single_trial_MLR');
        idx=i;
        disp('Single trial estimates found');
    end;
    if strcmpi(header.history(i).configuration.gui_info.function_name,'LW_single_trial_MLR_distorsion');
        idx=i;
        disp('Single trial estimates found');
    end;
end;
if idx==0;
    disp('No peaks found');
    return;
end;
peak_estimates=header.history(idx).configuration.parameters.peak_estimates;

    
        





% --- Outputs from this function are returned to the command line.
function varargout = GLW_single_trial_viewresults_OutputFcn(hObject, eventdata, handles) 
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
%peak_popup
st=get(handles.peak_popup,'String');
configuration.parameters.operation=st{get(handles.peak_popup,'Value')};
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);






% --- Executes on selection change in peak_popup.
function peak_popup_Callback(hObject, eventdata, handles)
% hObject    handle to peak_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_table_peaks(handles);





function update_table_peaks(handles);
peak_estimates=get(handles.peak_popup,'Userdata');
selected_peak=get(handles.peak_popup,'Value');
peak_latencies=peak_estimates(selected_peak).latencies;
peak_amplitudes=peak_estimates(selected_peak).amplitudes;
table_data=cell(length(peak_latencies),2);
for i=1:length(peak_latencies);
    table_data{i,1}=peak_latencies(i);
    table_data{i,2}=peak_amplitudes(i);
end;
set(handles.uitable_peaks,'Data',table_data);







% --- Executes during object creation, after setting all properties.
function peak_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_popup (see GCBO)
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






% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datasets=get(handles.prefix_edit,'Userdata');
dataset_pos=get(handles.dataset_popup,'Value');
peak_estimates=fetch_peak_estimates(datasets(dataset_pos).header);
if isempty(peak_estimates);
    set(handles.peak_popup,'String','');
else
    st={};
    for i=1:length(peak_estimates);
        st{i}=['peak ' num2str(i)];
    end;
    set(handles.peak_popup,'String',st);
end;
set(handles.peak_popup,'Userdata',peak_estimates);
update_table_peaks(handles);




% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
