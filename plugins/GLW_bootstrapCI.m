function varargout = GLW_bootstrapCI(varargin)
% GLW_BOOTSTRAPCI M-file for GLW_bootstrapCI.fig
%      GLW_BOOTSTRAPCI, by itself, creates a new GLW_BOOTSTRAPCI or raises the existing
%      singleton*.
%
%      H = GLW_BOOTSTRAPCI returns the handle to a new GLW_BOOTSTRAPCI or the handle to
%      the existing singleton*.
%
%      GLW_BOOTSTRAPCI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_BOOTSTRAPCI.M with the given input arguments.
%
%      GLW_BOOTSTRAPCI('Property','Value',...) creates a new GLW_BOOTSTRAPCI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_bootstrapCI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_bootstrapCI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_bootstrapCI

% Last Modified by GUIDE v2.5 11-Jun-2013 14:33:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_bootstrapCI_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_bootstrapCI_OutputFcn, ...
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


% --- Executes just before GLW_bootstrapCI is made visible.
function GLW_bootstrapCI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_bootstrapCI (see VARARGIN)

% Choose default command line output for GLW_bootstrapCI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles = varargin{2};
set(handles.filebox,'String',inputfiles);

% UIWAIT makes GLW_bootstrapCI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%load header files to determine number of epochs per file
NbEpochs = [];
NbAvailableBoot = [];
for filepos=1:length(inputfiles);
    %load header
    header=LW_load_header(inputfiles{filepos});
    NbEpochs = [NbEpochs,'  ',num2str(header.datasize(1))];
    R = header.datasize(1);
    N= header.datasize(1);
    NbAvailableBoot = [NbAvailableBoot,'  ',num2str(factorial(R+N-1) / (factorial(N-1) * factorial(R)))];
end

% update Number of Epochs box and number of bootstrap box
set(handles.text_NbFiles,'String',NbEpochs);
set(handles.text_NbBootstraps,'String',NbAvailableBoot);




% --- Outputs from this function are returned to the command line.
function varargout = GLW_bootstrapCI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_NbBootstraps_Callback(hObject, eventdata, handles)
% hObject    handle to edit_NbBootstraps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_NbBootstraps as text
%        str2double(get(hObject,'String')) returns contents of edit_NbBootstraps as a double



