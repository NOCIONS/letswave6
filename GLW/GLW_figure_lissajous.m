function varargout = GLW_figure_lissajous(varargin)
% GLW_FIGURE_LISSAJOUS MATLAB code for GLW_figure_lissajous.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_figure_lissajous_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_figure_lissajous_OutputFcn, ...
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









% --- Executes just before GLW_figure_lissajous is made visible.
function GLW_figure_lissajous_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_figure_lissajous (see VARARGIN)
% Choose default command line output for GLW_figure_lissajous
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
%datasets_x_popup
if isempty(datasets);
    return;
end;
%datasets
set(handles.datasets_x_popup,'Userdata',datasets);
%datasets_x_popup, datasets_y_popup
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.datasets_x_popup,'String',st);
set(handles.datasets_x_popup,'Value',1);
set(handles.datasets_y_popup,'String',st);
set(handles.datasets_y_popup,'Value',1);
%y_x_edit
set(handles.y_x_edit,'String',num2str(datasets(1).header.ystart));
%z_x_edit
set(handles.z_x_edit,'String',num2str(datasets(1).header.zstart));
%y_y_edit
set(handles.y_y_edit,'String',num2str(datasets(1).header.ystart));
%z_y_edit
set(handles.z_y_edit,'String',num2str(datasets(1).header.zstart));
%epoch_x_popup / channel_x_popup
update_listbox(handles);
%waves_listbox
set(handles.waves_listbox,'UserData',[]);
set(handles.waves_listbox,'String',{});
%linecolor_axes
set(handles.linecolor_axes,'Color',[1 1 1]);
line_handle=plot(handles.linecolor_axes,[-1 1],[0 0],'-','Color',[0 0 0],'Linewidth',1);
set(handles.linecolor_axes,'XLim',[-1.5 1.5]);
set(handles.linecolor_axes, 'XTickLabelMode', 'Manual');
set(handles.linecolor_axes, 'XTick', []);
set(handles.linecolor_axes, 'YTickLabelMode', 'Manual');
set(handles.linecolor_axes, 'YTick', []);
set(handles.linecolor_axes,'UserData',line_handle);
%font list
t=listfonts;
set(handles.font_popup,'String',t);
%find font in list
a=find(strcmpi(t,'Arial')==1);
if isempty(a);
else
    set(handles.font_popup,'Value',a(1));
end;
%
read_linestyle(handles);
%!!!
%END
%!!!





function update_listbox(handles);
datasets=get(handles.datasets_x_popup,'Userdata');
selected_datasets_x=get(handles.datasets_x_popup,'Value');
selected_datasets_y=get(handles.datasets_y_popup,'Value');
%
dataset_x=datasets(selected_datasets_x(1));
dataset_y=datasets(selected_datasets_y(1));
%epoch_x_popup
st={};
for i=1:dataset_x.header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_x_popup,'String',st);
v=get(handles.epoch_x_popup,'Value');
if v>length(st);
    set(handles.epoch_x_popup,'Value',1);
end;
%epoch_y_popup
st={};
for i=1:dataset_y.header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_y_popup,'String',st);
v=get(handles.epoch_y_popup,'Value');
if v>length(st);
    set(handles.epoch_y_popup,'Value',1);
end;
%index_x_popup
if dataset_x.header.datasize(3)==1;
    set(handles.index_x_popup,'Enable','off');
else
    set(handles.index_x_popup,'Enable','on');
    if isfield(dataset_x.header.index_labels);
        st=dataset_x.header.index_labels;
    else
        st={};
        for i=1:dataset_x.header.datasize(3);
            st=num2str(i);
        end;
    end;
    set(handles.index_x_popup,'String',st);
    v=get(handles.index_x_popup,'Value');
    if v>length(st);
        set(handles.index_x_popup,'Value',1);
    end;
end;
%index_y_popup
if dataset_y.header.datasize(3)==1;
    set(handles.index_y_popup,'Enable','off');
else
    set(handles.index_y_popup,'Enable','on');
    if isfield(dataset_y.header.index_labels);
        st=dataset_y.header.index_labels;
    else
        st={};
        for i=1:dataset_y.header.datasize(3);
            st=num2str(i);
        end;
    end;
    set(handles.index_y_popup,'String',st);
    v=get(handles.index_y_popup,'Value');
    if v>length(st);
        set(handles.index_y_popup,'Value',1);
    end;
end;
%channel_x_popup
st={};
for i=1:length(dataset_x.header.chanlocs);
    st{i}=dataset_x.header.chanlocs(i).labels;
end;
set(handles.channel_x_popup,'String',st);
v=get(handles.channel_x_popup,'Value');
if v>length(st);
    set(handles.channel_x_popup,'Value',1);
end;
%channel_y_popup
st={};
for i=1:length(dataset_y.header.chanlocs);
    st{i}=dataset_y.header.chanlocs(i).labels;
