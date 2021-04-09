function varargout = GLW_explore_SSEP(varargin)
% GLW_EXPLORE_SSEP MATLAB code for GLW_explore_SSEP.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_explore_SSEP_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_explore_SSEP_OutputFcn, ...
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









% --- Executes just before GLW_explore_SSEP is made visible.
function GLW_explore_SSEP_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_explore_SSEP (see VARARGIN)
% Choose default command line output for GLW_explore_SSEP
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
if isempty(datasets);
    return;
end;
%dataset_popup
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_popup,'Userdata',datasets);
set(handles.dataset_popup,'String',st);
set(handles.dataset_popup,'Value',1);
set(handles.epoch_listbox,'Value',[]);
set(handles.channel_listbox,'Value',[]);
set(handles.index_popup,'Value',1);
%update_popups
update_popups(handles);
%!!!
%END
%!!!




function update_popups(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%header
header=datasets(get(handles.dataset_popup,'Value')).header;
%epoch_listbox
st={};
for i=1:header.datasize(1);
    st{i}=num2str(i);
end;
set(handles.epoch_listbox,'String',st);
v=get(handles.epoch_listbox,'Value');
v(find(v>header.datasize(1)))=[];
set(handles.epoch_listbox,'Value',v);
%channel_listbox
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
v=get(handles.channel_listbox,'Value');
v(find(v>length(st)))=[];
set(handles.channel_listbox,'Value',v);
%index_popup
st={};
if isfield(header,'index_labels');
    st=header.index_labels;
    set(handles.index_popup,'String',st);
else
    st={};
    for i=1:header.datasize(3);
        st{i}=num2str(i);
    end;
    set(handles.index_popup,'String',st);
end;
v=get(handles.index_popup,'Value');
if v>length(st);
    set(handles.index_popup,'Value',1);
end;





function update_table_listbox(handles);
%datasets
datasets=get(handles.dataset_popup,'Userdata');
%wave_data
table_data=get(handles.table_listbox,'UserData');
%build string
st={};
if isempty(table_data);
else
    for i=1:length(table_data);
        dataset_pos=table_data(i).dataset_pos;
        header=datasets(dataset_pos).header;
        %epoch_label
        if length(table_data(i).epoch_pos)>1;
            epoch_label=['average of ' num2str(length(table_data(i).epoch_pos)) ' epochs'];
        else
            epoch_label=['epoch ' num2str(table_data(i).epoch_pos)];
        end;
        %chan_label
        if length(table_data(i).channel_pos)>1;
            chan_label=['average of ' num2str(length(table_data(i).channel_pos)) ' channels'];
        else
            chan_label=header.chanlocs(table_data(i).channel_pos).labels;
        end;
        %st
        if isfield(header,'index_labels');
            st{i}=[header.name ' E:' epoch_label ' C:' chan_label ' I:' header.index_labels{table_data(i).index_pos}];
        else
            st{i}=[header.name ' E:' epoch_label ' C:' chan_label ' I:' num2str(table_data(i).index_pos)];
        end;
    end;
end;
set(handles.table_listbox,'String',st);





function [af1,af2,af1f2]=findfrequencies(f1,f2,num_harmonics,header)
freqmin=header.xstart;
freqmax=header.xstart+((header.datasize(6)-1)*header.xstep);
%f1,f2
for n=1:num_harmonics;
    af1(n)=f1*n;
    af2(n)=f2*n;
end;
%f1f2
i=1;
for n=1:num_harmonics;
    for m=1:num_harmonics;
        af1f2(i)=af1(n)+af2(m);
        i=i+1;
        af1f2(i)=abs(af1(n)-af2(m));
        i=i+1;
    end;
end;
%check ranges
af1(find(af1<freqmin))=[];
af1(find(af1>freqmax))=[];
af2(find(af2<freqmin))=[];
af2(find(af2>freqmax))=[];
af1f2(find(af1f2<freqmin))=[];
af1f2(find(af1f2>freqmax))=[];
%sort
af1=unique(sort(af1));
af2=unique(sort(af2));
af1f2=unique(sort(af1f2));
%disp
%disp(['F1 : ' num2str(af1)]);
%disp(['F2 : ' num2str(af2)]);
%disp(['F1F2 : ' num2str(af1f2)]);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_explore_SSEP_OutputFcn(hObject, eventdata, handles) 
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





% --- Executes on button press in figure_btn.
function figure_btn_Callback(hObject, eventdata, handles)
%table_data
table_data=get(handles.table_listbox,'UserData');
%table_string
table_string=get(handles.table_listbox,'String');
table_string=strrep(table_string,'_',' ');
%freq2? f2_chk
f2_chk=get(handles.freq2_chk,'Value');
%datasets
datasets=get(handles.dataset_popup,'UserData');
disp(['Graph size : ' num2str(length(table_data))]);
%check that table_data is not empty
if isempty(table_data);
    return;
end;
%f1, f2 and num_harmonics
f1=str2num(get(handles.freq1_edit,'String'));
f2=str2num(get(handles.freq2_edit,'String'));
num_harmonics=str2num(get(handles.num_harmonics_edit,'String'));
%loop through table_data
for tpos=1:length(table_data);
    %calculate the data to be displayed
    %loop through rows
    %each row will appear as an additional bar within each bar stack
    %header
    header=datasets(table_data(tpos).dataset_pos).header;
    %calc af1,af2,af1f2
    [af1,af2,af1f2]=findfrequencies(f1,f2,num_harmonics,header);
    %tpx
    tpx=1:1:header.datasize(6);
    tpx=((tpx-1)*header.xstep)+header.xstart;
    %df1, df2, df1f2
    for i=1:length(af1);
        [cf1(i),df1(i)]=min(abs(tpx-af1(i)));
    end;
    if f2_chk==1;
        for i=1:length(af2);
            [cf2(i),df2(i)]=min(abs(tpx-af2(i)));
        end;
        for i=1:length(af1f2);
            [cf1f2(i),df1f2(i)]=min(abs(tpx-af1f2(i)));
        end;
    end;
    %tolerance
    tolerance=str2num(get(handles.tolerance_edit,'String'));
    df1_min=df1-tolerance;
    df1_min(find(df1_min<1))=1;
    df1_max=df1+tolerance;
    df1_max(find(df1_max>header.datasize(6)))=header.datasize(6);
    if f2_chk==1;
        df2_min=df2-tolerance;
        df2_min(find(df2_min<1))=1;
        df2_max=df2+tolerance;
        df2_max(find(df2_max>header.datasize(6)))=header.datasize(6);
        df1f2_min=df1f2-tolerance;
        df1f2_min(find(df1f2_min<1))=1;
        df1f2_max=df1f2+tolerance;
        df1f2_max(find(df1f2_max>header.datasize(6)))=header.datasize(6);
    end;
    %discard ambiguous frequencies
    if get(handles.discard_ambiguous_chk,'Value')==1;
        if f2_chk==1;
            %f1
            df1_remove=[];
            for i=1:length(df1);
                tpdf1_min=df1_min;
                tpdf2_min=df2_min;
                tpdf1f2_min=df1f2_min;
                tpdf1_max=df1_max;
                tpdf2_max=df2_max;
                tpdf1f2_max=df1f2_max;
                tpdf1_min(i)=[];
                tpdf1_max(i)=[];
                tp_min=[tpdf1_min tpdf2_min tpdf1f2_min];
                tp_max=[tpdf1_max tpdf2_max tpdf1f2_max];
                for j=1:length(tp_min);
                    if df1_min(i)>=tp_min(j);
                        if df1_max(i)<=tp_max(j);
                            df1_remove=[df1_remove i];
                        end;
                    end;
                end;
            end;
            %f2
            df2_remove=[];
            for i=1:length(df2);
                tpdf1_min=df1_min;
                tpdf2_min=df2_min;
                tpdf1f2_min=df1f2_min;
                tpdf1_max=df1_max;
                tpdf2_max=df2_max;
                tpdf1f2_max=df1f2_max;
                tpdf2_min(i)=[];
                tpdf2_max(i)=[];
                tp_min=[tpdf1_min tpdf2_min tpdf1f2_min];
                tp_max=[tpdf1_max tpdf2_max tpdf1f2_max];
                for j=1:length(tp_min);
                    if df2_min(i)>=tp_min(j);
                        if df2_max(i)<=tp_max(j);
                            df2_remove=[df2_remove i];
                        end;
                    end;
                end;
            end;
            %f1f2
            df1f2_remove=[];
            for i=1:length(df1f2);
                tpdf1_min=df1_min;
                tpdf2_min=df2_min;
                tpdf1f2_min=df1f2_min;
                tpdf1_max=df1_max;
                tpdf2_max=df2_max;
                tpdf1f2_max=df1f2_max;
                tpdf1f2_min(i)=[];
                tpdf1f2_max(i)=[];
                tp_min=[tpdf1_min tpdf2_min tpdf1f2_min];
                tp_max=[tpdf1_max tpdf2_max tpdf1f2_max];
                for j=1:length(tp_min);
                    if df1f2_min(i)>=tp_min(j);
                        if df1f2_max(i)<=tp_max(j);
                            df1f2_remove=[df1f2_remove i];
                        end;
                    end;
                end;
            end;
            if length(df1_remove)>0;
                disp(['F1 : removing ambiguous frequencies (Hz) : ' num2str(af1(df1_remove))]);
                disp(['F1 : removing ambiguous frequencies (bin) : ' num2str(df1(df1_remove))]);
                af1(df1_remove)=[];
                cf1(df1_remove)=[];
                df1(df1_remove)=[];
                df1_min(df1_remove)=[];
                df1_max(df1_remove)=[];
            end;
            if length(df2_remove)>0;
                disp(['F2 : removing ambiguous frequencies (Hz) : ' num2str(af2(df2_remove))]);
                disp(['F2 : removing ambiguous frequencies (bin) : ' num2str(df2(df2_remove))]);
                af2(df2_remove)=[];
                cf2(df2_remove)=[];
                df2(df2_remove)=[];
                df2_min(df2_remove)=[];
                df2_max(df2_remove)=[];
            end;
            if length(df1f2_remove)>0;
                disp(['F1xF2 : removing ambiguous frequencies (Hz) : ' num2str(af1f2(df1f2_remove))]);
                disp(['F1xF2 : removing ambiguous frequencies (bin) : ' num2str(df1f2(df1f2_remove))]);
                af1f2(df1f2_remove)=[];
                cf1f2(df1f2_remove)=[];
                df1f2(df1f2_remove)=[];
                df1f2_min(df1f2_remove)=[];
                df1f2_max(df1f2_remove)=[];
            end;
        end;
    end;
    %epoch,channel,index positions
    epoch_pos=table_data(tpos).epoch_pos;
    channel_pos=table_data(tpos).channel_pos;
    index_pos=table_data(tpos).index_pos;
    %fetch data
    tpdata=[];
    tpdata(:,:,:,:,:,:)=datasets(table_data(tpos).dataset_pos).data(epoch_pos,channel_pos,index_pos,1,1,:);
    tpdata_sd=[];
    if length(channel_pos)>1;
        %average channels
        tpdata_sd=std(tpdata,0,2);
        tpdata=mean(tpdata,2);
    end;
    if length(epoch_pos)>1;
        %average epochs
        tpdata_sd=std(tpdata,0,1);
        tpdata=mean(tpdata,1);
    end;
    %squeeze tpdata, tpdata_sd
    tpdata=squeeze(tpdata);
    if isempty(tpdata_sd);
        tpdata_sd=zeros(size(tpdata));
    else
        tpdata_sd=squeeze(tpdata_sd);
    end;
    %***F1***
    %graph_data.f1(:,wavepos)=tpdata(df1);
    for i=1:length(df1);
        [graph_data.f1(i,tpos),selected_df1(i)]=max(tpdata(df1_min(i):df1_max(i)));
    end;
    selected_df1=selected_df1+df1_min-1;
    graph_data.f1_sd(:,tpos)=tpdata_sd(selected_df1);
    %***END F1***
    if f2_chk==1;
        %***F2***
        %graph_data.f2(:,wavepos)=tpdata(df2);
        for i=1:length(df2);
            [graph_data.f2(i,tpos),selected_df2(i)]=max(tpdata(df2_min(i):df2_max(i)));
        end;
        selected_df2=selected_df2+df2_min-1;
        graph_data.f2_sd(:,tpos)=tpdata_sd(selected_df2);
        %***END F2***
        %***F1F2***
        %graph_data.f1f2(:,wavepos)=tpdata(df1f2);
        for i=1:length(df1f2);
            [graph_data.f1f2(i,tpos),selected_df1f2(i)]=max(tpdata(df1f2_min(i):df1f2_max(i)));
        end;
        selected_df1f2=selected_df1f2+df1f2_min-1;
        graph_data.f1f2_sd(:,tpos)=tpdata_sd(selected_df1f2);
        %***END F1F2***
    end;
end;
%check if sd should be displayed
if get(handles.display_errorbars_chk,'Value')==0;
    graph_data.sd=0;
else
    graph_data.sd=1;
end;
%create figure
if get(handles.average_freq_cat_chk,'Value')==0;
    %Figure NOT AVERAGED ACROSS CATEGORIES
    %***F1***
    figure('name','F1');
    if graph_data.sd==0;
        bar(graph_data.f1);
    else
        barwitherr(graph_data.f1_sd,graph_data.f1);
    end;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:length(af1));
    set(gca,'XTickLabel',num2cell(af1));
    %***END F1***
    if f2_chk==1;
        %***F2***
        figure('name','F2');
        if graph_data.sd==0;
            bar(graph_data.f2);
        else
            barwitherr(graph_data.f2_sd,graph_data.f2);
        end;
        set(gca,'XTickMode','manual');
        set(gca,'XTick',1:length(af2));
        set(gca,'XTickLabel',num2cell(af2));
        %***END F2***
        %***F1F2***
        figure('name','F1xF2');
        if graph_data.sd==0;
            bar(graph_data.f1f2);
        else
            barwitherr(graph_data.f1f2_sd,graph_data.f1f2);
        end;
        set(gca,'XTickMode','manual');
        set(gca,'XTick',1:length(af1f2));
        set(gca,'XTickLabel',num2cell(af1f2));
        %***END F1F2***
    end;
