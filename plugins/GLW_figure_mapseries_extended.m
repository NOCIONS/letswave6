function varargout = GLW_figure_mapseries_extended(varargin)
% GLW_FIGURE_MAPSERIES_EXTENDED MATLAB code for GLW_figure_mapseries_extended.fig
%




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_figure_mapseries_extended_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_figure_mapseries_extended_OutputFcn, ...
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




% --- Executes just before GLW_figure_mapseries_extended is made visible.
function GLW_figure_mapseries_extended_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_figure_mapseries_extended (see VARARGIN)
% Choose default command line output for GLW_figure_mapseries_extended
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%fill listbox with inputfiles (the array of input files is stored in varargin{2})
%The 'UserData' field contains the full path+filename of the LW5 datafile
set(handles.filebox,'UserData',varargin{2});
st=get(handles.filebox,'UserData');
for i=1:length(st);
    [p,n,e]=fileparts(st{i});
    inputfiles{i}=n;
end;
set(handles.filebox,'Value',1);
%The 'String' field only contains the name (without path and extension)
set(handles.filebox,'String',inputfiles);
%Headers
for i=1:length(st);
    load(st{i},'-mat');
    userdata(i).header=header;
    userdata(i).filename=st{i};
end;
set(handles.epochbox,'UserData',userdata);
%epochs
filepos=get(handles.filebox,'Value');
header=userdata(filepos).header;
epochlist={};
for i=1:header.datasize(1);
    epochlist{i}=num2str(i);
end;
set(handles.epochbox,'String',epochlist);
set(handles.epochbox,'Value',1);
set(handles.uitable,'Data',{});
set(handles.uitable,'UserData',[]);







% --- Outputs from this function are returned to the command line.
function varargout = GLW_figure_mapseries_extended_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure





% --- Executes during object creation, after setting all properties.
function figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called





% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filepos=get(handles.filebox,'Value');
userdata=get(handles.epochbox,'UserData');
header=userdata(filepos).header;
epochlist={};
for i=1:header.datasize(1);
    epochlist{i}=num2str(i);
end;
set(handles.epochbox,'String',epochlist);
set(handles.epochbox,'Value',1);




% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in processbutton.
function processbutton_Callback(hObject, eventdata, handles)
% hObject    handle to processbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
%userdata
userdata=get(handles.epochbox,'UserData');
%tabledata
dispdata=get(handles.uitable,'UserData');
%cmin,cmax
cminG=str2num(get(handles.cmin_edit,'String'));
cmaxG=str2num(get(handles.cmax_edit,'String'));
%xi
xstart=str2num(get(handles.xstart_edit,'String'));
xend=str2num(get(handles.xend_edit,'String'));
mapcount=fix(str2num(get(handles.mapcount_edit,'String')));
disp(['Number of maps : ' num2str(mapcount)]);
xi=linspace(xstart,xend,mapcount);

%--update from CJ (june 10th 2013)
if ~isempty(get(handles.ManualInterval,'String'))
    xi = eval(sprintf('[%s]',get(handles.ManualInterval,'String')));
end
%--end update
disp(['xi : ' num2str(xi)]);
%figure
figure('color',[1 1 1]);
%viewpoint
viewpoint=get(handles.viewpoint_popup,'Value');
% top
% bottom
% front
% back
% left
% right
Az=[0 0 -180 0 -90 90];
El=[90 -90 0 0 0 0] ;

%electrode on or off
electrodeOn = 'off';
if get(handles.electrodeOn,'Value')
electrodeOn = 'on';
end

%colormap
cmapstr = get(handles.popup_colormap,'string');
cmapVal = get(handles.popup_colormap,'Value');
cmapVal = cmapstr{cmapVal};
if strcmpi(cmapVal,'halfJetWhite')
    load 'halfJetWhite.mat';
    cmapVal = 'cmap';
end
if strcmpi(cmapVal,'halfJetGray');    
    load 'halfJetGray.mat';
    cmapVal = 'cmap';
end
if strcmpi(cmapVal,'jetwhite')
load 'jetwhite_colormap.mat';
cmapVal = 'cmap';
end

if strcmpi(cmapVal,'jetGray')
load 'jetGray.mat';
cmapVal = 'cmap';
end

if strcmpi(cmapVal,'jetSigPval')
    h=figure;
    cmap =colormap(jet);
    cmap(1,:)=0.6;%if using pvaluelog    
    cmapVal = 'cmap';
    close(h);
end

