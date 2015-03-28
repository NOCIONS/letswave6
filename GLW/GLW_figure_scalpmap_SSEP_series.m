function varargout = GLW_figure_scalpmap_SSEP_series(varargin)
% GLW_FIGURE_SCALPMAP_SSEP_SERIES MATLAB code for GLW_figure_scalpmap_SSEP_series.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_figure_scalpmap_SSEP_series_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_figure_scalpmap_SSEP_series_OutputFcn, ...
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









% --- Executes just before GLW_figure_scalpmap_SSEP_series is made visible.
function GLW_figure_scalpmap_SSEP_series_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_figure_scalpmap_SSEP_series (see VARARGIN)
% Choose default command line output for GLW_figure_scalpmap_SSEP_series
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%function('dummy',configuration,datasets);
%configuration
configuration=varargin{2};
set(handles.process_btn,'Userdata',configuration);
%datasets
datasets=varargin{3};
%axis
axis off;
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%!!!!!!!!!!!!!!!!!!!!!!!!
%update GUI configuration
%!!!!!!!!!!!!!!!!!!!!!!!!
%datasets_listbox
if isempty(datasets);
    return;
end;
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.datasets_listbox,'String',st);
set(handles.datasets_listbox,'Value',1);
%y_edit
set(handles.y_edit,'String',num2str(datasets(1).header.ystart));
%z_edit
set(handles.z_edit,'String',num2str(datasets(1).header.zstart));
%datasets
set(handles.datasets_listbox,'Userdata',datasets);
%epochs_listbox
update_epochs_listbox(handles);
%uitable
set(handles.uitable,'UserData',[]);
set(handles.uitable,'Data',{});
%!!!
%END
%!!!





function update_epochs_listbox(handles);
datasets=get(handles.datasets_listbox,'Userdata');
dataset=datasets(get(handles.datasets_listbox,'Value'));
%epoch_listbox
for i=1:dataset.header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
v=get(handles.epoch_listbox,'Value');
if v>length(st);
    set(handles.epoch_listbox,'Value',1);
end;
%index_popup
if dataset.header.datasize(3)==1;
    set(handles.index_text,'Enable','off');
    set(handles.index_popup,'Enable','off');
else
    set(handles.index_text,'Enable','on');
    set(handles.index_popup,'Enable','on');
    if isfield(dataset.header.index_labels);
        st=dataset.header.index_labels;
    else
        st={};
        for i=1:dataset.header.datasize(3);
            st=num2str(i);
        end;
    end;
    set(handles.index_popup,'String',st);
    v=get(handles.index_popup,'Value');
    if v>length(st);
        set(handles.index_popup,'Value',1);
    end;
end;
%z_edit
if dataset.header.datasize(4)==1;
    set(handles.z_text,'Enable','off');
    set(handles.z_edit,'Enable','off');
else
    set(handles.z_text,'Enable','on');
    set(handles.z_edit,'Enable','on');
end;
%y_text
if dataset.header.datasize(5)==1;
    set(handles.y_text,'Enable','off');
    set(handles.y_edit,'Enable','off');
else
    set(handles.y_text,'Enable','on');
    set(handles.y_edit,'Enable','on');
end;



% --- Outputs from this function are returned to the command line.
function varargout = GLW_figure_scalpmap_SSEP_series_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
%configuration
configuration=get(handles.process_btn,'UserData');
varargout{2}=configuration;




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called








% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%datasets
datasets=get(handles.datasets_listbox,'Userdata');
%tabledata
table_data=get(handles.uitable,'UserData');
%cmin,cmax
cmin=str2num(get(handles.color_scale_min_edit,'String'));
cmax=str2num(get(handles.color_scale_max_edit,'String'));
%xi
xstart=str2num(get(handles.frequency_edit,'String'));
num_harmonics=str2num(get(handles.num_harmonics_edit,'String'));
xi=xstart:xstart:xstart*num_harmonics;
%tolerance
tolerance=str2num(get(handles.tolerance_edit,'String'));
%figure
figure;
%loop through rows
for row_pos=1:size(table_data,1);
    %dataset_pos > dataset
    dataset_pos=table_data(row_pos,1);
    dataset=datasets(dataset_pos);
    %epoch_pos
    epoch_pos=table_data(row_pos,2);
    %index_pos
    if dataset.header.datasize(3)==1;
        index_pos=1;
    else
        index_pos=table_data(row_pos,3);
    end;
    %dz
    if dataset.header.datasize(4)==1;
        dz=1;
    else
        z=table_data(row_pos,4);
        dz=fix(((z-dataset.header.zstart)/dataset.header.zstep))+1;
    end;
    %dy
    if dataset.header.datasize(5)==1;
        dy=1;
    else
        y=table_data(row_pos,5);
        dy=fix(((y-dataset.header.ystart)/dataset.header.ystep))+1;
    end;
    %xi > dxi
    dxi=fix(((xi-dataset.header.xstart)/dataset.header.xstep))+1;
    %dxi1,dxi2 (tolerance)
    dxi1=dxi-floor(tolerance/2);
    dxi2=dxi+ceil(tolerance/2);
    %loop through dxi
    for i=1:length(dxi);
        %find max_dxi
        if dxi1(i)==dxi2(i);
            %no tolerance
            fdxi=dxi1(i);
        else
            %tolerance
            [a,b]=max(squeeze(mean(dataset.data(epoch_pos,:,index_pos,dz,dy,dxi1(i):dxi2(i)),2)));
            fdxi=dxi1(i)+(b-1);
        end;
        %subplot
        subplot(size(table_data,1),length(dxi),((row_pos-1)*length(dxi))+i);
        %headplot
        CLW_topoplot(dataset.header,dataset.data,epoch_pos,index_pos,fdxi,dy,dz,'maplimits',[cmin cmax]);
        %title
        title(gca,num2str(xi(i)));
    end;
end;








% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on selection change in datasets_listbox.
function datasets_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to datasets_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function datasets_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datasets_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in epoch_listbox.
function epoch_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function epoch_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in index_popup.
function index_popup_Callback(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_harmonics_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_harmonics_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function num_harmonics_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_harmonics_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function frequency_edit_Callback(hObject, eventdata, handles)
% hObject    handle to frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function color_scale_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to color_scale_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function color_scale_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_scale_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function color_scale_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to color_scale_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function color_scale_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to color_scale_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in viewpoint_popup.
function viewpoint_popup_Callback(hObject, eventdata, handles)
% hObject    handle to viewpoint_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function viewpoint_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to viewpoint_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
datasets=get(handles.datasets_listbox,'Userdata');
dataset=datasets(get(handles.datasets_listbox,'Value'));
%
dataset_pos=get(handles.datasets_listbox,'Value');
epoch_pos=get(handles.epoch_listbox,'Value');
dataset_names=get(handles.datasets_listbox,'String');
epoch_names=get(handles.epoch_listbox,'String');
table_data=get(handles.uitable,'UserData');
if dataset.header.datasize(3)==1;
    index_pos=0;
else
    index_pos=get(handles.index_popup,'Value');
end;
if dataset.header.datasize(4)==1;
    z_value=0;
else
    z_value=str2num(get(handles.z_edit,'String'));
end;
if dataset.header.datasize(5)==1;
    y_value=0;
else
    y_value=str2num(get(handles.y_edit,'String'));
end;
if isempty(table_data);
    table_data(1,1)=dataset_pos;
    table_data(1,2)=epoch_pos;
    table_data(1,3)=index_pos;
    table_data(1,4)=z_value;
    table_data(1,5)=y_value;
else
    table_data(end+1,1)=dataset_pos;
    table_data(end,2)=epoch_pos;
    table_data(end,3)=index_pos;
    table_data(end,4)=z_value;
    table_data(end,5)=y_value;
    
end;
for i=1:size(table_data,1);
    table{i,1}=dataset_names{table_data(i,1)};
    table{i,2}=epoch_names{table_data(i,2)};
    table{i,3}=num2str(index_pos);
    table{i,4}=num2str(z_value);
    table{i,5}=num2str(y_value);
end;
set(handles.uitable,'UserData',table_data);
set(handles.uitable,'Data',table);







% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uitable,'UserData',[]);
set(handles.uitable,'Data',{});



