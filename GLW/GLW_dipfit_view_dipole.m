function varargout = GLW_dipfit_view_dipole(varargin)
% GLW_DIPFIT_VIEW_DIPOLE MATLAB code for GLW_dipfit_view_dipole.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_dipfit_view_dipole_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_dipfit_view_dipole_OutputFcn, ...
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









% --- Executes just before GLW_dipfit_view_dipole is made visible.
function GLW_dipfit_view_dipole_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_dipfit_view_dipole (see VARARGIN)
% Choose default command line output for GLW_dipfit_view_dipole
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
j=1;
tp=[];
for setpos=1:length(datasets);
    %header
    header=datasets(setpos).header;
    %history_labels
    for i=1:length(header.history);
        history_labels{i}=header.history(i).configuration.gui_info.function_name;
    end;
    %find dipoles
    dipole_list=[];
    fn{1}='LW_dipfit_fit_latency';
    fn{2}='LW_dipfit_fit_ICs';
    fn{3}='LW_diptif_fit_events';
    for k=1:length(fn);
        a=find(strcmpi(fn{k},history_labels));
        if isempty(a);
        else
            for i=1:length(a);
                a(i)
                %vol
                tp(j).vol=header.history(a(i)).configuration.parameters.vol;
                %mri
                tp(j).mri=header.history(a(i)).configuration.parameters.mri;
                %elec
                tp(j).elec=header.history(a(i)).configuration.parameters.elec;
                %dipole_list
                tp(j).dipole_list=header.history(a(i)).configuration.parameters.dipole_list;
                %header_chanlocs
                chanlocs=header.chanlocs;
                %header_channel_labels
                header_channel_labels={};
                for k=1:length(header.chanlocs);
                    header_channel_labels{k}=chanlocs(k).labels;
                end;
                %topo_channel_labels
                topo_channel_labels=header.history(a(i)).configuration.parameters.topo_channel_labels;
                %parse
                l=1;
                c_idx=[];
                %find chanlocs which are present in topo_channel_labels
                for k=1:length(topo_channel_labels);
                    ca=find(strcmpi(topo_channel_labels{k},header_channel_labels));
                    if isempty(ca);
                    else
                        c_idx(l)=ca(1);
                        l=l+1;
                    end;
                end;
                chanlocs=chanlocs(c_idx); %this chanlocs corresponds to the associated topo
                %find chanlocs which are topo_enabled
                l=1;
                c_idx=[];
                for k=1:length(chanlocs);
                    if isfield(chanlocs(k),'topo_enabled');
                        if chanlocs(k).topo_enabled==1;
                            c_idx(l)=k;
                            l=l+1;
                        end;
                    end;
                end;
                chanlocs=chanlocs(c_idx);
                tp(j).header_chanlocs=chanlocs;
                %topo_list
                topo_list=header.history(a(i)).configuration.parameters.topo_list;
                for k=1:length(topo_list);
                    topo_list(k).topo=topo_list(k).topo(c_idx);
                end;
                tp(j).topo_list=topo_list;
                %filename
                tp(j).dataset_name=header.name;
                %j
                j=j+1;
            end;
        end;
    end;
end;
%store
set(handles.plot_dipole_btn,'Userdata',tp);
%find all dipole_labels
dipole_labels={};
dipole_idx=[];
k=1;
for i=1:length(tp);
    for j=1:length(tp(i).dipole_list);
        dipole_labels{k}=tp(i).dipole_list(j).dipole.label;
        dipole_idx(k).idx=[i j];
        k=k+1;
    end;
end;
set(handles.dipole_listbox,'Userdata',dipole_idx);
set(handles.dipole_listbox,'String',dipole_labels);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);













% --- Outputs from this function are returned to the command line.
function varargout = GLW_dipfit_view_dipole_OutputFcn(hObject, eventdata, handles) 
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





