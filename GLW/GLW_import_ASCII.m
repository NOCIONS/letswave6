function varargout = GLW_import_ASCII(varargin)
% GLW_IMPORT_ASCII MATLAB code for GLW_import_ASCII.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_import_ASCII_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_import_ASCII_OutputFcn, ...
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









% --- Executes just before GLW_import_ASCII is made visible.
function GLW_import_ASCII_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_import_ASCII (see VARARGIN)
% Choose default command line output for GLW_import_ASCII
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
%configuration.parameters.filenames={};
set(handles.filenames_listbox,'String',configuration.parameters.filenames);
%configuration.parameters.header_lines=0;
set(handles.header_lines_edit,'String',num2str(configuration.parameters.header_lines));
%configuration.parameters.import_channel_labels=0;
set(handles.import_channel_labels_chk,'Value',configuration.parameters.import_channel_labels);
%configuration.parameters.channel_label_line=0;
set(handles.channel_label_line_edit,'String',num2str(configuration.parameters.channel_label_line));
%configuration.parameters.epoch_size=1000;
set(handles.epoch_size_edit,'String',num2str(configuration.parameters.epoch_size));
%configuration.parameters.sampling_rate=1000;
set(handles.sampling_rate_edit,'String',num2str(configuration.parameters.sampling_rate));
%configuration.parameters.xstart=-0.5;
set(handles.xstart_edit,'String',num2str(configuration.parameters.xstart));
%configuration.parameters.discard_characters_channel_labels='''"';
set(handles.discard_characters_channel_labels_edit,'String',configuration.parameters.discard_characters_channel_labels);
%delimiter_string
delimiterstring{1}=' ';
delimiterstring{2}=',';
delimiterstring{3}='\t';
delimiterstring{4}=';';
set(handles.column_delimiters_listbox,'Userdata',delimiterstring);
%configuration.parameters.column_delimiters
idx=[];
j=1;
if isempty(configuration.parameters.column_delimiters);
else
    for i=1:length(configuration.parameters.column_delimiters);
        a=find([delimiterstring{:}]==configuration.parameters.column_delimiters{i});
        if isempty(a);
        else
            idx(j)=a(1);
            j=j+1;
        end;
    end;
end;
set(handles.column_delimiters_listbox,'Value',idx);
update_edits(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);





function update_edits(handles);
if get(handles.import_channel_labels_chk,'Value')==1;
    set(handles.channel_label_line_edit,'Enable','on');
else
    set(handles.channel_label_line_edit,'Enable','off');
end,




% --- Outputs from this function are returned to the command line.
function varargout = GLW_import_ASCII_OutputFcn(hObject, eventdata, handles) 
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
%configuration.parameters.filenames={};
configuration.parameters.filenames=get(handles.filenames_listbox,'Userdata');
%configuration.parameters.header_lines=0;
configuration.parameters.header_lines=str2num(get(handles.header_lines_edit,'String'));
%configuration.parameters.import_channel_labels=0;
configuration.parameters.import_channel_labels=get(handles.import_channel_labels_chk,'Value');
%configuration.parameters.channel_label_line=0;
configuration.parameters.channel_label_line=str2num(get(handles.channel_label_line_edit,'String'));
%configuration.parameters.epoch_size=1000;
configuration.parameters.epoch_size=str2num(get(handles.epoch_size_edit,'String'));
%configuration.parameters.sampling_rate=1000;
configuration.parameters.sampling_rate=str2num(get(handles.sampling_rate_edit,'String'));
%configuration.parameters.xstart=-0.5;
configuration.parameters.xstart=str2num(get(handles.xstart_edit,'String'));
%configuration.parameters.discard_characters_channel_labels='''"';
configuration.parameters.discard_characters_channel_labels=get(handles.discard_characters_channel_labels_edit,'String');
%configuration.parameters.column_delimiters={'tab'};
st=get(handles.column_delimiters_listbox,'Userdata');
st=st(get(handles.column_delimiters_listbox,'Value'));
configuration.parameters.column_delimiters=st;
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


% --- Executes on selection change in filenames_listbox.
function filenames_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to filenames_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function filenames_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filenames_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_files_btn.
function select_files_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_files_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec='*.txt;*.TXT;*.asc;*.ASC';
st={};
[st,pathname]=uigetfile(filterspec,'select datafiles','MultiSelect','on');
if isempty(st);
else
    if iscell(st);
    else
        st2{1}=st;
        st=st2;
    end;
    for i=1:length(st);
        filename{i}=[pathname,st{i}];
    end;
end;
set(handles.filenames_listbox,'String',st);
set(handles.filenames_listbox,'Userdata',filename);







function header_lines_edit_Callback(hObject, eventdata, handles)
% hObject    handle to header_lines_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function header_lines_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to header_lines_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function channel_label_line_edit_Callback(hObject, eventdata, handles)
% hObject    handle to channel_label_line_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function channel_label_line_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_label_line_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epoch_size_edit_Callback(hObject, eventdata, handles)
% hObject    handle to epoch_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function epoch_size_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epoch_size_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sampling_rate_edit_Callback(hObject, eventdata, handles)
% hObject    handle to sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function sampling_rate_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sampling_rate_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xstart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function xstart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in column_delimiters_listbox.
function column_delimiters_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to column_delimiters_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function column_delimiters_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to column_delimiters_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function discard_characters_channel_labels_edit_Callback(hObject, eventdata, handles)
% hObject    handle to discard_characters_channel_labels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function discard_characters_channel_labels_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to discard_characters_channel_labels_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in import_channel_labels_chk.
function import_channel_labels_chk_Callback(hObject, eventdata, handles)
% hObject    handle to import_channel_labels_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_edits(handles);



function prefix_edit_Callback(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function prefix_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefix_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in select_folder_btn.
function select_folder_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_folder_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
st=get(handles.output_folder_edit,'String');
a=uigetdir(st);
if isempty(a);
else
    set(handles.output_folder_edit,'String',a);
end;


% --- Executes on button press in continuous_chk.
function continuous_chk_Callback(hObject, eventdata, handles)
% hObject    handle to continuous_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.continuous_chk,'Value')==1;
    set(handles.epoch_size_edit,'Enable','off');
    set(handles.epoch_size_edit,'String','0');
else
    set(handles.epoch_size_edit,'Enable','on');
end;