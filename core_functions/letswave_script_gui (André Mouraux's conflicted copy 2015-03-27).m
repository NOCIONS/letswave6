function varargout = letswave_script_gui(varargin)
% LETSWAVE_SCRIPT_GUI MATLAB code for letswave_script_gui.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @letswave_script_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @letswave_script_gui_OutputFcn, ...
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









% --- Executes just before letswave_script_gui is made visible.
function letswave_script_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to letswave_script_gui (see VARARGIN)
% Choose default command line output for letswave_script_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%datasets
inputfiles=varargin{2};
set(handles.prefix_edit,'Userdata',inputfiles);
for i=1:length(inputfiles);
    [p n e]=fileparts(inputfiles{i});
    st{i}=n;
end;
set(handles.files_listbox,'String',st);
%axis
axis off;
%set GUI parameters
CLW_set_GUI_parameters(handles);
%overwrite_chk Userdata stores status update_status
set(handles.overwrite_chk,'Userdata',varargin{3});
%menu_item_families
menu_item_families{1}='file_menu';                      menu_item_families_label{1}='File';
menu_item_families{2}='import_signals_menu';            menu_item_families_label{2}='Import datasets';
menu_item_families{3}='export_signals_menu';            menu_item_families_label{3}='Export datasets';
menu_item_families{4}='file_management_menu';           menu_item_families_label{4}='File management';
menu_item_families{5}='edit_menu';                      menu_item_families_label{5}='Edit dataset properties';
menu_item_families{6}='edit_electrodes_menu';           menu_item_families_label{6}='Edit electrodes';
menu_item_families{7}='events_menu';                    menu_item_families_label{7}='Events';
menu_item_families{8}='preprocess_menu';                menu_item_families_label{8}='Preprocessing';
menu_item_families{9}='frequency_filters_menu';         menu_item_families_label{9}='Frequency filters';
menu_item_families{10}='spatial_filters_menu';          menu_item_families_label{10}='Spatial filters';
menu_item_families{11}='segmentation_menu';             menu_item_families_label{11}='Segmentation';
menu_item_families{12}='baseline_operations_menu';      menu_item_families_label{12}='Baseline operations';
menu_item_families{13}='artifacts_menu';                menu_item_families_label{13}='Suppress or reject artifacts';
menu_item_families{14}='frequency_transforms_menu';     menu_item_families_label{14}='Time/Frequency transforms';
menu_item_families{15}='time_frequency_filters_menu';   menu_item_families_label{15}='Time-frequency filters';
menu_item_families{16}='csd_menu';                      menu_item_families_label{16}='Current Source Density (CSD)';
menu_item_families{17}='resample_signals_menu';         menu_item_families_label{17}='Resample signals';
menu_item_families{18}='arrange_signals_menu';          menu_item_families_label{18}='Arrange signals';
menu_item_families{19}='postprocess_menu';              menu_item_families_label{19}='Postprocessing';
menu_item_families{20}='average_menu';                  menu_item_families_label{20}='Average';
menu_item_families{21}='math_menu';                     menu_item_families_label{21}='Mathematical operations';
menu_item_families{22}='source_analysis_menu';          menu_item_families_label{22}='Source analysis';
menu_item_families{23}='single_trial_menu';             menu_item_families_label{23}='Single-trial analyses';
menu_item_families{24}='stats_menu';                    menu_item_families_label{24}='Statistics';
menu_item_families{25}='view_menu';                     menu_item_families_label{25}='View';
menu_item_families{26}='figures_menu';                  menu_item_families_label{26}='Figures';
set(handles.item_family_popup,'UserData',menu_item_families);
set(handles.item_family_popup,'String',menu_item_families_label);
%letswave path (p)
[p,n,e]=fileparts(which('letswave6.m'));
%build menu
build_menu(handles,p);
%update menu
update_menu(handles);
%update prefix_edit
set(handles.prefix_edit,'String','scrpt');
%update overwrite_chk
set(handles.overwrite_chk,'Value',0);
%update script_listbox userdata
set(handles.script_listbox,'Userdata',[]);
%update script_listbox
update_script_listbox(handles);




function build_menu(handles,p);
disp(['Searching for functions in : ' p filesep 'LW']);
tp=dir([p filesep 'LW' filesep 'LW_*.m']);
if length(tp)>0;
    disp('Building menu structure.');
    j=1;
    for i=1:length(tp);
        [p n e]=fileparts(tp(i).name);
        %load the functions
        fh = str2func(n);
        c=fh('gui_info');
        %c.gui_info.scriptable
        if strcmpi(c.gui_info.scriptable,'yes');
            c=fh('default',c,dataset);
            menu_item.parent{j}=c.gui_info.parent;
            menu_item.name{j}=c.gui_info.name;
            c.gui_info.name;
            menu_item.configuration_list(j)=c;
            j=j+1;
        end;
    end;
    set(handles.item_listbox,'Userdata',menu_item);
else
    disp('No functions : unable to build menu structure!');
end;




function update_menu(handles);
menu_item=get(handles.item_listbox,'Userdata');
menu_item_families=get(handles.item_family_popup,'Userdata');
parent_label=menu_item_families{get(handles.item_family_popup,'Value')};
idx=find(strcmpi(menu_item.parent,parent_label)==1);
if isempty(idx);
    menu_item.current.configuration_list=[];
    menu_item.current.name=[];
else
    menu_item.current.configuration_list=menu_item.configuration_list(idx);
    menu_item.current.name=menu_item.name(idx);
end;
set(handles.item_listbox,'Userdata',menu_item);
if isempty(menu_item.current.name);
    set(handles.item_listbox,'String','<empty>');
else
    set(handles.item_listbox,'String',menu_item.current.name);
end;
set(handles.item_listbox,'Value',1);




function update_script_listbox(handles);
script_list=get(handles.script_listbox,'Userdata');
if isempty(script_list);
    set(handles.script_listbox,'String','<empty>');
else
    for i=1:length(script_list);
        st{i}=script_list(i).configuration.gui_info.name;
    end;
    set(handles.script_listbox,'String',st);
end;





% --- Outputs from this function are returned to the command line.
function varargout = letswave_script_gui_OutputFcn(hObject, eventdata, handles) 
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
%prefix_edit
prefix_str=get(handles.prefix_edit,'String');
%overwrite_chk
overwrite_chk=get(handles.overwrite_chk,'Value');
%inputfiles
inputfiles=get(handles.prefix_edit,'Userdata');
inputfiles=inputfiles(get(handles.files_listbox,'Value'));
%update_status
update_status=get(handles.overwrite_chk,'Userdata');
update_status.function(update_status.handles,'*** Starting script.',1,0);
%script_list
script_list=get(handles.script_listbox,'Userdata');
%loop through inpufiles
for filepos=1:length(inputfiles);
    %load dataset
    update_status.function(update_status.handles,['Loading : ' inputfiles{filepos}],1,0);
    [dataset.header dataset.data]=CLW_load(inputfiles{filepos});
    %run script
    dataset=CLW_run_script(dataset,script_list,update_status);
    %save dataset
    if overwrite_chk==1;
        filename=CLW_save(inputfiles{filepos},'',dataset.header,dataset.data);
        update_status.function(update_status.handles,['Saved : ' filename],1,0);
    else
        filename=CLW_save(inputfiles{filepos},prefix_str,dataset.header,dataset.data);
        update_status.function(update_status.handles,['Saved : ' filename],1,0);
    end;
end;
update_status.function(update_status.handles,['*** Finished script'],0,1);






% --- Executes on selection change in operation_popup.
function operation_popup_Callback(hObject, eventdata, handles)
% hObject    handle to operation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function operation_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to operation_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





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
    









% --- Executes on selection change in files_listbox.
function files_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to files_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function files_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to files_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on selection change in item_family_popup.
function item_family_popup_Callback(hObject, eventdata, handles)
% hObject    handle to item_family_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_menu(handles);





% --- Executes during object creation, after setting all properties.
function item_family_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to item_family_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on selection change in item_listbox.
function item_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to item_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function item_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to item_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






% --- Executes on selection change in script_listbox.
function script_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to script_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function script_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to script_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(hObject);






% --- Executes on button press in add_btn.
function add_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_item=get(handles.item_listbox,'Userdata');
if isempty(menu_item.current.configuration_list);
else
    %idx of item to add
    idx=get(handles.item_listbox,'Value');
    %current script_list
    script_list=get(handles.script_listbox,'Userdata');
    if isempty(script_list);
        script_list(1).configuration=menu_item.current.configuration_list(idx);
    else
        script_list(end+1).configuration=menu_item.current.configuration_list(idx);
    end;
    set(handles.script_listbox,'Userdata',script_list);
    update_script_listbox(handles);
end;







% --- Executes on button press in delete_btn.
function delete_btn_Callback(hObject, eventdata, handles)
% hObject    handle to delete_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
script_list=get(handles.script_listbox,'Userdata');
if isempty(script_list);
else
    script_idx=get(handles.script_listbox,'Value');
    if script_idx>0;
        script_list(script_idx)=[];
        set(handles.script_listbox,'Userdata',script_list);
        update_script_listbox(handles);
    end;
end;







% --- Executes on button press in configure_btn.
function configure_btn_Callback(hObject, eventdata, handles)
% hObject    handle to configure_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
script_list=get(handles.script_listbox,'Userdata');
if isempty(script_list);
else
    script_idx=get(handles.script_listbox,'Value');
    if script_idx>0;
        %configuration
        configuration=script_list(script_idx).configuration;
        configuration.gui_info.configuration_mode='script';
        %inputfiles
        inputfiles=get(handles.prefix_edit,'Userdata');
        file_idx=get(handles.files_listbox,'Value');
        if isempty(file_idx);
            inputfile=inputfiles{1};
        else
            inputfile=inputfiles{file_idx(1)};
        end;
        %header/data
        if strcmpi(configuration.gui_info.configuration_requires_data,'yes');
            [dataset.header,dataset.data]=CLW_load(inputfile);
        else
            dataset.header=CLW_load_header(inputfile);
            dataset.data=[];
        end;
        eval_st=[configuration.gui_info.function_name '(''configure'',configuration,dataset)'];
        configuration=eval(eval_st);
        if isempty(configuration);
        else
            script_list(script_idx).configuration=configuration;
            set(handles.script_listbox,'Userdata',script_list);
            update_script_listbox(handles);
        end;
    end;
end;






% --- Executes on button press in up_btn.
function up_btn_Callback(hObject, eventdata, handles)
% hObject    handle to up_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
script_list=get(handles.script_listbox,'Userdata');
if isempty(script_list);
else
    script_idx=get(handles.script_listbox,'Value');
    if script_idx>1;
        tp=script_list(script_idx-1);
        script_list(script_idx-1)=script_list(script_idx);
        script_list(script_idx)=tp;
        set(handles.script_listbox,'Userdata',script_list);
        update_script_listbox(handles);
        set(handles.script_listbox,'Value',script_idx-1);        
    end;
end;




% --- Executes on button press in down_btn.
function down_btn_Callback(hObject, eventdata, handles)
% hObject    handle to down_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
script_list=get(handles.script_listbox,'Userdata');
if isempty(script_list);
else
    script_idx=get(handles.script_listbox,'Value');
    if script_idx<length(script_list);
        tp=script_list(script_idx+1);
        script_list(script_idx+1)=script_list(script_idx);
        script_list(script_idx)=tp;
        set(handles.script_listbox,'Userdata',script_list);
        update_script_listbox(handles);
        set(handles.script_listbox,'Value',script_idx+1);        
    end;
end;








% --- Executes on button press in insert_btn.
function insert_btn_Callback(hObject, eventdata, handles)
% hObject    handle to insert_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
menu_item=get(handles.item_listbox,'Userdata');
if isempty(menu_item.current.configuration_list);
else
    %idx of item to add
    idx=get(handles.item_listbox,'Value');
    script_idx=get(handles.script_listbox,'Value');
    if script_idx>0;
        script_list=get(handles.script_listbox,'Userdata');
        if isempty(script_list);
            script_list(1).configuration=menu_item.current.configuration_list(idx);
        else
            script_list(script_idx+1:end+1)=script_list(script_idx:end);
            script_list(script_idx).configuration=menu_item.current.configuration_list(idx);
        end;
    end;
    set(handles.script_listbox,'Userdata',script_list);
    update_script_listbox(handles);
end;


% --- Executes on button press in save_script_btn.
function save_script_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_script_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec={'*.lwscript'};
dialogtitle='Save script';
[filename,pathname]=uiputfile(filterspec,dialogtitle);
filename=[pathname filename];
script_list=get(handles.script_listbox,'Userdata');
save(filename,'script_list');







% --- Executes on button press in load_script_btn.
function load_script_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_script_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec={'*.lwscript'};
dialogtitle='Load script';
[filename,pathname]=uigetfile(filterspec,dialogtitle);
filename=[pathname filename];
load(filename,'-mat');
set(handles.script_listbox,'Userdata',script_list);
update_script_listbox(handles);






% --- Executes on button press in build_script_btn.
function build_script_btn_Callback(hObject, eventdata, handles)
% hObject    handle to build_script_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec={'*.lw6'};
dialogtitle='Load dataset';
[filename,pathname]=uigetfile(filterspec,dialogtitle);
if filename==0;
else
    filename=[pathname filename];
    header=CLW_load_header(filename);
    if isfield(header,'history');
        if isfield(header.history,'gui_info');
            for i=1:length(header.history);
                script_list(i).configuration=header.history(i).configuration;
                if strcmpi(script_list(i).configuration.gui_info.scriptable,'no');
                    j(i)=0;
                    disp([script_list(i).configuration.gui_info.name ' : function not scriptable, removed from list.']);
                else
                    j(i)=1;
                end;
            end;
            script_list(find(j==0))=[];
            set(handles.script_listbox,'Userdata',script_list);
            update_script_listbox(handles);
        end;
    end;
end;






% --- Executes on button press in clear_script_btn.
function clear_script_btn_Callback(hObject, eventdata, handles)
% hObject    handle to clear_script_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.script_listbox,'Userdata',[]);
update_script_listbox(handles);