end;
set(handles.channel_y_popup,'String',st);
v=get(handles.channel_y_popup,'Value');
if v>length(st);
    set(handles.channel_y_popup,'Value',1);
end;
%z_x_edit
if dataset_x.header.datasize(4)==1;
    set(handles.z_x_edit,'Enable','off');
else
    set(handles.z_x_edit,'Enable','on');
end;
%z_y_edit
if dataset_y.header.datasize(4)==1;
    set(handles.z_y_edit,'Enable','off');
else
    set(handles.z_y_edit,'Enable','on');
end;
%y_x_edit
if dataset_x.header.datasize(5)==1;
    set(handles.y_x_edit,'Enable','off');
else
    set(handles.y_x_edit,'Enable','on');
end;
%y_y_edit
if dataset_y.header.datasize(5)==1;
    set(handles.y_y_edit,'Enable','off');
else
    set(handles.y_y_edit,'Enable','on');
end;







function update_waves_listbox(handles);
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
%datasets
datasets=get(handles.datasets_x_popup,'Userdata');
%datasetstring
datasetstring=get(handles.datasets_x_popup,'String');
%build string
st={};
if isempty(wavedata);
else
    for i=1:length(wavedata);
        datasetpos_x=wavedata(i).datasetpos_x;
        datasetpos_y=wavedata(i).datasetpos_y;
        header_x=datasets(datasetpos_x).header;
        header_y=datasets(datasetpos_y).header;
        st{i}=[num2str(wavedata(i).row) ':' num2str(wavedata(i).col) ' X:' datasetstring{datasetpos_x} ' E:' num2str(wavedata(i).epochpos_x) ' C:' header_x.chanlocs(wavedata(i).channelpos_x).labels ' I:' num2str(wavedata(i).indexpos_x) ' Y:' datasetstring{datasetpos_y} ' E:' num2str(wavedata(i).epochpos_y) ' C:' header_y.chanlocs(wavedata(i).channelpos_y).labels ' I:' num2str(wavedata(i).indexpos_y)];
    end;
end;
set(handles.waves_listbox,'String',st);







function read_linestyle(handles);
line_handle=get(handles.linecolor_axes,'UserData');
%color
C=get(line_handle,'Color');
set(handles.linecolor_btn,'UserData',C);
%width
W=get(line_handle,'LineWidth');
set(handles.linewidth_popup,'Value',W);
%linestyle
st={'-';':';'-.';'--'};
W=get(line_handle,'LineStyle');
set(handles.linestyle_popup,'Value',find(strcmpi(W,st)));





function write_linestyle(handles);
line_handle=get(handles.linecolor_axes,'UserData');
%color
C=get(handles.linecolor_btn,'UserData');
set(line_handle,'Color',C);
%width
W=get(handles.linewidth_popup,'Value');
set(line_handle,'LineWidth',W);
%style
st={'-';':';'-.';'--'};
W=st{get(handles.linestyle_popup,'Value')};
set(line_handle,'LineStyle',W);




% --- Outputs from this function are returned to the command line.
function varargout = GLW_figure_lissajous_OutputFcn(hObject, eventdata, handles) 
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
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
%check wavedata is not empty
if isempty(wavedata);
    return;
end;
%datasets
datasets=get(handles.datasets_x_popup,'Userdata');
%figure
h=figure;
%num_rows,num_cols
for i=1:length(wavedata);
    row_i(i)=wavedata(i).row;
    col_i(i)=wavedata(i).col;
end;
num_rows=max(row_i);
num_cols=max(col_i);
%prepare legends
for i=1:num_rows*num_cols;
    legend_string(i).st={};
