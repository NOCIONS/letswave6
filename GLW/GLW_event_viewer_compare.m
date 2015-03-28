function varargout = GLW_event_viewer_compare(varargin)
% GLW_EVENT_VIEWER_COMPARE MATLAB code for GLW_event_viewer_compare.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_event_viewer_compare_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_event_viewer_compare_OutputFcn, ...
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









% --- Executes just before GLW_event_viewer_compare is made visible.
function GLW_event_viewer_compare_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_event_viewer_compare (see VARARGIN)
% Choose default command line output for GLW_event_viewer_compare
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
%datasets
set(handles.dataset1_popup,'Userdata',datasets);
%dataset_string
st={};
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset1_popup,'String',st);
set(handles.dataset2_popup,'String',st);
set(handles.dataset1_popup,'Value',1);
set(handles.dataset2_popup,'Value',1);
%events
update_event_listbox(handles);
set(handles.event1_popup,'Value',1);
set(handles.event2_popup,'Value',1);
%header
header=datasets(1).header;
%initialize y_edit,z_edit
set(handles.y_edit,'String',num2str(header.ystart));
set(handles.z_edit,'String',num2str(header.zstart));
%initialize channel_popup
st={};
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
set(handles.channel_listbox,'Value',1);
st={};
%index_edit
set(handles.index_edit,'String',1);
%update_event_list
update_event_list(handles);
%!!!
%END
%!!!


function update_event_list(handles);
%datasets
datasets=get(handles.dataset1_popup,'Userdata');
%header1 header2
header1=datasets(get(handles.dataset1_popup,'Value')).header;
header2=datasets(get(handles.dataset2_popup,'Value')).header;
%code1 code2
event_codes=get(handles.event1_popup,'String');
code1=event_codes{get(handles.event1_popup,'Value')};
event_codes=get(handles.event2_popup,'String');
code2=event_codes{get(handles.event2_popup,'Value')};
%find events
tp1=[];
[tp1.stringlist,tp1.epochlist,tp1.eventlist]=find_events(header1,code1);
tp2=[];
[tp2.stringlist,tp2.epochlist,tp2.eventlist]=find_events(header2,code2);
stringlist1=tp1.stringlist;
stringlist2=tp2.stringlist;
%
set(handles.event1_listbox,'String',stringlist1);
set(handles.event2_listbox,'String',stringlist2);
if get(handles.event1_listbox,'Value')>length(stringlist1);
    set(handles.event1_listbox,'Value',1);
end;
if get(handles.event2_listbox,'Value')>length(stringlist2);
    set(handles.event2_listbox,'Value',1);
end;
%
set(handles.event1_listbox,'Userdata',tp1);
set(handles.event2_listbox,'Userdata',tp2);




function [stringlist,epochlist,eventlist]=find_events(header,code);
%loop through epochs
eventlist=[];
epochlist=[];
stringlist={};
if isfield(header,'events');
    for epochpos=1:header.datasize(1);
        stringlist{epochpos}=[num2str(epochpos) ' : NaN'];
        %loop through events
        for i=1:length(header.events);
            if isnumeric(header.events(i).code);
                current_code=num2str(header.events(i).code);
            else
                current_code=header.events(i).code;
            end;
            if strcmpi(current_code,code);
                if header.events(i).epoch==epochpos;
                    if isempty(find(epochlist==epochpos));
                        epochlist=[epochlist epochpos];
                        eventlist=[eventlist i];
                        stringlist{epochpos}=[num2str(epochpos) ' : ' num2str(header.events(i).latency)];
                    end;
                end;
            end;
        end;
    end;
end;






function update_event_listbox(handles);
%datasets
datasets=get(handles.dataset1_popup,'Userdata');
%headers
header1=datasets(get(handles.dataset1_popup,'Value')).header;
header2=datasets(get(handles.dataset2_popup,'Value')).header;
%search_events
event_string1=search_events(header1);
event_string2=search_events(header2);
set(handles.event1_popup,'String',event_string1);
set(handles.event2_popup,'String',event_string2);
if get(handles.event1_popup,'Value')>length(event_string1);
    set(handles.event1_popup,'Value',1);
