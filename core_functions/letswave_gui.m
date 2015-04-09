function varargout = letswave_gui(varargin)
% LETSWAVE_GUI MATLAB code for letswave_gui.fig
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% University of Louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information







% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @letswave_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @letswave_gui_OutputFcn, ...
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








% --- Executes just before letswave_gui is made visible.
function letswave_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for letswave_gui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes letswave_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);
axis off;
%set path
set(handles.path_edit,'String',pwd);
%update
set(handles.filter_listbox,'Value',[]);
update(handles);
%letswave path (p)
[p,n,e]=fileparts(which('letswave6.m'));
%build menu
build_menu(handles,p);
%plugins
find_plugins(handles,p);
%GUI_options
CLW_set_GUI_parameters(handles);






function build_menu(handles,p);
disp(['Searching for functions in : ' p filesep 'LW']);
tp=dir([p filesep 'LW' filesep 'LW_*.m']);
if length(tp)>0;
    disp('Building menu structure.');
    for i=1:length(tp);
        [p n e]=fileparts(tp(i).name);
        %load the functions
        fh = str2func(n);
        c=fh('gui_info');
        a=eval(['handles.' c.gui_info.parent]);
        fh=uimenu(a,'Label',c.gui_info.name,'Callback',{@menu_callback,i});
        st{i}=c.gui_info.function_name;
    end;
    set(handles.file_menu,'UserData',st);
else
    disp('No functions : unable to build menu structure!');
end;






%menu_item function
function menu_callback(src,evt,function_index);
handles=guidata(src);
try
    inputfiles=getfiles(handles);
catch
    inputfiles={};
