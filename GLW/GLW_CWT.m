function varargout = GLW_CWT(varargin)
% GLW_CWT MATLAB code for GLW_CWT.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_CWT_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_CWT_OutputFcn, ...
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









% --- Executes just before GLW_CWT is made visible.
function GLW_CWT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_CWT (see VARARGIN)
% Choose default command line output for GLW_CWT
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
%header
header=datasets(1).header;
%wavelet_name
wavelet_name_list={'cmor1-1.5','cmor1-1','cmor1-0.5','cmor1-0.1','fbsp1-1-1.5','fbsp1-1-1','fbsp1-1-0.5','fbsp2-1-1','fbsp2-1-0.5','fbsp2-1-0.1','shan1-1.5','shan1-1','shan1-0.5','shan1-0.1','shan2-3','cgau1','cgau2','cgau3','cgau4','cgau5'};
set(handles.mother_wavelet_listbox,'Userdata',wavelet_name_list);
set(handles.mother_wavelet_name_edit,'String',configuration.parameters.wavelet_name);
%low_frequency, high_frequency
set(handles.low_frequency_edit,'String',num2str(configuration.parameters.low_frequency));
set(handles.high_frequency_edit,'String',num2str(configuration.parameters.high_frequency));
%num frequency lines
set(handles.num_frequency_lines_edit,'String',num2str(configuration.parameters.num_frequency_lines));
%output
output_st=configuration.parameters.output;
output_list={'amplitude','power','phase','complex'};
set(handles.output_popup,'Userdata',output_list);
a=find(strcmpi(configuration.parameters.output,output_list)==1);
if isempty(a);
    set(handles.output_popup,'Value',1);
else
    set(handles.output_popup,'Value',a(1));
end;
%average epochs
set(handles.average_epochs_chk,'Value',configuration.parameters.average_epochs);
%segment data
set(handles.segment_data_chk,'Value',configuration.parameters.segment_data);
%event names
st={};
if isfield(header,'events');
    for i=1:length(header.events);
        st{i}=header.events(i).code;
    end;
    st=sort(unique(st));
else
    st{1}='<empty>';
    set(handles.segment_data_chk,'Enable','off');
    set(handles.segment_data_chk,'Value',0);
end;
set(handles.event_listbox,'String',st);
a=find(strcmpi(configuration.parameters.event_name,st)==1);
if isempty(a);
else
    set(handles.event_listbox,'Value',a(1));
end;
%x_start
set(handles.x_start_edit,'String',num2str(configuration.parameters.x_start));
%x_end
set(handles.x_end_edit,'String',num2str(configuration.parameters.x_end));
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_CWT_OutputFcn(hObject, eventdata, handles) 
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
%wavelet name list
wavelet_name_list={'cmor1-1.5','cmor1-1','cmor1-0.5','cmor1-0.1','fbsp1-1-1.5','fbsp1-1-1','fbsp1-1-0.5','fbsp2-1-1','fbsp2-1-0.5','fbsp2-1-0.1','shan1-1.5','shan1-1','shan1-0.5','shan1-0.1','shan2-3','cgau1','cgau2','cgau3','cgau4','cgau5'};
set(handles.mother_wavelet_listbox,'Userdata',wavelet_name_list);
%wavelet_name
configuration.parameters.wavelet_name=get(handles.mother_wavelet_name_edit,'String');
%low_frequency, high_frequency
configuration.parameters.low_frequency=str2num(get(handles.low_frequency_edit,'String'));
configuration.parameters.high_frequency=str2num(get(handles.high_frequency_edit,'String'));
%num_frequency_lines
configuration.parameters.num_frequency_lines=str2num(get(handles.num_frequency_lines_edit,'String'));
%wavelet name
wavelet_name_list=get(handles.mother_wavelet_listbox,'Userdata');
%output
st=get(handles.output_popup,'Userdata');
configuration.parameters.output=st{get(handles.output_popup,'Value')};
%average epochs
configuration.parameters.average_epochs=get(handles.average_epochs_chk,'Value');
%segmentation
configuration.parameters.segment_data=get(handles.segment_data_chk,'Value');
configuration.parameters.x_start=str2num(get(handles.x_start_edit,'String'));
configuration.parameters.x_end=str2num(get(handles.x_end_edit,'String'));
%event_name
st=get(handles.event_listbox,'String');
event_name=st{get(handles.event_listbox,'Value')};
configuration.parameters.event_name=event_name;
%
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



function mother_wavelet_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to mother_wavelet_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function mother_wavelet_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mother_wavelet_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function low_frequency_edit_Callback(hObject, eventdata, handles)
% hObject    handle to low_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function low_frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function high_frequency_edit_Callback(hObject, eventdata, handles)
% hObject    handle to high_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function high_frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_frequency_lines_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_frequency_lines_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function num_frequency_lines_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_frequency_lines_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in output_popup.
function output_popup_Callback(hObject, eventdata, handles)
% hObject    handle to output_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function output_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in mother_wavelet_listbox.
function mother_wavelet_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to mother_wavelet_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavelet_name_list=get(handles.mother_wavelet_listbox,'Userdata');
wavelet_name_idx=get(handles.mother_wavelet_listbox,'Value');
st=wavelet_name_list{wavelet_name_idx};
set(handles.mother_wavelet_name_edit,'String',st);




% --- Executes during object creation, after setting all properties.
function mother_wavelet_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mother_wavelet_listbox (see GCBO)
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


% --- Executes on button press in segment_data_chk.
function segment_data_chk_Callback(hObject, eventdata, handles)
% hObject    handle to segment_data_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in event_listbox.
function event_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function event_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to event_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_start_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x_start_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_start_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_end_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function x_end_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_end_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
