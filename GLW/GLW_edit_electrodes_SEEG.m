function varargout = GLW_edit_electrodes_SEEG(varargin)
% GLW_EDIT_ELECTRODES_SEEG MATLAB code for GLW_edit_electrodes_SEEG.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_edit_electrodes_SEEG_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_edit_electrodes_SEEG_OutputFcn, ...
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









% --- Executes just before GLW_edit_electrodes_SEEG is made visible.
function GLW_edit_electrodes_SEEG_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_edit_electrodes_SEEG (see VARARGIN)
% Choose default command line output for GLW_edit_electrodes_SEEG
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
%fill channel_listbox 
header=datasets(1).header;
for i=1:length(header.chanlocs);
    st{i}=header.chanlocs(i).labels;
end;
set(handles.channel_listbox,'String',st);
set(handles.channel1_popup,'String',st);
set(handles.channel2_popup,'String',st);
set(handles.channel_listbox,'Value',1);
set(handles.channel2_popup,'Value',1);
set(handles.channel1_popup,'Value',1);
%new_chanlocs
new_chanlocs=header.chanlocs;
if isempty(configuration.parameters.list_labels);
else
    for i=1:length(configuration.parameters.list_labels);
        a=find(strcmpi(st,configuration.parameters.list_labels{i})==1);
        if isempty(a);
        else
            new_chanlocs(a(1)).X=configuration.parameters.list_X(i);
            new_chanlocs(a(1)).Y=configuration.parameters.list_Y(i);
            new_chanlocs(a(1)).Z=configuration.parameters.list_Z(i);
            new_chanlocs(a(1)).topo_enabled=0;
            new_chanlocs(chanpos1+i-1).SEEG_enabled=1;
        end;
    end;