end
%update_status (US)
US=send_update_status(handles);
cb='test';
st=get(handles.file_menu,'UserData');
%gui_info
eval_st=[st{function_index} '(''gui_info'')'];
configuration=eval(eval_st);
%check if function is 'scriptable'
%if 'scriptable', then process data sequentially to reduce memory use
%if not 'scriptable', all datasets will be processed in parallel
switch configuration.gui_info.scriptable
    %SCRIPTABLE
    case 'yes'
        %is scriptable
        %process datasets one after the other to reduce memory use
        %CONFIGURATION will LOAD ALL DATASETS 
        %ONLY IF it does NOT require DATA
        %check if dataset.data is required for configuration
        %
        %---------
        %CONFIGURE (SCRIPTABLE)
        %---------
        %
        switch configuration.gui_info.configuration_requires_data;
            case 'yes'
                %load dataset.header and dataset.data of first inputfile
                if isempty(inputfiles);
                    datasets.header=[];
                    datasets.data=[];
                else
                    [datasets.header datasets.data]=CLW_load(inputfiles{1});
                end;
                %default configuration
                eval_st=[st{function_index} '(''default'',configuration,datasets)'];
                configuration=eval(eval_st);
                %change configuration_mode to 'direct'
                configuration.gui_mode.configuration_mode='direct';
                %configure
                eval_st=[st{function_index} '(''configure'',configuration,datasets)'];
                configuration=eval(eval_st);
            case 'no'
                %load dataset.header, but not dataset.data of ALL inputfiles
                if isempty(inputfiles);
                    datasets.header=[];
                    datasets.data=[];
                else
                    for i=1:length(inputfiles);
                        %load dataset.header
                        [datasets(i).header]=CLW_load_header(inputfiles{i});
                        datasets(i).data=[];
                    end;
                end;
                %default configuration
                eval_st=[st{function_index} '(''default'',configuration,datasets)'];
                configuration=eval(eval_st);
                %change configuration_mode to 'direct'
                configuration.gui_mode.configuration_mode='direct';
                %configure
                eval_st=[st{function_index} '(''configure'',configuration,datasets)'];
                configuration=eval(eval_st);
                %now load datasets.data of FIRST dataset (if needed for process)
                if isempty(configuration);
                else
                    if strcmpi(configuration.gui_info.process_requires_data,'yes');
                        if isempty(inputfiles);
                            datasets.header=[];
                            datasets.data=[];
                        else
                            datasets=[];
                            [datasets.header datasets.data]=CLW_load(inputfiles{1});
                            US.function(US.handles,['Loading : ' inputfiles{1}],1,0);
                        end;
                    end;
                end;
            case 'no_header'
                %configuration requires nothing, not even a header
                datasets.header=[];
                datasets.data=[];
                %default configuration
                eval_st=[st{function_index} '(''default'',configuration,datasets)'];
                configuration=eval(eval_st);
                %change configuration_mode to 'direct'
                configuration.gui_mode.configuration_mode='direct';
                %configure
                eval_st=[st{function_index} '(''configure'',configuration,datasets)'];
                configuration=eval(eval_st);
        end;
        if isempty(configuration);
        else
            %
            %-------
            %PROCESS (SCRIPTABLE)
            %-------
            if strcmpi(configuration.gui_info.process_none,'yes');
                %nothing to do as this function does not process data
            else
                if isempty(inputfiles);
                    datasets.data=[];
                    datasets.header=[];
                else
                    %keep only the first dataset
                    datasets=datasets(1);
                    %PROCESS ALL DATASETS
                    for filepos=1:length(inputfiles);
                        %load data (if filepos>1)
                        if filepos>1;
                            datasets=[];
                            switch configuration.gui_info.process_requires_data
                                case 'yes'
                                    [datasets.header datasets.data]=CLW_load(inputfiles{filepos});
                                    US.function(US.handles,['Loading : ' inputfiles{filepos}],1,0);
                                case 'no'
                                    [datasets.header]=CLW_load_header(inputfiles{filepos});
                                    US.function(US.handles,['Loading header : ' inputfiles{filepos}],1,0);
                                    datasets.data=[];
                                case 'no_header'
                                    datasets.data=[];
                                    datasets.header=[];
                            end;
                        end;
                        eval_st=[st{function_index} '(''process'',configuration,datasets,US)'];
                        [configuration,datasets]=eval(eval_st);
                        if isempty(datasets);
                        else
                            %check if process requires to save the dataset
                            if strcmpi(configuration.gui_info.save_dataset,'yes');
                                switch configuration.gui_info.process_requires_data
                                    case 'yes'
                                        for i=1:length(datasets);
                                            if isempty(datasets(i).data);
                                                US.function(US.handles,['Dataset is empty, not saving.'],1,0);
                                            else
                                                %path
                                                [p n e]=fileparts(inputfiles{filepos});
                                                %save header and data
                                                filename=CLW_save(p,datasets(i).header,datasets(i).data);
                                                US.function(US.handles,['Saving : ' filename],1,0);
                                            end;
                                        end;
                                    case 'no'
                                        %the process only changed the header
                                        %save the new header and copy the original data
                                        for i=1:length(datasets);
                                            %path
                                            [p n e]=fileparts(inputfiles{filepos});
                                            %save header
                                            filename=CLW_save_header(p,datasets(i).header);
                                            US.function(US.handles,['Saving header : ' filename],1,0);
                                            %original data should be copied
                                            %if and only if it has new name
                                            [p2 n2 e2]=fileparts(filename);
                                            input_data_filename=[p filesep n '.mat']
                                            output_data_filename=[p2 filesep n2 '.mat'];
                                            if strcmpi(input_data_filename,output_data_filename);
                                            else
                                                copyfile(input_data_filename,output_data_filename);
                                            end;
                                        end;
                                    case 'no_header'
                                        %nothing to do
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
        
    %NOT SCRIPTABLE
    case 'no';
        %is not scriptable
        %process datasets in parallel
        %CONFIGURATION and LOAD DATASET
        %check if dataset.data is required for configuration
        %process datasets one after the other to reduce memory use
        %CONFIGURATION will LOAD ALL DATASETS 
        %
        %---------
        %CONFIGURE (NOT SCRIPTABLE)
        %---------
        %
        switch configuration.gui_info.configuration_requires_data;
            case 'yes'
                %data is required
                if isempty(inputfiles);
                    datasets.header=[];
                    datasets.data=[];
                else
                    %load ALL datasets.header and datasets.data
                    for filepos=1:length(inputfiles);
                        [datasets(filepos).header datasets(filepos).data]=CLW_load(inputfiles{filepos});
                        US.function(US.handles,['Loading : ' inputfiles{filepos}],1,0);
                    end;
                end;
                %default configuration
                eval_st=[st{function_index} '(''default'',configuration,datasets)'];
                configuration=eval(eval_st);
                %configure
                eval_st=[st{function_index} '(''configure'',configuration,datasets)'];
                configuration=eval(eval_st);
            case 'no'
                %data is not required
                %load only the headers
                %load datasets.header
                if isempty(inputfiles);
                    datasets.header=[];
                    datasets.data=[];
                else
                    for filepos=1:length(inputfiles);
                        [datasets(filepos).header]=CLW_load_header(inputfiles{filepos});
                        US.function(US.handles,['Loading header : ' inputfiles{filepos}],1,0);
                        datasets(filepos).data=[];
                    end;
                end;
                %default configuration
                eval_st=[st{function_index} '(''default'',configuration,datasets)'];
                configuration=eval(eval_st);
                %configure
                eval_st=[st{function_index} '(''configure'',configuration,datasets)'];
                configuration=eval(eval_st);
                %now load datasets.data (ONLY if needed for process)
                if isempty(configuration);
                else
                    if strcmpi(configuration.gui_info.process_requires_data,'yes');
                        if isempty(inputfiles);
                            datasets.data=[];
                            datasets.header=[];
                        else
                            for filepos=1:length(inputfiles);
                                [datasets(filepos).header datasets(filepos).data]=CLW_load(inputfiles{filepos});
                                US.function(US.handles,['Loading : ' inputfiles{filepos}],1,0);
                            end;
                        end;
                    end;
                end;
            case 'no_header'
                datasets.header=[];
                datasets.data=[];
                %default configuration
                eval_st=[st{function_index} '(''default'',configuration,datasets)'];
                configuration=eval(eval_st);
                %configure
                eval_st=[st{function_index} '(''configure'',configuration,datasets)'];
                configuration=eval(eval_st);
        end;
        %
        %-------
        %PROCESS (NOT SCRIPTABLE)
        %-------
        %
        if isempty(configuration);
        else
            if strcmpi(configuration.gui_info.process_none,'yes');
                %nothing to process as this function does not process data
            else
                %PROCESS DATASETS
                eval_st=[st{function_index} '(''process'',configuration,datasets,US)'];
                [configuration,datasets]=eval(eval_st);
                if isempty(datasets);
                else
                    %check if process requires to save the dataset
                    switch configuration.gui_info.save_dataset
                        %yes, the dataset must be saved
                        case 'yes'
                            %path
                            if isempty(inputfiles);
                                p=pwd;
                            else
                                [p,n,e]=fileparts(inputfiles{1});
                            end;
                            if strcmpi(configuration.gui_info.process_requires_data,'yes');
                                %the process changed both data and header
                                %so overwrite both header and data
                                for i=1:length(datasets);
                                    if isempty(datasets(i).data);
                                        US.function(US.handles,['Dataset is empty, not saving.'],1,0);
                                    else
                                        filename=CLW_save(p,datasets(i).header,datasets(i).data);
                                        US.function(US.handles,['Saving : ' filename],1,0);
                                    end;
                                end;
                            else
                                %the process only changed the header
                                %so only overwrite the header
                                for i=1:length(datasets);
                                    [p,n,e]=fileparts(inputfiles{i});
                                    filename=CLW_save_header(p,datasets(i).header);
                                    US.function(US.handles,['Saving : ' filename],1,0);
                                    %original data should be copied
                                    %if and only if it has new name
                                    [p2 n2 e2]=fileparts(filename);
                                    input_data_filename=[p filesep n '.mat']
                                    output_data_filename=[p2 filesep n2 '.mat'];
                                    if strcmpi(input_data_filename,output_data_filename);
                                    else
                                        copyfile(input_data_filename,output_data_filename);
                                    end;
                                end;
                            end;
                    end;
                end;
            end;
        end;
