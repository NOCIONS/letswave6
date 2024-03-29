function varargout = CGLW_multi_viewer_average(varargin)
% CGLW_MULTI_VIEWER_AVERAGE MATLAB code for CGLW_multi_viewer_average.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_multi_viewer_average_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_multi_viewer_average_OutputFcn, ...
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









% --- Executes just before CGLW_multi_viewer_average is made visible.
function CGLW_multi_viewer_average_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_multi_viewer_average (see VARARGIN)
% Choose default command line output for CGLW_multi_viewer_average
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set_GUI_parameters
CLW_set_GUI_parameters(handles);
%filenames
inputfiles=varargin{2};
for i=1:length(inputfiles);
    [p n e]=fileparts(inputfiles{i});
    st{i}=n;
end;
%figure handles
[userdata.wave_figure userdata.wave_figure_handles]=CGLW_multi_viewer_figure_average;
userdata.mother_handles=handles;
set(handles.graph_wave_popup,'UserData',userdata);
%set(userdata.wave_figure_handles.xtext,'UserData',userdata);
%datasets_header, datasets_data
for i=1:length(st);
    [datasets_header(i).header datasets_data(i).data]=CLW_load(inputfiles{i});
end;
set(handles.dataset_listbox,'Userdata',datasets_header);
set(handles.epoch_listbox,'Userdata',datasets_data);
%dataset_listbox
st={};
for i=1:length(datasets_header);
    st{i}=datasets_header(i).header.name;
end;
set(handles.dataset_listbox,'String',st);
set(handles.dataset_listbox,'Value',1);
%header
header=datasets_header(1).header;
%index_popup
if header.datasize(3)>1;
    set(handles.index_text,'Visible','on');
    set(handles.index_popup,'Visible','on');
    if isfield(header,'index_labels');
        set(handles.index_popup,'String',header.index_labels);
        set(handles.index_popup,'Value',1);
    else
        st={};
        for i=1:header.datasize(3);
            st{i}=num2str(i);
        end;
        set(handles.index_popup,'String',st);
        set(handles.index_popup,'Value',1);
    end;
end;
%y
if header.datasize(5)>1;
    set(handles.y_text,'Visible','on');
    set(handles.y_edit,'Visible','on');
    set(handles.y_edit,'String',num2str(header.ystart));
end;
%z
if header.datasize(4)>1;
    set(handles.z_text,'Visible','on');
    set(handles.z_edit,'Visible','on');
    set(handles.z_edit,'String',num2str(header.zstart));
end;
%update_listbox
update_listbox(handles);
%load display settings
try
    tp=which('letswave.m');
    [p,n,e]=fileparts(tp);
    localtarget=[p filesep 'core_functions' filesep 'multiview_average_settings.mat'];
    load(localtarget);
    set(handles.menu_wave_mean,'Checked',multiview_average_settings.menu_wave_mean);
    set(handles.menu_wave_mean_sd,'Checked',multiview_average_settings.menu_wave_mean_sd);
    set(handles.menu_wave_median,'Checked',multiview_average_settings.menu_wave_median);
    set(handles.menu_wave_median_iqr,'Checked',multiview_average_settings.menu_wave_median_iqr);
    set(handles.menu_legend_dataset,'Checked',multiview_average_settings.menu_legend_dataset);
    set(handles.menu_legend_epoch,'Checked',multiview_average_settings.menu_legend_epoch);
    set(handles.menu_legend_channel,'Checked',multiview_average_settings.menu_legend_channel);
    set(handles.menu_reverse_yaxis,'Checked',multiview_average_settings.menu_reverse_yaxis);
end;
%fetch data
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);






function update_graph(handles);
%figure_handles
userdata=get(handles.graph_wave_popup,'UserData');
figure(userdata.wave_figure);
%fetch legend options
display_legend_dataset=strcmpi(get(handles.menu_legend_dataset,'Checked'),'on');
display_legend_epoch=strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
display_legend_channel=strcmpi(get(handles.menu_legend_channel,'Checked'),'on');
%fetch plot options
display_waves=1;
if strcmpi(get(handles.menu_wave_mean,'Checked'),'on');
    display_waves=1;
end;
if strcmpi(get(handles.menu_wave_mean_sd,'Checked'),'on');
    display_waves=2;
end;
if strcmpi(get(handles.menu_wave_median,'Checked'),'on');
    display_waves=3;
end;
if strcmpi(get(handles.menu_wave_median_iqr,'Checked'),'on');
    display_waves=4;
end;
if strcmpi(get(handles.menu_reverse_yaxis,'Checked'),'on');
    display_reverse_y=1;
else
    display_reverse_y=0;