end;
%wave_string
wave_string=get(handles.waves_listbox,'String');
%plot
hold on;
for wavepos=1:length(wavedata);
    header_x=datasets(wavedata(wavepos).datasetpos_x).header;
    header_y=datasets(wavedata(wavepos).datasetpos_y).header;
    epochpos_x=wavedata(wavepos).epochpos_x;
    epochpos_y=wavedata(wavepos).epochpos_y;
    channelpos_x=wavedata(wavepos).channelpos_x;
    channelpos_y=wavedata(wavepos).channelpos_y;
    %indexpos
    if header_x.datasize(3)==1;
        indexpos_x=1;
    else
        indexpos_x=wavedata(wavepos).indexpos_x;
    end;
    if header_y.datasize(3)==1;
        indexpos_y=1;
    else
        indexpos_y=wavedata(wavepos).indexpos_y;
    end;
    %dy
    if header_x.datasize(5)==1;
        dy_x=1;
    else
        y=wavedata(wavepos).y_x;
        dy_x=((y-header_x.ystart)/header_x.ystep)+1;
    end;
    if header_y.datasize(5)==1;
        dy_y=1;
    else
        y=wavedata(wavepos).y_y;
        dy_y=((y-header_y.ystart)/header_y.ystep)+1;
    end;
    %dz
    if header_x.datasize(4)==1;
        dz_x=1;
    else
        z=wavedata(wavepos).z_x;
        dz_x=((z-header_x.zstart)/header_x.zstep)+1;
    end;
    if header_y.datasize(4)==1;
        dz_y=1;
    else
        z=wavedata(wavepos).z_y;
        dz_y=((z-header_y.zstart)/header_y.zstep)+1;
    end;
    %tpx
    tpx_x=1:1:header_x.datasize(6);
    tpx_x=((tpx_x-1)*header_x.xstep)+header_x.xstart;
    tpx_y=1:1:header_y.datasize(6);
    tpx_y=((tpx_y-1)*header_y.xstep)+header_y.xstart;
    %tpy
    tpy_x=squeeze(datasets(wavedata(wavepos).datasetpos_x).data(epochpos_x,channelpos_x,indexpos_x,dz_x,dy_x,:));
    tpy_y=squeeze(datasets(wavedata(wavepos).datasetpos_y).data(epochpos_y,channelpos_y,indexpos_y,dz_y,dy_y,:));
    %crop matching latencies
    tpx_min=min([min(tpx_x) min(tpx_y)]);
    tpx_max=max([max(tpx_x) max(tpx_y)]);
    [a1,b1]=min(abs(tpx_x-tpx_min));
    [a2,b2]=min(abs(tpx_x-tpx_max));
    tpx_x=tpx_x(b1:b2);
    tpy_x=tpy_x(b1:b2);
    [a1,b1]=min(abs(tpx_y-tpx_min));
    [a2,b2]=min(abs(tpx_y-tpx_max));
    tpx_y=tpx_y(b1:b2);
    tpy_y=tpy_y(b1:b2);
    %merge
    tpx=[tpx_x tpx_y];
    tpx=unique(tpx);
    tpy_x=interp1(tpx_x,tpy_x,tpx);
    tpy_y=interp1(tpx_y,tpy_y,tpx);
    %subplot
    p=((wavedata(wavepos).row-1)*num_cols)+wavedata(wavepos).col;
    ax=subplot(num_rows,num_cols,p);
    hold(ax,'on');
    %legend_string
    legend_string(p).st{end+1}=wave_string{wavepos};
    %plot
    plot(tpy_x,tpy_y,'Color',wavedata(wavepos).color,'LineWidth',wavedata(wavepos).linewidth,'LineStyle',wavedata(wavepos).linestyle);
    hold(ax,'off');
end;
set(h,'Color',get(handles.linecolor_axes,'Color'));
for i=1:num_rows*num_cols;
    ax=subplot(num_rows,num_cols,i);  
    bax(i)=ax;
    %background color
    set(ax,'Color',get(handles.linecolor_axes,'Color'));
    %XLim
    if get(handles.xlim_chk,'Value')==1;
        xlim1=str2num(get(handles.xlim1_edit,'String'));
        xlim2=str2num(get(handles.xlim2_edit,'String'));
        set(ax,'XLim',[xlim1 xlim2]);
    end;
    xlim=get(ax,'XLim');
    set(handles.xlim1_edit,'String',num2str(xlim(1)));
    set(handles.xlim2_edit,'String',num2str(xlim(2)));
    %YLim
    if get(handles.ylim_chk,'Value')==1;
        ylim1=str2num(get(handles.ylim1_edit,'String'));
        ylim2=str2num(get(handles.ylim2_edit,'String'));
        set(ax,'YLim',[ylim1 ylim2]);
    end;
    ylim=get(ax,'YLim');
    set(handles.ylim1_edit,'String',num2str(ylim(1)));
    set(handles.ylim2_edit,'String',num2str(ylim(2)));
    %XInterval
    if get(handles.xtick_interval_chk,'Value')==1;
        interval=str2num(get(handles.xtick_interval_edit,'String'));
        anchor=str2num(get(handles.xanchor_edit,'String'));
        xtickinterval(interval,anchor);
    end;
    xtick=get(ax,'XTick');
    set(handles.xtick_interval_edit,'String',num2str(xtick(2)-xtick(1)));
    set(handles.xanchor_edit,'String',num2str(xtick(1)));
    %YInterval
    if get(handles.ytick_interval_chk,'Value')==1;
        interval=str2num(get(handles.ytick_interval_edit,'String'));
        anchor=str2num(get(handles.yanchor_edit,'String'));
        ytickinterval(interval,anchor);
    end;
    ytick=get(ax,'YTick');
    set(handles.ytick_interval_edit,'String',num2str(ytick(2)-ytick(1)));
    set(handles.yanchor_edit,'String',num2str(ytick(1)));
    %YDir
    if get(handles.ydir_chk,'Value')==1;
        set(ax,'YDir','reverse');
    else
        set(ax,'YDir','normal');
    end;
    hold off;
    %font
    st=get(handles.font_popup,'String');
    font_name=st{get(handles.font_popup,'Value')};
    set(ax,'FontName',font_name);
    set(ax,'FontSize',str2num(get(handles.fontsize_edit,'String')));
    %box
    if get(handles.drawbox_chk,'Value')==1;
        set(ax,'Box','on');
    else
        set(ax,'Box','off');
    end;
    %TickDir
    st=get(handles.tickdir_popup,'String');
    tickdir=st{get(handles.tickdir_popup,'Value')};
    set(ax,'TickDir',tickdir);
    %TickLength
    ticklength=get(ax,'TickLength');
    ticklength(1)=str2num(get(handles.ticklength_edit,'String'));
    set(ax,'TickLength',ticklength);
    %XGrid
    if get(handles.xgridline_chk,'Value')==1;
        set(ax,'XGrid','on');
    else
        set(ax,'XGrid','off');
    end;
    %YGrid
    if get(handles.ygridline_chk,'Value')==1;
        set(ax,'YGrid','on');
    else
        set(ax,'YGrid','off');
    end;
    %hide x-axis?
    if get(handles.hide_xaxis_chk,'Value')==1;
        set(ax,'XTickLabelMode','Manual');
        set(ax,'XTick',[]);
        set(ax,'XColor',get(handles.linecolor_axes,'Color'))
    end;
    %hide y-axis?
    if get(handles.hide_yaxis_chk,'Value')==1;
        set(ax,'YTickLabelMode','Manual');
        set(ax,'YTick',[]);
        set(ax,'YColor',get(handles.linecolor_axes,'Color'))
    end;
    %invisible axis?
    if get(handles.invisible_axis_chk,'Value')==1;
        set(ax,'Visible','off');
    end;
    %xaxis label?
    if get(handles.xaxis_label_chk,'Value')==1;
        xlabel(ax,get(handles.xaxis_label_edit,'String'));
    end;
    %yaxis label?
    if get(handles.yaxis_label_chk,'Value')==1;
        ylabel(ax,get(handles.yaxis_label_edit,'String'));
    end;
    %legend
    if get(handles.drawlegend_chk,'Value')==1;
        if get(handles.legendpos_popup,'Value')==1;
            legend(ax,legend_string(i).st,'Location','Best');
        else
            legend(ax,legend_string(i).st,'Location','SouthOutside');
        end;
    end;
