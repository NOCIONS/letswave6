function varargout = GLW_explore_ROI(varargin)
% GLW_EXPLORE_ROI MATLAB code for GLW_explore_ROI.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_explore_ROI_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_explore_ROI_OutputFcn, ...
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









% --- Executes just before GLW_explore_ROI is made visible.
function GLW_explore_ROI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_explore_ROI (see VARARGIN)
% Choose default command line output for GLW_explore_ROI
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
%bargraph_type_popup
colheaders={'mean','std','median','perc25','perc75','min','min_X','min_Y','min_Z','max','max_X','max_Y','max_Z','top%','top%_X','top%_Y','top%_Z','bottom%','bottom%_X','bottom%_Y','bottom%_Z'};
set(handles.bargraph_type_popup,'String',colheaders);
%datasets
if isempty(datasets);
    return;
end;
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_listbox,'Userdata',datasets);
set(handles.dataset_listbox,'String',st);
set(handles.dataset_listbox,'Value',1);
%index
set(handles.index_popup,'Value',1);
if datasets(1).header.datasize(3)==1;
    set(handles.index_popup,'String','1');
else
    if isfield(datasets(1).header.index_labels);
        set(handles.index_popup,'String',datasets(1).header.index_labels);
    else
        for i=1:length(datasets(1).header.datasize(3));
            set(handles.index_popup,'String',num2str(i));
        end;
    end;
end;
%update
update_boxes(handles);
update_dimboxes(handles);
update_ROI_binpos(handles);
%!!!
%END
%!!!





function update_dimboxes(handles);
if get(handles.xdim_chk,'Value')==1;
    set(handles.xpanel,'Visible','on');
else
    set(handles.xpanel,'Visible','off');
end;
if get(handles.ydim_chk,'Value')==1;
    set(handles.ypanel,'Visible','on');
else
    set(handles.ypanel,'Visible','off');
end;
if get(handles.zdim_chk,'Value')==1;
    set(handles.zpanel,'Visible','on');
else
    set(handles.zpanel,'Visible','off');
end;



function update_boxes(handles);
%selected_datasets
i=get(handles.dataset_listbox,'Value');
datasets=get(handles.dataset_listbox,'Userdata');
selected_datasets=datasets(i);
%epochs
for i=1:length(selected_datasets);
    a(i)=selected_datasets(i).header.datasize(1);
end;
st={};
max_epochs=max(a);
for i=1:max_epochs;
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
v=get(handles.epoch_listbox,'Value');
if isempty(v);
else
    v(find(v>max_epochs))=[];
end;
set(handles.epoch_listbox,'Value',v);
%channels
st=get(handles.channel_listbox,'String');
current_selection=st(get(handles.channel_listbox,'Value'));
st={};
k=1;
for i=1:length(selected_datasets);
    for j=1:length(selected_datasets(i).header.chanlocs);
        st{k}=selected_datasets(i).header.chanlocs(j).labels;
        k=k+1;
    end;
end;
st=unique(st);
st=sort(st);
set(handles.channel_listbox,'String',st);
j=1;
new_selection=[];
for i=1:length(current_selection);
    a=find(strcmpi(current_selection(i),st));
    if isempty(a);
    else
        new_selection(j)=a;
        j=j+1;
    end;
end;
set(handles.channel_listbox,'Value',new_selection);





function update_ROI_binpos(handles);
%selected_datasets
i=get(handles.dataset_listbox,'Value');
datasets=get(handles.dataset_listbox,'Userdata');
selected_datasets=datasets(i);
%xdim
x1=str2num(get(handles.x1_edit,'String'));
x2=str2num(get(handles.x2_edit,'String'));
xstart=selected_datasets(1).header.xstart;
xstep=selected_datasets(1).header.xstep;
dx1=round((x1-xstart)/xstep)+1;
dx2=round((x2-xstart)/xstep)+1;
set(handles.dx1_edit,'String',num2str(dx1));
set(handles.dx2_edit,'String',num2str(dx2));
%ydim
y1=str2num(get(handles.y1_edit,'String'));
y2=str2num(get(handles.y2_edit,'String'));
ystart=selected_datasets(1).header.ystart;
ystep=selected_datasets(1).header.ystep;
dy1=round((y1-ystart)/ystep)+1;
dy2=round((y2-ystart)/ystep)+1;
set(handles.dy1_edit,'String',num2str(dy1));
set(handles.dy2_edit,'String',num2str(dy2));
%zdim
z1=str2num(get(handles.z1_edit,'String'));
z2=str2num(get(handles.z2_edit,'String'));
zstart=selected_datasets(1).header.zstart;
zstep=selected_datasets(1).header.zstep;
dz1=round((z1-zstart)/zstep)+1;
dz2=round((z2-zstart)/zstep)+1;
set(handles.dz1_edit,'String',num2str(dz1));
set(handles.dz2_edit,'String',num2str(dz2));
%
update_ROI_pos(handles);