end;
%output.tpdata_y(dataset,epoch,channel,dx)
%output.tpdata_x(dataset,epoch,channel,dx)
output=get(handles.channel_listbox,'Userdata');
%graph_row_idx,graph_col_idx,graph_wave_idx
graph_avg_idx=get(handles.graph_avg_popup,'Value');
graph_row_idx=get(handles.graph_row_popup,'Value');
graph_wave_idx=get(handles.graph_wave_popup,'Value');
%display_legend?
if sum([display_legend_dataset display_legend_epoch display_legend_channel])>0;
    display_legend=1;
else
    display_legend=0;
end;
%prepare labels
if display_legend==1;
    %a legend must be displayed
    %selected_dataset_labels
    st=get(handles.dataset_listbox,'String');
    selected_dataset_labels=st(output.selected_datasets);
    %selected_epoch_labels
    st=get(handles.epoch_listbox,'String');
    selected_epoch_labels=st(output.selected_epochs);
    %selected_channel_labels
    st=get(handles.channel_listbox,'String');
    selected_channel_labels=st(output.selected_channels);
    %tpdata_labels
    tpdata_labels=[];
    for i=1:length(output.selected_datasets);
        for j=1:length(output.selected_epochs);
            for k=1:length(output.selected_channels);
                tpdata_labels(i,j,k).dataset_label=selected_dataset_labels{i};
                tpdata_labels(i,j,k).epoch_label=selected_epoch_labels{j};
                tpdata_labels(i,j,k).channel_label=selected_channel_labels{k};
            end;
        end;
    end;
end;
%permute dimensions (tpdata(average,rowpos,wavepos,:))
tpdata_y=permute(output.tpdata_y,[graph_avg_idx,graph_row_idx,graph_wave_idx,4]);
tpdata_x=permute(output.tpdata_x,[graph_avg_idx,graph_row_idx,graph_wave_idx,4]);
if display_legend==1;
    tpdata_labels=permute(tpdata_labels,[graph_avg_idx,graph_row_idx,graph_wave_idx]);
end;
%num_rows,num_cols,num_waves,num_graphs
num_avgs=size(tpdata_y,1);
num_rows=size(tpdata_y,2);
num_waves=size(tpdata_y,3);
num_graphs=num_rows;
%linecolors
linecolors=distinguishable_colors(num_waves);
%loop through graph rows
for row_pos=1:num_rows;
    currentaxis(row_pos)=subaxis(num_rows,1,row_pos,'MarginLeft',0.06,'MarginRight',0.02,'MarginTop',0.04,'MarginBottom',0.08,'SpacingHoriz',0.06,'SpacingVert',0.06);
    cla('reset');
    hold on;
    %plot
    for wavepos=1:num_waves;
        switch display_waves
            case 1 %mean
                %calculate mean
                tpdata_mean=zeros([1 size(tpdata_y,4)]);
                tpdata_mean=squeeze(mean(tpdata_y(:,row_pos,wavepos,:),1));
                h(wavepos)=plot(squeeze(tpdata_x(1,row_pos,1,:)),tpdata_mean,'Color',linecolors(wavepos,:));
            case 2 %mean_sd
                %calculate mean ?sd
                tpdata_mean=zeros([1 size(tpdata_y,4)]);
                tpdata_sd=zeros([1 size(tpdata_y,4)]);
                tpdata_mean=squeeze(mean(tpdata_y(:,row_pos,wavepos,:),1));
                tpdata_sd=squeeze(std(tpdata_y(:,row_pos,wavepos,:),[],1));
                h(wavepos)=plot(squeeze(tpdata_x(1,row_pos,1,:)),tpdata_mean,'Color',linecolors(wavepos,:));
                shadedErrorBar(tpdata_x(1,row_pos,1,:),tpdata_mean,tpdata_sd,{'color',squeeze(linecolors(wavepos,:))},1);
            case 3 %median
                %calculate median ?iqr
                tpdata_mean=zeros([1 size(tpdata_y,4)]);
                tpdata_mean=squeeze(median(tpdata_y(:,row_pos,wavepos,:),1));
                h(wavepos)=plot(squeeze(tpdata_x(1,row_pos,1,:)),tpdata_mean,'Color',linecolors(wavepos,:));
            case 4 %median_iqr
                %calculate median ?iqr
                tpdata_mean=zeros([1 size(tpdata_y,4)]);
                tpdata_sd=zeros([2 size(tpdata_y,4)]);
                tpdata_mean=squeeze(median(tpdata_y(:,row_pos,wavepos,:),1));
                tpdata_sd(1,:)=squeeze(prctile(tpdata_y(:,row_pos,wavepos,:),75,1));
                tpdata_sd(2,:)=squeeze(prctile(tpdata_y(:,row_pos,wavepos,:),25,1));
                h(wavepos)=plot(squeeze(tpdata_x(1,row_pos,1,:)),tpdata_mean,'Color',linecolors(wavepos,:));
                %shadedErrorBar (see help and code) adds/substracts 
                %errBar data from y,therefore it is necessary to compensate
                %for this:
                tpdata_sd(1,:) = tpdata_sd(1,:)-tpdata_mean';
                tpdata_sd(2,:) = -tpdata_sd(2,:)+tpdata_mean';
                shadedErrorBar(tpdata_x(1,row_pos,1,:),tpdata_mean,tpdata_sd,{'color',squeeze(linecolors(wavepos,:))},1);
        end;
    end;
    hold off;
    %legend
    if display_legend==1;
        for wave_pos=1:num_waves;
            legend_string{wave_pos}='';
            if display_legend_dataset==1;
                legend_string{wave_pos}=[legend_string{wave_pos} tpdata_labels(row_pos,1,wave_pos).dataset_label ' '];
            end;
            if display_legend_epoch==1;
                legend_string{wave_pos}=[legend_string{wave_pos} '[' tpdata_labels(row_pos,1,wave_pos).epoch_label '] '];
            end;
            if display_legend_channel==1;
                legend_string{wave_pos}=[legend_string{wave_pos} '[' tpdata_labels(row_pos,1,wave_pos).channel_label '] '];
            end;
        end;
        legend(legend_string,'Location','NorthEast');
    end;
    %uistack
    for wavepos=1:num_waves;
        uistack(h(wavepos),'top');
    end;