end;
US.function(US.handles,'*** Finished Process',0,1);







% --- Outputs from this function are returned to the command line.
function varargout = letswave_gui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;







function update_status(handles,text_string,status,filebox_update);
%update letswave_gui logtext
if isempty(text);
else
    st=get(handles.logtext,'String');
    st{length(st)+1}=text_string;
    set(handles.logtext,'String',st);
    set(handles.logtext,'Value',length(st));
end;
%update letswave_gui logtext
% 0=ready
% 1=busy
if status==0;
    set(handles.statustext,'String','Ready');
    set(handles.statustext,'ForegroundColor',[0 0.5 0]);
else
    set(handles.statustext,'String','Busy');
    set(handles.statustext,'ForegroundColor',[1 0 0]);
end;
%if filebox_update
if filebox_update==1;
    update(handles);
end;
drawnow expose;






function result=send_update_status(handles);
result.function=@update_status;
result.handles=handles;





% --- Executes on selection change in file_listbox.
function file_listbox_Callback(hObject, eventdata, handles)
st=get(handles.figure1,'SelectionType');
inputfiles=getfiles(handles);
try
    load(inputfiles{1},'-MAT');
    info_string=['E:' num2str(header.datasize(1)) ' C:' num2str(header.datasize(2)) ' X:' num2str(header.datasize(6)) ' Y:' num2str(header.datasize(5)) ' Z:' num2str(header.datasize(4)) ' I:' num2str(header.datasize(3))];
    set(handles.info_text,'String',info_string);
    if strcmpi(st,'open');
        view_files(handles);
    end;