end;
%adjust axis limits
if get(handles.match_axis_chk,'Value')==1;
    for i=1:length(bax);
        laxis(i,:)=axis(bax(i));
    end;
    for i=1:length(bax);
        axis(bax(i),[min(laxis(:,1)) max(laxis(:,2)) min(laxis(:,3)) max(laxis(:,4))]);
    end;
end;













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
delete(hObject);


% --- Executes on selection change in datasets_x_popup.
function datasets_x_popup_Callback(hObject, eventdata, handles)
% hObject    handle to datasets_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_listbox(handles);



% --- Executes during object creation, after setting all properties.
function datasets_x_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datasets_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in epoch_x_popup.
function epoch_x_popup_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function epoch_x_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function z_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function y_x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in index_x_popup.
function index_x_popup_Callback(hObject, eventdata, handles)
% hObject    handle to index_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function index_x_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_x_popup (see GCBO)
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
%datasets
datasets=get(handles.datasets_x_popup,'Userdata');
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
%wavepos
wavepos=length(wavedata)+1;
%datasetpos,epochpos,channelpos
wavedata(wavepos).datasetpos_x=get(handles.datasets_x_popup,'Value');
wavedata(wavepos).epochpos_x=get(handles.epoch_x_popup,'Value');
wavedata(wavepos).channelpos_x=get(handles.channel_x_popup,'Value');
wavedata(wavepos).datasetpos_y=get(handles.datasets_y_popup,'Value');
wavedata(wavepos).epochpos_y=get(handles.epoch_y_popup,'Value');
wavedata(wavepos).channelpos_y=get(handles.channel_y_popup,'Value');
%dataset
dataset_x=datasets(wavedata(wavepos).datasetpos_x);
dataset_y=datasets(wavedata(wavepos).datasetpos_y);
%indexpos
if dataset_x.header.datasize(3)==1;
    wavedata(wavepos).indexpos_x=1;
else
    wavedata(wavepos).indexpos_x=get(handles.index_x_popup,'Value');
end;
if dataset_y.header.datasize(3)==1;
    wavedata(wavepos).indexpos_y=1;
else
    wavedata(wavepos).indexpos_y=get(handles.index_y_popup,'Value');
end;
%z
if dataset_x.header.datasize(4)==1;
    wavedata(wavepos).z_x=1;
else
    wavedata(wavepos).z_x=str2num(get(handles.z_x_edit,'String'));
end;
if dataset_y.header.datasize(4)==1;
    wavedata(wavepos).z_y=1;