end;
%link axis
linkaxes(currentaxis,'xy')
%xlim
if get(handles.xaxis_auto_chk,'Value')==1;
    xmin=min(tpdata_x(:));
    xmax=max(tpdata_x(:));
    set(handles.xaxis_min_edit,'String',num2str(xmin));
    set(handles.xaxis_max_edit,'String',num2str(xmax));
end;
xlim(currentaxis(1),[str2num(get(handles.xaxis_min_edit,'String')) str2num(get(handles.xaxis_max_edit,'String'))]);
%ylim
if get(handles.yaxis_auto_chk,'Value')==1;
    ymin=min(tpdata_mean(:));
    ymax=max(tpdata_mean(:));
    set(handles.yaxis_min_edit,'String',num2str(ymin));
    set(handles.yaxis_max_edit,'String',num2str(ymax));
end;
ylim(currentaxis(1),[str2num(get(handles.yaxis_min_edit,'String')) str2num(get(handles.yaxis_max_edit,'String'))]);
%decoration
for i=1:length(currentaxis);
    set(currentaxis(i),'FontName','Arial');
    set(currentaxis(i),'FontUnits','pixels');
    set(currentaxis(i),'FontSize',9);
    set(currentaxis(i),'Box','off');
    set(currentaxis(i),'TickDir','out');
    set(currentaxis(i),'TickLength',[0.005 0.005]);
    %ydir
    if display_reverse_y==0;
        set(currentaxis(i),'YDir','normal');
    else
        set(currentaxis(i),'YDir','reverse');
    end;
end;
%update userdata
userdata.currentaxis=currentaxis;
set(handles.graph_wave_popup,'UserData',userdata);
%update info for figure
set(userdata.wave_figure_handles.xtext,'UserData',handles);
%










function update_listbox(handles);
%datasets_header
datasets_header=get(handles.dataset_listbox,'Userdata');
%selected_datasets_header
selected_datasets_header=datasets_header(get(handles.dataset_listbox,'Value'));
%epoch_listbox (show only epochs available across all datasets)
a=[];
for i=1:length(selected_datasets_header);
    a(i)=selected_datasets_header(i).header.datasize(1);
end;
num_epochs=min(a);
st={};
for i=1:num_epochs;
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
v=get(handles.epoch_listbox,'Value');
v(find(v>length(st)))=[];
if isempty(v);
    v=1;
end;
set(handles.epoch_listbox,'Value',v);
%channel_listbox (show only channels available across all datasets)
all_st={};
for i=1:length(selected_datasets_header);
    st={};
    header=selected_datasets_header(i).header;
    for j=1:length(header.chanlocs);
        st{j}=header.chanlocs(j).labels;
    end;
    st=unique(st,'stable');
    all_st=[all_st st];
end;
unique_all_st=unique(all_st,'stable');
for i=1:length(unique_all_st);
    a=find(strcmpi(unique_all_st(i),all_st));
    count_channels(i)=length(a);
end;
unique_all_st=unique_all_st(find(count_channels==length(selected_datasets_header)));
set(handles.channel_listbox,'String',unique_all_st);