end;




% --- Executes during object creation, after setting all properties.
function file_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in refreshbutton.
function refreshbutton_Callback(hObject, eventdata, handles)
update(handles);





function find_plugins(handles,p);
%search for plugins
disp(['Searching for plugins in : ' p filesep 'plugins']);
tp=dir([p filesep 'plugins' filesep 'LW' filesep '*.m']);
if length(tp)>0;
   disp('Plugins found in the plugins folder.');
   for i=1:length(tp);
       %load the plugins
   end;
end;





%refresh input listboxes
function update(handles);
st=get(handles.path_edit,'String');
%set text string to dir
set(handles.text,'String',st);
%set work dir to dir
cd(st); 
clear d;
d=dir(st);
%update dirlist and filelist
j=1;
k=1;
filelist=[];
dirlist=[];
for i=1:length(d);
    if d(i).isdir==1;
        dirlist{j}=d(i).name;
        j=j+1;
    end;
    if d(i).isdir==0;
        st=d(i).name;
        [path,name,ext]=fileparts(d(i).name);
        if strcmpi(ext,'.lw6')==1;
           filelist{k}=name;
           k=k+1;
        end,
    end;
end;
filterstring=findfilters(filelist);
updatefilterbox(handles,filterstring);
if get(handles.filter_chk,'Value')==1;
    filelist=filterfilelist(handles,filelist);
end;
%
old_filelist=get(handles.file_listbox,'String');
if isempty(old_filelist);
else
    v=get(handles.file_listbox,'Value');
    if v==0;
        v=[];
    end;
    if isempty(v);
        old_filelist={};
    else
        old_filelist=old_filelist(v);
    end;
end;
set(handles.file_listbox,'String',filelist);
idx=[];
if isempty(old_filelist);
else
    for i=1:length(old_filelist);
        a=find(strcmpi(old_filelist{i},filelist));
        if isempty(a);
        else
            idx=[idx a(1)];
        end;
    end;
end;
if isempty(idx);
    set(handles.file_listbox,'Value',1);
else
    set(handles.file_listbox,'Value',idx);
end;
%
set(handles.info_text,'String','');







%find filters
function filterstring=findfilters(filelist);
filterstring={};
sp=' ';
for i=1:length(filelist);
    st=textscan(filelist{i},'%s');
    st=st{1};
    for j=1:length(st);
        filterstring{end+1}=st{j};
    end;
end;
filterstring=unique(filterstring);
filterstring=sort(filterstring);