else
    wavedata(wavepos).z_y=str2num(get(handles.z_y_edit,'String'));
end;
%y
if dataset_x.header.datasize(5)==1;
    wavedata(wavepos).y_x=1;
else
    wavedata(wavepos).y_x=str2num(get(handles.y_x_edit,'String'));
end;
if dataset_y.header.datasize(5)==1;
    wavedata(wavepos).y_y=1;
else
    wavedata(wavepos).y_y=str2num(get(handles.y_y_edit,'String'));
end;
%style
line_handle=get(handles.linecolor_axes,'UserData');
wavedata(wavepos).color=get(line_handle,'Color');
wavedata(wavepos).linewidth=get(line_handle,'LineWidth');
wavedata(wavepos).linestyle=get(line_handle,'LineStyle');
%row,col
wavedata(wavepos).row=str2num(get(handles.row_edit,'String'));
wavedata(wavepos).col=str2num(get(handles.column_edit,'String'));
%
set(handles.waves_listbox,'UserData',wavedata);
set(handles.waves_listbox,'Value',length(wavedata));
%
update_waves_listbox(handles);











% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.waves_listbox,'UserData',[]);
set(handles.waves_listbox,'Value',[]);
update_waves_listbox(handles);







% --- Executes on selection change in channel_x_popup.
function channel_x_popup_Callback(hObject, eventdata, handles)
% hObject    handle to channel_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function channel_x_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_x_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
wavepos=get(handles.waves_listbox,'Value');
if isempty(wavedata)
else
    wavedata(wavepos)=[];
    set(handles.waves_listbox,'UserData',wavedata);
    wavepos2=wavepos-1;
    if wavepos2==0
        wavepos2=1;
    end;
    set(handles.waves_listbox,'Value',wavepos2);
end;
update_waves_listbox(handles);








% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
datasetpos_x=get(handles.datasets_x_popup,'Value');
epochpos_x=get(handles.epoch_x_popup,'Value');
channelpos_x=get(handles.channel_x_popup,'Value');
datasetpos_y=get(handles.datasets_y_popup,'Value');
epochpos_y=get(handles.epoch_y_popup,'Value');
channelpos_y=get(handles.channel_y_popup,'Value');
%wavepos
wavepos=get(handles.waves_listbox,'Value');
if isempty(wavepos);
else
    %wavedata
    wavedata=get(handles.waves_listbox,'UserData');
    if isempty(wavedata);
    else
        %x_axis
        wavedata(wavepos).datasetpos_x=datasetpos_x;
        wavedata(wavepos).epochpos_x=epochpos_x;
        wavedata(wavepos).channelpos_x=channelpos_x;
        wavedata(wavepos).indexpos_x=get(handles.index_x_popup,'Value');
        wavedata(wavepos).y_x=str2num(get(handles.y_x_edit,'String'));
        wavedata(wavepos).z_x=str2num(get(handles.z_x_edit,'String'));
        %y_axis
        wavedata(wavepos).datasetpos_y=datasetpos_y;
        wavedata(wavepos).epochpos_y=epochpos_y;
        wavedata(wavepos).channelpos_y=channelpos_y;
        wavedata(wavepos).indexpos_y=get(handles.index_y_popup,'Value');
        wavedata(wavepos).y_y=str2num(get(handles.y_y_edit,'String'));
        wavedata(wavepos).z_y=str2num(get(handles.z_y_edit,'String'));
        %row,col
        wavedata(wavepos).row=str2num(get(handles.row_edit,'String'));
        wavedata(wavepos).col=str2num(get(handles.column_edit,'String'));
        %style
        line_handle=get(handles.linecolor_axes,'UserData');
        wavedata(wavepos).color=get(line_handle,'Color');
        wavedata(wavepos).linewidth=get(line_handle,'LineWidth');
        wavedata(wavepos).linestyle=get(line_handle,'LineStyle');
        set(handles.waves_listbox,'UserData',wavedata);
        update_waves_listbox(handles);
    end;
end;






% --- Executes on selection change in linestyle_popup.
function linestyle_popup_Callback(hObject, eventdata, handles)
% hObject    handle to linestyle_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
write_linestyle(handles);







% --- Executes during object creation, after setting all properties.
function linestyle_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linestyle_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on selection change in linewidth_popup.
function linewidth_popup_Callback(hObject, eventdata, handles)
% hObject    handle to linewidth_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
write_linestyle(handles);






% --- Executes during object creation, after setting all properties.
function linewidth_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to linewidth_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in linecolor_btn.
function linecolor_btn_Callback(hObject, eventdata, handles)
% hObject    handle to linecolor_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
C=get(handles.linecolor_btn,'UserData');
C=uisetcolor(C);
set(handles.linecolor_btn,'UserData',C);
write_linestyle(handles);








% --- Executes on button press in xtick_interval_chk.
function xtick_interval_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xtick_interval_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xtick_interval_chk