else
    %Figure AVERAGED ACROSS CATEGORIES
    figure;
    tp(1,:)=mean(graph_data.f1,1);
    tp_sd(1,:)=mean(graph_data.f1_sd,1);
    tp_label{1}='F1';
    if f2_chk==1;
        tp(2,:)=mean(graph_data.f2,1);
        tp(3,:)=mean(graph_data.f1f2,1);
        tp_sd(2,:)=mean(graph_data.f2_sd,1);
        tp_sd(3,:)=mean(graph_data.f1f2_sd,1);
        tp_label{2}='F2';
        tp_label{3}='F1xF2';
    end;
    if graph_data.sd==0;
        bar(tp);
    else
        barwitherr(tp_sd,tp);
    end;
    set(gca,'XTickMode','manual');
    set(gca,'XTick',1:length(tp_label));
    set(gca,'XTickLabel',tp_label);
end;









% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);


% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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


% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_popups(handles);





% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
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
%check epoch and channel selection is not empty
epoch_selection=get(handles.epoch_listbox,'Value');
channel_selection=get(handles.channel_listbox,'Value');
if isempty(epoch_selection);
    return;
end;
if isempty(channel_selection);
    return;
end;
%
table_data=get(handles.table_listbox,'UserData');
tpos=length(table_data)+1;
table_data(tpos).dataset_pos=get(handles.dataset_popup,'Value');
table_data(tpos).epoch_pos=epoch_selection;
table_data(tpos).channel_pos=channel_selection;
table_data(tpos).index_pos=get(handles.index_popup,'Value');
set(handles.table_listbox,'UserData',table_data);
update_table_listbox(handles);








