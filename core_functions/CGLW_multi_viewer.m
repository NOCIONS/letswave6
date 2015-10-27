function varargout = CGLW_multi_viewer(varargin)
% CGLW_MULTI_VIEWER MATLAB code for CGLW_multi_viewer.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_multi_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_multi_viewer_OutputFcn, ...
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









% --- Executes just before CGLW_multi_viewer is made visible.
function CGLW_multi_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_multi_viewer (see VARARGIN)
% Choose default command line output for CGLW_multi_viewer
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%set fonts
%find objects with property FontSize
h=findobj(handles.figure1,'-property','FontSize');
%figure
figure(handles.figure1);
%set_GUI_parameters
load letswave_config.mat
%find objects with property FontSize
h=findobj(handles.figure1,'-property','FontSize');
%set fonts
set(h,'FontUnits',letswave_config.FontUnits);
set(h,'FontSize',letswave_config.FontSize);
set(h,'FontName',letswave_config.FontName);
%filenames
inputfiles=varargin{2};
for i=1:length(inputfiles);
    [p n e]=fileparts(inputfiles{i});
    st{i}=n;
end;
%datasets_header, datasets_data
for i=1:length(st);
    [datasets_header(i).header datasets_data(i).data]=CLW_load(inputfiles{i});
end;
set(handles.dataset_listbox,'UserData',datasets_header);
set(handles.epoch_listbox,'UserData',datasets_data);
set(handles.xaxis_auto_chk,'UserData',inputfiles);
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
    localtarget=[p filesep 'core_functions' filesep 'multiview_settings.mat'];
    load(localtarget);
    set(handles.menu_wave_plot,'Checked',multiview_settings.menu_wave_plot);
    set(handles.menu_wave_stem,'Checked',multiview_settings.menu_wave_stem);
    set(handles.menu_wave_stair,'Checked',multiview_settings.menu_wave_stair);
    set(handles.menu_legend_dataset,'Checked',multiview_settings.menu_legend_dataset);
    set(handles.menu_legend_epoch,'Checked',multiview_settings.menu_legend_epoch);
    set(handles.menu_legend_channel,'Checked',multiview_settings.menu_legend_channel);
    set(handles.menu_reverse_yaxis,'Checked',multiview_settings.menu_reverse_yaxis);
end;
%check for display_settings in header
if isfield(header,'display_settings');
    set(handles.xaxis_min_edit,'String',header.display_settings.xaxis_min_edit);
    set(handles.yaxis_min_edit,'String',header.display_settings.yaxis_min_edit);
    set(handles.xaxis_max_edit,'String',header.display_settings.xaxis_max_edit);
    set(handles.yaxis_max_edit,'String',header.display_settings.yaxis_max_edit);
    set(handles.xaxis_auto_chk,'Value',header.display_settings.xaxis_auto_chk);
    set(handles.yaxis_auto_chk,'Value',header.display_settings.yaxis_auto_chk);
    set(handles.menu_reverse_yaxis,'Checked',header.display_settings.menu_reverse_yaxis);
end;
%figure handles
userdata=[];
userdata.mother_handles=handles;
%min and max of the entire dataset
for i=1:length(datasets_data);
    maxi(i)=max(datasets_data(i).data(:));
    mini(i)=min(datasets_data(i).data(:));
end;
userdata.datasets_ymin=min(mini(i));
userdata.datasets_ymax=max(maxi(i));
userdata.cursor_mode=-1;
%store userdata
set(handles.graph_wave_popup,'UserData',userdata);
%figure ands uipanel_main uipanel_cursor position in pixels
set(handles.figure1,'Units','pixels');
set(handles.uipanel_main,'Units','pixels');
set(handles.uipanel_cursor,'Units','pixels');
%fetch data
fetch_data(handles);
%fetch graph options
fetch_graph_options(handles);
%fetch graph axis limits
fetch_graph_axis_limits(handles);
%create graph
create_graph(handles);
%adjust object sizes
adjust_object_sizes(handles);
%update graph cursors
update_graph_cursors(handles);





%****************************
function clear_plots(handles)
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
for row_pos=1:size(userdata.plot_handle,1);
    for col_pos=1:size(userdata.plot_handle,2);
        for wave_pos=1:size(userdata.plot_handle,3);
            delete(userdata.plot_handle(row_pos,col_pos,wave_pos).handle);
        end;
    end;
end;
userdata.plot_handle=[];
userdata.num_waves=0;
set(handles.graph_wave_popup,'UserData');



%************************************
function fetch_graph_options(handles)
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
%fetch legend options
userdata.display_legend_dataset=strcmpi(get(handles.menu_legend_dataset,'Checked'),'on');
userdata.display_legend_epoch=strcmpi(get(handles.menu_legend_epoch,'Checked'),'on');
userdata.display_legend_channel=strcmpi(get(handles.menu_legend_channel,'Checked'),'on');
%fetch plot options
userdata.display_waves=1;
if strcmpi(get(handles.menu_wave_plot,'Checked'),'on');
    userdata.display_waves=1;
end;
if strcmpi(get(handles.menu_wave_stem,'Checked'),'on');
    userdata.display_waves=2;
end;
if strcmpi(get(handles.menu_wave_stair,'Checked'),'on');
    userdata.display_waves=3;
end;
if strcmpi(get(handles.menu_reverse_yaxis,'Checked'),'on');
    userdata.display_reverse_y=1;
else
    userdata.display_reverse_y=0;
end;
%display_legend?
if sum([userdata.display_legend_dataset userdata.display_legend_epoch userdata.display_legend_channel])>0;
    userdata.display_legend=1;
else
    userdata.display_legend=0;
end;
%store userdata
set(handles.graph_wave_popup,'UserData',userdata);