function fetch_data(handles);
%tdata(datasets,epochs,channels)
%datasets_header
datasets_header=get(handles.dataset_listbox,'Userdata');
%datasets_data
datasets_data=get(handles.epoch_listbox,'Userdata');
%selected_datasets
selected_datasets=get(handles.dataset_listbox,'Value');
%selected_epochs
selected_epochs=get(handles.epoch_listbox,'Value');
%selected_channels
selected_channels=get(handles.channel_listbox,'Value');
%selected_channels_string
st=get(handles.channel_listbox,'String');
selected_channels_string=st(selected_channels);
%indexpos
indexpos=get(handles.index_popup,'Value');
%loop through selected datasets
for datasetpos=1:length(selected_datasets);
    %header
    header=datasets_header(selected_datasets(datasetpos)).header;
    %chanlabels
    chanlabels={};
    for i=1:length(header.chanlocs);
        chanlabels{i}=header.chanlocs(i).labels;
    end;
    %find index of selected channels
    channel_idx=[];
    for i=1:length(selected_channels_string);
        a=find(strcmpi(selected_channels_string{i},chanlabels));
        channel_idx(i)=a;
    end;
    %dy
    if header.datasize(5)==1;
        dy=1;
    else
        y=str2num(get(handles.y_edit,'String'));
        dy=((y-header.ystart)*header.ystep)+1;
        if dy<1;
            dy=1;
        end;
        if dy>header.datasize(5);
            dy=header.datasize(5);
        end;
    end;
    %dz
    if header.datasize(4)==1;
        dz=1;
    else
        z=str2num(get(handles.y_edit,'String'));
        dz=((z-header.zstart)*header.zstep)+1;
        if dz<1;
            dz=1;
        end;
        if dz>header.datasize(4);
            dz=header.datasize(4);
        end;
    end;
    tdata(datasetpos).data(:,:,:,:,:,:)=datasets_data(selected_datasets(datasetpos)).data(selected_epochs,channel_idx,indexpos,dz,dy,:);
end;
%tdata(datasets).data(epoch,channel,index,1,1,:)
%datasize_max
datasize=[];
for i=1:length(tdata);
    datasize(i)=size(tdata(i).data,6);
end;
datasize_max=max(datasize);
%prepare tpdata
output.tpdata_y=nan(length(tdata),length(selected_epochs),length(channel_idx),datasize_max);
output.tpdata_x=nan(length(tdata),length(selected_epochs),length(channel_idx),datasize_max);
for datasetpos=1:length(tdata);
    output.tpdata_y(datasetpos,:,:,1:size(tdata(datasetpos).data,6))=squeeze(tdata(datasetpos).data(:,:,1,1,1,:));
    %header
    header=datasets_header(selected_datasets(datasetpos)).header;
    %tpx
    tpx=1:1:header.datasize(6);
    tpx=((tpx-1)*header.xstep)+header.xstart;
    for epochpos=1:length(selected_epochs);
        for chanpos=1:length(channel_idx);
            output.tpdata_x(datasetpos,epochpos,chanpos,1:size(tdata(datasetpos).data,6))=tpx;
        end;
    end;
end;
output.selected_datasets=selected_datasets;
output.selected_epochs=selected_epochs;
output.selected_channels=selected_channels;
%store tdata
set(handles.channel_listbox,'Userdata',output);








% --- Outputs from this function are returned to the command line.
function varargout = CGLW_multi_viewer_average_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called















% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
delete(userdata.wave_figure);
delete(hObject);


% --- Executes on selection change in dataset_listbox.
function dataset_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_listbox(handles);
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);





% --- Executes during object creation, after setting all properties.
function dataset_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
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
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);



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
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);




% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);




% --- Executes during object creation, after setting all properties.
function y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);


% --- Executes during object creation, after setting all properties.
function z_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in yaxis_auto_chk.
function yaxis_auto_chk_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_auto_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);
figure(handles.figure1);



% --- Executes on button press in xaxis_auto_chk.
function xaxis_auto_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_auto_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_graph(handles);
figure(handles.figure1);



% --- Executes on selection change in graph_avg_popup.
function graph_avg_popup_Callback(hObject, eventdata, handles)
% hObject    handle to graph_avg_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graph_avg_popup,'Value');
sel2=get(handles.graph_row_popup,'Value');
sel3=get(handles.graph_wave_popup,'Value');
tp=[1,2,3];
tp(find(tp==sel1))=[];
tp(find(tp==sel2))=[];
tp(find(tp==sel3))=[];
if isempty(tp);
else
    if sel2==sel1;
        sel2=tp(1);
    end;
    if sel3==sel1;
        sel3=tp(1);
    end;