% --- Executes on selection change in table_listbox.
function table_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to table_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
table_data=get(handles.table_listbox,'UserData');
%update using current selection
selected=get(handles.table_listbox,'Value');
if isempty(selected);
else
    set(handles.dataset_popup,'Value',table_data(selected).dataset_pos);
    update_popups(handles);
    if table_data(selected).epoch_pos>0;
        set(handles.epoch_listbox,'Value',table_data(selected).epoch_pos);
        set(handles.epoch_listbox,'Enable','on');
        %set(handles.average_epochs_chk,'Value',0);
    else
        set(handles.epoch_listbox,'Value',1);
        set(handles.epoch_listbox,'Enable','off');
        %set(handles.average_epochs_chk,'Value',1);
    end;
    if table_data(selected).channel_pos>0;
        set(handles.channel_listbox,'Value',table_data(selected).channel_pos);
        set(handles.channel_listbox,'Enable','on');
        %set(handles.average_channels_chk,'Value',0);
    else
        set(handles.channel_listbox,'Value',1);
        set(handles.channel_listbox,'Enable','off');
        %set(handles.average_channels_chk,'Value',1);
    end;
    set(handles.index_popup,'Value',table_data(selected).index_pos);
end;







% --- Executes during object creation, after setting all properties.
function table_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to table_listbox (see GCBO)
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
table_data=get(handles.table_listbox,'UserData');
tpos=get(handles.table_listbox,'Value');
if isempty(table_data)
else
    table_data(tpos)=[];
    set(handles.table_listbox,'UserData',table_data);
    tpos2=tpos-1;
    if tpos2==0
        tpos2=1;
    end;
    set(handles.table_listbox,'Value',tpos2);