function update_ROI_pos(handles);
%selected_datasets
i=get(handles.dataset_listbox,'Value');
datasets=get(handles.dataset_listbox,'Userdata');
selected_datasets=datasets(i);
%xdim
dx1=str2num(get(handles.dx1_edit,'String'));
dx2=str2num(get(handles.dx2_edit,'String'));
xstart=selected_datasets(1).header.xstart;
xstep=selected_datasets(1).header.xstep;
x1=((dx1-1)*xstep)+xstart;
x2=((dx2-1)*xstep)+xstart;
set(handles.x1_edit,'String',num2str(x1));
set(handles.x2_edit,'String',num2str(x2));
%ydim
dy1=str2num(get(handles.dy1_edit,'String'));
dy2=str2num(get(handles.dy2_edit,'String'));
ystart=selected_datasets(1).header.ystart;
ystep=selected_datasets(1).header.ystep;
y1=((dy1-1)*ystep)+ystart;
y2=((dy2-1)*ystep)+ystart;
set(handles.y1_edit,'String',num2str(y1));
set(handles.y2_edit,'String',num2str(y2));
%zdim
dz1=str2num(get(handles.dz1_edit,'String'));
dz2=str2num(get(handles.dz2_edit,'String'));
zstart=selected_datasets(1).header.zstart;
zstep=selected_datasets(1).header.zstep;
z1=((dz1-1)*zstep)+zstart;
z2=((dz2-1)*zstep)+zstart;
set(handles.z1_edit,'String',num2str(z1));
set(handles.z2_edit,'String',num2str(z2));







