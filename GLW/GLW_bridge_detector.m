function varargout = GLW_bridge_detector(varargin)
% GLW_BRIDGE_DETECTOR MATLAB code for GLW_bridge_detector.fig






% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GLW_bridge_detector_OpeningFcn, ...
                   'gui_OutputFcn',  @GLW_bridge_detector_OutputFcn, ...
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









% --- Executes just before GLW_bridge_detector is made visible.
function GLW_bridge_detector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure1
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_bridge_detector (see VARARGIN)
% Choose default command line output for GLW_bridge_detector
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
%populate datasets_popup
st={};
for i=1:length(datasets);
    st{i}=datasets(i).header.name;
end;
set(handles.dataset_popup,'String',st);
%table_data
for i=1:length(datasets)
    table_data(i).table={};
end;
set(handles.uitable,'UserData',table_data);
update_table(handles);
%!!!
%END
%!!!
% UIWAIT makes the GUI wait for user response (see UIRESUME)
uiwait(handles.figure1);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_bridge_detector_OutputFcn(hObject, eventdata, handles) 
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
%operation_popup
configuration.parameters=[];
%!!!
%END
%!!!
%put back configuration
set(handles.process_btn,'Userdata',configuration);
close(handles.figure1);






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
    set(handles.prefix_edit,'Visible','on');
end;
    




% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiresume(handles.figure1);



function threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes during object creation, after setting all properties.
function threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in run_btn.
function run_btn_Callback(hObject, eventdata, handles)
% hObject    handle to run_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%datasets
datasets=get(handles.prefix_edit,'Userdata');
%table_data
table_data=get(handles.uitable,'UserData');
%loop through datasets
for dataset_pos=1:length(datasets);
    data=datasets(dataset_pos).data;
    header=datasets(dataset_pos).header;
    sizeData=size(data);
    chanLabels={header.chanlocs.labels};
    chanlocs=header.chanlocs;
    %if we have multiple epochs, we want to DC correct, detrend and concatenate them first.
    datatemp=[];
    if sizeData(1)>1
        NbBinsSegment=sizeData(6);
        binStart=1:NbBinsSegment:NbBinsSegment*sizeData(1);
        binEnd=binStart-1;
        binEnd(1)=[];
        binEnd(length(binEnd)+1)=binEnd(length(binEnd))+NbBinsSegment;
        for ss=1:sizeData(1);
            datatemp(1,:,1,1,1,binStart(ss):binEnd(ss))=detrend(detrend(squeeze(data(ss,:,:,:,:,:))','constant'))';
        end
        data=datatemp;
    end
    %parse data and chanlocs according to topo_enabled
    k=1;
    for chanpos=1:size(chanlocs,2);
        if chanlocs(chanpos).topo_enabled==1
            chanlocs2(k)=chanlocs(chanpos);
            chanind(k)=chanpos;
            k=k+1;
        end;
    end;
    header.chanlocs=chanlocs2;
    chanLabels=chanLabels(chanind);
    chandata=squeeze(data(1,chanind,1,1,1,:));
    Nel=size(chandata,1);
    %use segments of 1.5 seconds to compute correlation between electrodes. That
    %allows to reduce the impact of common general trends across electrodes
    %(even if not bridged) to affect the correlations. Also I remove the DC and
    %do a linear linear detrend separately on each segment/electrode.
    segLength = 1.5;
    NbSegments = 20;    
    NbBinsSegment = segLength/header.xstep;
    binStart = 1:NbBinsSegment:NbBinsSegment*NbSegments;
    binEnd = binStart+1;
    binEnd(1)=[];
    binEnd(length(binEnd)+1) = binEnd(length(binEnd)) + NbBinsSegment;
    %make sure we're not trying to use more data than what we have.
    binStart(binStart > size(chandata,2)) = [];
    binEnd(binEnd > size(chandata,2)) = [];    
    %compute covariance matrix across channels
    covMat = [];
    bcount = 0;
    for b = 1:length(binStart);
        if binEnd(b) > binStart(b) + 10; % if segment has more than 10 bins
             bcount =  bcount + 1;
            datatemp = detrend(detrend(chandata(:,fix(binStart(b)):fix(binEnd(b)))','constant'));
            covMat(:,:,bcount) = corrcoef(datatemp);
        end
    end
    %compute mean and standard deviation across correlation measures for
    %different segments.
    stdcovMat = std(covMat,[],3);
    covMat = mean(covMat,3);
    %indices for upper triangle of covariance matrix (symetrical around the
    %diagonal)
    upperPartInd = logical(triu(ones(Nel,Nel)));
    %remove upper triangle and diagonal then threshold
    covMat(upperPartInd) = 0;
    threshold = str2num(get(handles.threshold_edit,'String'));
    BridgedElectrodesInd = find(covMat > threshold);
    if ~isempty(BridgedElectrodesInd);
        figure;
        imagesc([1:Nel],[1:Nel],covMat,[threshold 1]);
        hc=colorbar;
        set(gca,'ydir','normal');
        ds.chanPairs = [];
        [ds.chanPairs(:, 1) ds.chanPairs(:, 2)] = ind2sub([Nel Nel],BridgedElectrodesInd);
        ds.connectStrength = covMat(BridgedElectrodesInd);
        topoplot_connect(ds, header.chanlocs); % external function
        title(header.name);       
        tp_table={};
        for E=1:length(BridgedElectrodesInd);
            tp_table{E,1}=chanlocs(ds.chanPairs(E, 1)).labels;
            tp_table{E,2}=chanlocs(ds.chanPairs(E, 2)).labels;
            tp_table{E,3}=num2str(ds.connectStrength(E));
        end
    else        
        tp_table={};
    end
    table_data(dataset_pos).table=tp_table;
end
set(handles.uitable,'UserData',table_data);
update_table(handles);



function update_table(handles);
table_data=get(handles.uitable,'UserData');
datasetpos=get(handles.dataset_popup,'Value');
set(handles.uitable,'Data',table_data(datasetpos).table);



% --- Executes on selection change in dataset_popup.
function dataset_popup_Callback(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_table(handles);




% --- Executes during object creation, after setting all properties.
function dataset_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dataset_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