% checkbox_avg_intervals
% we want to load all the data to determine the min
%and max color axis by row.

%loop through rows
for rowpos=1:size(dispdata,1);
    %filepos,epochpos
    filepos=dispdata(rowpos,1);
    epochpos=dispdata(rowpos,2);
    %header
    header=userdata(filepos).header;
    %filename
    filename=userdata(filepos).filename;
    %load data
    [p n e]=fileparts(filename);
    st=[p filesep n '.mat'];
    disp(['loading : ' st]);
    load(st,'-mat');
    dataCell{rowpos} = data;
    clear data;
    %xi > dxi
    dxi=round(((xi-header.xstart)/header.xstep))+1; %CJ edit: changed from fix to round.
    %dy,dz,index
    dy=1;
    dz=1;
    index=1;
    if get(handles.checkbox_avg_intervals,'value');
        for i=1:length(dxi)-1;
            %determine cmin and cmax based on available channels
            isChannelLocation = ~cellfun(@isempty,{header.chanlocs.X});
            vector=squeeze(mean(dataCell{rowpos}(epochpos,isChannelLocation,index,dz,dy,dxi(i):dxi(i+1)),6));
            
            cmax = cmaxG;
            cmin = cminG;
            if isempty(cmaxG) && isempty(cminG);
                cmax = max(abs(vector));
                cmin = -max(abs(vector));
            end
            if isempty(cmax);
                cmax = max(vector);
            end
            if isempty(cmin);
                cmin = min(vector);
            end
            if cmax < cmin
                cmax = cmin+0.01;
            end
            cmaxStore(rowpos,i) = cmax;
            cminStore(rowpos,i) = cmin;
            
        end
    else
        %loop through dxi
        for i=1:length(dxi);
            %determine cmin and cmax based on available channels
            isChannelLocation = ~cellfun(@isempty,{header.chanlocs.X});
            vector=squeeze(dataCell{rowpos}(epochpos,isChannelLocation,index,dz,dy,dxi(i)));
            
            cmax = cmaxG;
            cmin = cminG;
            if isempty(cmaxG) && isempty(cminG);
                cmax = max(abs(vector));
                cmin = -max(abs(vector));
            end
            if isempty(cmax);
                cmax = max(vector);
            end
            if isempty(cmin);
                cmin = min(vector);
            end
            if cmax < cmin
                cmax = cmin+0.01;
            end
            cmaxStore(rowpos,i) = cmax;
            cminStore(rowpos,i) = cmin;
        end
    end
end
cmaxStore = max(cmaxStore);
cminStore = min(cminStore);


%loop through rows
for rowpos=1:size(dispdata,1);
    %filepos,epochpos
    filepos=dispdata(rowpos,1);
    epochpos=dispdata(rowpos,2);
    %header
    header=userdata(filepos).header;
    %filename
    filename=userdata(filepos).filename;
    %load data
%     [p n e]=fileparts(filename);
%     st=[p filesep n '.mat'];
%     disp(['loading : ' st]);
%     load(st,'-mat');
    %xi > dxi
    dxi=round(((xi-header.xstart)/header.xstep))+1; %CJ edit: changed from fix to round.
    %dy,dz,index
    dy=1;
    dz=1;
    index=1;
    if get(handles.checkbox_avg_intervals,'value');
         for i=1:length(dxi)-1;
        %subplot
        subplot(size(dispdata,1),length(dxi)-1,((rowpos-1)*(length(dxi)-1))+i);
        
        cmax = cmaxStore(i);
        cmin = cminStore(i);
        
         %headplot
        if get(handles.radiobutton_headplot,'Value');
            vector = squeeze(mean(dataCell{rowpos}(epochpos,isChannelLocation,index,dz,dy,dxi(i):dxi(i+1)),6));
            meanWinData = dataCell{rowpos}(epochpos,isChannelLocation,index,dz,dy,dxi(i):dxi(i+1));
            meanWinData(:,:,:,:,:,1:2) = [vector ;vector]';
            meanWinData(:,:,:,:,:,3:end) = [];                      
            LW_headplot(header,meanWinData,epochpos,index,1,dy,dz,'maplimits',[cmin cmax],'electrodes',electrodeOn);
            %viewpoint
            if ~isempty(get(handles.exactView,'string'));
                viewVal = str2double(get(handles.exactView,'string'));
                set(gca,'View',viewVal);
            else
                set(gca,'View',[Az(viewpoint) El(viewpoint)]);
            end
            
        end
        if get(handles.radiobutton_scalpMap,'Value');
            vector = squeeze(mean(dataCell{rowpos}(epochpos,isChannelLocation,index,dz,dy,dxi(i):dxi(i+1)),6));
            meanWinData = dataCell{rowpos}(epochpos,isChannelLocation,index,dz,dy,dxi(i):dxi(i+1));
            meanWinData(:,:,:,:,:,1:2) = [vector ;vector]';
            meanWinData(:,:,:,:,:,3:end) = []; 
            
            LW_topoplot(header,meanWinData,epochpos,index,1,dy,dz,'maplimits',[cmin cmax],'shading','interp','whitebk','on','electrodes',electrodeOn,'style','both');