end;
update_table_listbox(handles);







% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.table_listbox,'UserData',[]);
set(handles.table_listbox,'Value',1);
update_table_listbox(handles);







% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tpos=get(handles.table_listbox,'Value');
if isempty(tpos);
    return;
end;
epoch_pos=get(handles.epoch_listbox,'Value');
channel_pos=get(handles.channel_listbox,'Value');
if isempty(epoch_pos);
    return;
end;
if isempty(channel_pos);
    return;
end;
table_data=get(handles.table_listbox,'UserData');
if isempty(table_data);
else
    table_data(tpos).dataset_pos=get(handles.dataset_popup,'Value');
    table_data(tpos).epoch_pos=get(handles.epoch_listbox,'Value');
    table_data(tpos).channel_pos=get(handles.channel_listbox,'Value');
    table_data(tpos).index_pos=get(handles.index_popup,'Value');
    set(handles.table_listbox,'UserData',table_data);
    update_table_listbox(handles);
end;







function freq1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to freq1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function freq1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function freq2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to freq2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function freq2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freq2_edit (see GCBO)
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


% --- Executes on button press in display_errorbars_chk.
function display_errorbars_chk_Callback(hObject, eventdata, handles)
% hObject    handle to display_errorbars_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in discard_ambiguous_chk.
function discard_ambiguous_chk_Callback(hObject, eventdata, handles)
% hObject    handle to discard_ambiguous_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





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