%************
function output=fetch_data_for_tables(handles)
%datasets_header
datasets_header=get(handles.dataset_listbox,'Userdata');
%datasets_data
datasets_data=get(handles.epoch_listbox,'Userdata');
%selected_datasets
output.selected_datasets=get(handles.dataset_listbox,'Value');
%selected_epochs
output.selected_epochs=get(handles.epoch_listbox,'Value');
%selected_channels
output.selected_channels=get(handles.channel_listbox,'Value');
%selected_channels_string
st=get(handles.channel_listbox,'String');
output.selected_channels_string=st(output.selected_channels);
%indexpos
indexpos=get(handles.index_popup,'Value');
%loop through selected datasets
for datasetpos=1:length(output.selected_datasets);
    %header
    header=datasets_header(output.selected_datasets(datasetpos)).header;
    output.selected_datasets_header(datasetpos).header=header;
    output.selected_datasets_labels{datasetpos}=header.name;
    %chanlabels
    chanlabels={};
    for i=1:length(header.chanlocs);
        chanlabels{i}=header.chanlocs(i).labels;
    end;
    %find index of selected channels
    channel_idx=[];
    for i=1:length(output.selected_channels_string);
        a=find(strcmpi(output.selected_channels_string{i},chanlabels));
        channel_idx(i)=a(1);
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
    tdata(datasetpos).data(:,:,:,:,:,:)=datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs,channel_idx,indexpos,dz,dy,:);
end;
%datasize_max
datasize=[];
for i=1:length(tdata);
    datasize(i)=size(tdata(i).data,6);
end;
datasize_max=max(datasize);
%prepare tpdata
output.tpdata_y=nan(length(tdata),length(output.selected_epochs),length(channel_idx),datasize_max);
output.tpdata_x=nan(length(tdata),length(output.selected_epochs),length(channel_idx),datasize_max);
for datasetpos=1:length(tdata);
    output.tpdata_y(datasetpos,:,:,1:size(tdata(datasetpos).data,6))=squeeze(tdata(datasetpos).data(:,:,1,1,1,:));
    %header
    header=datasets_header(output.selected_datasets(datasetpos)).header;
    %tpx
    tpx=1:1:double(header.datasize(6));
    tpx=((tpx-1)*header.xstep)+header.xstart;
    for epochpos=1:length(output.selected_epochs);
        for chanpos=1:length(channel_idx);
            output.tpdata_x(datasetpos,epochpos,chanpos,1:size(tdata(datasetpos).data,6))=tpx;
        end;
    end;
end;




%***************************
function fetch_data(handles)
%fetch and permute data and labels
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
        channel_idx(i)=a(1);
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
    tpx=1:1:double(header.datasize(6));
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
%graph_row_idx,graph_col_idx,graph_wave_idx
graph_row_idx=get(handles.graph_row_popup,'Value');
graph_col_idx=get(handles.graph_col_popup,'Value');
graph_wave_idx=get(handles.graph_wave_popup,'Value');
%selected_dataset_labels
st=get(handles.dataset_listbox,'String');
output.selected_dataset_labels=st(output.selected_datasets);
%selected_epoch_labels
st=get(handles.epoch_listbox,'String');
output.selected_epoch_labels=st(output.selected_epochs);
%selected_channel_labels
st=get(handles.channel_listbox,'String');
output.selected_channel_labels=st(output.selected_channels);
%output.tpdata_labels
output.tpdata_labels=[];
for i=1:length(output.selected_datasets);
    for j=1:length(output.selected_epochs);
        for k=1:length(output.selected_channels);
            output.tpdata_labels(i,j,k).dataset_label=output.selected_dataset_labels{i};
            output.tpdata_labels(i,j,k).epoch_label=output.selected_epoch_labels{j};
            output.tpdata_labels(i,j,k).channel_label=output.selected_channel_labels{k};
        end;
    end;
end;
%permute dimensions (tpdata(rowpos,colpos,wavepos))
output.tpdata_y=permute(output.tpdata_y,[graph_row_idx,graph_col_idx,graph_wave_idx,4]);
output.tpdata_x=permute(output.tpdata_x,[graph_row_idx,graph_col_idx,graph_wave_idx,4]);
output.tpdata_labels=permute(output.tpdata_labels,[graph_row_idx,graph_col_idx,graph_wave_idx]);
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
%store xmin, xmax, ymin, ymax in userdata
userdata.data_ymin=min(output.tpdata_y(:));
userdata.data_ymax=max(output.tpdata_y(:));
userdata.data_xmin=min(output.tpdata_x(:));
userdata.data_xmax=max(output.tpdata_x(:));
%store num_rows, num_cols, num_waves, num_graphs in userdata
userdata.data_num_rows=size(output.tpdata_y,1);
userdata.data_num_cols=size(output.tpdata_y,2);
userdata.data_num_waves=size(output.tpdata_y,3);
userdata.data_num_graphs=userdata.data_num_rows*userdata.data_num_cols;
%store userdata
set(handles.graph_wave_popup,'UserData',userdata);
%store tdata
set(handles.channel_listbox,'Userdata',output);




%*****************************************
function update_graph_axis_limits(handles);
userdata=get(handles.graph_wave_popup,'UserData');
axis(userdata.axes_handle(1,1),[userdata.xmin userdata.xmax userdata.ymin userdata.ymax]);
ydir_text={'normal','reverse'};
set(userdata.axes_handle(:),'YDir',ydir_text{userdata.display_reverse_y+1});





%***********************************
function fetch_graph_axis_limits(handles)
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
if isempty(userdata);
    return;
end;
%X axis
userdata.xaxis_auto_chk=get(handles.xaxis_auto_chk,'Value');
%xlim
if userdata.xaxis_auto_chk==1;
    userdata.xmin=userdata.data_xmin;
    userdata.xmax=userdata.data_xmax;
    set(handles.xaxis_min_edit,'String',num2str(userdata.xmin));
    set(handles.xaxis_max_edit,'String',num2str(userdata.xmax));