end;
%store new_chanlocs
set(handles.update_btn,'Userdata',new_chanlocs);
%update_coordinates
update_coordinates(handles);
update_channel1_coordinates(handles);
update_channel2_coordinates(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






function update_coordinates(handles);
%chanpos
chanpos=get(handles.channel_listbox,'Value');
%initialize strings
x_st='';
y_st='';
z_st='';
%new_chanlocs
new_chanlocs=get(handles.update_btn,'Userdata');
if isfield(new_chanlocs(chanpos),'X');
    if isempty(new_chanlocs(chanpos).X);
    else
        x_st=num2str(new_chanlocs(chanpos).X);
        y_st=num2str(new_chanlocs(chanpos).Y);
        z_st=num2str(new_chanlocs(chanpos).Z);        
    end;
end;
set(handles.x_edit,'String',x_st);
set(handles.y_edit,'String',y_st);
set(handles.z_edit,'String',z_st);





function update_channel1_coordinates(handles);
%chanpos
chanpos=get(handles.channel1_popup,'Value');
%initialize strings
x_st='';
y_st='';
z_st='';
%new_chanlocs
new_chanlocs=get(handles.update_btn,'Userdata');
if isfield(new_chanlocs(chanpos),'X');
    if isempty(new_chanlocs(chanpos).X);
    else
        x_st=num2str(new_chanlocs(chanpos).X);
        y_st=num2str(new_chanlocs(chanpos).Y);
        z_st=num2str(new_chanlocs(chanpos).Z);        
    end;
end;
set(handles.x1_edit,'String',x_st);
set(handles.y1_edit,'String',y_st);
set(handles.z1_edit,'String',z_st);




function update_channel2_coordinates(handles);
%chanpos
chanpos=get(handles.channel2_popup,'Value');
%initialize strings
x_st='';
y_st='';
z_st='';
%new_chanlocs
new_chanlocs=get(handles.update_btn,'Userdata');
if isfield(new_chanlocs(chanpos),'X');
    if isempty(new_chanlocs(chanpos).X);
    else
        x_st=num2str(new_chanlocs(chanpos).X);
        y_st=num2str(new_chanlocs(chanpos).Y);
        z_st=num2str(new_chanlocs(chanpos).Z);        
    end;
end;
set(handles.x2_edit,'String',x_st);
set(handles.y2_edit,'String',y_st);
set(handles.z2_edit,'String',z_st);




% --- Outputs from this function are returned to the command line.
function varargout = GLW_edit_electrodes_SEEG_OutputFcn(hObject, eventdata, handles) 
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
%new_chanlocs
new_chanlocs=get(handles.update_btn,'Userdata');
%chanlocs
datasets=get(handles.prefix_edit,'Userdata');
chanlocs=datasets(1).header.chanlocs;
%update chanlocs
if isfield(chanlocs,'SEEG_enabled');
else
    for i=1:length(chanlocs);
        chanlocs(i).SEEG_enabled=0;
    end;
end;
%find changed
j=1;
list_labels={};
list_X=0;
list_Y=0;
list_Z=0;
for i=1:length(chanlocs);
    if structcmp(chanlocs(i),new_chanlocs(i),'IgnoreSorting','on')==0;
        if new_chanlocs(i).SEEG_enabled==1;
            list_labels{j}=new_chanlocs(i).labels;
            list_X(j)=new_chanlocs(i).X;
            list_Y(j)=new_chanlocs(i).Y;
            list_Z(j)=new_chanlocs(i).Z;
            j=j+1;
        end;
    end;
end;
%update configuration
configuration.parameters.list_labels=list_labels;
configuration.parameters.list_X=list_X;
configuration.parameters.list_Y=list_Y;
configuration.parameters.list_Z=list_Z;
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
    set(handles.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);





% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_coordinates(handles);





% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes on selection change in channel1_popup.
function channel1_popup_Callback(hObject, eventdata, handles)
% hObject    handle to channel1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_channel1_coordinates(handles);




% --- Executes during object creation, after setting all properties.
function channel1_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel1_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel2_popup.
function channel2_popup_Callback(hObject, eventdata, handles)
% hObject    handle to channel2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_channel2_coordinates(handles);




% --- Executes during object creation, after setting all properties.
function channel2_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel2_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





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





% --- Executes during object creation, after setting all properties.
function y1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z1_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function z1_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function x_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_edit (see GCBO)
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



function x2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function x2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function y2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function y2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function z2_edit_Callback(hObject, eventdata, handles)
% hObject    handle to z2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function z2_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to z2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on button press in interpolate_btn.
function interpolate_btn_Callback(hObject, eventdata, handles)
% hObject    handle to interpolate_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%X1,Y1,Z1
X1=str2num(get(handles.x1_edit,'String'));
Y1=str2num(get(handles.y1_edit,'String'));
Z1=str2num(get(handles.z1_edit,'String'));
%X2,Y2,Z2
X2=str2num(get(handles.x2_edit,'String'));
Y2=str2num(get(handles.y2_edit,'String'));
Z2=str2num(get(handles.z2_edit,'String'));
%new_chanlocs
new_chanlocs=get(handles.update_btn,'Userdata');
%chanpos1,chanpos2
chanpos1=get(handles.channel1_popup,'Value');
chanpos2=get(handles.channel2_popup,'Value');
%number of channels
num_channels=(chanpos2-chanpos1)+1;
%interpolate
X_vector=linspace(X1,X2,num_channels);
Y_vector=linspace(Y1,Y2,num_channels);
Z_vector=linspace(Z1,Z2,num_channels);
%update new_chanlocs
for i=1:length(X_vector);
    new_chanlocs(chanpos1+i-1).X=X_vector(i);
    new_chanlocs(chanpos1+i-1).Y=Y_vector(i);
    new_chanlocs(chanpos1+i-1).Z=Z_vector(i);
    new_chanlocs(chanpos1+i-1).topo_enabled=0;
    new_chanlocs(chanpos1+i-1).SEEG_enabled=1;
end;
%store new_chanlocs
set(handles.update_btn,'Userdata',new_chanlocs);
%update
update_coordinates(handles);
update_channel1_coordinates(handles);
update_channel2_coordinates(handles);
    
    
    




% --- Executes on button press in update_btn.
function update_btn_Callback(hObject, eventdata, handles)
% hObject    handle to update_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%X,Y,Z
X=str2num(get(handles.x_edit,'String'));
Y=str2num(get(handles.y_edit,'String'));
Z=str2num(get(handles.z_edit,'String'));
%new_chanlocs
new_chanlocs=get(handles.update_btn,'Userdata');
%chanpos
chanpos=get(handles.channel_listbox,'Value');
%update new_chanlocs coordinates
new_chanlocs(chanpos).X=X;
new_chanlocs(chanpos).Y=Y;
new_chanlocs(chanpos).Z=Z;
set(handles.update_btn,'Userdata',new_chanlocs);