%update filter_listbox
function updatefilterbox(handles,filterstring);
cstring=get(handles.filter_listbox,'String');
cvalues=get(handles.filter_listbox,'Value');
set(handles.filter_listbox,'String',filterstring);
ns=[];
if isempty(cvalues);
else
    if isempty(filterstring);
    else
        selected_filters=cstring(cvalues);
        for i=1:length(filterstring);
            for j=1:length(selected_filters);
                if strcmpi(filterstring{i},selected_filters{j});
                    ns=[ns i];
                end;
            end;
        end;
    end;
end;
set(handles.filter_listbox,'Value',ns);





%filterfilelist
function outputlist=filterfilelist(handles,filelist);
tp=get(handles.filter_listbox,'Value');
st=get(handles.filter_listbox,'String');
filterstring=st(tp);
all_idx=1:1:length(filelist);
for i=1:length(filterstring);
    idx=[];
    for j=1:length(filelist);
        a=strfind(filelist{j},filterstring{i});
        if isempty(a);
        else
            idx=[idx j];
        end;
    end;
    all_idx=intersect(all_idx,idx);
end;
outputlist=filelist(all_idx);
    




%parse and analyse selection of datafiles
function [inputfiles]=getfiles(handles);
inputfiles=get(handles.file_listbox,'String');
inputfiles=inputfiles(get(handles.file_listbox,'Value'));
%get path
p=get(handles.path_edit,'String');
if p(length(p))==filesep;
else
    p(length(p)+1)=filesep;
end;
%add path and extension to inputfiles
for i=1:length(inputfiles);
    inputfiles{i}=[p,inputfiles{i},'.lw6'];
end;

    





% --- Executes on button press in refresh_btn.
function refresh_btn_Callback(hObject, eventdata, handles)
update(handles);






% --- Executes during object creation, after setting all properties.
function path_edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)








% --- Executes on selection change in filter_listbox.
function filter_listbox_Callback(hObject, eventdata, handles)
if isempty(get(handles.filter_listbox,'Value'));
else
    set(handles.filter_chk,'Value',1);
    update(handles);
end;




function filter_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in filter_chk.
function filter_chk_Callback(hObject, eventdata, handles)
update(handles);




function path_edit_Callback(hObject, eventdata, handles)
st=get(handles.path_edit,'String');
if exist(st)==7;
    set(handles.path_edit,'String',st);
    update(handles);
end;



function logtext_Callback(hObject, eventdata, handles)




function logtext_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function path_btn_Callback(hObject, eventdata, handles)
st=get(handles.path_edit,'String');
st=uigetdir(st);
if st==0;
else
    if exist(st)==7;
        set(handles.path_edit,'String',st);
        set(handles.filter_chk,'Value',0);
        set(handles.filter_listbox,'Value',[]);
        update(handles);
    end;
end;





% --- Executes on button press in sendworkspace_btn.
function sendworkspace_btn_Callback(hObject, eventdata, handles)
inputfiles=getfiles(handles);
if length(inputfiles)>1;
    disp('!!! Cannot send more than one datafile to the workspace');
else
    %load header
    disp(['Loading header : ' inputfiles{1}]);
    load(inputfiles{1},'-mat');
    %load data
    [p,n,e]=fileparts(inputfiles{1});
    st=[p filesep n '.mat'];
    disp(['Load data : ' st]);
    load(st,'-mat');
    lwdata.data=data;
    lwdata.header=header;
    disp('Sending to workspace : lwdata');
    assignin('base','lwdata',lwdata);
end;






% --- Executes on button press in readworkspace_btn.
function readworkspace_btn_Callback(hObject, eventdata, handles)
inputfiles=getfiles(handles);
if length(inputfiles)>1;
    disp('!!! No more than one file can be selected');
else
    try
        lwdata=evalin('base','lwdata');
    catch
        disp('lwdata variable not found,in workspace');
        return;
    end;
    if isfield(lwdata,'header');
        if isfield(lwdata,'data');
            t=questdlg('Are you sure?');
            if strcmpi(t,'Yes');
                header=lwdata.header;
                data=lwdata.data;
                disp(['saving header : ' inputfiles{1}]);
                save(inputfiles{1},'header','-mat');
                [p,n,e]=fileparts(inputfiles{1});
                st=[p filesep n '.mat'];
                disp(['saving data : ' st]);
                save(st,'data','-mat');
                disp('*** Done!');
            else
                disp('Operation cancelled.');
            end;
        else;
            disp('!!! Data field not found');
            return,
        end;
    else
        disp('!!! Header field not found');
        return;
    end;