% --- Executes on button press in average_freq_cat_chk.
function average_freq_cat_chk_Callback(hObject, eventdata, handles)
% hObject    handle to average_freq_cat_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)







% --- Executes on button press in freq2_chk.
function freq2_chk_Callback(hObject, eventdata, handles)
% hObject    handle to freq2_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on button press in all_epochs_btn.
function all_epochs_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_epochs_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.epoch_listbox,'String');
v=get(handles.epoch_listbox,'Value');
if isempty(v);
    v=1:length(st);
    set(handles.epoch_listbox,'Value',v);
else
    set(handles.epoch_listbox,'Value',[]);
end;

% --- Executes on button press in all_channels_btn.
function all_channels_btn_Callback(hObject, eventdata, handles)
% hObject    handle to all_channels_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.channel_listbox,'String');
v=get(handles.channel_listbox,'Value');
if isempty(v);
    v=1:length(st);
    set(handles.channel_listbox,'Value',v);
else
    set(handles.channel_listbox,'Value',[]);
end;


% --- Executes on button press in process_btn.
function process_btn_Callback(hObject, eventdata, handles)
% hObject    handle to process_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%table_data
user_data=get(handles.table_listbox,'UserData');
%table_string
table_string=get(handles.table_listbox,'String');
table_string=strrep(table_string,'_',' ');
%freq2? f2_chk
f2_chk=get(handles.freq2_chk,'Value');
%datasets
datasets=get(handles.dataset_popup,'UserData');
disp(['Graph size : ' num2str(length(user_data))]);
%check that table_data is not empty
if isempty(user_data);
    return;