% --- Executes on selection change in dipole_listbox.
function dipole_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to dipole_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function dipole_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dipole_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in scalp_chk.
function scalp_chk_Callback(hObject, eventdata, handles)
% hObject    handle to scalp_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in glass_above_chk.
function glass_above_chk_Callback(hObject, eventdata, handles)
% hObject    handle to glass_above_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in glass_left_chk.
function glass_left_chk_Callback(hObject, eventdata, handles)
% hObject    handle to glass_left_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in glass_right_chk.
function glass_right_chk_Callback(hObject, eventdata, handles)
% hObject    handle to glass_right_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in glass_front_chk.
function glass_front_chk_Callback(hObject, eventdata, handles)
% hObject    handle to glass_front_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in glass_back_chk.
function glass_back_chk_Callback(hObject, eventdata, handles)
% hObject    handle to glass_back_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in plot_dipole_btn.
function plot_dipole_btn_Callback(hObject, eventdata, handles)
% hObject    handle to plot_dipole_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%dipole_data
dipole_data=get(handles.plot_dipole_btn,'Userdata');
%dipole_idx
dipole_idx=get(handles.dipole_listbox,'Userdata');
%selected_dipoles
selected_dipoles=get(handles.dipole_listbox,'Value');
%dipole_idx
dipole_idx=dipole_idx(selected_dipoles);
%display_methods
k=1;
if (get(handles.scalp_chk,'Value')==1);
    display_methods(k)=1;
    k=k+1;
end;
if (get(handles.glass_above_chk,'Value')==1);
    display_methods(k)=2;
    k=k+1;
end;
if (get(handles.glass_left_chk,'Value')==1);
    display_methods(k)=3;
    k=k+1;
end;
if (get(handles.glass_right_chk,'Value')==1);
    display_methods(k)=4;
    k=k+1;
end;
if (get(handles.glass_front_chk,'Value')==1);
    display_methods(k)=5;
    k=k+1;
end;
if (get(handles.glass_back_chk,'Value')==1);
    display_methods(k)=6;
    k=k+1;
end;
%volpos
volpos=str2num(get(handles.display_volume_edit,'String'));
%brightness
volcolor=[0.85 0.75 0.75];
%figure
h=figure;
set(h,'Color','w');
%loop through selected dipoles
for rowpos=1:length(dipole_idx);
    %vol
    vol=dipole_data(dipole_idx(rowpos).idx(1)).vol;
    %loop through display_methods
    for colpos=1:length(display_methods);
        %graphpos
        graphpos=colpos+((rowpos-1)*length(display_methods));
        %subplot (subaxis)
        a=subaxis(length(selected_dipoles),length(display_methods),graphpos,'MarginLeft',0.02,'MarginRight',0.02,'MarginTop',0.02,'MarginBottom',0.02,'SpacingHoriz',0.02,'SpacingVert',0.02);
        %method
        method=display_methods(colpos);
        %topo
        topo=dipole_data(dipole_idx(rowpos).idx(1)).topo_list(dipole_idx(rowpos).idx(2)).topo;
        %dipole
        dipole=dipole_data(dipole_idx(rowpos).idx(1)).dipole_list(dipole_idx(rowpos).idx(2)).dipole;
        %topoplot
        if method==1;
            %header_chanlocs
            header_chanlocs=dipole_data(dipole_idx(rowpos).idx(1)).header_chanlocs;
            %norm_length
            norm_length=get(handles.norm_diplength_chk,'Value');
            plot_topo(topo,header_chanlocs,dipole,norm_length);
        end;
        if method==2; %3D from above
            viewpoint=[0 90];
            elec=dipole_data(dipole_idx(rowpos).idx(1)).elec;
            vol=dipole_data(dipole_idx(rowpos).idx(1)).vol;
            volpos=str2num(get(handles.display_volume_edit,'String'));
            volcolor=[0.85 0.75 0.75];
            plot_vol(topo,elec,vol,volpos,dipole,volcolor,viewpoint);
        end;
        if method==3; %3D from left
            viewpoint=[270 0];
            elec=dipole_data(dipole_idx(rowpos).idx(1)).elec;
            vol=dipole_data(dipole_idx(rowpos).idx(1)).vol;
            volpos=str2num(get(handles.display_volume_edit,'String'));
            volcolor=[0.85 0.75 0.75];
            plot_vol(topo,elec,vol,volpos,dipole,volcolor,viewpoint);
        end;
        if method==4; %3D from right
            viewpoint=[90 0];
            elec=dipole_data(dipole_idx(rowpos).idx(1)).elec;
            vol=dipole_data(dipole_idx(rowpos).idx(1)).vol;
            volpos=str2num(get(handles.display_volume_edit,'String'));
            volcolor=[0.85 0.75 0.75];
            plot_vol(topo,elec,vol,volpos,dipole,volcolor,viewpoint);
        end;
        if method==5; %3D from back
            viewpoint=[180 0];
            elec=dipole_data(dipole_idx(rowpos).idx(1)).elec;
            vol=dipole_data(dipole_idx(rowpos).idx(1)).vol;
            volpos=str2num(get(handles.display_volume_edit,'String'));
            volcolor=[0.85 0.75 0.75];
            plot_vol(topo,elec,vol,volpos,dipole,volcolor,viewpoint);
        end;
        if method==6; %3D from back
            viewpoint=[0 0];
            elec=dipole_data(dipole_idx(rowpos).idx(1)).elec;
            vol=dipole_data(dipole_idx(rowpos).idx(1)).vol;
            volpos=str2num(get(handles.display_volume_edit,'String'));
            volcolor=[0.85 0.75 0.75];
            plot_vol(topo,elec,vol,volpos,dipole,volcolor,viewpoint);
        end;
    end;