end;







% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over path_edit.
function path_edit_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in tag_btn.
function tag_btn_Callback(hObject, eventdata, handles)
% hObject    handle to tag_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filenames=get(handles.file_listbox,'String');
if isempty(filenames);
    return;
end;
filenames=filenames(get(handles.file_listbox,'Value'));
filenames_idx=get(handles.file_listbox,'Value');
if isempty(filenames);
    return;
end;
tag_list={};
for filepos=1:length(filenames);
    header=CLW_load_header(filenames{filepos});
    if isfield(header,'tags');
        tag_list=[tag_list header.tags];
        file_tags(filepos).list=header.tags;
    else
        file_tags(filepos).list={};
    end;
end;
if isempty(tag_list);
    return;
end;
tag_list=sort(unique(tag_list));
a=listdlg('ListString',tag_list);
if isempty(a);
    return;
end;
tag_list=tag_list(a);
for i=1:length(file_tags);
    file_checked(i)=0;
    for j=1:length(tag_list);
        a=find(strcmpi(tag_list{j},file_tags(i).list));
        if isempty(a);
        else
            file_checked(i)=1;
        end;
    end;
end;
filenames_idx=filenames_idx(find(file_checked==1));
set(handles.file_listbox,'Value',filenames_idx);

    





function view_files(handles);
inputfiles=getfiles(handles);
cb='test';
if isempty(inputfiles);
    return;
end;
header=CLW_load_header(inputfiles{1});
if header.datasize(5)==1;
    CGLW_multi_viewer(cb,inputfiles,send_update_status(handles));
else
    CGLW_multi_viewer_maps(cb,inputfiles,send_update_status(handles));
end;





% --- Executes on button press in view_btn.
function view_btn_Callback(hObject, eventdata, handles)
% hObject    handle to view_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
view_files(handles);