function xanchor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xanchor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function xanchor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xanchor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in drawbox_chk.
function drawbox_chk_Callback(hObject, eventdata, handles)
% hObject    handle to drawbox_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in font_popup.
function font_popup_Callback(hObject, eventdata, handles)
% hObject    handle to font_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function font_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to font_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fontsize_edit_Callback(hObject, eventdata, handles)
% hObject    handle to fontsize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function fontsize_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fontsize_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ticklength_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ticklength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ticklength_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ticklength_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tickdir_popup.
function tickdir_popup_Callback(hObject, eventdata, handles)
% hObject    handle to tickdir_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function tickdir_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tickdir_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vertical_spread_edit_Callback(hObject, eventdata, handles)
% hObject    handle to vertical_spread_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function vertical_spread_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vertical_spread_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xlim_chk.
function xlim_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xlim_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function xlim1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xlim1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function xlim1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlim1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xlim2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xlim2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function xlim2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlim2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xtick_interval_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xtick_interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function xtick_interval_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xtick_interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ylim_chk.
function ylim_chk_Callback(hObject, eventdata, handles)
% hObject    handle to ylim_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function ylim1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ylim1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ylim1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ylim1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ylim2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ylim2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ylim2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ylim2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ytick_interval_chk.
function ytick_interval_chk_Callback(hObject, eventdata, handles)
% hObject    handle to ytick_interval_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function ytick_interval_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ytick_interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function ytick_interval_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ytick_interval_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yanchor_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yanchor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function yanchor_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yanchor_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ydir_chk.
function ydir_chk_Callback(hObject, eventdata, handles)
% hObject    handle to ydir_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in ygridline_chk.
function ygridline_chk_Callback(hObject, eventdata, handles)
% hObject    handle to ygridline_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in hide_yaxis_chk.
function hide_yaxis_chk_Callback(hObject, eventdata, handles)
% hObject    handle to hide_yaxis_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in xgridline_chk.
function xgridline_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xgridline_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in hide_xaxis_chk.
function hide_xaxis_chk_Callback(hObject, eventdata, handles)
% hObject    handle to hide_xaxis_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on selection change in waves_listbox.
function waves_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to waves_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
%update using current selection
selected=get(handles.waves_listbox,'Value');
if isempty(selected);
else
    %datasetpos
    set(handles.datasets_x_popup,'Value',wavedata(selected).datasetpos_x);
    set(handles.datasets_y_popup,'Value',wavedata(selected).datasetpos_y);
    %
    update_waves_listbox(handles);
    %x_axis
    set(handles.epoch_x_popup,'Value',wavedata(selected).epochpos_x);
    set(handles.channel_x_popup,'Value',wavedata(selected).channelpos_x);
    set(handles.index_x_popup,'Value',wavedata(selected).indexpos_x);
    set(handles.y_x_edit,'String',num2str(wavedata(selected).y_x));
    set(handles.z_x_edit,'String',num2str(wavedata(selected).z_x));
    %y_axis
    set(handles.epoch_y_popup,'Value',wavedata(selected).epochpos_y);
    set(handles.channel_y_popup,'Value',wavedata(selected).channelpos_y);
    set(handles.index_y_popup,'Value',wavedata(selected).indexpos_y);
    set(handles.y_y_edit,'String',num2str(wavedata(selected).y_y));
    set(handles.z_y_edit,'String',num2str(wavedata(selected).z_y));
    %row,col
    set(handles.row_edit,'String',num2str(wavedata(selected).row));
    set(handles.column_edit,'String',num2str(wavedata(selected).col)); 
    %styles
    line_handle=get(handles.linecolor_axes,'UserData');
    set(line_handle,'Color',wavedata(selected).color);
    set(line_handle,'LineWidth',wavedata(selected).linewidth);
    set(line_handle,'LineStyle',wavedata(selected).linestyle);
    read_linestyle(handles);
end;







% --- Executes during object creation, after setting all properties.
function waves_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to waves_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes on button press in invisible_axis_chk.
function invisible_axis_chk_Callback(hObject, eventdata, handles)
% hObject    handle to invisible_axis_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes on button press in cycle_colors_btn.
function cycle_colors_btn_Callback(hObject, eventdata, handles)
% hObject    handle to cycle_colors_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
%distinguishable_colors
bg=get(handles.linecolor_axes,'Color');
colors=distinguishable_colors(length(wavedata),bg);
%loop
for wavepos=1:length(wavedata);
    wavedata(wavepos).color=colors(wavepos,:);
end;
set(handles.waves_listbox,'UserData',wavedata);





% --- Executes on button press in drawlegend_chk.
function drawlegend_chk_Callback(hObject, eventdata, handles)
% hObject    handle to drawlegend_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on selection change in legendpos_popup.
function legendpos_popup_Callback(hObject, eventdata, handles)
% hObject    handle to legendpos_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes during object creation, after setting all properties.
function legendpos_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to legendpos_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yaxis_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function yaxis_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yaxis_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in yaxis_label_chk.
function yaxis_label_chk_Callback(hObject, eventdata, handles)
% hObject    handle to yaxis_label_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