end;
set(handles.graph_avg_popup,'Value',sel1);
set(handles.graph_row_popup,'Value',sel2);
set(handles.graph_wave_popup,'Value',sel3);
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);







% --- Executes during object creation, after setting all properties.
function graph_avg_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph_avg_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graph_wave_popup.
function graph_wave_popup_Callback(hObject, eventdata, handles)
% hObject    handle to graph_wave_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graph_avg_popup,'Value');
sel2=get(handles.graph_row_popup,'Value');
sel3=get(handles.graph_wave_popup,'Value');
tp=[1,2,3];
tp(find(tp==sel1))=[];
tp(find(tp==sel2))=[];
tp(find(tp==sel3))=[];
if isempty(tp);
else
    if sel1==sel3;
        sel1=tp(1);
    end;
    if sel2==sel3;
        sel2=tp(1);
    end;
end;
set(handles.graph_avg_popup,'Value',sel1);
set(handles.graph_row_popup,'Value',sel2);
set(handles.graph_wave_popup,'Value',sel3);
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);




% --- Executes during object creation, after setting all properties.
function graph_wave_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph_wave_popup (see GCBO)
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
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);



% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graph_row_popup.
function graph_row_popup_Callback(hObject, eventdata, handles)
% hObject    handle to graph_row_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graph_avg_popup,'Value');
sel2=get(handles.graph_row_popup,'Value');
sel3=get(handles.graph_wave_popup,'Value');
tp=[1,2,3];
tp(find(tp==sel1))=[];
tp(find(tp==sel2))=[];
tp(find(tp==sel3))=[];
if isempty(tp);
else
    if sel1==sel2;
        sel1=tp(1);
    end;
    if sel3==sel2;
        sel3=tp(1);
    end;
end;
set(handles.graph_avg_popup,'Value',sel1);
set(handles.graph_row_popup,'Value',sel2);
set(handles.graph_wave_popup,'Value',sel3);
fetch_data(handles);
update_graph(handles);
figure(handles.figure1);







% --- Executes during object creation, after setting all properties.
function graph_row_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph_row_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in table_btn.
function table_btn_Callback(hObject, eventdata, handles)
% hObject    handle to table_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%output
output=get(handles.channel_listbox,'Userdata');
%peakdir
peakdir=get(handles.peakdir_popup,'Value');
%x1
x1=str2num(get(handles.interval1_edit,'String'));
%x2
x2=str2num(get(handles.interval2_edit,'String'));
%y
y=str2num(get(handles.y_edit,'String'));
%z
z=str2num(get(handles.z_edit,'String'));
%indexpos
indexpos=get(handles.index_popup,'Value');
%datasets_header
datasets_header=get(handles.dataset_listbox,'Userdata');
%dataset_labels
st=get(handles.dataset_listbox,'String');
dataset_labels=st(output.selected_datasets);
%epoch_labels
st=get(handles.epoch_listbox,'String');
epoch_labels=st(output.selected_epochs);
%channel_labels
st=get(handles.channel_listbox,'String');
channel_labels=st(output.selected_channels);
%loop through datasets
for datasetpos=1:length(output.selected_datasets);
    %header
    header=datasets_header(output.selected_datasets(datasetpos)).header;
    %dy
    if header.datasize(5)==1;
        dy=1;
    else
        dy=round(((y-header.ystart)/header.ystep))+1;
    end;        
    %dz
    if header.datasize(4)==1;
        dz=1;
    else
        dz=round(((z-header.zstart)/header.zstep))+1;
    end;        
    %dx1
    [a,dx1]=min(abs(squeeze(output.tpdata_x(datasetpos,1,1,:))-x1));
    %dx2
    [a,dx2]=min(abs(squeeze(output.tpdata_x(datasetpos,1,1,:))-x2));
    %reset table_data
    table_data={};
    %loop through epochs
    k=1;
    for epochpos=1:length(output.selected_epochs);
        %loop through channels
        for chanpos=1:length(output.selected_channels);
            switch peakdir
                case 1
                    [y,dx]=max(squeeze(output.tpdata_y(datasetpos,epochpos,chanpos,dx1:dx2)));
                    x=output.tpdata_x(datasetpos,epochpos,chanpos,(dx-1)+dx1);
                case 2
                    [y,dx]=min(squeeze(output.tpdata_y(datasetpos,epochpos,chanpos,dx1:dx2)));
                    x=output.tpdata_x(datasetpos,epochpos,chanpos,(dx-1)+dx1);
                case 3
                    y=output.tpdata_y(datasetpos,epochpos,chanpos,dx1);
                    x=x1;
            end;
            table_data{k,1}=dataset_labels{datasetpos};
            table_data{k,2}=channel_labels{chanpos};
            table_data{k,3}=epoch_labels{epochpos};
            table_data{k,4}=num2str(x);
            table_data{k,5}=num2str(y);
            k=k+1;
        end;
    end;
