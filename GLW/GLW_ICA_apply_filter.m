function varargout = GLW_ICA_apply_filter(varargin)
% GLW_ICA_APPLY_FILTER MATLAB code for GLW_ICA_apply_filter.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_ICA_apply_filter_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_ICA_apply_filter_OutputFcn, ...
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









% --- Executes just before GLW_ICA_apply_filter is made visible.
function GLW_ICA_apply_filter_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_ICA_apply_filter (see VARARGIN)
% Choose default command line output for GLW_ICA_apply_filter
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
%load header
if isempty(datasets);
    return;
else
    %IC_mm, IC_um
    ICA_mm=[];
    ICA_um=[];
    %datasets(1)
    history=datasets(1).header.history;
    for j=1:length(history);
        switch history(j).configuration.gui_info.function_name
            case 'LW_ICA_compute';
                ICA_um=history(j).configuration.parameters.ICA_um;
                ICA_mm=history(j).configuration.parameters.ICA_mm;
            case 'LW_ICA_assign'
                ICA_um=history(j).configuration.parameters.ICA_um;
                ICA_mm=history(j).configuration.parameters.ICA_mm;
            case 'LW_ICA_compute_merged'
                ICA_um=history(j).configuration.parameters.ICA_um;
                ICA_mm=history(j).configuration.parameters.ICA_mm;
        end;
    end;
    %datasets(>1)
    if length(datasets)>1;
        for i=1:length(datasets);
            history=datasets(i).header.history;
            for j=1:length(history);
                switch history(j).configuration.gui_info.function_name
                    case 'LW_ICA_compute';
                        tp_um=history(j).configuration.parameters.ICA_um;
                        tp_mm=history(j).configuration.parameters.ICA_mm;
                    case 'LW_ICA_compute_merged';
                        tp_um=history(j).configuration.parameters.ICA_um;
                        tp_mm=history(j).configuration.parameters.ICA_mm;
                    case 'LW_ICA_assign_matrix'
                        tp_um=history(j).configuration.parameters.ICA_um;
                        tp_mm=history(j).configuration.parameters.ICA_mm;
                end;
            end;
            if tp_um==ICA_um;
            else
                disp('ERROR : the datasets do not have matching unmixing matrices');
                return;
            end;
            if tp_mm==ICA_mm;
            else
                disp('ERROR : the datasets to not have matching mixing matrices!');
                return;
            end;
        end;
    end;
    if isempty(ICA_um);
        disp('ERROR : no matrix found in dataset');
        return;
    end;
    %store IC_um and IC_mm
    matrix.ICA_um=ICA_um;
    matrix.ICA_mm=ICA_mm;
    set(handles.IC_topo_btn,'Userdata',matrix);
    %header
    header=datasets(1).header;
    %IC labels for IC_list_listbox
    st={};
    for i=1:size(ICA_mm,2);
        st{i}=['IC ' num2str(i)];
    end;
    set(handles.IC_list_listbox,'String',st);
    set(handles.IC_list_listbox,'Value',configuration.parameters.IC_list);
    %IC labels for IC_listbox
    set(handles.IC_listbox,'String',st);
    %epoch labels for epoch_listbox
    st={};
    for i=1:header.datasize(1);
        st{i}=[num2str(i)];
    end;
    set(handles.epoch_listbox,'String',st);
    %channel labels for channel_listbox
    st={};
    for i=1:length(header.chanlocs);
        st{i}=header.chanlocs(i).labels;
    end;
    set(handles.channel_listbox,'String',st);
    %dataset listbox
    st={};
    for i=1:length(datasets);
        st{i}=datasets(i).header.name;
    end;
    set(handles.dataset_listbox,'String',st);
    %update_graphs
    update_graphs(handles);
end;
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);