% --------------------------------------------------------------------
function proc_scripts_Callback(hObject, eventdata, handles)
% hObject    handle to proc_scripts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
letswave_script_gui(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_seeg_viewer_Callback(hObject, eventdata, handles)
% hObject    handle to proc_seeg_viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_SEEG_viewer(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------



% --------------------------------------------------------------------
function proc_multi_viewer_Callback(hObject, eventdata, handles)
% hObject    handle to proc_multi_viewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_multi_viewer(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------



% --------------------------------------------------------------------
function proc_multiviewer_maps_Callback(hObject, eventdata, handles)
% hObject    handle to proc_multiviewer_maps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_multi_viewer_maps(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_multi_viewer_continuous_Callback(hObject, eventdata, handles)
% hObject    handle to proc_multi_viewer_continuous (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_multi_viewer_continuous(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_multi_viewer_average_Callback(hObject, eventdata, handles)
% hObject    handle to proc_multi_viewer_average (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_multi_viewer_average(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_edit_tags_Callback(hObject, eventdata, handles)
% hObject    handle to proc_edit_tags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_edit_tags(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_folder_create_Callback(hObject, eventdata, handles)
% hObject    handle to proc_folder_create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_folder_create(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------



% --------------------------------------------------------------------
function proc_folder_rename_Callback(hObject, eventdata, handles)
% hObject    handle to proc_folder_rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_folder_rename(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_folder_delete_Callback(hObject, eventdata, handles)
% hObject    handle to proc_folder_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_folder_delete(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_dataset_rename_Callback(hObject, eventdata, handles)
% hObject    handle to proc_dataset_rename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_rename(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_dataset_delete_Callback(hObject, eventdata, handles)
% hObject    handle to proc_dataset_delete (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_delete(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_dataset_copy_Callback(hObject, eventdata, handles)
% hObject    handle to proc_dataset_copy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_copy(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_dataset_move_Callback(hObject, eventdata, handles)
% hObject    handle to proc_dataset_move (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_move(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_export_MAT_Callback(hObject, eventdata, handles)
% hObject    handle to proc_export_MAT (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_exportMAT(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_export_ASCII_Callback(hObject, eventdata, handles)
% hObject    handle to proc_export_ASCII (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_exportASCII(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_history_Callback(hObject, eventdata, handles)
% hObject    handle to proc_history (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
inputfiles=getfiles(handles);
cb='test';
CGLW_dataset_history(cb,inputfiles,send_update_status(handles));
% --------------------------------------------------------------------


% --------------------------------------------------------------------
function proc_update_Callback(hObject, eventdata, handles)
% hObject    handle to proc_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CGLW_update;



% --------------------------------------------------------------------
function proc_gui_options_Callback(hObject, eventdata, handles)
% hObject    handle to proc_gui_options (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
letswave_GUI_options;


% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function import_signals_menu_Callback(hObject, eventdata, handles)
% hObject    handle to import_signals_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function export_signals_menu_Callback(hObject, eventdata, handles)
% hObject    handle to export_signals_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function scripts_menu_Callback(hObject, eventdata, handles)
% hObject    handle to scripts_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function edit_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edit_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function events_menu_Callback(hObject, eventdata, handles)
% hObject    handle to events_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function preprocess_menu_Callback(hObject, eventdata, handles)
% hObject    handle to preprocess_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function frequency_filters_menu_Callback(hObject, eventdata, handles)
% hObject    handle to frequency_filters_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function spatial_filters_menu_Callback(hObject, eventdata, handles)
% hObject    handle to spatial_filters_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function segmentation_menu_Callback(hObject, eventdata, handles)
% hObject    handle to segmentation_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function baseline_operations_menu_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_operations_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function artifacts_menu_Callback(hObject, eventdata, handles)
% hObject    handle to artifacts_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function frequency_transforms_menu_Callback(hObject, eventdata, handles)
% hObject    handle to frequency_transforms_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function postprocess_menu_Callback(hObject, eventdata, handles)
% hObject    handle to postprocess_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function stats_menu_Callback(hObject, eventdata, handles)
% hObject    handle to stats_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function view_menu_Callback(hObject, eventdata, handles)
% hObject    handle to view_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function figures_menu_Callback(hObject, eventdata, handles)
% hObject    handle to figures_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function average_menu_Callback(hObject, eventdata, handles)
% hObject    handle to average_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function math_menu_Callback(hObject, eventdata, handles)
% hObject    handle to math_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function source_analysis_menu_Callback(hObject, eventdata, handles)
% hObject    handle to source_analysis_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function time_frequency_filters_menu_Callback(hObject, eventdata, handles)
% hObject    handle to time_frequency_filters_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function resample_signals_menu_Callback(hObject, eventdata, handles)
% hObject    handle to resample_signals_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function arrange_signals_menu_Callback(hObject, eventdata, handles)
% hObject    handle to arrange_signals_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function edit_electrodes_menu_Callback(hObject, eventdata, handles)
% hObject    handle to edit_electrodes_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function file_management_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_management_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function single_trial_menu_Callback(hObject, eventdata, handles)
% hObject    handle to single_trial_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function csd_menu_Callback(hObject, eventdata, handles)
% hObject    handle to csd_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function help_menu_Callback(hObject, eventdata, handles)
% hObject    handle to help_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function what_is_new_menu_Callback(hObject, eventdata, handles)
% hObject    handle to what_is_new_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web https://github.com/NOCIONS/letswave6/commits/master -browser


% --------------------------------------------------------------------
function report_bug_menu_Callback(hObject, eventdata, handles)
% hObject    handle to report_bug_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web https://github.com/NOCIONS/letswave6/issues/new -browser


% --------------------------------------------------------------------
function reference_manual_menu_Callback(hObject, eventdata, handles)
% hObject    handle to reference_manual_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
a=which('letswave6.m')
[p,n,e]=fileparts(a);
filename=[p filesep 'reference_manual' filesep 'LW6_user_manual.pdf'];
open(filename);