% --- Outputs from this function are returned to the command line.
function varargout = GLW_explore_ROI_OutputFcn(hObject, eventdata, handles) 
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
datasets=get(handles.dataset_listbox,'Userdata');
%selected_datasets
selected_datasets=datasets(get(handles.dataset_listbox,'Value'));
%selected_epochs
selected_epochs=get(handles.epoch_listbox,'Value');
%selected_channels
selected_channels=get(handles.channel_listbox,'Value');
st=get(handles.channel_listbox,'String');
selected_channel_labels=st(selected_channels);
%indexpos
indexpos=get(handles.index_popup,'Value');
%linepos
linepos=1;
%top_percent
%top_percent
top_percent=str2num(get(handles.top_percent_edit,'String'));
%crop
xcrop=get(handles.xdim_chk,'Value');
ycrop=get(handles.ydim_chk,'Value');
zcrop=get(handles.zdim_chk,'Value');
%x1,x2,y1,y2,z1,z2
x1=str2num(get(handles.x1_edit,'String'));
x2=str2num(get(handles.x2_edit,'String'));
y1=str2num(get(handles.y1_edit,'String'));
y2=str2num(get(handles.y2_edit,'String'));
z1=str2num(get(handles.z1_edit,'String'));
z2=str2num(get(handles.z2_edit,'String'));
%colheaders
colheaders={'dataset','epoch','channel','index','mean','std','median','perc25','perc75','min','min_X','min_Y','min_Z','max','max_X','max_Y','max_Z','top%','top%_X','top%_Y','top%_Z','bottom%','bottom%_X','bottom%_Y','bottom%_Z'};
%loop through selected datasets
for datasetpos=1:length(selected_datasets);
    header=selected_datasets(datasetpos).header;
    data=selected_datasets(datasetpos).data;
    %dx1,dx2,dy1,dy2,dz1,dz2
    if xcrop==1;
        dx1=round((x1-header.xstart)/header.xstep)+1;
        dx2=round((x2-header.xstart)/header.xstep)+1;
    else
        dx1=1;
        dx2=header.datasize(6);
    end;
    if ycrop==1;
        dy1=round((y1-header.ystart)/header.ystep)+1;
        dy2=round((y2-header.ystart)/header.ystep)+1;
    else
        dy1=1;
        dy2=header.datasize(5);
    end;
    if zcrop==1;
        dz1=round((z1-header.zstart)/header.zstep)+1;
        dz2=round((z2-header.zstart)/header.zstep)+1;
    else
        dz1=1;
        dz2=header.datasize(4);
    end;
    %check limits
    if dx1<1;
        dx1=1;
    end;
    if dy1<1;
        dy1=1;
    end;
    if dz1<1;
        dz1=1;
    end;
    if dx2>header.datasize(6);
        dx2=header.datasize(6);
    end;
    if dy2>header.datasize(5);
        dy2=header.datasize(5);
    end;
    if dz2>header.datasize(4);
        dz2=header.datasize(4);
    end;
    %selected_epochs2 (keep only epochs present in the current dataset)
    if get(handles.all_epochs_chk,'Value')==0;
        selected_epochs2=selected_epochs;
        selected_epochs2(find(selected_epochs2>header.datasize(1)))=[];
    else
        selected_epochs2=1:header.datasize(1);
    end;
    %selected_channels2 (keep only channels present in the current dataset)
    st={};
    for i=1:length(header.chanlocs);
        st{i}=header.chanlocs(i).labels;
    end;
    if get(handles.all_channels_chk,'Value')==0;
        selected_channels2=[];
        j=1;
        for i=1:length(selected_channel_labels);
            a=find(strcmpi(selected_channel_labels{i},st));
            if isempty(a);
            else
                selected_channels2(j)=a;
                j=j+1;
            end;
        end;
    else
        selected_channels2=1:header.datasize(2);
    end;
    %loop through selected epochs
    for epochpos=1:length(selected_epochs2);
        %loop through selected channels
        for chanpos=1:length(selected_channels2);
            tp_data=data(selected_epochs2(epochpos),selected_channels2(chanpos),indexpos,dz1:dz2,dy1:dy2,dx1:dx2);
            tp_data=tp_data(:);
            %tp_data_idx
            tp_data_idx=zeros(length(tp_data),3);
            idx=1;
            for dz=dz1:dz2;
                for dy=dy1:dy2;
                    for dx=dx1:dx2;
                        tp_data_idx(idx,1)=((dx-1)*header.xstep)+header.xstart;
                        tp_data_idx(idx,2)=((dy-1)*header.ystep)+header.ystart;
                        tp_data_idx(idx,3)=((dz-1)*header.zstep)+header.zstart;
                        idx=idx+1;
                    end;
                end;
            end;
            %table_data
            %'dataset'
            table_data{linepos,1}=header.name;
            %'epoch'
            table_data{linepos,2}=selected_epochs2(epochpos);
            %'channel'
            table_data{linepos,3}=header.chanlocs(selected_channels2(chanpos)).labels;
            %'index'
            table_data{linepos,4}=indexpos;
            %'mean'
            table_data{linepos,5}=mean(tp_data);
            %'std'
            table_data{linepos,6}=std(tp_data);
            %'median'
            table_data{linepos,7}=median(tp_data);
            %'perc25'
            table_data{linepos,8}=prctile(tp_data,25);
            %'perc75'
            table_data{linepos,9}=prctile(tp_data,75);
            %'min'
            [a,b]=min(tp_data);
            table_data{linepos,10}=a;
            %'min_X'
            table_data{linepos,11}=tp_data_idx(b,1);
            %'min_Y'
            table_data{linepos,12}=tp_data_idx(b,2);
            %'min_Z'
            table_data{linepos,13}=tp_data_idx(b,3);
            %'max'
            [a,b]=max(tp_data);
            table_data{linepos,14}=a;
            %'max_X'
            [a,b]=max(tp_data);
            table_data{linepos,15}=tp_data_idx(b,1);
            %'max_Y'
            table_data{linepos,16}=tp_data_idx(b,2);
            %'max_Z'
            table_data{linepos,17}=tp_data_idx(b,3);
            %'top%'
            [tp_data_sort,idx]=sort(tp_data);
            table_data{linepos,18}=mean(tp_data_sort(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data)));
            tp_data_sort_idx=tp_data_idx(idx,:);
            mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
            %'top%_X'
            table_data{linepos,19}=mean_tp_data_sort_idx(1);
            %'top%_Y'
            table_data{linepos,20}=mean_tp_data_sort_idx(2);
            %'top%_Z'
            table_data{linepos,21}=mean_tp_data_sort_idx(3);
            %'bottom%'
            tp_data_sort=flipdim(tp_data_sort,1);
            tp_data_sort_idx=flipdim(tp_data_sort_idx,1);
            table_data{linepos,22}=mean(tp_data_sort(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data)));
            mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
            %'bottom%_X'
            table_data{linepos,23}=mean_tp_data_sort_idx(1);
            %'bottom%_Y'
            table_data{linepos,24}=mean_tp_data_sort_idx(2);
            %'bottom%_Z'
            table_data{linepos,25}=mean_tp_data_sort_idx(3);
            %inc linepos
            linepos=linepos+1;
            end;
        end;
    end;