function tolerance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to tolerance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function tolerance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tolerance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in headplot_btn.
function headplot_btn_Callback(hObject, eventdata, handles)
% hObject    handle to headplot_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.datasets_listbox,'Userdata');
%tabledata
table_data=get(handles.uitable,'UserData');
%cmin,cmax
cmin=str2num(get(handles.color_scale_min_edit,'String'));
cmax=str2num(get(handles.color_scale_max_edit,'String'));
%xi
xstart=str2num(get(handles.frequency_edit,'String'));
num_harmonics=str2num(get(handles.num_harmonics_edit,'String'));
xi=xstart:xstart:xstart*num_harmonics;
%tolerance
tolerance=str2num(get(handles.tolerance_edit,'String'));
%figure
figure;
%view_point
st=get(handles.viewpoint_popup,'String');
view_point=st{get(handles.viewpoint_popup,'Value')};
%loop through rows
for row_pos=1:size(table_data,1);
    %dataset_pos > dataset
    dataset_pos=table_data(row_pos,1);
    dataset=datasets(dataset_pos);
    %splinefile
    st='LW_headmodel_compute';
    for i=1:length(dataset.header.history);
        if strcmpi(st,dataset.header.history(i).configuration.gui_info.function_name);
            splinefile=dataset.header.history(i).configuration.parameters.spl_filename;
        end;
    end;
    %epoch_pos
    epoch_pos=table_data(row_pos,2);
    %index_pos
    if dataset.header.datasize(3)==1;
        index_pos=1;
    else
        index_pos=table_data(row_pos,3);
    end;
    %dz
    if dataset.header.datasize(4)==1;
        dz=1;
    else
        z=table_data(row_pos,4);
        dz=fix(((z-dataset.header.zstart)/dataset.header.zstep))+1;
    end;
    %dy
    if dataset.header.datasize(5)==1;
        dy=1;
    else
        y=table_data(row_pos,5);
        dy=fix(((y-dataset.header.ystart)/dataset.header.ystep))+1;
    end;
    %xi > dxi
    dxi=fix(((xi-dataset.header.xstart)/dataset.header.xstep))+1;
    %dxi1,dxi2 (tolerance)
    dxi1=dxi-floor(tolerance/2);
    dxi2=dxi+ceil(tolerance/2);
    %loop through dxi
    for i=1:length(dxi);
        %find max_dxi
        if dxi1(i)==dxi2(i);
            %no tolerance
            fdxi=dxi1(i);
        else
            %tolerance
            [a,b]=max(squeeze(mean(dataset.data(epoch_pos,:,index_pos,dz,dy,dxi1(i):dxi2(i)),2)));
            fdxi=dxi1(i)+(b-1);
        end;
        %subplot
        subplot(size(table_data,1),length(dxi),((row_pos-1)*length(dxi))+i);
        %vector
        vector=squeeze(dataset.data(epoch_pos,:,index_pos,dz,dy,fdxi));
        %parse data and chanlocs according to topo_enabled
        k=1;
        vector2=[];
        chanlocs2=chanlocs(1);
        for chanpos=1:size(chanlocs,2);
            if chanlocs(chanpos).topo_enabled==1
                vector2(k)=double(vector(chanpos));
                chanlocs2(k)=chanlocs(chanpos);
                k=k+1;
            end;
        end;
        %headplot
        headplot(vector2,splinefile,'maplimits',[cmin cmax]);
        %title
        title(gca,num2str(xi(i)));
        %viewpoint
        switch view_point
            case 'top'
               set(gca,'View',[0 90]);
           case 'back'
               set(gca,'View',[0 30]);
           case 'left'
               set(gca,'View',[-90 30]);
           case 'right'
               set(gca,'View',[90 30]);
           case 'front'
               set(gca,'View',[180 30]);
       end;
    end;
end;