end;





function plot_topo(topo,header_chanlocs,dipole,norm_length);
%topoplot
gridscale=256;
if norm_length==0;
    topoplot(topo,header_chanlocs,'dipole',dipole,'diporient',-1,'dipnorm','off','gridscale',gridscale,'shading','interp','whitebk','on');
else
    topoplot(topo,header_chanlocs,'dipole',dipole,'diporient',-1,'dipnorm','on','gridscale',gridscale,'shading','interp','whitebk','on');
end;





function plot_vol(topo,elec,vol,volpos,dipole,volcolor,viewpoint);
%fetch patch
tri=vol.bnd(volpos).tri;
pnt=vol.bnd(volpos).pnt;
%volume limits
xmax=max(abs(elec.pnt(:,1)));
ymax=max(abs(elec.pnt(:,2)));
zmax=max(abs(elec.pnt(:,3)));
%white background
set(gcf,'Color','w');
%color map
colormap=volcolor;
%plot volume
trisurf(tri,pnt(:,1),pnt(:,2),pnt(:,3),1,'EdgeColor','none','DiffuseStrength',0.3,'FaceAlpha',0.5);
material metal;
camlight;
lighting gouraud;
%tighten scales to volume limits
set(gca,'XLim',[-xmax xmax]);
set(gca,'YLim',[-ymax ymax]);
set(gca,'ZLim',[-zmax zmax]);
hold on;
%fetch dipole information
if ndims(dipole)==1;
    dip(1).posxyz=dipole.posxyz(:);
    dip(1).momxyz=dipole.momxyz(:);
else
    for i=1:size(dipole.posxyz,1);
        dip(i).posxyz=dipole.posxyz(i,:);
        dip(i).momxyz=dipole.momxyz(i,:);
    end;
end;
%reformat dipole information
for i=1:length(dip);
    dip(i).posxyz(2)=-dip(i).posxyz(2);
    dip(i).posxyz(:)=dip(i).posxyz([2 1 3]);
    dip(i).momxyz(2)=-dip(i).momxyz(2);
    dip(i).momxyz(:)=dip(i).momxyz([2 1 3]);
    ft_plot_dipole(dip(i).posxyz,dip(i).momxyz,'units','mm');
end;
%set viewpoint
view(viewpoint);
hold off;










function display_volume_edit_Callback(hObject, eventdata, handles)
% hObject    handle to display_volume_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function display_volume_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_volume_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in superimposed_popup.
function superimposed_popup_Callback(hObject, eventdata, handles)
% hObject    handle to superimposed_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes during object creation, after setting all properties.
function superimposed_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to superimposed_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_superimposed_btn.
function plot_superimposed_btn_Callback(hObject, eventdata, handles)
% hObject    handle to plot_superimposed_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in norm_diplength_chk.
function norm_diplength_chk_Callback(hObject, eventdata, handles)
% hObject    handle to norm_diplength_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of norm_diplength_chk