else
    userdata.xmin=str2num(get(handles.xaxis_min_edit,'String'));
    userdata.xmax=str2num(get(handles.xaxis_max_edit,'String'));
end;
%Y axis    
userdata.yaxis_auto_chk=get(handles.yaxis_auto_chk,'Value');
%ylim
if userdata.yaxis_auto_chk==1;
    userdata.ymin=userdata.data_ymin;
    userdata.ymax=userdata.data_ymax;
    set(handles.yaxis_min_edit,'String',num2str(userdata.ymin));
    set(handles.yaxis_max_edit,'String',num2str(userdata.ymax));
else
    userdata.ymin=str2num(get(handles.yaxis_min_edit,'String'));
    userdata.ymax=str2num(get(handles.yaxis_max_edit,'String'));
end;
if userdata.ymin==userdata.ymax;
    userdata.ymin=-1;
    userdata.ymax=1;
end;
if userdata.xmin==userdata.xmax;
    userdata.xmin=0;
    userdata.xmax=1;
end;
%store userdata
set(handles.graph_wave_popup,'UserData',userdata);





%*****************************
function create_graph(handles)
%figure_handles
userdata=get(handles.graph_wave_popup,'UserData');
%output
output=get(handles.channel_listbox,'Userdata');
%num_rows,num_cols,num_waves,num_graphs
num_rows=userdata.data_num_rows;
num_cols=userdata.data_num_cols;
num_waves=userdata.data_num_waves;
num_graphs=userdata.data_num_graphs;
userdata.num_rows=num_rows;
userdata.num_cols=num_cols;
userdata.num_waves=num_waves;
userdata.num_graphs=num_graphs;
%linecolors
linecolors=distinguishable_colors(256);
userdata.linecolors=linecolors;
%figure width and height (in pixels)
userdata=calculate_axes_sizes(userdata,handles);
%create axes
k=1;
%loop through graph cols
for col_pos=1:num_cols;
    %loop through graph rows
    for row_pos=1:num_rows;
        userdata.axes_handle(row_pos,col_pos)=subplot('position',[userdata.left(col_pos) userdata.bottom(row_pos) userdata.plot_width userdata.plot_height]);
    end;
end;
%plot the data
%loop through graph cols
for col_pos=1:num_cols;
    %loop through graph rows
    for row_pos=1:num_rows;
        %loop through the waves
        hold(userdata.axes_handle(row_pos,col_pos),'on');
        for wave_pos=1:num_waves;
            switch userdata.display_waves
                case 1
                    userdata.plot_handle(row_pos,col_pos,wave_pos).handle=plot(userdata.axes_handle(row_pos,col_pos),squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)),squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)),'Color',linecolors(wave_pos,:));
                case 2
                    userdata.plot_handle(row_pos,col_pos,wave_pos).handle=stem(userdata.axes_handle(row_pos,col_pos),squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)),squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)),'Color',linecolors(wave_pos,:));
                case 3
                    userdata.plot_handle(row_pos,col_pos,wave_pos).handle=stairs(userdata.axes_handle(row_pos,col_pos),squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)),squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)),'Color',linecolors(wave_pos,:));
            end;
        end;
        %hold(userdata.axes_handle(row_pos,col_pos),'off');
        %legend
        if userdata.display_legend==1;
            for wave_pos=1:num_waves;
                legend_string{wave_pos}='';
                if userdata.display_legend_dataset==1;
                    legend_string{wave_pos}=[legend_string{wave_pos} output.tpdata_labels(row_pos,col_pos,wave_pos).dataset_label ' '];
                end;
                if userdata.display_legend_epoch==1;
                    legend_string{wave_pos}=[legend_string{wave_pos} '[' output.tpdata_labels(row_pos,col_pos,wave_pos).epoch_label '] '];
                end;
                if userdata.display_legend_channel==1;
                    legend_string{wave_pos}=[legend_string{wave_pos} '[' output.tpdata_labels(row_pos,col_pos,wave_pos).channel_label '] '];
                end;
            end;
            legend_string(find(legend_string=='_'))=' '
            legend(userdata.axes_handle(row_pos,col_pos),legend_string,'Location','NorthEast');
        end;
    end;
end;
%link axis
linkaxes(userdata.axes_handle(:),'xy');
%set axis
axis(userdata.axes_handle(1,1),[userdata.xmin userdata.xmax userdata.ymin userdata.ymax]);
ydir_text={'normal','reverse'};
set(userdata.axes_handle(1,1),'YDir',ydir_text{userdata.display_reverse_y+1});
%decoration
set(userdata.axes_handle(:),'FontName','Arial');
set(userdata.axes_handle(:),'FontUnits','pixels');
set(userdata.axes_handle(:),'FontSize',9);
set(userdata.axes_handle(:),'Box','off');
set(userdata.axes_handle(:),'TickDir','out');
set(userdata.axes_handle(:),'TickLength',[0.005 0.005]);
%ydir
if userdata.display_reverse_y==0;
    set(userdata.axes_handle(:),'YDir','normal');
else
    set(userdata.axes_handle(:),'YDir','reverse');
end;
%cursor
userdata.cursor_mode=-2;
userdata.vert_cursor_handle.handle=[];
userdata.horz_cursor_handle.handle=[];
userdata.cursor_pos=0;
%update userdata
set(handles.graph_wave_popup,'UserData',userdata);