end;
col_headers{1}='dataset';
col_headers{2}='channel';
col_headers{3}='epoch';
col_headers{4}='x';
col_headers{5}='y';
h=figure;
uitable(h,'Data',table_data,'ColumnName',col_headers,'Units','normalized','Position', [0 0 1 1]);


        





% --- Executes on button press in topo_btn.
function topo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to topo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fetch legend options
display_legend_dataset=strcmpi(get(handles.menu_legend_dataset,'Checked'),'on');
display_legend_epoch=strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
%output
output=get(handles.channel_listbox,'Userdata');
%peakdir
peakdir=get(handles.peakdir_popup,'Value');
%x1
x1=str2num(get(handles.interval1_edit,'String'));
%x2
x2=str2num(get(handles.interval2_edit,'String'));
%y
y=str2num(get(handles.y_edit,'String'));
%z
z=str2num(get(handles.z_edit,'String'));
%indexpos
indexpos=get(handles.index_popup,'Value');
%datasets_header
datasets_header=get(handles.dataset_listbox,'Userdata');
%dataset_labels
st=get(handles.dataset_listbox,'String');
dataset_labels=st(output.selected_datasets);
%epoch_labels
st=get(handles.epoch_listbox,'String');
epoch_labels=st(output.selected_epochs);
%figure
f=figure;
%numrows,numcols
numrows=length(output.selected_datasets);
numcols=length(output.selected_epochs);
%datasets_data
datasets_data=get(handles.epoch_listbox,'Userdata');
%cmin,cmax
cmin=str2num(get(handles.yaxis_min_edit,'String'));
cmax=str2num(get(handles.yaxis_max_edit,'String'));
%loop through datasets
plotpos=1;
for datasetpos=1:length(output.selected_datasets);
    %header
    header=datasets_header(output.selected_datasets(datasetpos)).header;
    %dy
    if header.datasize(5)==1;
        dy=1;
    else
        dy=round(((y-header.ystart)/header.ystep))+1;
    end;        
    %dz
    if header.datasize(4)==1;
        dz=1;
    else
        dz=round(((z-header.zstart)/header.zstep))+1;
    end;        
    %dx1
    [a,dx1]=min(abs(squeeze(output.tpdata_x(datasetpos,1,1,:))-x1));
    %dx2
    [a,dx2]=min(abs(squeeze(output.tpdata_x(datasetpos,1,1,:))-x2));
    %reset table_data
    table_data={};
    %chanlocs
    chanlocs=header.chanlocs;
    %loop through epochs
    for epochpos=1:length(output.selected_epochs);
        switch peakdir
            case 1
                %mean of selected_channels
                tpdata=output.tpdata_y(datasetpos,epochpos,output.selected_channels,dx1:dx2);
                tpdata=squeeze(mean(tpdata,3));
                [y,dx]=max(tpdata);
                x=output.tpdata_x(datasetpos,epochpos,1,(dx-1)+dx1);
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,(dx-1)+dx1));
            case 2
                %mean of selected_channels
                tpdata=output.tpdata_y(datasetpos,epochpos,output.selected_channels,dx1:dx2);
                tpdata=squeeze(mean(tpdata,3));
                [y,dx]=min(tpdata);
                x=output.tpdata_x(datasetpos,epochpos,1,(dx-1)+dx1);
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,(dx-1)+dx1));
            case 3
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,dx1));
                x=x1;
        end;
       subplot(numrows,numcols,plotpos);
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
       h=topoplot(vector2,chanlocs2,'maplimits',[cmin cmax]);
       %title
       st={};
       if display_legend_dataset==1;
           st=[dataset_labels{datasetpos} ' '];
       end;
       if display_legend_epoch==1;
           st=[st '[' epoch_labels{epochpos} ']']
       end;
       if isempty(st);
       else
           title(st);
       end;
       plotpos=plotpos+1;
    end;
end;
set(gcf,'color',[1 1 1]);

        