end;
if get(handles.event2_popup,'Value')>length(event_string2);
    set(handles.event2_popup,'Value',1);
end;








function event_string=search_events(header);
%event_string
event_string={};
%check for event field
if isfield(header,'events');
else
    return;
end;
%loop through events > event_string
for eventpos=1:length(header.events);
    if isnumeric(header.events(eventpos).code)
        code=num2str(header.events(eventpos).code);
    else
        code=header.events(eventpos).code;
    end;
    event_string{eventpos}=code;
end;
event_string=unique(event_string);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_event_viewer_compare_OutputFcn(hObject, eventdata, handles) 
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
%operation_popup
st=get(handles.operation_popup,'String');
configuration.parameters.operation=st{get(handles.operation_popup,'Value')};
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);











% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);




% --- Executes on selection change in event1_listbox.
function event1_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event1_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function event1_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event1_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in event2_listbox.
function event2_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event2_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function event2_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event2_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in compare_btn.
function compare_btn_Callback(hObject, eventdata, handles)
% hObject    handle to compare_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% hObject    handle to comparebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%type of test (1=parametric, 2=non-parametric
parametric=get(handles.parametric_popup,'Value');
%type of test (1=paired, 2=non paired
paired=get(handles.paired_popup,'Value');
%datasets
datasets=get(handles.dataset1_popup,'Userdata');
%events
tp1=get(handles.event1_listbox,'UserData');
tp2=get(handles.event2_listbox,'UserData');
%if paired, only keep paired events
if paired==1;    
    [tp,tp1i,tp2i]=intersect(tp1.epochlist,tp2.epochlist);
    tp1.epochlist=tp1.epochlist(tp1i);
    tp1.eventlist=tp1.eventlist(tp1i);
    tp2.epochlist=tp2.epochlist(tp2i);
    tp2.eventlist=tp2.eventlist(tp2i);
end;
%dataset1_pos dataset2_pos
dataset1_pos=get(handles.dataset1_popup,'Value');
dataset2_pos=get(handles.dataset2_popup,'Value');
header1=datasets(dataset1_pos).header;
header2=datasets(dataset2_pos).header;
%fetch data1
%(channel,index,dz,dy,eventpos)
data1=zeros(header1.datasize(2),header1.datasize(3),header1.datasize(4),header1.datasize(5),length(tp1.eventlist));
for i=1:length(tp1.eventlist);
    epochpos=header1.events(tp1.eventlist(i)).epoch;
    lat=header1.events(tp1.eventlist(i)).latency;
    dx=round((lat-header1.xstart)/header1.xstep)+1;
    data1(:,:,:,:,i)=squeeze(datasets(dataset1_pos).data(epochpos,:,:,:,:,dx));
end;
%fetch data2
%(channel,index,dz,dy,eventpos)
data2=zeros(header2.datasize(2),header2.datasize(3),header2.datasize(4),header2.datasize(5),length(tp2.eventlist));
for i=1:length(tp2.eventlist);
    epochpos=header2.events(tp2.eventlist(i)).epoch;
    lat=header2.events(tp2.eventlist(i)).latency;
    dx=round((lat-header2.xstart)/header2.xstep)+1;
    data2(:,:,:,:,i)=squeeze(datasets(dataset2_pos).data(epochpos,:,:,:,:,dx));
end;
%statistics
disp('Running statistics. This can take a while ...');
%loop through channels
for chanpos=1:header1.datasize(2);
    %loop through index
    for indexpos=1:header1.datasize(3);
        %loop through z
        for dz=1:header1.datasize(4);
            %loop through y
            for dy=1:header1.datasize(5);
                v1=squeeze(data1(chanpos,indexpos,dz,dy,:));
                v2=squeeze(data2(chanpos,indexpos,dz,dy,:));
                if parametric==1;
                    if paired==1;
                        [h,p]=ttest(v1,v2);
                    else
                        [h,p]=ttest2(v1,v2);
                    end;
                else
                    if paired==1;
                        [p,h]=signrank(v1,v2);
                    else
                        [p,h]=ranksum(v1,v2);
                    end;
                end;
                output.p(chanpos,indexpos,dz,dy)=p;
                output.h(chanpos,indexpos,dz,dy)=h;
                output.mean1(chanpos,indexpos,dz,dy)=mean(v1);
                output.mean2(chanpos,indexpos,dz,dy)=mean(v2);
                output.std1(chanpos,indexpos,dz,dy)=std(v1);
                output.std2(chanpos,indexpos,dz,dy)=std(v2);
            end;
        end;
    end;
end;
disp('Finished!');
output.header=header1;
set(handles.compare_btn,'Userdata',output);









% --- Executes on selection change in paired_popup.
function paired_popup_Callback(hObject, eventdata, handles)
% hObject    handle to paired_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function paired_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to paired_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in parametric_popup.
function parametric_popup_Callback(hObject, eventdata, handles)
% hObject    handle to parametric_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function parametric_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to parametric_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataset2_popup.
function dataset2_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_event_listbox(handles);
update_event_list(handles);



% --- Executes during object creation, after setting all properties.
function dataset2_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in event2_popup.
function event2_popup_Callback(hObject, eventdata, handles)
% hObject    handle to event2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_event_list(handles);




% --- Executes during object creation, after setting all properties.
function event2_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dataset1_popup.
function dataset1_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_event_listbox(handles);
update_event_list(handles);






% --- Executes during object creation, after setting all properties.
function dataset1_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in event1_popup.
function event1_popup_Callback(hObject, eventdata, handles)
% hObject    handle to event1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_event_list(handles);



% --- Executes during object creation, after setting all properties.
function event1_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in topo_btn.
function topo_btn_Callback(hObject, eventdata, handles)
% hObject    handle to topo_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%output
%output.p(chanpos,indexpos,dz,dy)=p;
%output.h(chanpos,indexpos,dz,dy)=h;
%output.header
output=get(handles.compare_btn,'Userdata');
%indexpos
indexpos=str2num(get(handles.index_edit,'String'));
%dz
z=str2num(get(handles.z_edit,'String'));
dz=1+round((z-output.header.zstart)/output.header.zstep);
%dy
y=str2num(get(handles.y_edit,'String'));
dy=1+round((y-output.header.ystart)/output.header.ystep);
%figure
figure;
%plot_2D
plot_2D=0;
if get(handles.scalp_2D_chk,'Value')==1;
    plot_2D=1;
else
    plot_2D=0;
end;
%chanlocs
chanlocs=output.header.chanlocs;
%chan_idx
k=1;
for i=1:length(chanlocs);
    if chanlocs(i).topo_enabled==1;
        chan_idx(k)=i;
        k=k+1;
    end;
end;
chanlocs=chanlocs(chan_idx);
%$$$ p $$$
%subaxis
subaxis(1,4,1,'MarginLeft',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.01);
%vector
vector=double(squeeze(output.p(chan_idx,indexpos,dz,dy)));
CLim=[0 0.1];
if plot_2D==1;
    h=topoplot(vector,chanlocs,'gridscale',128,'shading','interp','whitebk','on','maplimits',CLim);
else
    %filename_spl
    spl_filename=[];
    history=output.header.history;
    for i=1:length(history);
        if strcmpi(history(i).configuration.gui_info.function_name,'LW_headmodel_compute');
            spl_filename=history(i).configuration.parameters.spl_filename;
        end;
    end;
    if isempty(spl_filename);
        return;
    end;
    h=headplot(vector,spl_filename,'maplimits',CLim);
end;
title('p');
%$$$ h $$$
%subaxis
subaxis(1,4,2,'MarginLeft',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.01);
%vector
vector=double(squeeze(output.h(chan_idx,indexpos,dz,dy)));
%chanlocs
CLim=[0 1];
if plot_2D==1;
    h=topoplot(vector,chanlocs,'gridscale',128,'shading','interp','whitebk','on','maplimits',CLim);
else
    if isempty(spl_filename);
        return;
    end;
    h=headplot(vector,spl_filename,'maplimits',CLim);
end;
title('h');
%$$$ mean1 $$$
%subaxis
subaxis(1,4,3,'MarginLeft',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.01);
%vector
vector=double(squeeze(output.mean1(chan_idx,indexpos,dz,dy)));
%chanlocs
CLim=[str2num(get(handles.cmin_edit,'String')) str2num(get(handles.cmax_edit,'String'))];
if plot_2D==1;
    h=topoplot(vector,chanlocs,'gridscale',128,'shading','interp','whitebk','on','maplimits',CLim);
else
    if isempty(spl_filename);
        return;
    end;
    h=headplot(vector,spl_filename,'maplimits',CLim);
end;
title('mean1');
%$$$ mean2 $$$
%subaxis
subaxis(1,4,4,'MarginLeft',0.01,'MarginRight',0.01,'MarginTop',0.01,'MarginBottom',0.01);
%vector
vector=double(squeeze(output.mean2(chan_idx,indexpos,dz,dy)));
%chanlocs
if plot_2D==1;
    h=topoplot(vector,chanlocs,'gridscale',128,'shading','interp','whitebk','on','maplimits',CLim);
else
    if isempty(spl_filename);
        return;
    end;
    h=headplot(vector,spl_filename,'maplimits',CLim);
end;
title('mean2');
set(gcf,'color',[1 1 1]);



function index_edit_Callback(hObject, eventdata, handles)
% hObject    handle to index_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function index_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index_edit (see GCBO)
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


% --- Executes on button press in scalp_2D_chk.
function scalp_2D_chk_Callback(hObject, eventdata, handles)
% hObject    handle to scalp_2D_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.scalp_2D_chk,'Value')==1;
    set(handles.scalp_3D_chk,'Value',0);
else
    set(handles.scalp_3D_chk,'Value',1);
end;



% --- Executes on button press in scalp_3D_chk.
function scalp_3D_chk_Callback(hObject, eventdata, handles)
% hObject    handle to scalp_3D_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.scalp_3D_chk,'Value')==1;
    set(handles.scalp_2D_chk,'Value',0);