%***************************************************
function out_userdata=calculate_axes_sizes(userdata,handles)
%num_rows, num_cols
num_rows=userdata.data_num_rows;
num_cols=userdata.data_num_cols;
%vert_margin,horz_margin
horz_margin=30;
vert_margin=20;
userdata.horz_margin=horz_margin;
userdata.vert_margin=vert_margin;
%left_offset
p=get(handles.uipanel_main,'Position');
left_offset=p(1)+p(3)+horz_margin;
%bottom_offset
p=get(handles.uipanel_cursor,'Position');
bottom_offset=p(2)+p(4)+vert_margin;
%figure width and height (in pixels)
p=get(handles.figure1,'Position');
figure_width=p(3);
figure_height=p(4);
f_width=figure_width-left_offset;
f_height=figure_height-bottom_offset;
userdata.figure_width=figure_width;
userdata.figure_height=figure_height;
userdata.f_width=f_width;
userdata.f_height=f_height;
userdata.left_offset=left_offset;
userdata.bottom_offset=bottom_offset;
%width, height
width=(f_width)/num_cols;
height=(f_height)/num_rows;
userdata.width=width;
userdata.height=height;
%plot_width, plot_height
plot_width=width-horz_margin;
plot_height=height-vert_margin;
userdata.plot_width=plot_width/figure_width;
userdata.plot_height=plot_height/figure_height;
%left, bottom
for i=1:num_cols;
    left(i)=((i-1)*width);
end;
for i=1:num_rows;
    bottom(i)=((i-1)*height);   
end;
left=(left+left_offset)/figure_width;
bottom=(bottom+bottom_offset)/figure_height;
bottom=fliplr(bottom);
userdata.left=left;
userdata.bottom=bottom;
out_userdata=userdata;






%**********************************
function update_graph_data(handles)
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
%output
output=get(handles.channel_listbox,'Userdata');
%plot the data
%loop through graph cols
for col_pos=1:userdata.data_num_cols;
    %loop through graph rows
    for row_pos=1:userdata.data_num_rows;
        for wave_pos=1:userdata.data_num_waves;
            %loop through the waves
            handle_ok=0;
            if size(userdata.plot_handle,3)>=wave_pos
                if size(userdata.plot_handle,2)>=col_pos
                    if size(userdata.plot_handle,1)>=row_pos
                        if ishandle(userdata.plot_handle(row_pos,col_pos,wave_pos).handle);
                            handle_ok=1;
                        end;
                    end;
                end;
            end;
            if handle_ok==1;
                set(userdata.plot_handle(row_pos,col_pos,wave_pos).handle,'XData',squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)));
                set(userdata.plot_handle(row_pos,col_pos,wave_pos).handle,'YData',squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)));
            else
                %hold(userdata.axes_handle(row_pos,col_pos),'on');
                switch userdata.display_waves
                    case 1
                        userdata.plot_handle(row_pos,col_pos,wave_pos).handle=plot(userdata.axes_handle(row_pos,col_pos),squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)),squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)),'Color',userdata.linecolors(wave_pos,:));
                    case 2
                        userdata.plot_handle(row_pos,col_pos,wave_pos).handle=stem(userdata.axes_handle(row_pos,col_pos),squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)),squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)),'Color',userdata.linecolors(wave_pos,:));
                    case 3
                        userdata.plot_handle(row_pos,col_pos,wave_pos).handle=stairs(userdata.axes_handle(row_pos,col_pos),squeeze(output.tpdata_x(row_pos,col_pos,wave_pos,:)),squeeze(output.tpdata_y(row_pos,col_pos,wave_pos,:)),'Color',userdata.linecolors(wave_pos,:));
                end;
            end;
        end;        
        %hold(userdata.axes_handle(row_pos,col_pos),'off');
        %delete excess waves
        if userdata.data_num_waves<userdata.num_waves
            for wave_pos=userdata.data_num_waves+1:userdata.num_waves
                delete(userdata.plot_handle(row_pos,col_pos,wave_pos).handle);
            end;
        end;
        %legend
        if userdata.display_legend==1;
            for wave_pos=1:userdata.data_num_waves;
                lstr='';
                if userdata.display_legend_dataset==1;
                    lstr=[lstr output.tpdata_labels(row_pos,col_pos,wave_pos).dataset_label ' '];
                end;
                if userdata.display_legend_epoch==1;
                    lstr=[lstr '[' output.tpdata_labels(row_pos,col_pos,wave_pos).epoch_label '] '];
                end;
                if userdata.display_legend_channel==1;
                    lstr=[lstr '[' output.tpdata_labels(row_pos,col_pos,wave_pos).channel_label '] '];
                end;
            lstr(find(lstr=='_'))=' ';
            legend_string{wave_pos}=lstr;
            end;
            if size(userdata.vert_cursor_handle,1)>=row_pos;
                if size(userdata.vert_cursor_handle,2)>=col_pos;
                    if ishandle(userdata.vert_cursor_handle(row_pos,col_pos).handle);
                        uistack(userdata.vert_cursor_handle(row_pos,col_pos).handle,'top');
                    end;
                end;
            end;
            legend(userdata.axes_handle(row_pos,col_pos),legend_string,'Location','NorthEast');
        else
            legend(userdata.axes_handle(row_pos,col_pos),'hide');
        end;
    end;
end;
%resize userdata.plot_handle
userdata.num_waves=userdata.data_num_waves;
userdata.plot_handle=userdata.plot_handle(:,:,1:userdata.num_waves);
%store userdata
set(handles.graph_wave_popup,'UserData',userdata);




%************
function update_graph_cursors(handles);
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
%VERTICAL CURSOR
%vertical cursor
for row_pos=1:userdata.num_rows;
    for col_pos=1:userdata.num_cols;
        create_handle=1;
        if row_pos<=size(userdata.vert_cursor_handle,1);
            if col_pos<=size(userdata.vert_cursor_handle,2);
                if ishandle(userdata.vert_cursor_handle(row_pos,col_pos).handle);
                    create_handle=0;
                end;
            end;
        end;
        if create_handle==0;
            set(userdata.vert_cursor_handle(row_pos,col_pos).handle,'XData',[userdata.cursor_pos userdata.cursor_pos]);
            set(userdata.vert_cursor_handle(row_pos,col_pos).handle,'YData',[userdata.datasets_ymin userdata.datasets_ymax]);
        else
            userdata.vert_cursor_handle(row_pos,col_pos).handle=plot(userdata.axes_handle(row_pos,col_pos),[userdata.cursor_pos userdata.cursor_pos],[userdata.ymin userdata.ymax],'k');
        end;
    end;