%             colorbar;
        end
        %colormap
        eval(sprintf('colormap(%s)',cmapVal));
        %title
        title(gca,sprintf('%s-%s -Scale: %.2f - %.2f',num2str(xi(i)),num2str(xi(i+1)),cmin,cmax));
        
             
         end
        
    else
    %loop through dxi
    for i=1:length(dxi);
        %subplot
        subplot(size(dispdata,1),length(dxi),((rowpos-1)*length(dxi))+i);
        
        cmax = cmaxStore(i);
        cmin = cminStore(i);
        
        %headplot
        if get(handles.radiobutton_headplot,'Value');
            LW_headplot(header,dataCell{rowpos},epochpos,index,dxi(i),dy,dz,'maplimits',[cmin cmax],'electrodes',electrodeOn);
            %viewpoint
            if ~isempty(get(handles.exactView,'string'));
                viewVal = str2double(get(handles.exactView,'string'));
                set(gca,'View',viewVal);
            else
                set(gca,'View',[Az(viewpoint) El(viewpoint)]);
            end
            
        end
        if get(handles.radiobutton_scalpMap,'Value')
            LW_topoplot(header,dataCell{rowpos},epochpos,index,dxi(i),dy,dz,'maplimits',[cmin cmax],'shading','interp','whitebk','on','electrodes',electrodeOn,'style','both');
%        colorbar;
        end
        %colormap
        eval(sprintf('colormap(%s)',cmapVal));
        %title
        title(gca,sprintf('%s -Scale: %.2f - %.2f',num2str(xi(i)),cmin,cmax));
        
    end;
end
end;

if get(handles.checkbox_doprint,'Value');
    CCF=gcf;
    destPath = [pwd, filesep];
    XimPrintsize =str2double(get(handles.printSizeWidth,'String'));
    YimPrintsize =str2double(get(handles.printSizeHeigth,'String'));
    set(CCF,'PaperUnits','centimeters');
    set(CCF,'paperposition',[0 0 XimPrintsize YimPrintsize]);
    resol = str2double(get(handles.printSizeResolution,'String'));
    
    c=clock;
    
    % build save name
    headmap = '3D';
    if get(handles.radiobutton_scalpMap,'Value');
        headmap = '2D';
    end
    
   
    xi=sprintf('%.4g-',xi);
    xi(end) = [];  
    
    [p,n,e]=fileparts(userdata(1).filename);    
    
    figname = sprintf('%s int_%s clim_%.2g-%.2g_date_%i-%.2g-%i_%gh%gm%02ds',n,xi,cmin,cmax,c(3),c(2),c(1),c(4),c(5),round(c(6)));
    figname = sprintf('%s clim_%.2g-%.2g_date_%i-%.2g-%i_%gh%gm%02ds',n,cmin,cmax,c(3),c(2),c(1),c(4),c(5),round(c(6)));
    eval(sprintf('print(CCF,''-dtiff'',''-r%i'',[destPath,figname,''.tiff''])',resol));
end






% --- Executes on selection change in epochbox.
function epochbox_Callback(hObject, eventdata, handles)
% hObject    handle to epochbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --- Executes during object creation, after setting all properties.
function epochbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addbutton.
function addbutton_Callback(hObject, eventdata, handles)
% hObject    handle to addbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filepos=get(handles.filebox,'Value');
epochpos=get(handles.epochbox,'Value');
filenames=get(handles.filebox,'String');
epochnames=get(handles.epochbox,'String');
tabledata=get(handles.uitable,'UserData');
if isempty(tabledata);
    tabledata(1,1)=filepos;
    tabledata(1,2)=epochpos;
else
    tabledata(end+1,1)=filepos;
    tabledata(end,2)=epochpos;