% --- Executes on button press in headplot_btn.
function headplot_btn_Callback(hObject, eventdata, handles)
% hObject    handle to headplot_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%fetch legend options
display_legend_dataset=strcmpi(get(handles.menu_legend_dataset,'Checked'),'on');
display_legend_epoch=strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
%output
output=get(handles.channel_listbox,'Userdata');
%peakdir
peakdir=get(handles.peakdir_popup,'Value');
%x1
x1=str2num(get(handles.interval1_edit,'String'));
%x2
x2=str2num(get(handles.interval2_edit,'String'));
%y
y=str2num(get(handles.y_edit,'String'));
%z
z=str2num(get(handles.z_edit,'String'));
%indexpos
indexpos=get(handles.index_popup,'Value');
%datasets_header
datasets_header=get(handles.dataset_listbox,'Userdata');
%dataset_labels
st=get(handles.dataset_listbox,'String');
dataset_labels=st(output.selected_datasets);
%epoch_labels
st=get(handles.epoch_listbox,'String');
epoch_labels=st(output.selected_epochs);
%figure
f=figure;
%numrows,numcols
numrows=length(output.selected_datasets);
numcols=length(output.selected_epochs);
%datasets_data
datasets_data=get(handles.epoch_listbox,'Userdata');
%cmin,cmax
cmin=str2num(get(handles.yaxis_min_edit,'String'));
cmax=str2num(get(handles.yaxis_max_edit,'String'));
%loop through datasets
plotpos=1;
for datasetpos=1:length(output.selected_datasets);
    %header
    header=datasets_header(output.selected_datasets(datasetpos)).header;
%     %splinefile
%     st='LW_headmodel_compute';
%     for i=1:length(header.history);
%         if strcmpi(st,header.history(i).configuration.gui_info.function_name);
%             splinefile=header.history(i).configuration.parameters.spl_filename;
%         end;
%     end;
%     if isempty(splinefile);
%         return;
%     end;
    %dy
    if header.datasize(5)==1;
        dy=1;
    else
        dy=round(((y-header.ystart)/header.ystep))+1;
    end;        
    %dz
    if header.datasize(4)==1;
        dz=1;
    else
        dz=round(((z-header.zstart)/header.zstep))+1;
    end;        
    %dx1
    [a,dx1]=min(abs(squeeze(output.tpdata_x(datasetpos,1,1,:))-x1));
    %dx2
    [a,dx2]=min(abs(squeeze(output.tpdata_x(datasetpos,1,1,:))-x2));
    %reset table_data
    table_data={};
    %chanlocs
    chanlocs=header.chanlocs;
    %loop through epochs
    for epochpos=1:length(output.selected_epochs);
        switch peakdir
            case 1
                %mean of selected_channels
                tpdata=output.tpdata_y(datasetpos,epochpos,output.selected_channels,dx1:dx2);
                tpdata=squeeze(mean(tpdata,3));
                [y,dx]=max(tpdata);
                x=output.tpdata_x(datasetpos,epochpos,1,(dx-1)+dx1);
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,(dx-1)+dx1));
            case 2
                %mean of selected_channels
                tpdata=output.tpdata_y(datasetpos,epochpos,output.selected_channels,dx1:dx2);
                tpdata=squeeze(mean(tpdata,3));
                [y,dx]=min(tpdata);
                x=output.tpdata_x(datasetpos,epochpos,1,(dx-1)+dx1);
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,(dx-1)+dx1));
            case 3
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,dx1));
                x=x1;
        end;
       subplot(numrows,numcols,plotpos);
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
       CLW_headplot(vector2,header,'maplimits',[cmin cmax]);
       %headplot(vector2,splinefile,'maplimits',[cmin cmax]);
       %camera
       st=get(handles.camera_popup,'String');
       a=get(handles.camera_popup,'Value');
       view_point=st{a};
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
       %title
       st={};
       if display_legend_dataset==1;
           st=[dataset_labels{datasetpos} ' '];
       end;
       if display_legend_epoch==1;
           st=[st '[' epoch_labels{epochpos} ']']
       end;
       if isempty(st);
       else
           title(st);
       end;
       plotpos=plotpos+1;
    end;
end;
set(gcf,'color',[1 1 1]);











function interval1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to interval1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function interval1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function interval2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to interval2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function interval2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to interval2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in peakdir_popup.
function peakdir_popup_Callback(hObject, eventdata, handles)
% hObject    handle to peakdir_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.peakdir_popup,'Value')==3;
    set(handles.interval2_edit,'Visible','off');
else
    set(handles.interval2_edit,'Visible','on');
end;





% --- Executes during object creation, after setting all properties.
function peakdir_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peakdir_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xaxis_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.xaxis_auto_chk,'Value',0);
update_graph(handles);
figure(handles.figure1);




% --- Executes during object creation, after setting all properties.
function xaxis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xaxis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.xaxis_auto_chk,'Value',0);
update_graph(handles);
figure(handles.figure1);





% --- Executes during object creation, after setting all properties.
function xaxis_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yaxis_min_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.yaxis_auto_chk,'Value',0);
update_graph(handles);
figure(handles.figure1);





% --- Executes during object creation, after setting all properties.
function yaxis_min_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxis_min_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yaxis_max_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.yaxis_auto_chk,'Value',0);
update_graph(handles);
figure(handles.figure1);