end;
%delete excess vert_handles
if size(userdata.vert_cursor_handle,1)>userdata.num_rows;
    for row_pos=userdata.num_rows+1:size(userdata.vert_cursor_handle,1);
        for col_pos=1:size(userdata.vert_cursor_handle,2);
            if ishandle(userdata.vert_cursor_handle(row_pos,col_pos).handle);
                delete(userdata.vert_cursor_handle(row_pos,col_pos).handle);
            end;
        end;
    end;
end;
if size(userdata.vert_cursor_handle,2)>userdata.num_cols;
    for row_pos=1:size(userdata.vert_cursor_handle,1);
        for col_pos=userdata.num_cols+1:size(userdata.vert_cursor_handle,2);
            if ishandle(userdata.vert_cursor_handle(row_pos,col_pos).handle);
                delete(userdata.vert_cursor_handle(row_pos,col_pos).handle);
            end;
        end;
    end;
end;
userdata.vert_cursor_handle=userdata.vert_cursor_handle(1:userdata.num_rows,1:userdata.num_cols);
%HORIZONTAL CURSORS
%check cursor_mode
if userdata.cursor_mode==-1
    %cursor_mode=-1 means that all horz cursors must be deleted
    %cursor is disabled, delete all the horz_handles
    for row_pos=1:size(userdata.horz_cursor_handle,1);
        for col_pos=1:size(userdata.horz_cursor_handle,2);
            for wave_pos=1:size(userdata.horz_cursor_handle,3);
                if ishandle(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                    delete(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                end;
            end;
        end;
    end;
    userdata.horz_cursor_handle=[];
    userdata.horz_cursor_handle.handle=[];
    %cursor is disabled and all horz_handles have been deleted
    userdata.cursor_mode=-2;
end;
if userdata.cursor_mode>=0
    %cursor_mode=0, 1 or 2 means that horz_cursors must be displayed
    %output
    output=get(handles.channel_listbox,'Userdata');
    %horizontal cursor
    for row_pos=1:userdata.num_rows;
        for col_pos=1:userdata.num_cols;
            for wave_pos=1:userdata.num_waves;
                [a,b]=min(abs(output.tpdata_x(row_pos,col_pos,wave_pos,:)-userdata.cursor_pos));
                y=output.tpdata_y(row_pos,col_pos,wave_pos,b);
                create_handle=1;
                if row_pos<=size(userdata.horz_cursor_handle,1);
                    if col_pos<=size(userdata.horz_cursor_handle,2);
                        if wave_pos<=size(userdata.horz_cursor_handle,3);
                            if ishandle(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                                create_handle=0;
                            end;
                        end;
                    end;
                end;
                if create_handle==0;
                    set(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle,'XData',[userdata.xmin userdata.xmax]);
                    set(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle,'YData',[y y]);
                else
                    userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle=plot(userdata.axes_handle(row_pos,col_pos),[userdata.xmin userdata.xmax],[y y],'Color',userdata.linecolors(wave_pos,:));
                end;
            end;
        end;
    end;
    %delete excess horz_handles
    if size(userdata.horz_cursor_handle,1)>userdata.num_rows;
        for row_pos=userdata.num_rows+1:size(userdata.horz_cursor_handle,1);
            for col_pos=1:size(userdata.horz_cursor_handle,2);
                for wave_pos=1:size(userdata.horz_cursor_handle,3);
                    if ishandle(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                        delete(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                    end;
                end;
            end;
        end;
    end;
    if size(userdata.horz_cursor_handle,2)>userdata.num_cols;
        for row_pos=1:size(userdata.horz_cursor_handle,1);
            for col_pos=userdata.num_cols+1:size(userdata.horz_cursor_handle,2);
                for wave_pos=1:size(userdata.horz_cursor_handle,3);
                    if ishandle(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                        delete(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                    end;
                end;
            end;
        end;
    end;
    if size(userdata.horz_cursor_handle,3)>userdata.num_waves;
        for row_pos=1:size(userdata.horz_cursor_handle,1);
            for col_pos=1:size(userdata.horz_cursor_handle,2);
                for wave_pos=userdata.num_waves+1:size(userdata.horz_cursor_handle,3);
                    if ishandle(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                        delete(userdata.horz_cursor_handle(row_pos,col_pos,wave_pos).handle);
                    end;
                end;
            end;
        end;
    end;
    userdata.horz_cursor_handle=userdata.horz_cursor_handle(1:userdata.num_rows,1:userdata.num_cols,1:userdata.num_waves);
end;
set(handles.graph_wave_popup,'UserData',userdata);






%*********************************
function update_graph_axes(handles)
%userdata
userdata=get(handles.graph_wave_popup,'UserData');
if isempty(userdata);
    return;
end;
%check if num_rows/num_cols is the same from data_num_rows/data_num_cols
if and(userdata.num_rows==userdata.data_num_rows,userdata.num_cols==userdata.data_num_cols);
    %set axis
    axis(userdata.axes_handle(1,1),[userdata.xmin userdata.xmax userdata.ymin userdata.ymax]);
    return;
end;
%axes set sizes
userdata=calculate_axes_sizes(userdata,handles);
%loop through rows
for row_pos=1:userdata.data_num_rows;
    %loop through cols
    for col_pos=1:userdata.data_num_cols;
        if or(col_pos>userdata.num_cols,row_pos>userdata.num_rows)
            %if the handle does not exist, create it
            userdata.axes_handle(row_pos,col_pos)=subplot('position',[userdata.left(col_pos) userdata.bottom(row_pos) userdata.plot_width userdata.plot_height]);
            hold(userdata.axes_handle(row_pos,col_pos),'on');
            %decoration
            set(userdata.axes_handle(row_pos,col_pos),'FontName','Arial');
            set(userdata.axes_handle(row_pos,col_pos),'FontUnits','pixels');
            set(userdata.axes_handle(row_pos,col_pos),'FontSize',9);
            set(userdata.axes_handle(row_pos,col_pos),'Box','off');
            set(userdata.axes_handle(row_pos,col_pos),'TickDir','out');
            set(userdata.axes_handle(row_pos,col_pos),'TickLength',[0.005 0.005]);

        else            
            %if the handle exists
            set(userdata.axes_handle(row_pos,col_pos),'Position',[userdata.left(col_pos) userdata.bottom(row_pos) userdata.plot_width userdata.plot_height]);
        end;
    end;
end;
%delete excess handles
if userdata.num_cols>userdata.data_num_cols;
    for col_pos=userdata.data_num_cols+1:userdata.num_cols;
        for row_pos=1:userdata.num_rows;
            if ishandle(userdata.axes_handle(row_pos,col_pos))
                delete(userdata.axes_handle(row_pos,col_pos));
            end;
        end;
    end;
end;
if userdata.num_rows>userdata.data_num_rows;
    for row_pos=userdata.data_num_rows+1:userdata.num_rows;
        for col_pos=1:userdata.num_cols;
            if ishandle(userdata.axes_handle(row_pos,col_pos))
                delete(userdata.axes_handle(row_pos,col_pos));
            end;
        end;
    end;
end;
userdata.num_cols=userdata.data_num_cols;
userdata.num_rows=userdata.data_num_rows;
userdata.axes_handle=userdata.axes_handle(1:userdata.num_rows,1:userdata.num_cols);
%link axis
linkaxes(userdata.axes_handle(:),'xy');
%set axis
axis(userdata.axes_handle(1,1),[userdata.xmin userdata.xmax userdata.ymin userdata.ymax]);
%ydir
ydir_text={'normal','reverse'};
set(userdata.axes_handle(:),'YDir',ydir_text{userdata.display_reverse_y+1});
%store userdata
set(handles.graph_wave_popup,'UserData',userdata);



















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











% --- Outputs from this function are returned to the command line.
function varargout = CGLW_multi_viewer_OutputFcn(hObject, eventdata, handles) 
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
datasets_header=get(handles.dataset_listbox,'UserData');
inputfiles=get(handles.xaxis_auto_chk,'UserData');
for i=1:length(datasets_header);
    header=datasets_header(i).header;
    header.display_settings.xaxis_min_edit=get(handles.xaxis_min_edit,'String');
    header.display_settings.yaxis_min_edit=get(handles.yaxis_min_edit,'String');
    header.display_settings.xaxis_max_edit=get(handles.xaxis_max_edit,'String');
    header.display_settings.yaxis_max_edit=get(handles.yaxis_max_edit,'String');
    header.display_settings.xaxis_auto_chk=get(handles.xaxis_auto_chk,'Value');
    header.display_settings.yaxis_auto_chk=get(handles.yaxis_auto_chk,'Value');
    header.display_settings.menu_reverse_yaxis=get(handles.menu_reverse_yaxis,'Checked');
    [p,n,e]=fileparts(inputfiles{i});
    CLW_save_header(p,header)
end;
delete(hObject);


% --- Executes on selection change in dataset_listbox.
function dataset_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_data(handles);
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);





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
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);




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
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);





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
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);



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
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);




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
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);



% --- Executes on button press in xaxis_auto_chk.
function xaxis_auto_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_auto_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);



% --- Executes on selection change in graph_row_popup.
function graph_row_popup_Callback(hObject, eventdata, handles)
% hObject    handle to graph_row_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graph_row_popup,'Value');
sel2=get(handles.graph_col_popup,'Value');
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
set(handles.graph_row_popup,'Value',sel1);
set(handles.graph_col_popup,'Value',sel2);
set(handles.graph_wave_popup,'Value',sel3);
fetch_data(handles);
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);







