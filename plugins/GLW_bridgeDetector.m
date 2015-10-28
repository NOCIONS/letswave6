function varargout = GLW_bridgeDetector(varargin)
% GLW_BRIDGEDETECTOR M-file for GLW_bridgeDetector.fig
%      GLW_BRIDGEDETECTOR, by itself, creates a new GLW_BRIDGEDETECTOR or raises the existing
%      singleton*.
%
%      H = GLW_BRIDGEDETECTOR returns the handle to a new GLW_BRIDGEDETECTOR or the handle to
%      the existing singleton*.
%
%      GLW_BRIDGEDETECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_BRIDGEDETECTOR.M with the given input arguments.
%
%      GLW_BRIDGEDETECTOR('Property','Value',...) creates a new GLW_BRIDGEDETECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_bridgeDetector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_bridgeDetector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_bridgeDetector

% Last Modified by GUIDE v2.5 06-Sep-2013 15:10:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_bridgeDetector_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_bridgeDetector_OutputFcn, ...
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


% --- Executes just before GLW_bridgeDetector is made visible.
function GLW_bridgeDetector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_bridgeDetector (see VARARGIN)

% Choose default command line output for GLW_bridgeDetector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles=varargin{2};
set(handles.filebox,'String',inputfiles);

% UIWAIT makes GLW_bridgeDetector wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_bridgeDetector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in filebox.
function filebox_Callback(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns filebox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filebox


% --- Executes during object creation, after setting all properties.
function filebox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filebox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_threshold_Callback(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_threshold as text
%        str2double(get(hObject,'String')) returns contents of edit_threshold as a double


% --- Executes during object creation, after setting all properties.
function edit_threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_output.
function checkbox_output_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_output


% --- Executes on button press in pushbutton_process.
function pushbutton_process_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


inputfiles=get(handles.filebox,'String');
 %process
    disp('*** Detecting bridges');
    
for filepos=1:length(inputfiles);
    [header,data]=CLW_load(inputfiles{filepos});
    sizeData = size(data);
    chanLabels = {header.chanlocs.labels};
    chanlocs=header.chanlocs;
    %if we have multiple epochs, we want to DC correct, detrend and concatenate
    %them first.
    datatemp = [];
    if sizeData(1) > 1
        NbBinsSegment = sizeData(6);
        binStart = 1:NbBinsSegment:NbBinsSegment*sizeData(1);
        binEnd = binStart-1;
        binEnd(1)=[];
        binEnd(length(binEnd)+1) = binEnd(length(binEnd)) + NbBinsSegment;
        for ss = 1:sizeData(1);
            datatemp(1,:,1,1,1,binStart(ss):binEnd(ss)) = detrend(detrend(squeeze(data(ss,:,:,:,:,:))','constant'))';
        end
        data = datatemp;
    end
    
    %parse data and chanlocs according to topo_enabled
    k=1;
    for chanpos=1:size(chanlocs,2);
        if chanlocs(chanpos).topo_enabled==1
            chanlocs2(k)=chanlocs(chanpos);
            chanind(k) = chanpos;
            k=k+1;
        end;
    end;
    header.chanlocs = chanlocs2;
    chanLabels = chanLabels(chanind);
    chandata = squeeze(data(1,chanind,1,1,1,:));
    Nel = size(chandata,1);
    
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
    
    %compute covariance mtrix across channels
    covMat = [];
    bcount = 0;
    for b = 1:length(binStart);
        if binEnd(b) > binStart(b) + 10; % if segment has more than 10 bins
             bcount =  bcount + 1;
            datatemp = detrend(detrend(chandata(:,fix(binStart(b)):fix(binEnd(b)))','constant'));
            %         figure;plot(datatemp);
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
    
    %%% optional: scale the correlation by the standard deviation of the
    % %correlation values
    % stdcovMat = stdcovMat ./ mean(stdcovMat(:));
    % stdcovMat(stdcovMat<0.00001) = 0.001;
    % covMat = covMat ./stdcovMat;
    % %normalize
    % covMat = (covMat-min(covMat(upperPartInd))) / (max(covMat(upperPartInd)) - min(covMat(upperPartInd)));
    % covMat = (covMat * 2) -1;
    %%%
    
    %remove upper triangle and diagonal then threshold
    covMat(upperPartInd) = 0;
    threshold = str2num(get(handles.edit_threshold,'String'));
    BridgedElectrodesInd = find(covMat > threshold);
    
    %plot
    % figure('color',[1 1 1]);
    % imagesc([1:Nel],[1:Nel],covMat,[threshold 1]); colorbar
    % set(gca,'Xtick',[1:Nel],'Xticklabel',chanLabels,'Ytick',[1:Nel],'Yticklabel',chanLabels,'fontsize',6);
    
    if ~isempty(BridgedElectrodesInd);
        figure;
        imagesc([1:Nel],[1:Nel],covMat,[threshold 1]);
        hc=colorbar;
        set(gca,'ydir','normal');
        
        ds.chanPairs = [];
        [ds.chanPairs(:, 1) ds.chanPairs(:, 2)] = ind2sub([Nel Nel],BridgedElectrodesInd);
        ds.connectStrength = covMat(BridgedElectrodesInd);
        topoplot_connect(ds, header.chanlocs); % external function
        title(sprintf('\n%s\nPotentially bridged electrodes',n),'interpreter','none');       
        
        if get(handles.checkbox_output,'value');
           fprintf('\n');
%             disp(sprintf('  file:%s', n));
            disp('  Electrode pairs   Correlation')
            for E=1:length(BridgedElectrodesInd);
                fprintf('  %s - %s              %.3f\n',chanlocs(ds.chanPairs(E, 1)).labels,chanlocs(ds.chanPairs(E, 2)).labels,ds.connectStrength(E));
            end
        end
    else        
%         disp(n);
        disp('  --> no above threshold pair-wise correlation detected');
    end
    fprintf('\n\n');
end

disp('**finished');
    
    
    
    
    
    
    
    
    
    
    
    
    
    