else
    set(handles.scalp_2D_chk,'Value',1);
end;




function cmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function cmin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function cmax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmax_edit (see GCBO)
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
%output.header
output=get(handles.compare_btn,'Userdata');
%selected channels
selected_channels=get(handles.channel_listbox,'Value');
%channel labels
channel_labels=get(handles.channel_listbox,'String');
%column headers
colnames{1}='channel';
colnames{2}='mean(A)';
colnames{3}='sd(A)';
colnames{4}='mean(B)';
colnames{5}='sd(B)';
colnames{6}='h';
colnames{7}='p';
%index_pos
indexpos=str2num(get(handles.index_edit,'String'));
%dz
z=str2num(get(handles.z_edit,'String'));
dz=1+round((z-output.header.zstart)/output.header.zstep);
%dy
y=str2num(get(handles.y_edit,'String'));
dy=1+round((y-output.header.ystart)/output.header.ystep);
%(chanpos,indexpos,dz,dy);
tabledata={};
for i=1:length(selected_channels);
    tabledata{i,1}=output.header.chanlocs(selected_channels(i)).labels;
    tabledata{i,2}=num2str(output.mean1(selected_channels(i),indexpos,dz,dy));
    tabledata{i,3}=num2str(output.std1(selected_channels(i),indexpos,dz,dy));
    tabledata{i,4}=num2str(output.mean2(selected_channels(i),indexpos,dz,dy));
    tabledata{i,5}=num2str(output.std2(selected_channels(i),indexpos,dz,dy));
    tabledata{i,6}=num2str(output.h(selected_channels(i),indexpos,dz,dy));
    tabledata{i,7}=num2str(output.p(selected_channels(i),indexpos,dz,dy));
end;
h=figure;
uitable(h,'Data',tabledata,'ColumnName',colnames,'Units','normalized','Position', [0 0 1 1]);







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