% --- Executes during object creation, after setting all properties.
function graph_row_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph_row_popup (see GCBO)
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
sel1=get(handles.graph_row_popup,'Value');
sel2=get(handles.graph_col_popup,'Value');
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
set(handles.graph_row_popup,'Value',sel1);
set(handles.graph_col_popup,'Value',sel2);
set(handles.graph_wave_popup,'Value',sel3);
fetch_data(handles);
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);





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
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);



% --- Executes during object creation, after setting all properties.
function index_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in graph_col_popup.
function graph_col_popup_Callback(hObject, eventdata, handles)
% hObject    handle to graph_col_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sel1=get(handles.graph_row_popup,'Value');
sel2=get(handles.graph_col_popup,'Value');
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
set(handles.graph_row_popup,'Value',sel1);
set(handles.graph_col_popup,'Value',sel2);
set(handles.graph_wave_popup,'Value',sel3);
fetch_data(handles);
fetch_graph_axis_limits(handles);
update_graph_axes(handles);
update_graph_data(handles);
update_graph_cursors(handles);








% --- Executes during object creation, after setting all properties.
function graph_col_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to graph_col_popup (see GCBO)
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
output=fetch_data_for_tables(handles);
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
%epoch_labels
st=get(handles.epoch_listbox,'String');
epoch_labels=st(output.selected_epochs);
%loop through datasets
k=1;
%reset table_data
table_data={};
for datasetpos=1:length(output.selected_datasets);
    %header
    header=output.selected_datasets_header(datasetpos).header;
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
    %loop through epochs
    for epochpos=1:length(output.selected_epochs);
        %loop through channels
        for chanpos=1:length(output.selected_channels);
            %max
            [ymax,dx]=max(squeeze(output.tpdata_y(datasetpos,epochpos,chanpos,dx1:dx2)));
            xmax=output.tpdata_x(datasetpos,epochpos,chanpos,(dx-1)+dx1);
            %min
            [ymin,dx]=min(squeeze(output.tpdata_y(datasetpos,epochpos,chanpos,dx1:dx2)));
            xmin=output.tpdata_x(datasetpos,epochpos,chanpos,(dx-1)+dx1);
            %mean
            xmean=mean(squeeze(output.tpdata_y(datasetpos,epochpos,chanpos,dx1:dx2)));
            %x1,y1
            y1=output.tpdata_y(datasetpos,epochpos,chanpos,dx1);
            %x2,y2
            y2=output.tpdata_y(datasetpos,epochpos,chanpos,dx2);
            %table_data
            table_data{k,1}=output.selected_datasets_labels{datasetpos};
            table_data{k,2}=output.selected_channels_string{chanpos};
            table_data{k,3}=epoch_labels{epochpos};
            table_data{k,4}=num2str(xmax);
            table_data{k,5}=num2str(ymax);
            table_data{k,6}=num2str(xmin);
            table_data{k,7}=num2str(ymin);
            table_data{k,8}=num2str(xmean);
            table_data{k,9}=num2str(x1);
            table_data{k,10}=num2str(y1);
            table_data{k,11}=num2str(x2);
            table_data{k,12}=num2str(y2);
            k=k+1;
        end;
    end;