function xaxis_label_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function xaxis_label_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xaxis_label_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in xaxis_label_chk.
function xaxis_label_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xaxis_label_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes on selection change in datasets_y_popup.
function datasets_y_popup_Callback(hObject, eventdata, handles)
% hObject    handle to datasets_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_listbox(handles);




% --- Executes during object creation, after setting all properties.
function datasets_y_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to datasets_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in epoch_y_popup.
function epoch_y_popup_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function epoch_y_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function z_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y_y_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function y_y_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_y_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in index_y_popup.
function index_y_popup_Callback(hObject, eventdata, handles)
% hObject    handle to index_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function index_y_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_y_popup.
function channel_y_popup_Callback(hObject, eventdata, handles)
% hObject    handle to channel_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function channel_y_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_y_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in multiple_rows_btn.
function multiple_rows_btn_Callback(hObject, eventdata, handles)
% hObject    handle to multiple_rows_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavedata=get(handles.waves_listbox,'UserData');
for i=1:length(wavedata);
    wavedata(i).row=i;
    wavedata(i).col=1;
end;
set(handles.waves_listbox,'UserData',wavedata);
update_waves_listbox(handles);






% --- Executes on button press in multiple_columns_btn.
function multiple_columns_btn_Callback(hObject, eventdata, handles)
% hObject    handle to multiple_columns_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavedata=get(handles.waves_listbox,'UserData');
for i=1:length(wavedata);
    wavedata(i).row=1;
    wavedata(i).col=i;
end;
set(handles.waves_listbox,'UserData',wavedata);
update_waves_listbox(handles);



function row_edit_Callback(hObject, eventdata, handles)
% hObject    handle to row_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function row_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to row_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function column_edit_Callback(hObject, eventdata, handles)
% hObject    handle to column_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function column_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in match_axis_chk.
function match_axis_chk_Callback(hObject, eventdata, handles)
% hObject    handle to match_axis_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in single_plot_btn.
function single_plot_btn_Callback(hObject, eventdata, handles)
% hObject    handle to single_plot_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavedata=get(handles.waves_listbox,'UserData');
for i=1:length(wavedata);
    wavedata(i).row=1;
    wavedata(i).col=1;
end;
set(handles.waves_listbox,'UserData',wavedata);
update_waves_listbox(handles);


% --- Executes on button press in xcorr_btn.
function xcorr_btn_Callback(hObject, eventdata, handles)
% hObject    handle to xcorr_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%wavedata
wavedata=get(handles.waves_listbox,'UserData');
%check wavedata is not empty
if isempty(wavedata);
    return;
end;
%datasets
datasets=get(handles.datasets_x_popup,'Userdata');
%num_rows,num_cols
for i=1:length(wavedata);
    row_i(i)=wavedata(i).row;
    col_i(i)=wavedata(i).col;
end;
num_rows=max(row_i);
num_cols=max(col_i);
%prepare legends
for i=1:num_rows*num_cols;
    legend_string(i).st={};
