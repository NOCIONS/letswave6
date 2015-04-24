function varargout = GLW_ANOVA(varargin)
% GLW_ANOVA MATLAB code for GLW_ANOVA.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_ANOVA_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_ANOVA_OutputFcn, ...
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









% --- Executes just before GLW_ANOVA is made visible.
function GLW_ANOVA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_ANOVA (see VARARGIN)
% Choose default command line output for GLW_ANOVA
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
%set(handles.prefix_edit,'String',configuration.gui_info.process_filename_string);
%update overwrite_chk
if strcmpi(configuration.gui_info.process_overwrite,'yes');
    set(handles.overwrite_chk,'Value',1);
else
    set(handles.overwrite_chk,'Value',0);
end;
%!!!!!!!!!!!!!!!!!!!!!!!!
%update GUI configuration
%!!!!!!!!!!!!!!!!!!!!!!!!
%input filenames
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.anova_table,'RowName',st);
%factor_data > table_headers
if isempty(configuration.parameters.factor_data);
    set(handles.factor_name_edit,'Userdata',configuration.parameters.factor_data);
    update_table_headers(handles);
else
    set(handles.factor_name_edit,'Userdata',configuration.parameters.factor_data);
    update_table_headers(handles);
end;
%table_data
if isempty(configuration.parameters.table_data);
    set(handles.anova_table,'Data',configuration.parameters.table_data);
else
    set(handles.anova_table,'Data',configuration.parameters.table_data);
end;
%output_filename_fvalues
set(handles.output_filename_fvalues_edit,'String',configuration.gui_info.process_filename_string{1});
%output_filename_pvalues
set(handles.output_filename_pvalues_edit,'String',configuration.gui_info.process_filename_string{2});
%enable_parallel
set(handles.enable_parallel_chk,'Value',configuration.parameters.enable_parallel);
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
function varargout = GLW_ANOVA_OutputFcn(hObject, eventdata, handles) 
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
%configuration.gui_info.process_filename_string=get(handles.prefix_edit,'String');
%overwrite_chk
if get(handles.overwrite_chk,'Value')==0;
    configuration.gui_info.process_overwrite='no';
else
    configuration.gui_info.process_overwrite='yes';
end;
%!!!!!!!!!!!!!!!!!!!!
%UPDATE CONFIGURATION
%!!!!!!!!!!!!!!!!!!!!
%factor_data > table_headers
configuration.parameters.factor_data=get(handles.factor_name_edit,'Userdata');
%table_data
configuration.parameters.table_data=get(handles.anova_table,'Data');
%output_filename_fvalues
configuration.gui_info.process_filename_string{1}=get(handles.output_filename_fvalues_edit,'String');
%output_filename_pvalues
configuration.gui_info.process_filename_string{2}=get(handles.output_filename_pvalues_edit,'String');
%enable_parallel
configuration.parameters.enable_parallel=get(handles.enable_parallel_chk,'Value');
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
    set(handles.prefix_edit,'Visible','on');
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







function update_table_headers(handles);
factor_data=get(handles.factor_name_edit,'Userdata');
factor_string={};
editable=true;
for i=1:length(factor_data);
    if factor_data(i).within==1;
        factor_string{i}=['W:' factor_data(i).label];
    else
        factor_string{i}=['B:' factor_data(i).label];        
    end;
    editable(i)=true;
end;
set(handles.anova_table,'ColumnName',factor_string);
set(handles.anova_table,'ColumnEditable',editable);









% --- Executes on button press in add_within_btn.
function add_within_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_within_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%factor_name
factor_name=get(handles.factor_name_edit,'String');
%factor_data
factor_data=get(handles.factor_name_edit,'UserData');
tp=length(factor_data)+1;
%factor_data.label
factor_data(tp).label=factor_name;
%factor_data.within (0 or 1)
factor_data(tp).within=1;
%store factor_data
set(handles.factor_name_edit,'UserData',factor_data);
%update_table_headers
update_table_headers(handles);
%table_data
table_data=get(handles.anova_table,'Data');
num_rows=get(handles.anova_table,'RowName');
tp=num2cell(ones(length(num_rows),1));
table_data=horzcat(table_data,tp);
set(handles.anova_table,'Data',table_data);







function factor_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to factor_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function factor_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to factor_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in add_between_btn.
function add_between_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_between_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%factor_name
factor_name=get(handles.factor_name_edit,'String');
%factor_data
factor_data=get(handles.factor_name_edit,'UserData');
tp=length(factor_data)+1;
%factor_data.label
factor_data(tp).label=factor_name;
%factor_data.within (0 or 1)
factor_data(tp).within=0;
%store factor_data
set(handles.factor_name_edit,'UserData',factor_data);
%update_table_headers
update_table_headers(handles);
%table_data
table_data=get(handles.anova_table,'Data');
num_rows=get(handles.anova_table,'RowName');
tp=num2cell(ones(length(num_rows),1));
table_data=horzcat(table_data,tp);
set(handles.anova_table,'Data',table_data);







% --- Executes on button press in clear_btn.
function clear_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.factor_name_edit,'UserData',[]);
update_table_headers(handles);
set(handles.anova_table,'Data',[]);




function output_filename_pvalues_edit_Callback(hObject, eventdata, handles)
% hObject    handle to output_filename_pvalues_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function output_filename_pvalues_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_filename_pvalues_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function output_filename_fvalues_edit_Callback(hObject, eventdata, handles)
% hObject    handle to output_filename_fvalues_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function output_filename_fvalues_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_filename_fvalues_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in enable_parallel_chk.
function enable_parallel_chk_Callback(hObject, eventdata, handles)
% hObject    handle to enable_parallel_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of enable_parallel_chk