end;
col_headers{1}='dataset';
col_headers{2}='channel';
col_headers{3}='epoch';
col_headers{4}='xmax';
col_headers{5}='ymax';
col_headers{6}='xmin';
col_headers{7}='ymin';
col_headers{8}='ymean';
col_headers{9}='x1';
col_headers{10}='y1';
col_headers{11}='x2';
col_headers{12}='y2';
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
output=fetch_data_for_tables(handles);
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
    header=output.selected_datasets_header(datasetpos).header;
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
                tpdata=output.tpdata_y(datasetpos,epochpos,:,dx1:dx2);
                tpdata=squeeze(mean(tpdata,3));
                [y,dx]=max(tpdata);
                x=output.tpdata_x(datasetpos,epochpos,1,(dx-1)+dx1);
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,(dx-1)+dx1));
            case 2
                %mean of selected_channels
                tpdata=output.tpdata_y(datasetpos,epochpos,:,dx1:dx2);
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
output=fetch_data_for_tables(handles);
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
    %splinefile
    st='LW_headmodel_compute';
    for i=1:length(header.history);
        if strcmpi(st,header.history(i).configuration.gui_info.function_name);
            splinefile=header.history(i).configuration.parameters.spl_filename;
        end;
    end;
    if isempty(splinefile);
        return;
    end;
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
                tpdata=output.tpdata_y(datasetpos,epochpos,:,dx1:dx2);
                tpdata=squeeze(mean(tpdata,3));
                [y,dx]=max(tpdata);
                x=output.tpdata_x(datasetpos,epochpos,1,(dx-1)+dx1);
                vector=squeeze(datasets_data(output.selected_datasets(datasetpos)).data(output.selected_epochs(epochpos),:,indexpos,dz,dy,(dx-1)+dx1));
            case 2
                %mean of selected_channels
                tpdata=output.tpdata_y(datasetpos,epochpos,:,dx1:dx2);
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
       headplot(vector2,splinefile,'maplimits',[cmin cmax]);
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
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);




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
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);




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
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);





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
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);







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
userdata=get(handles.graph_wave_popup,'UserData');
switch userdata.cursor_mode
    case 0
        set(handles.x_text1,'String',num2str(userdata.cursor_pos));
        set(handles.interval1_edit,'String',num2str(userdata.cursor_pos));
        set(handles.x_text2,'String',num2str(userdata.cursor_pos));
        set(handles.interval2_edit,'String',num2str(userdata.cursor_pos));
    case 1
        set(handles.x_text1,'String',num2str(userdata.cursor_pos));
        set(handles.interval1_edit,'String',num2str(userdata.cursor_pos));
    case 2
        set(handles.x_text2,'String',num2str(userdata.cursor_pos));
        set(handles.interval2_edit,'String',num2str(userdata.cursor_pos));
    case -1
        set(handles.x_text1,'String',num2str(userdata.cursor_pos));
        set(handles.interval1_edit,'String',num2str(userdata.cursor_pos));
    case -2
        set(handles.x_text1,'String',num2str(userdata.cursor_pos));
        set(handles.interval1_edit,'String',num2str(userdata.cursor_pos));
end;