function update_graphs(handles);
%dataset_pos,epoch_pos,channel_pos,ic_pos
dataset_pos=get(handles.dataset_listbox,'Value');
epoch_pos=get(handles.epoch_listbox,'Value');
channel_pos=get(handles.channel_listbox,'Value');
IC_pos=get(handles.IC_listbox,'Value');
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%header
header=datasets(dataset_pos).header;
%data
data=datasets(dataset_pos).data;
%update epoch_listbox
st=get(handles.epoch_listbox,'String');
if length(st)==header.datasize(1);
else
    st={};
    for i=1:header.datasize(1);
        st{i}=num2str(i);
    end;
    set(handles.epoch_listbox,'String',st);
    if get(handles.epoch_listbox,'Value')>header.datasize(1);
        set(handles.epoch_listbox,'Value',header.datasize(1));
        epoch_pos=header.datasize(1);
    end;
end;
%tpx
tpx=1:1:header.datasize(6);
tpx=((tpx-1)*header.xstep)+header.xstart;
%original signal
tpy_original=squeeze(data(epoch_pos,channel_pos,1,1,1,:));
%matrix
matrix=get(handles.IC_topo_btn,'Userdata');
%IC (unmix)
tp=matrix.ICA_um*(squeeze(data(epoch_pos,:,1,1,1,:)));
tpy_IC=tp(IC_pos,:);
%selected_ICs
remove_ICs=get(handles.IC_list_listbox,'Value');
%mask
matrix.ICA_mm(:,remove_ICs)=0;
%IC (remix)
tp2=matrix.ICA_mm*tp;
tpy_filtered=tp2(channel_pos,:);
%plot
plot(handles.IC_axes,tpx,tpy_IC,'k');
plot(handles.signals_axes,tpx,tpy_original,'k');
hold(handles.signals_axes,'on');
plot(handles.signals_axes,tpx,tpy_filtered,'r');
hold(handles.signals_axes,'off');













% --- Outputs from this function are returned to the command line.
function varargout = GLW_ICA_apply_filter_OutputFcn(hObject, eventdata, handles)
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
%matrix
matrix=get(handles.IC_topo_btn,'Userdata');
%IC_list
IC_list=1:1:size(matrix.ICA_mm,2);
remove_ICs=get(handles.IC_list_listbox,'Value');
IC_list(remove_ICs)=[];
configuration.parameters.IC_list=IC_list;
configuration.parameters.ICA_um=matrix.ICA_um;
configuration.parameters.ICA_mm=matrix.ICA_mm;

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






% --- Executes on selection change in IC_list_listbox.
function IC_list_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to IC_list_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);






% --- Executes during object creation, after setting all properties.
function IC_list_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IC_list_listbox (see GCBO)
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
idx=get(handles.IC_list_listbox,'Value');
st=get(handles.IC_list_listbox,'String');
if isempty(idx);
    idx=1:1:length(st);
else
    idx=[];
end;
set(handles.IC_list_listbox,'Value',idx);
%update_graphs
update_graphs(handles);






% --- Executes on selection change in epoch_listbox.
function epoch_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);



% --- Executes during object creation, after setting all properties.
function epoch_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);





% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
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
update_graphs(handles);




% --- Executes during object creation, after setting all properties.
function IC_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IC_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in IC_topo_btn.
function IC_topo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to IC_topo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%matrix
matrix=get(handles.IC_topo_btn,'Userdata');
IC_idx=get(handles.IC_listbox,'Value');
%header
datasets=get(handles.prefix_edit,'Userdata');
header=datasets(1).header;
%topoplot
f=figure;
set(f,'ToolBar','none');
set(f,'Name',['IC : ' num2str(IC_idx)]);
for i=1:length(IC_idx);
    subplot(1,length(IC_idx),i);
    %vector
    vector=matrix.ICA_mm(:,IC_idx(i));
    h=CLW_topoplot_vector(header,vector,'shading','interp','whitebk','on');
end;





% --- Executes on selection change in dataset_listbox.
function dataset_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graphs(handles);





% --- Executes during object creation, after setting all properties.
function dataset_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