h=figure;
uitable(h,'Data',table_data,'ColumnName',colheaders,'Units','normalized','Position', [0 0 1 1]);










% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on button press in zdim_chk.
function zdim_chk_Callback(hObject, eventdata, handles)
% hObject    handle to zdim_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_dimboxes(handles);


% --- Executes on button press in ydim_chk.
function ydim_chk_Callback(hObject, eventdata, handles)
% hObject    handle to ydim_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_dimboxes(handles);


% --- Executes on button press in xdim_chk.
function xdim_chk_Callback(hObject, eventdata, handles)
% hObject    handle to xdim_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_dimboxes(handles);



function top_percent_edit_Callback(hObject, eventdata, handles)
% hObject    handle to top_percent_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function top_percent_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to top_percent_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dx1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dx1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_pos(handles);


% --- Executes during object creation, after setting all properties.
function dx1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dx1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dx2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dx2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_pos(handles);



% --- Executes during object creation, after setting all properties.
function dx2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dx2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_binpos(handles);



% --- Executes during object creation, after setting all properties.
function x2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_binpos(handles);


% --- Executes during object creation, after setting all properties.
function x1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_binpos(handles);




% --- Executes during object creation, after setting all properties.
function y1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_binpos(handles);



% --- Executes during object creation, after setting all properties.
function y2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dy2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dy2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_pos(handles);



% --- Executes during object creation, after setting all properties.
function dy2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dy2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dy1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dy1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_pos(handles);



% --- Executes during object creation, after setting all properties.
function dy1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dy1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_binpos(handles);



% --- Executes during object creation, after setting all properties.
function z1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_binpos(handles);



% --- Executes during object creation, after setting all properties.
function z2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dz2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dz2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_pos(handles);



% --- Executes during object creation, after setting all properties.
function dz2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dz2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function dz1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to dz1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_ROI_pos(handles);



% --- Executes during object creation, after setting all properties.
function dz1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dz1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataset_listbox.
function dataset_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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



% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
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