end;
for i=1:size(tabledata,1);
    table{i,1}=filenames{tabledata(i,1)};
    table{i,2}=epochnames{tabledata(i,2)};
end;
set(handles.uitable,'UserData',tabledata);
set(handles.uitable,'Data',table);





% --- Executes on button press in clearbutton.
function clearbutton_Callback(hObject, eventdata, handles)
% hObject    handle to clearbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.uitable,'UserData',[]);
set(handles.uitable,'Data',{});



function mapcount_edit_Callback(hObject, eventdata, handles)
% hObject    handle to mapcount_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mapcount_edit as text
%        str2double(get(hObject,'String')) returns contents of mapcount_edit as a double


% --- Executes during object creation, after setting all properties.
function mapcount_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapcount_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xstart_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xstart_edit as text
%        str2double(get(hObject,'String')) returns contents of xstart_edit as a double


% --- Executes during object creation, after setting all properties.
function xstart_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xstart_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xend_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xend_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xend_edit as text
%        str2double(get(hObject,'String')) returns contents of xend_edit as a double


% --- Executes during object creation, after setting all properties.
function xend_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xend_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cmin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmin_edit as text
%        str2double(get(hObject,'String')) returns contents of cmin_edit as a double


% --- Executes during object creation, after setting all properties.
function cmin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cmax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cmax_edit as text
%        str2double(get(hObject,'String')) returns contents of cmax_edit as a double


% --- Executes during object creation, after setting all properties.
function cmax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cmax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in viewpoint_popup.
function viewpoint_popup_Callback(hObject, eventdata, handles)
% hObject    handle to viewpoint_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns viewpoint_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from viewpoint_popup


% --- Executes during object creation, after setting all properties.
function viewpoint_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to viewpoint_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ManualInterval_Callback(hObject, eventdata, handles)
% hObject    handle to ManualInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ManualInterval as text
%        str2double(get(hObject,'String')) returns contents of ManualInterval as a double


% --- Executes during object creation, after setting all properties.
function ManualInterval_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ManualInterval (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_scalpMap.
function radiobutton_scalpMap_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_scalpMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_scalpMap
set(handles.radiobutton_headplot,'Value',0);
set(handles.radiobutton_scalpMap,'Value',1);

% --- Executes on button press in radiobutton_headplot.
function radiobutton_headplot_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_headplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_headplot
set(handles.radiobutton_headplot,'Value',1);
set(handles.radiobutton_scalpMap,'Value',0);



function exactView_Callback(hObject, eventdata, handles)
% hObject    handle to exactView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of exactView as text
%        str2double(get(hObject,'String')) returns contents of exactView as a double


% --- Executes during object creation, after setting all properties.
function exactView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exactView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in electrodeOn.
function electrodeOn_Callback(hObject, eventdata, handles)
% hObject    handle to electrodeOn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of electrodeOn


% --- Executes on selection change in colorMapList.
function colorMapList_Callback(hObject, eventdata, handles)
% hObject    handle to colorMapList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns colorMapList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colorMapList


% --- Executes during object creation, after setting all properties.
function colorMapList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colorMapList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popup_colormap.
function popup_colormap_Callback(hObject, eventdata, handles)
% hObject    handle to popup_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_colormap contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_colormap


% --- Executes during object creation, after setting all properties.
function popup_colormap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_colormap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printSizeHeigth_Callback(hObject, eventdata, handles)
% hObject    handle to printSizeHeigth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of printSizeHeigth as text
%        str2double(get(hObject,'String')) returns contents of printSizeHeigth as a double


% --- Executes during object creation, after setting all properties.
function printSizeHeigth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printSizeHeigth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printSizeWidth_Callback(hObject, eventdata, handles)
% hObject    handle to printSizeWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of printSizeWidth as text
%        str2double(get(hObject,'String')) returns contents of printSizeWidth as a double


% --- Executes during object creation, after setting all properties.
function printSizeWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printSizeWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function printSizeResolution_Callback(hObject, eventdata, handles)
% hObject    handle to printSizeResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of printSizeResolution as text
%        str2double(get(hObject,'String')) returns contents of printSizeResolution as a double


% --- Executes during object creation, after setting all properties.
function printSizeResolution_CreateFcn(hObject, eventdata, handles)
% hObject    handle to printSizeResolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_doprint.
function checkbox_doprint_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_doprint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_doprint


% --- Executes on button press in checkbox_avg_intervals.
function checkbox_avg_intervals_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_avg_intervals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_avg_intervals