end;
%f1, f2 and num_harmonics
f1=str2num(get(handles.freq1_edit,'String'));
f2=str2num(get(handles.freq2_edit,'String'));
num_harmonics=str2num(get(handles.num_harmonics_edit,'String'));
%loop through table_data
graph_data=[];
for tpos=1:length(user_data);
    %calculate the data to be displayed
    %loop through rows
    %each row will appear as an additional bar within each bar stack
    %header
    header=datasets(user_data(tpos).dataset_pos).header;
    %calc af1,af2,af1f2
    [af1,af2,af1f2]=findfrequencies(f1,f2,num_harmonics,header);
    %tpx
    tpx=1:1:header.datasize(6);
    tpx=((tpx-1)*header.xstep)+header.xstart;
    %df1, df2, df1f2
    for i=1:length(af1);
        [cf1(i),df1(i)]=min(abs(tpx-af1(i)));
    end;
    if f2_chk==1;
        for i=1:length(af2);
            [cf2(i),df2(i)]=min(abs(tpx-af2(i)));
        end;
        for i=1:length(af1f2);
            [cf1f2(i),df1f2(i)]=min(abs(tpx-af1f2(i)));
        end;
    end;
    %tolerance
    tolerance=str2num(get(handles.tolerance_edit,'String'));
    df1_min=df1-tolerance;
    df1_min(find(df1_min<1))=1;
    df1_max=df1+tolerance;
    df1_max(find(df1_max>header.datasize(6)))=header.datasize(6);
    if f2_chk==1;
        df2_min=df2-tolerance;
        df2_min(find(df2_min<1))=1;
        df2_max=df2+tolerance;
        df2_max(find(df2_max>header.datasize(6)))=header.datasize(6);
        df1f2_min=df1f2-tolerance;
        df1f2_min(find(df1f2_min<1))=1;
        df1f2_max=df1f2+tolerance;
        df1f2_max(find(df1f2_max>header.datasize(6)))=header.datasize(6);
    end;
    %discard ambiguous frequencies
    if get(handles.discard_ambiguous_chk,'Value')==1;
        if f2_chk==1;
            %f1
            df1_remove=[];
            for i=1:length(df1);
                tpdf1_min=df1_min;
                tpdf2_min=df2_min;
                tpdf1f2_min=df1f2_min;
                tpdf1_max=df1_max;
                tpdf2_max=df2_max;
                tpdf1f2_max=df1f2_max;
                tpdf1_min(i)=[];
                tpdf1_max(i)=[];
                tp_min=[tpdf1_min tpdf2_min tpdf1f2_min];
                tp_max=[tpdf1_max tpdf2_max tpdf1f2_max];
                for j=1:length(tp_min);
                    if df1_min(i)>=tp_min(j);
                        if df1_max(i)<=tp_max(j);
                            df1_remove=[df1_remove i];
                        end;
                    end;
                end;
            end;
            %f2
            df2_remove=[];
            for i=1:length(df2);
                tpdf1_min=df1_min;
                tpdf2_min=df2_min;
                tpdf1f2_min=df1f2_min;
                tpdf1_max=df1_max;
                tpdf2_max=df2_max;
                tpdf1f2_max=df1f2_max;
                tpdf2_min(i)=[];
                tpdf2_max(i)=[];
                tp_min=[tpdf1_min tpdf2_min tpdf1f2_min];
                tp_max=[tpdf1_max tpdf2_max tpdf1f2_max];
                for j=1:length(tp_min);
                    if df2_min(i)>=tp_min(j);
                        if df2_max(i)<=tp_max(j);
                            df2_remove=[df2_remove i];
                        end;
                    end;
                end;
            end;
            %f1f2
            df1f2_remove=[];
            for i=1:length(df1f2);
                tpdf1_min=df1_min;
                tpdf2_min=df2_min;
                tpdf1f2_min=df1f2_min;
                tpdf1_max=df1_max;
                tpdf2_max=df2_max;
                tpdf1f2_max=df1f2_max;
                tpdf1f2_min(i)=[];
                tpdf1f2_max(i)=[];
                tp_min=[tpdf1_min tpdf2_min tpdf1f2_min];
                tp_max=[tpdf1_max tpdf2_max tpdf1f2_max];
                for j=1:length(tp_min);
                    if df1f2_min(i)>=tp_min(j);
                        if df1f2_max(i)<=tp_max(j);
                            df1f2_remove=[df1f2_remove i];
                        end;
                    end;
                end;
            end;
            if length(df1_remove)>0;
                disp(['F1 : removing ambiguous frequencies (Hz) : ' num2str(af1(df1_remove))]);
                disp(['F1 : removing ambiguous frequencies (bin) : ' num2str(df1(df1_remove))]);
                af1(df1_remove)=[];
                cf1(df1_remove)=[];
                df1(df1_remove)=[];
                df1_min(df1_remove)=[];
                df1_max(df1_remove)=[];
            end;
            if length(df2_remove)>0;
                disp(['F2 : removing ambiguous frequencies (Hz) : ' num2str(af2(df2_remove))]);
                disp(['F2 : removing ambiguous frequencies (bin) : ' num2str(df2(df2_remove))]);
                af2(df2_remove)=[];
                cf2(df2_remove)=[];
                df2(df2_remove)=[];
                df2_min(df2_remove)=[];
                df2_max(df2_remove)=[];
            end;
            if length(df1f2_remove)>0;
                disp(['F1xF2 : removing ambiguous frequencies (Hz) : ' num2str(af1f2(df1f2_remove))]);
                disp(['F1xF2 : removing ambiguous frequencies (bin) : ' num2str(df1f2(df1f2_remove))]);
                af1f2(df1f2_remove)=[];
                cf1f2(df1f2_remove)=[];
                df1f2(df1f2_remove)=[];
                df1f2_min(df1f2_remove)=[];
                df1f2_max(df1f2_remove)=[];
            end;
        end;
    end;
    %epoch,channel,index positions
    epoch_pos=user_data(tpos).epoch_pos;
    channel_pos=user_data(tpos).channel_pos;
    index_pos=user_data(tpos).index_pos;
    %fetch data
    tpdata=[];
    tpdata(:,:,:,:,:,:)=datasets(user_data(tpos).dataset_pos).data;
    %***F1***
    %colheaders
    colheaders={'dataset','epoch','channel'};
    for i=1:length(af1);
        colheaders{3+i}=num2str(af1(i));
    end;
    %loop through epochs
    k=1;
    selected_vf1=[];
    selected_df1=[];
    table_data={};
    for ep=1:length(epoch_pos);
        %loop through channels
        for cp=1:length(channel_pos);
            %loop through df1
            for i=1:length(df1);
                [selected_vf1(i),selected_df1(i)]=max(tpdata(epoch_pos(ep),channel_pos(cp),index_pos,1,1,df1_min(i):df1_max(i)));
            end;
            %***END F1***
            table_data{k,1}=header.name;
            table_data{k,2}=epoch_pos(ep);
            table_data{k,3}=channel_pos(cp);
            for tp=1:length(df1);
                table_data{k,3+tp}=selected_vf1(tp);
            end;
            k=k+1;
        end;
    end;
    %table_data
    h=figure('name','F1');
    uitable(h,'Data',table_data,'ColumnName',colheaders,'Units','normalized','Position', [0 0 1 1]);
    %***F2***
    if f2_chk==1;
        %colheaders
        colheaders={'dataset','epoch','channel'};
        for i=1:length(af2);
            colheaders{3+i}=num2str(af2(i));
        end;
        %loop through epochs
        k=1;
        selected_vf2=[];
        selected_df2=[];
        table_data={};
        for ep=1:length(epoch_pos);
            %loop through channels
            for cp=1:length(channel_pos);
                %loop through df2
                for i=1:length(df2);
                    [selected_vf2(i),selected_df2(i)]=max(tpdata(epoch_pos(ep),channel_pos(cp),index_pos,1,1,df2_min(i):df2_max(i)));
                end;
                %***END F2***
                table_data{k,1}=header.name;
                table_data{k,2}=epoch_pos(ep);
                table_data{k,3}=channel_pos(cp);
                for tp=1:length(df2);
                    table_data{k,3+tp}=selected_vf2(tp);
                end;
                k=k+1;
            end;
        end;
        %table_data
        h=figure('name','F2');
        uitable(h,'Data',table_data,'ColumnName',colheaders,'Units','normalized','Position', [0 0 1 1]);
    end;
    %***F1F2***
    if f2_chk==1;
        %colheaders
        colheaders={'dataset','epoch','channel'};
        for i=1:length(af1f2);
            colheaders{3+i}=num2str(af1f2(i));
        end;
        %loop through epochs
        k=1;
        selected_vf1f2=[];
        selected_df1f2=[];
        table_data={};
        for ep=1:length(epoch_pos);
            %loop through channels
            for cp=1:length(channel_pos);
                %loop through df2
                for i=1:length(df1f2);
                    [selected_vf1f2(i),selected_df1f2(i)]=max(tpdata(epoch_pos(ep),channel_pos(cp),index_pos,1,1,df1f2_min(i):df1f2_max(i)));
                end;
                %***END F1F2***
                table_data{k,1}=header.name;
                table_data{k,2}=epoch_pos(ep);
                table_data{k,3}=channel_pos(cp);
                for tp=1:length(df1f2);
                    table_data{k,3+tp}=selected_vf1f2(tp);
                end;
                k=k+1;
            end;
        end;
        %table_data
        h=figure('name','F1F2');
        uitable(h,'Data',table_data,'ColumnName',colheaders,'Units','normalized','Position', [0 0 1 1]);
    end;

        
end;