% --- Executes on button press in bargraph_btn.
function bargraph_btn_Callback(hObject, eventdata, handles)
% hObject    handle to bargraph_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.dataset_listbox,'Userdata');
%selected_datasets
selected_datasets=datasets(get(handles.dataset_listbox,'Value'));
%selected_epochs
selected_epochs=get(handles.epoch_listbox,'Value');
%selected_channels
selected_channels=get(handles.channel_listbox,'Value');
st=get(handles.channel_listbox,'String');
selected_channel_labels=st(selected_channels);
%indexpos
indexpos=get(handles.index_popup,'Value');
%linepos
linepos=1;
%top_percent
%top_percent
top_percent=str2num(get(handles.top_percent_edit,'String'));
%crop
xcrop=get(handles.xdim_chk,'Value');
ycrop=get(handles.ydim_chk,'Value');
zcrop=get(handles.zdim_chk,'Value');
%x1,x2,y1,y2,z1,z2
x1=str2num(get(handles.x1_edit,'String'));
x2=str2num(get(handles.x2_edit,'String'));
y1=str2num(get(handles.y1_edit,'String'));
y2=str2num(get(handles.y2_edit,'String'));
z1=str2num(get(handles.z1_edit,'String'));
z2=str2num(get(handles.z2_edit,'String'));
%graph_type
st=get(handles.bargraph_type_popup,'String');
graph_type=st{get(handles.bargraph_type_popup,'Value')};
%loop through selected datasets
for datasetpos=1:length(selected_datasets);
    header=selected_datasets(datasetpos).header;
    data=selected_datasets(datasetpos).data;
    %table_dataset_labels
    table_dataset_labels{datasetpos}=header.name;
    %dx1,dx2,dy1,dy2,dz1,dz2
    if xcrop==1;
        dx1=round((x1-header.xstart)/header.xstep)+1;
        dx2=round((x2-header.xstart)/header.xstep)+1;
    else
        dx1=1;
        dx2=header.datasize(6);
    end;
    if ycrop==1;
        dy1=round((y1-header.ystart)/header.ystep)+1;
        dy2=round((y2-header.ystart)/header.ystep)+1;
    else
        dy1=1;
        dy2=header.datasize(5);
    end;
    if zcrop==1;
        dz1=round((z1-header.zstart)/header.zstep)+1;
        dz2=round((z2-header.zstart)/header.zstep)+1;
    else
        dz1=1;
        dz2=header.datasize(4);
    end;
    %check limits
    if dx1<1;
        dx1=1;
    end;
    if dy1<1;
        dy1=1;
    end;
    if dz1<1;
        dz1=1;
    end;
    if dx2>header.datasize(6);
        dx2=header.datasize(6);
    end;
    if dy2>header.datasize(5);
        dy2=header.datasize(5);
    end;
    if dz2>header.datasize(4);
        dz2=header.datasize(4);
    end;
    %selected_epochs2 (keep only epochs present in the current dataset)
    if get(handles.all_epochs_chk,'Value')==0;
        selected_epochs2=selected_epochs;
        selected_epochs2(find(selected_epochs2>header.datasize(1)))=[];
    else
        selected_epochs2=1:header.datasize(1);
    end;
    %selected_channels2 (keep only channels present in the current dataset)
    st={};
    for i=1:length(header.chanlocs);
        st{i}=header.chanlocs(i).labels;
    end;
    if get(handles.all_channels_chk,'Value')==0;
        selected_channels2=[];
        j=1;
        for i=1:length(selected_channel_labels);
            a=find(strcmpi(selected_channel_labels{i},st));
            if isempty(a);
            else
                selected_channels2(j)=a;
                j=j+1;
            end;
        end;
    else
        selected_channels2=1:header.datasize(2);
    end;
    %loop through selected epochs
    for epochpos=1:length(selected_epochs2);
        %table_epoch_labels
        table_epoch_labels{epochpos}=['E' num2str(selected_epochs2(epochpos))];
        %loop through selected channels
        for chanpos=1:length(selected_channels2);
            %table_channel_labels
            table_channel_labels{chanpos}=header.chanlocs(selected_channels2(chanpos)).labels;
            %tp_data
            tp_data=data(selected_epochs2(epochpos),selected_channels2(chanpos),indexpos,dz1:dz2,dy1:dy2,dx1:dx2);
            tp_data=tp_data(:);
            %tp_data_idx
            tp_data_idx=zeros(length(tp_data),3);
            idx=1;
            for dz=dz1:dz2;
                for dy=dy1:dy2;
                    for dx=dx1:dx2;
                        tp_data_idx(idx,1)=((dx-1)*header.xstep)+header.xstart;
                        tp_data_idx(idx,2)=((dy-1)*header.ystep)+header.ystart;
                        tp_data_idx(idx,3)=((dz-1)*header.zstep)+header.zstart;
                        idx=idx+1;
                    end;
                end;
            end;
            %graph_data
            switch graph_type;
                case 'mean'
                    table_data(datasetpos,epochpos,chanpos)=mean(tp_data);
                case 'std'
                    table_data(datasetpos,epochpos,chanpos)=std(tp_data);
                case 'median'
                    table_data(datasetpos,epochpos,chanpos)=median(tp_data);
                case 'perc25'
                    table_data(datasetpos,epochpos,chanpos)=prctile(tp_data,25);
                case 'perc75'
                    table_data(datasetpos,epochpos,chanpos)=prctile(tp_data,75);
                case 'min'
                    [a,b]=min(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=a;
                case 'min_X'
                    [a,b]=min(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=tp_data_idx(b,1);
                case 'min_Y'
                    [a,b]=min(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=tp_data_idx(b,2);
                case 'min_Z'
                    [a,b]=min(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=tp_data_idx(b,3);
                case 'max'
                    [a,b]=max(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=a;
                case 'max_X'
                    [a,b]=max(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=tp_data_idx(b,1);
                case 'max_Y'
                    [a,b]=max(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=tp_data_idx(b,2);
                case 'max_Z'
                    [a,b]=max(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=tp_data_idx(b,3);
                case 'top%'
                    [tp_data_sort,idx]=sort(tp_data);
                    table_data(datasetpos,epochpos,chanpos)=mean(tp_data_sort(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data)));
                case 'top%_X'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort_idx=tp_data_idx(idx,:);
                    mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
                    table_data(datasetpos,epochpos,chanpos)=mean_tp_data_sort_idx(1);
                case 'top%_Y'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort_idx=tp_data_idx(idx,:);
                    mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
                    table_data(datasetpos,epochpos,chanpos)=mean_tp_data_sort_idx(2);
                case 'top%_Z'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort_idx=tp_data_idx(idx,:);
                    mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
                    table_data(datasetpos,epochpos,chanpos)=mean_tp_data_sort_idx(3);
                case 'bottom%'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort=flip(tp_data_sort);
                    table_data(datasetpos,epochpos,chanpos)=mean(tp_data_sort(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data)));
                case 'bottom%_X'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort=flip(tp_data_sort);
                    tp_data_sort_idx=tp_data_idx(idx,:);
                    tp_data_sort_idx=flip(tp_data_sort_idx,1);
                    mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
                    table_data(datasetpos,epochpos,chanpos)=mean_tp_data_sort_idx(1);
                case 'bottom%_Y'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort=flip(tp_data_sort);
                    tp_data_sort_idx=tp_data_idx(idx,:);
                    tp_data_sort_idx=flip(tp_data_sort_idx,1);
                    mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
                    table_data(datasetpos,epochpos,chanpos)=mean_tp_data_sort_idx(2);
                case 'bottom%_Z'
                    [tp_data_sort,idx]=sort(tp_data);
                    tp_data_sort=flip(tp_data_sort);
                    tp_data_sort_idx=tp_data_idx(idx,:);
                    tp_data_sort_idx=flip(tp_data_sort_idx,1);
                    mean_tp_data_sort_idx=mean(tp_data_sort_idx(length(tp_data)-round(length(tp_data)/top_percent):length(tp_data),:),1);
                    table_data(datasetpos,epochpos,chanpos)=mean_tp_data_sort_idx(3);
            end;
        end;
    end;
end;
h=figure;
if get(handles.average_epochs_chk,'Value')==0;
    for epochpos=1:size(table_data,2);
        ax=subplot(size(table_data,2),1,epochpos);
        tp=squeeze(table_data(:,epochpos,:));
        bar(ax,tp');
        title(ax,table_epoch_labels{epochpos});
        legend(ax,table_dataset_labels);
        set(ax,'Xticklabel',table_channel_labels);
    end;
else
    table_data_mean=mean(table_data,2);
    table_data_std=std(table_data,0,2);
    ax=subplot(1,1,1);
    tp=squeeze(table_data_mean);
    tpe=squeeze(table_data_std);
    %bar(ax,tp');
    barwitherr(tpe',tp');
    legend(ax,table_dataset_labels);
    set(ax,'Xticklabel',table_channel_labels);
end;









% --- Executes on selection change in bargraph_type_popup.
function bargraph_type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to bargraph_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function bargraph_type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bargraph_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in average_epochs_chk.
function average_epochs_chk_Callback(hObject, eventdata, handles)
% hObject    handle to average_epochs_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in all_epochs_chk.
function all_epochs_chk_Callback(hObject, eventdata, handles)
% hObject    handle to all_epochs_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_epochs_chk


% --- Executes on button press in all_channels_chk.
function all_channels_chk_Callback(hObject, eventdata, handles)
% hObject    handle to all_channels_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_channels_chk