% --- Executes during object creation, after setting all properties.
function edit_NbBootstraps_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_NbBootstraps (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_CIPercentile_Callback(hObject, eventdata, handles)
% hObject    handle to edit_CIPercentile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_CIPercentile as text
%        str2double(get(hObject,'String')) returns contents of edit_CIPercentile as a double


% --- Executes during object creation, after setting all properties.
function edit_CIPercentile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_CIPercentile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_Filename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_Filename as text
%        str2double(get(hObject,'String')) returns contents of edit_Filename as a double


% --- Executes during object creation, after setting all properties.
function edit_Filename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Filename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_pvalue.
function checkbox_pvalue_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_pvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_pvalue


% --- Executes on button press in checkbox_sigMask.
function checkbox_sigMask_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_sigMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_sigMask


% --- Executes on button press in pushbutton_process.
function pushbutton_process_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_process (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

inputfiles=get(handles.filebox,'String');

%1. load all files
disp('*** loading Files:');
% for D=1:length(inputfiles)
% disp(inputfiles{D});
% end
data2boot = [];
for filepos=1:length(inputfiles);
    [header,data]=LW_load(inputfiles{filepos});
    if header.datasize(1) == 1;
        error('I need multiple epochs to run bootstrap analyses!');
    end    
    %bootstrap
    NbSub = header.datasize(1);
    randSampling = [combsrep(1:NbSub,NbSub)];
    randSampling = randSampling(randperm(size(randSampling,1)),:);
    Nboot = str2double(get(handles.edit_NbBootstraps,'string'));
    while size(randSampling,1) < Nboot;
        randSampling = [randSampling;randSampling(randperm(size(randSampling,1)),:)];
    end
    randSampling = randSampling(1:Nboot,:);
    tail = str2double(get(handles.edit_tails,'String'));
    if tail > 2; tail = 2; end;
    if tail < 1; tail = 1; end;
    %confidence interval
    percentCI = str2double(get(handles.edit_CIPercentile,'string'));
    percentCI = 1-percentCI;
    loCI = max(round(Nboot*percentCI/tail),1);
    hiCI = Nboot - loCI +1;
    
    %boot
    disp('*** Computing bootstrap...');
    bootsort = zeros(Nboot,size(data,2),size(data,3),size(data,4),size(data,5),size(data,6));
    %loop through all the data
    for indexpos=1:size(data,3);
        for dz=1:size(data,4);
            for dy=1:size(data,5);
                for b=1:Nboot;
                    bootsort(b,:,indexpos,dz,dy,:) = squeeze(mean(data(randSampling(b,:),:,indexpos,dz,dy,:),1));
                end
            end;
        end;
    end;
    % average over epochs
    MeanData = mean(data,1);
    clear data;
    
    disp('*** Computing statistics... It may take a while...');
    computePval = 0;
    if get(handles.checkbox_pvalue,'Value');
        computePval = 1;
        PvalueStore = zeros(size(bootsort,2),size(bootsort,3),size(bootsort,4),size(bootsort,5),size(bootsort,6));
        threshold = str2double(get(handles.edit_threshold,'String'));
    end
    
    ci = zeros(2,size(bootsort,2),size(bootsort,3),size(bootsort,4),size(bootsort,5),size(bootsort,6));  
    for channelpos=1:size(bootsort,2);
        for indexpos=1:size(bootsort,3);
            for dz=1:size(bootsort,4);
                for dy=1:size(bootsort,5);                    
                    bootsortC = sort(bootsort(:,channelpos,indexpos,dz,dy,:));
                    %confidence interval
                    ci(:,channelpos,indexpos,dz,dy,:) = bootsortC([loCI hiCI],1,indexpos,dz,dy,:);
                    if computePval
                        for F=1:size(bootsortC,6);
                            if threshold < max(bootsortC(:,1,indexpos,dz,dy,F)) && threshold > min(bootsortC(:,1,indexpos,dz,dy,F));
                                temp_P = find(bootsortC(:,1,indexpos,dz,dy,F) >= threshold);
                                tempPval(1) = (1-(temp_P(1)-1)/Nboot)*tail;
                                tempPval(2) = (temp_P(1)/Nboot)*tail;
                                PvalueStore(channelpos,indexpos,dz,dy,F) = min(tempPval);
                            else PvalueStore(channelpos,indexpos,dz,dy,F) = (1/(Nboot+1))*tail; %realDIff is outside bootstrap range
                            end
                        end
                    end
                end
            end
        end
    end
    clear bootsort bootsortC
    
    % --- Save data;
    % update header nb of epochs
    outheader=header;
    %add history
    i=length(outheader.history)+1;
    outheader.history(i).description='LW_boostrapCI';
    outheader.history(i).date=date;
    outheader.datasize(1) = 1;
    header = outheader;
    
    preprefix = get(handles.edit_Filename,'String');
    %-- 1 save CI
    %     a. low CI
    data(1,:,1,1,1,:) = ci(1,:,:,:,:,:);
    %save
    prefix = [preprefix,' ciLow_',num2str(1-percentCI)];
    LW_save(inputfiles{filepos},prefix,header,data);
    
    %     a. hi CI
    data(1,:,1,1,1,:) = ci(2,:,:,:,:,:);
    %save 
    prefix = [preprefix,' ciHi_',num2str(1-percentCI)];
    LW_save(inputfiles{filepos},prefix,header,data);
    
    %-- 2. save pvalue
    if computePval
        if get(handles.checkbox_log10,'Value');
            data(1,:,1,1,1,:) = -log10(PvalueStore);
        else
            data(1,:,1,1,1,:) = PvalueStore;
        end
        %save
        prefix = [preprefix,' Pvalues'];
        LW_save(inputfiles{filepos},prefix,header,data);
    end
    
    % --- 3 sig mask
    if get(handles.checkbox_sigMask,'Value');
        isPositive = [];
        isNegative = [];
        isPositive(:,1,1,1,:) = squeeze(MeanData) > threshold;
        isNegative(:,1,1,1,:) = squeeze(MeanData) < threshold;
        isSig = PvalueStore < percentCI;
        
        if get(handles.checkbox_savePositive,'Value') && get(handles.checkbox_saveNegative,'Value');
            %both
            mask = ones(size(isSig));
        elseif get(handles.checkbox_savePositive,'Value') && ~get(handles.checkbox_saveNegative,'Value');
            mask = isPositive;
        elseif ~get(handles.checkbox_savePositive,'Value') && get(handles.checkbox_saveNegative,'Value');
            mask = isNegative;
        elseif ~get(handles.checkbox_savePositive,'Value') && ~get(handles.checkbox_saveNegative,'Value');
            mask = zeros(size(isNegative));
        end
        % build mask
        data(1,:,1,1,1,:) = isSig.*mask;
        %save
        prefix = [preprefix,' SigMask_',num2str(1-percentCI)];
        LW_save(inputfiles{filepos},prefix,header,data);
        
        if computePval % save Pvalues masked for significance
            if get(handles.checkbox_log10,'Value');
                data(1,:,1,1,1,:) = -log10(PvalueStore) .* (isSig.*mask);
            else
                data(1,:,1,1,1,:) = PvalueStore .* (isSig.*mask);
            end
            %save
            prefix = [preprefix,' Pval_x_mask_',num2str(1-percentCI)];
            LW_save(inputfiles{filepos},prefix,header,data);
        end     
    end
end
disp('*** Finished.');




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



function edit_tails_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tails (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tails as text
%        str2double(get(hObject,'String')) returns contents of edit_tails as a double


% --- Executes during object creation, after setting all properties.
function edit_tails_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tails (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_log10.
function checkbox_log10_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_log10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_log10


% --- Executes on button press in checkbox_savePositive.
function checkbox_savePositive_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_savePositive (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_savePositive


% --- Executes on button press in checkbox_saveNegative.
function checkbox_saveNegative_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_saveNegative (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_saveNegative