end;
%wave_string
wave_string=get(handles.waves_listbox,'String');
%figure
h=figure;
hold on;
%loop through wavepos
for wavepos=1:length(wavedata);
    header_x=datasets(wavedata(wavepos).datasetpos_x).header;
    header_y=datasets(wavedata(wavepos).datasetpos_y).header;
    epochpos_x=wavedata(wavepos).epochpos_x;
    epochpos_y=wavedata(wavepos).epochpos_y;
    channelpos_x=wavedata(wavepos).channelpos_x;
    channelpos_y=wavedata(wavepos).channelpos_y;
    %indexpos
    if header_x.datasize(3)==1;
        indexpos_x=1;
    else
        indexpos_x=wavedata(wavepos).indexpos_x;
    end;
    if header_y.datasize(3)==1;
        indexpos_y=1;
    else
        indexpos_y=wavedata(wavepos).indexpos_y;
    end;
    %dy
    if header_x.datasize(5)==1;
        dy_x=1;
    else
        y=wavedata(wavepos).y_x;
        dy_x=((y-header_x.ystart)/header_x.ystep)+1;
    end;
    if header_y.datasize(5)==1;
        dy_y=1;
    else
        y=wavedata(wavepos).y_y;
        dy_y=((y-header_y.ystart)/header_y.ystep)+1;
    end;
    %dz
    if header_x.datasize(4)==1;
        dz_x=1;
    else
        z=wavedata(wavepos).z_x;
        dz_x=((z-header_x.zstart)/header_x.zstep)+1;
    end;
    if header_y.datasize(4)==1;
        dz_y=1;
    else
        z=wavedata(wavepos).z_y;
        dz_y=((z-header_y.zstart)/header_y.zstep)+1;
    end;
    %tpx
    tpx_x=1:1:header_x.datasize(6);
    tpx_x=((tpx_x-1)*header_x.xstep)+header_x.xstart;
    tpx_y=1:1:header_y.datasize(6);
    tpx_y=((tpx_y-1)*header_y.xstep)+header_y.xstart;
    %tpy
    tpy_x=squeeze(datasets(wavedata(wavepos).datasetpos_x).data(epochpos_x,channelpos_x,indexpos_x,dz_x,dy_x,:));
    tpy_y=squeeze(datasets(wavedata(wavepos).datasetpos_y).data(epochpos_y,channelpos_y,indexpos_y,dz_y,dy_y,:));
    %crop matching latencies
    tpx_min=min([min(tpx_x) min(tpx_y)]);
    tpx_max=max([max(tpx_x) max(tpx_y)]);
    [a1,b1]=min(abs(tpx_x-tpx_min));
    [a2,b2]=min(abs(tpx_x-tpx_max));
    tpx_x=tpx_x(b1:b2);
    tpy_x=tpy_x(b1:b2);
    [a1,b1]=min(abs(tpx_y-tpx_min));
    [a2,b2]=min(abs(tpx_y-tpx_max));
    tpx_y=tpx_y(b1:b2);
    tpy_y=tpy_y(b1:b2);
    %merge
    tpx=[tpx_x tpx_y];
    tpx=unique(tpx);
    if header_y.ystep<header_x.xstep;
        xs=header_y.ystep;
    else
        xs=header_x.xstep;
    end;
    tpx=min(tpx):xs:max(tpx);
    %tpy
    tpy_x=interp1(tpx_x,tpy_x,tpx);
    tpy_y=interp1(tpx_y,tpy_y,tpx);
    %demean
    tpy_x=tpy_x-mean(tpy_x);
    tpy_y=tpy_y-mean(tpy_y);
    %xcorr
    [acor,alag]=xcorr(tpy_x,tpy_y,'coeff');
    alag=alag*xs;
    %table_data
    %name
    table_data{wavepos,1}=wave_string{wavepos};
    %corr at lag 0
    I=find(alag==0);
    table_data{wavepos,2}=acor(I);
    %maxcor
    [maxcor,I]=max(abs(acor));
    table_data{wavepos,3}=maxcor;
    %maxcorr
    table_data{wavepos,4}=alag(I);
    %subplot
    p=((wavedata(wavepos).row-1)*num_cols)+wavedata(wavepos).col;
    ax=subplot(num_rows,num_cols,p);
    hold(ax,'on');
    %legend_string
    legend_string(p).st{end+1}=wave_string{wavepos};
    %plot
    plot(alag,acor,'Color',wavedata(wavepos).color,'LineWidth',wavedata(wavepos).linewidth,'LineStyle',wavedata(wavepos).linestyle);
    hold(ax,'off');
end;
set(h,'Color',get(handles.linecolor_axes,'Color'));
for i=1:num_rows*num_cols;
    ax=subplot(num_rows,num_cols,i);  
    bax(i)=ax;
    %background color
    set(ax,'Color',get(handles.linecolor_axes,'Color'));
    %font
    st=get(handles.font_popup,'String');
    font_name=st{get(handles.font_popup,'Value')};
    set(ax,'FontName',font_name);
    set(ax,'FontSize',str2num(get(handles.fontsize_edit,'String')));
    %box
    if get(handles.drawbox_chk,'Value')==1;
        set(ax,'Box','on');
    else
        set(ax,'Box','off');
    end;
    %TickDir
    st=get(handles.tickdir_popup,'String');
    tickdir=st{get(handles.tickdir_popup,'Value')};
    set(ax,'TickDir',tickdir);
    %TickLength
    ticklength=get(ax,'TickLength');
    ticklength(1)=str2num(get(handles.ticklength_edit,'String'));
    set(ax,'TickLength',ticklength);
    %XGrid
    if get(handles.xgridline_chk,'Value')==1;
        set(ax,'XGrid','on');
    else
        set(ax,'XGrid','off');
    end;
    %YGrid
    if get(handles.ygridline_chk,'Value')==1;
        set(ax,'YGrid','on');
    else
        set(ax,'YGrid','off');
    end;
    %legend
    if get(handles.drawlegend_chk,'Value')==1;
        if get(handles.legendpos_popup,'Value')==1;
            legend(ax,legend_string(i).st,'Location','Best');
        else
            legend(ax,legend_string(i).st,'Location','SouthOutside');
        end;
    end;
end;
%table
h2=figure;
col_headers{1}='name';
col_headers{2}='correlation at lag 0';
col_headers{3}='max correlation';
col_headers{4}='lag at max correlation';
uitable(h2,'Data',table_data,'ColumnName',col_headers,'Units','normalized','Position', [0 0 1 1]);
    
    