% --------------------------------------------------------------------
function menu_waveforms_Callback(hObject, eventdata, handles)
% hObject    handle to menu_waveforms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_axes_Callback(hObject, eventdata, handles)
% hObject    handle to menu_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_legend_Callback(hObject, eventdata, handles)
% hObject    handle to menu_legend (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --------------------------------------------------------------------
function menu_default_Callback(hObject, eventdata, handles)
% hObject    handle to menu_default (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%waveforms
multiview_settings.menu_wave_plot=get(handles.menu_wave_plot,'Checked');
multiview_settings.menu_wave_stem=get(handles.menu_wave_stem,'Checked');
multiview_settings.menu_wave_stair=get(handles.menu_wave_stair,'Checked');
multiview_settings.menu_legend_dataset=get(handles.menu_legend_dataset,'Checked');
multiview_settings.menu_legend_epoch=get(handles.menu_legend_epoch,'Checked');
multiview_settings.menu_legend_channel=get(handles.menu_legend_channel,'Checked');
multiview_settings.menu_reverse_yaxis=get(handles.menu_reverse_yaxis,'Checked');
tp=which('letswave.m');
[p,n,e]=fileparts(tp);
localtarget=[p filesep 'core_functions' filesep 'multiview_settings.mat']
save(localtarget,'multiview_settings');





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
%
fetch_graph_options(handles);
update_graph_data(handles);






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
fetch_graph_options(handles);
update_graph_data(handles);





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
fetch_graph_options(handles);
update_graph_data(handles);




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
fetch_graph_options(handles);
fetch_graph_axis_limits(handles);
update_graph_axis_limits(handles);






% --------------------------------------------------------------------
function menu_wave_plot_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_plot,'Checked','on');
set(handles.menu_wave_stem,'Checked','off');
set(handles.menu_wave_stair,'Checked','off');
clear_plots(handles);
fetch_graph_options(handles);
update_graph_data(handles);





% --------------------------------------------------------------------
function menu_wave_stem_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_stem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_plot,'Checked','off');
set(handles.menu_wave_stem,'Checked','on');
set(handles.menu_wave_stair,'Checked','off');
clear_plots(handles);
fetch_graph_options(handles);
update_graph_data(handles);





% --------------------------------------------------------------------
function menu_wave_stair_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wave_stair (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.menu_wave_plot,'Checked','off');
set(handles.menu_wave_stem,'Checked','off');
set(handles.menu_wave_stair,'Checked','on');
clear_plots(handles);
fetch_graph_options(handles);
update_graph_data(handles);





% --- Executes on button press in update_x_btn.
function update_x_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_x_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
xlimits=xlim(userdata.axes_handle(1,1,1));
set(handles.xaxis_min_edit,'String',num2str(xlimits(1)));
set(handles.xaxis_max_edit,'String',num2str(xlimits(2)));
set(handles.xaxis_auto_chk,'Value',0);







% --- Executes on button press in update_y_btn.
function update_y_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_y_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
ylimits=ylim(userdata.axes_handle(1,1,1));
set(handles.yaxis_min_edit,'String',num2str(ylimits(1)));
set(handles.yaxis_max_edit,'String',num2str(ylimits(2)));
set(handles.yaxis_auto_chk,'Value',0);






% --- Executes on mouse motion over figure - except title and menu.
%******************************************************************
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
if isempty(userdata);
    return;
end;
for col_pos=1:size(userdata.axes_handle,2);
    currentpoint=get(userdata.axes_handle(1,col_pos),'CurrentPoint');
    cp(col_pos)=currentpoint(2,1);
end;
xlim=get(userdata.axes_handle(1,1),'XLim');
xdist=abs(cp(:)-xlim(1))+abs(cp(:)-xlim(2));
[a,b]=min(xdist);
set(handles.x_text,'String',num2str(cp(b)));
userdata.cursor_pos=cp(b);
set(handles.graph_wave_popup,'UserData',userdata);
update_graph_cursors(handles);


% --- Executes on button press in cursor_btn.
%********************************************************
function cursor_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cursor_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
userdata.cursor_mode=0;
set(handles.graph_wave_popup,'UserData',userdata);
update_graph_cursors(handles);




% --- Executes on button press in cursor1_btn.
%********************************************************
function cursor1_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cursor1_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
userdata.cursor_mode=1;
userdata.cursor_pos=str2num(get(handles.x_text1,'String'));
set(handles.graph_wave_popup,'UserData',userdata);
update_graph_cursors(handles);






% --- Executes on button press in cursor2_btn.
%*********************************************************
function cursor2_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cursor2_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
userdata.cursor_mode=2;
userdata.cursor_pos=str2num(get(handles.x_text2,'String'));
set(handles.graph_wave_popup,'UserData',userdata);
update_graph_cursors(handles);


% --- Executes on button press in cursor_no_btn.
%***********************************************************
function cursor_no_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cursor_no_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
userdata.cursor_mode=-1;
set(handles.graph_wave_popup,'UserData',userdata);
update_graph_cursors(handles);






% --- Executes when figure1 is resized.
%***********************************************************
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
adjust_object_sizes(handles);







%************************************
function adjust_object_sizes(handles)
%adjust figure objects to the size of the figure
userdata=get(handles.graph_wave_popup,'UserData');
if isempty(userdata);
    return;
end;
if isfield(userdata,'num_rows')
else
    return;
end;
userdata=calculate_axes_sizes(userdata,handles);
for row_pos=1:userdata.num_rows;
    for col_pos=1:userdata.num_cols;
        set(userdata.axes_handle(row_pos,col_pos),'Position',[userdata.left(col_pos) userdata.bottom(row_pos) userdata.plot_width userdata.plot_height]);
    end;
end;
%uipanel_main
p=get(handles.uipanel_main,'Position');
fp=get(handles.figure1,'Position');
p(4)=fix(0.99*fp(4));
set(handles.uipanel_main,'Position',p);
%uipanel_cursor
p=get(handles.uipanel_cursor,'Position');
p(3)=fix(0.99*(fp(3)-p(1)));
set(handles.uipanel_cursor,'Position',p);





% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
%**************************************************************
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
userdata=get(handles.graph_wave_popup,'UserData');
switch userdata.cursor_mode
    case -1
        set(handles.x_text2,'String',num2str(userdata.cursor_pos));
        set(handles.interval2_edit,'String',num2str(userdata.cursor_pos));
    case -2
        set(handles.x_text2,'String',num2str(userdata.cursor_pos));
        set(handles.interval2_edit,'String',num2str(userdata.cursor_pos));
end;


% --- Executes on button press in zoom_btn.
function zoom_btn_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=zoom;
zoom_state=get(h,'Enable');
if strcmpi(zoom_state,'off');
    set(h,'Enable','on');
else
    set(h,'Enable','off');
end;