% --- Executes during object creation, after setting all properties.
function yaxis_max_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxis_max_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in camera_popup.
function camera_popup_Callback(hObject, eventdata, handles)
% hObject    handle to camera_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function camera_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to camera_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on mouse press over figure1 background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes on mouse press over figure1 background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_5_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_7_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_default_Callback(hObject, eventdata, handles)
% hObject    handle to menu_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%waveforms
multiview_average_settings.menu_wave_mean=get(handles.menu_wave_mean,'Checked');
multiview_average_settings.menu_wave_mean_sd=get(handles.menu_wave_mean_sd,'Checked');
multiview_average_settings.menu_wave_median=get(handles.menu_wave_median,'Checked');
multiview_average_settings.menu_wave_median_iqr=get(handles.menu_wave_median_iqr,'Checked');
multiview_average_settings.menu_legend_dataset=get(handles.menu_legend_dataset,'Checked');
multiview_average_settings.menu_legend_epoch=get(handles.menu_legend_epoch,'Checked');
multiview_average_settings.menu_legend_channel=get(handles.menu_legend_channel,'Checked');
multiview_average_settings.menu_reverse_yaxis=get(handles.menu_reverse_yaxis,'Checked');
tp=which('letswave.m');
[p,n,e]=fileparts(tp);
localtarget=[p filesep 'core_functions' filesep 'multiview_average_settings.mat']
save(localtarget,'multiview_average_settings');





% --------------------------------------------------------------------
function menu_legend_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_legend_dataset,'Checked'),'on');
    set(handles.menu_legend_dataset,'Checked','off');
else
    set(handles.menu_legend_dataset,'Checked','on');
end;  
update_graph(handles);
figure(handles.figure1);


% --------------------------------------------------------------------
function menu_legend_epoch_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend_epoch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
    set(handles.menu_legend_epoch,'Checked','off');
else
    set(handles.menu_legend_epoch,'Checked','on');
end;  
update_graph(handles);
figure(handles.figure1);





% --------------------------------------------------------------------
function menu_legend_channel_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_legend_channel,'Checked'),'on');
    set(handles.menu_legend_channel,'Checked','off');
else
    set(handles.menu_legend_channel,'Checked','on');
end;  
update_graph(handles);
figure(handles.figure1);




% --------------------------------------------------------------------
function menu_reverse_yaxis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_reverse_yaxis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmpi(get(handles.menu_reverse_yaxis,'Checked'),'on');
    set(handles.menu_reverse_yaxis,'Checked','off');
else
    set(handles.menu_reverse_yaxis,'Checked','on');
end;  
update_graph(handles);
figure(handles.figure1);


% --------------------------------------------------------------------
function menu_wave_mean_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_mean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_mean,'Checked','on');
set(handles.menu_wave_mean_sd,'Checked','off');
set(handles.menu_wave_median,'Checked','off');
set(handles.menu_wave_median_iqr,'Checked','off');

update_graph(handles);
figure(handles.figure1);


% --------------------------------------------------------------------
function menu_wave_mean_sd_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_mean_sd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_mean,'Checked','off');
set(handles.menu_wave_mean_sd,'Checked','on');
set(handles.menu_wave_median,'Checked','off');
set(handles.menu_wave_median_iqr,'Checked','off');

update_graph(handles);
figure(handles.figure1);



% --------------------------------------------------------------------
function menu_wave_median_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_median (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_mean,'Checked','off');
set(handles.menu_wave_mean_sd,'Checked','off');
set(handles.menu_wave_median,'Checked','on');
set(handles.menu_wave_median_iqr,'Checked','off');

update_graph(handles);
figure(handles.figure1);


% --------------------------------------------------------------------
function menu_wave_median_iqr_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_median_iqr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_mean,'Checked','off');
set(handles.menu_wave_mean_sd,'Checked','off');
set(handles.menu_wave_median,'Checked','off');
set(handles.menu_wave_median_iqr,'Checked','on');

update_graph(handles);
figure(handles.figure1);





% --- Executes on button press in update_x_btn.
function update_x_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_x_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
xlimits=xlim(userdata.currentaxis(1));
set(handles.xaxis_min_edit,'String',num2str(xlimits(1)));
set(handles.xaxis_max_edit,'String',num2str(xlimits(2)));
set(handles.xaxis_auto_chk,'Value',0);







% --- Executes on button press in update_y_btn.
function update_y_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_y_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
ylimits=ylim(userdata.currentaxis(1));
set(handles.yaxis_min_edit,'String',num2str(ylimits(1)));
set(handles.yaxis_max_edit,'String',num2str(ylimits(2)));
set(handles.yaxis_auto_chk,'Value',0);
