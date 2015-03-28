function varargout = GLW_wilcoxon(varargin)
% GLW_WILCOXON MATLAB code for GLW_wilcoxon.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_wilcoxon_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_wilcoxon_OutputFcn, ...
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









% --- Executes just before GLW_wilcoxon is made visible.
function GLW_wilcoxon_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_wilcoxon (see VARARGIN)
% Choose default command line output for GLW_wilcoxon
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
%test_type_popup
%Wilcoxon signed rank test = signed_rank_test
%Wilcoxon rank sum test    = rank_sum_test
%Wilcoxon sign test        = sign_test
st={'signed_rank_test' 'rank_sum_test' 'sign_test'};
a=find(strcmpi(configuration.parameters.test_type,st));
if isempty(a);
else
    set(handles.test_type_popup,'Value',a(1));
end;
%reference_dataset_popup
if isempty(datasets);
    disp('No datasets. Exit.');
    return;
end;
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.reference_dataset_popup,'String',st);
%find reference_dataset
if isempty(configuration.parameters.reference_dataset);
else
    a=find(strcmpi(configuration.parameters.reference_dataset,st));
    if isempty(a);
    else
        set(handles.reference_dataset_popup,'Value',a(1));
    end;
end;
%tail_popup
st={'both','left','right'};
a=find(strcmpi(configuration.parameters.tails,st));
if isempty(a);
else
    set(handles.tails_popup,'Value',a(1));
end;
%alpha_edit
set(handles.alpha_edit,'String',num2str(configuration.parameters.alpha));
%permutation_chk
set(handles.permutation_chk,'Value',configuration.parameters.permutation);
%num_permutations_edit
set(handles.num_permutations_edit,'String',num2str(configuration.parameters.num_permutations));
%cluster_statistic_popup
st={'sd_mean','sd_max','perc_mean','perc_max'};
a=find(strcmpi(configuration.parameters.cluster_statistic,st));
if isempty(a);
else
    set(handles.cluster_statistic_popup,'Value',a(1));
end;
%cluster_threshold_edit
set(handles.cluster_threshold_edit,'String',num2str(configuration.parameters.cluster_threshold));
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_wilcoxon_OutputFcn(hObject, eventdata, handles) 
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
%test_type
st={'signed_rank_test' 'rank_sum_test' 'sign_test'};
configuration.parameters.test_type=st{get(handles.test_type_popup,'Value')};
%tails_popup
st={'both','left','right'};
configuration.parameters.tails=st{get(handles.tails_popup,'Value')};
%reference_dataset
st=get(handles.reference_dataset_popup,'String');
configuration.parameters.reference_dataset=st{get(handles.reference_dataset_popup,'Value')};
%alpha_edit
configuration.parameters.alpha=str2num(get(handles.alpha_edit,'String'));
%permutation_chk
configuration.parameters.permutation=get(handles.permutation_chk,'Value');
%num_permutations_edit
configuration.parameters.num_permutations=str2num(get(handles.num_permutations_edit,'String'));
%cluster_statistic_popup
st={'sd_mean','sd_max','perc_mean','perc_max'};
configuration.parameters.cluster_statistic=st{get(handles.cluster_statistic_popup,'Value')};
%cluster_threshold_edit
configuration.parameters.cluster_threshold=str2num(get(handles.cluster_threshold_edit,'String'));
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
    set(handleS.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);








% --- Executes on button press in permutation_chk.
function permutation_chk_Callback(hObject, eventdata, handles)
% hObject    handle to permutation_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function num_permutations_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_permutations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function num_permutations_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_permutations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cluster_threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function cluster_threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in cluster_statistic_popup.
function cluster_statistic_popup_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_statistic_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
s=get(handles.cluster_statistic_popup,'Value');
if s==1;
    st='2';
end;
if s==2;
    st='2';
end;
if s==3;
    st='95';
end;
if s==4;
    st='95';
end;
set(handles.cluster_threshold_edit,'String',st);



% --- Executes during object creation, after setting all properties.
function cluster_statistic_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_statistic_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function alpha_edit_Callback(hObject, eventdata, handles)
% hObject    handle to alpha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function alpha_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in test_type_popup.
function test_type_popup_Callback(hObject, eventdata, handles)
% hObject    handle to test_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function test_type_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to test_type_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in reference_dataset_popup.
function reference_dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to reference_dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function reference_dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reference_dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tails_popup.
function tails_popup_Callback(hObject, eventdata, handles)
% hObject    handle to tails_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tails_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tails_popup


% --- Executes during object creation, after setting all properties.
function tails_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tails_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
