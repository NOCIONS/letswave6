function varargout = GLW_weighted_channel_average_apply(varargin)
% GLW_WEIGHTED_CHANNEL_AVERAGE_APPLY MATLAB code for GLW_weighted_channel_average_apply.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_weighted_channel_average_apply_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_weighted_channel_average_apply_OutputFcn, ...
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









% --- Executes just before GLW_weighted_channel_average_apply is made visible.
function GLW_weighted_channel_average_apply_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_weighted_channel_average_apply (see VARARGIN)
% Choose default command line output for GLW_weighted_channel_average_apply
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
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_weighted_channel_average_apply_OutputFcn(hObject, eventdata, handles) 
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
%template_configuration
template_configuration=get(handles.template_name_edit,'Userdata');
configuration.parameters.template_labels=template_configuration.parameters.template_labels;
configuration.parameters.template_weights=template_configuration.parameters.template_weights;
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


% --- Executes on button press in load_btn.
function load_btn_Callback(hObject, eventdata, handles)
% hObject    handle to load_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filterspec=['*.lw6'];
[filename,pathname]=uigetfile(filterspec);
filename=fullfile(pathname,filename);
header=CLW_load_header(filename);
%history : find LW_weighted_channel_average_template
for i=1:length(header.history);
    st{i}=header.history(i).configuration.gui_info.function_name;
end;
a=find(strcmpi('LW_weighted_channel_average_template',st));
if isempty(a);
    disp('No Template Found!!!');
    return;
else
    disp('Template Found! Loading...');
    set(handles.template_name_edit,'String',header.name);
    configuration=header.history(a).configuration;
    set(handles.template_name_edit,'Userdata',configuration);
    %display topo
    f=figure;
    %chanlocs
    chanlocs=header.chanlocs;
    %st
    for i=1:length(chanlocs);
        st{i}=chanlocs(i).labels;
    end;
    %chan_idx
    for i=1:length(configuration.parameters.template_labels);
        a=find(strcmpi(configuration.parameters.template_labels{i},st));
        if isempty(a);
        else
            chan_idx(i)=a(1);
        end;
    end;
    %vector
    vector=zeros(length(chanlocs));
    vector(chan_idx)=configuration.parameters.template_weights;
    %parse data and chanlocs according to topo_enabled
    k=1;
    for chanpos=1:size(chanlocs,2);
        if chanlocs(chanpos).topo_enabled==1
            vector2(k)=double(vector(chanpos));
            chanlocs2(k)=chanlocs(chanpos);
            k=k+1;
        end;
    end;
    h=topoplot(vector2,chanlocs2);
    set(f,'color',[1 1 1]);
end;








function template_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to template_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function template_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to template_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
