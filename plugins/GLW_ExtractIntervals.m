function varargout = GLW_ExtractIntervals(varargin)
% GLW_EXTRACTINTERVALS M-file for GLW_ExtractIntervals.fig
%      GLW_EXTRACTINTERVALS, by itself, creates a new GLW_EXTRACTINTERVALS or raises the existing
%      singleton*.
%
%      H = GLW_EXTRACTINTERVALS returns the handle to a new GLW_EXTRACTINTERVALS or the handle to
%      the existing singleton*.
%
%      GLW_EXTRACTINTERVALS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GLW_EXTRACTINTERVALS.M with the given input arguments.
%
%      GLW_EXTRACTINTERVALS('Property','Value',...) creates a new GLW_EXTRACTINTERVALS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GLW_ExtractIntervals_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GLW_ExtractIntervals_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GLW_ExtractIntervals

% Last Modified by GUIDE v2.5 28-Oct-2015 13:05:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_ExtractIntervals_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_ExtractIntervals_OutputFcn, ...
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


% --- Executes just before GLW_ExtractIntervals is made visible.
function GLW_ExtractIntervals_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_ExtractIntervals (see VARARGIN)

% Choose default command line output for GLW_ExtractIntervals
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%fill listbox with inputfiles
inputfiles=varargin{2};
set(handles.filebox,'String',inputfiles);

% UIWAIT makes GLW_ExtractIntervals wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GLW_ExtractIntervals_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Harmonics_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to Harmonics_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Harmonics_textbox as text
%        str2double(get(hObject,'String')) returns contents of Harmonics_textbox as a double


% --- Executes during object creation, after setting all properties.
function Harmonics_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Harmonics_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseFreq_textbox_Callback(hObject, eventdata, handles)
% hObject    handle to baseFreq_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseFreq_textbox as text
%        str2double(get(hObject,'String')) returns contents of baseFreq_textbox as a double


% --- Executes during object creation, after setting all properties.
function baseFreq_textbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseFreq_textbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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


% --- Executes on button press in process_button.
function process_button_Callback(hObject, eventdata, handles)
% hObject    handle to process_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get frequencies 
BaseFreq = eval(sprintf('[%s]',get(handles.baseFreq_textbox,'String')));
Harmonics = eval(sprintf('[%s]',get(handles.Harmonics_textbox,'String')));
freqBins = Harmonics.*BaseFreq;

%Do we need to add harmonic nb to filename?
if get(handles.checkbox_addHarmonicName,'Value')
    HarmonicsFileName = sprintf('%i-',Harmonics);
    HarmonicsFileName(end) = [];
else
    HarmonicsFileName = '';
end

%Get filenames to process
inputfiles=get(handles.filebox,'String');

%Init
data2XLSExport = {};

for filepos=1:length(inputfiles);
    [header,data]=LW_load(inputfiles{filepos});
    %process
    disp('*** Averaging harmonics');
    %     tp=1:1:header.datasize(6);
    %     freqAxis = ((tp-1)*header.xstep)+header.xstart;
    binHarmonics = round((freqBins - header.xstart) ./ header.xstep +1);
    %flag to determine whether we need to average harmonics or extract
    %individual harmonics.
    averageH = 0;
    outXsize = length(binHarmonics);
    
    
    Hmethod = [];
    if get(handles.radiobutton_extractH,'Value');
        Hmethod = 1;
    elseif get(handles.radiobutton_sumH,'Value');
        Hmethod = 2;
        outXsize = 2;        
    elseif get(handles.radiobutton_averageH,'Value');
        Hmethod = 3;
        outXsize = 2;        
    elseif get(handles.radiobutton_averagePositiveH,'Value');
        Hmethod = 4;
        outXsize = 2;
    end
    
    %loop through all the data
    outdata = data(:,:,:,:,:,1:outXsize);
    for epochpos=1:size(data,1);
        for indexpos=1:size(data,3);
            for dz=1:size(data,4);
                for dy=1:size(data,5);
                    % if we average harmonics, we'll end up with the 6th
                    % dimension of data as a signal point, which does not
                    % work. Thus, let's repeat the average twice, so we'll
                    % have 2 data points.
                    avgH = [];
                    switch Hmethod
                        case 1 % each interval
                            outdata(epochpos,:,indexpos,dz,dy,:) = data(epochpos,:,indexpos,dz,dy,binHarmonics);
                        case 2 % sum interval
                            avgH = squeeze(sum(data(epochpos,:,indexpos,dz,dy,binHarmonics),6));
                           %update outdata
                           outdata(epochpos,:,indexpos,dz,dy,:) = repmat(avgH',[1 2]);
                        case 3 % average interval
                            avgH = squeeze(mean(data(epochpos,:,indexpos,dz,dy,binHarmonics),6));
                           %update outdata
                            outdata(epochpos,:,indexpos,dz,dy,:) = repmat(avgH',[1 2]);
                        case 4                            
                            extAll = squeeze(data(epochpos,:,indexpos,dz,dy,binHarmonics));
                            %average non-zero data
                            for E = 1:size(extAll,1);
                                if any(extAll(E,:)~=0);
                                    avgH(1,E) = mean(extAll(E,extAll(E,:)~=0));
                                else
                                    avgH(1,E) = 0;
                                end
                             end                             
                             %update outdata
                             outdata(epochpos,:,indexpos,dz,dy,:) = repmat(avgH',[1 2]);
                            
                    end
                    if averageH
                        
                    else
                        %update outdata
                        
                    end
                end;
            end;
        end;
    end;
    %output
    data = outdata;
    
    if get(handles.checkbox_export2excell,'value');
        
        data2XLSExport{1,1} = 'Filename';
        data2XLSExport{1,2} = 'Epoch';
        data2XLSExport{1,3} = 'Electrode';
        data2XLSExport{1,4} = 'BaseFrequency';
        data2XLSExport{1,5} = 'Harmonic_nb';
        data2XLSExport{1,6} = 'Harmonic_freq';
        data2XLSExport{1,7} = 'Harmonic_binNb';
        data2XLSExport{1,8} = 'Data';
        
        %DAN's FUNCTION
        [p,n,e]=fileparts(inputfiles{filepos});
        data2XLSExport=LW_harmexport(data2XLSExport,data,n,header,freqBins,Harmonics,BaseFreq,binHarmonics,Hmethod);
        
    end
        
    %update xaxis values
    header.xstart = freqBins(1);
    header.xstep = abs(freqBins(2) - freqBins(1));
    header.datasize = size(data);
    
    %prefix
    prefix=[get(handles.prefixtext,'String') ' H_' HarmonicsFileName];
    %save
    LW_save(inputfiles{filepos},prefix,header,data);
end;

if get(handles.checkbox_export2excell,'value');
    c=clock;
    [p,n,e]=fileparts(inputfiles{1});
    savename = strrep(sprintf('%i-%02d-%02d_%02dh%02dm%02ds_%s',c(1),c(3),c(2),c(4),c(5),round(c(6)),n),' ','_');
    
    %open excell to determine whic version is available
    % Prepare proper filename extension.
    % Get the Excel version because if it's verions 11 (Excel 2003) the
    % file extension should be .xls,
    % but if it's 12.0 (Excel 2007) then we'll need to use an extension
    % of .xlsx to avoid mistakes.
    Excel = actxserver('Excel.Application');
    excelVersion = str2double(Excel.Version);
    if excelVersion < 12
        excelExtension = '.xls';
    else
        excelExtension = '.xlsx';
    end
    
    xlswrite([savename,excelExtension],data2XLSExport);
end
disp('*** Finished.');



function prefixtext_Callback(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of prefixtext as text
%        str2double(get(hObject,'String')) returns contents of prefixtext as a double



% --- Executes during object creation, after setting all properties.
function prefixtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to prefixtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_addHarmonicName.
function checkbox_addHarmonicName_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_addHarmonicName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_addHarmonicName


% --- Executes on button press in radiobutton_extractH.
function radiobutton_extractH_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_extractH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_extractH
set(handles.radiobutton_extractH,'Value',1);
set(handles.radiobutton_averageH,'Value',0);
set(handles.radiobutton_sumH,'Value',0);
set(handles.radiobutton_averagePositiveH,'Value',0);

% --- Executes on button press in radiobutton_averageH.
function radiobutton_averageH_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_averageH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_averageH
set(handles.radiobutton_extractH,'Value',0);
set(handles.radiobutton_averageH,'Value',1);
set(handles.radiobutton_sumH,'Value',0);
set(handles.radiobutton_averagePositiveH,'Value',0);


% --- Executes on button press in checkbox_export2excell.
function checkbox_export2excell_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_export2excell (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_export2excell

function data2XLSExport=LW_harmexport(data2XLSExport,data,filename,header,freqBins,Harmonics,BaseFreq,binHarmonics,averageH);

switch averageH
    case {2, 3, 4}
    sizeND=size(data2XLSExport);
    sizeD=size(data);
    for i=1:sizeD(1)
        sizeND=size(data2XLSExport);
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),8)=num2cell(data(i,:,1,1,1,1))';
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),1)={filename};
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),2)={i};
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),3)={header.chanlocs(1,1:sizeD(2)).labels}';
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),4)={BaseFreq};
        switch averageH
            case 2
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),5)={['sum: ',mat2str(Harmonics)]};
            case 3
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),5)={['avg: ',mat2str(Harmonics)]};
            case 4
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),5)={['avg ~=0: ',mat2str(Harmonics)]};       
        end
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),6)={mat2str(freqBins)};       
        data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),7)={mat2str(binHarmonics)};
    end
    case 1
    sizeND=size(data2XLSExport);
    sizeD=size(data);
    
    for i=1:sizeD(1)
        for j=1:sizeD(6)
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),8)=num2cell(data(i,:,1,1,1,j))';
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),1)={filename};
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),2)={i};
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),3)={header.chanlocs(1,1:sizeD(2)).labels}';
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),4)={BaseFreq};
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),5)={Harmonics(j)};
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),6)={freqBins(j)};
            data2XLSExport(sizeND(1)+1:sizeND(1)+sizeD(2),7)={binHarmonics(j)};
            sizeND=size(data2XLSExport);
        end
    end
end


% --- Executes on button press in radiobutton_sumH.
function radiobutton_sumH_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_sumH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_sumH
set(handles.radiobutton_extractH,'Value',0);
set(handles.radiobutton_averageH,'Value',0);
set(handles.radiobutton_sumH,'Value',1);
set(handles.radiobutton_averagePositiveH,'Value',0);

% --- Executes on button press in radiobutton_averagePositiveH.
function radiobutton_averagePositiveH_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_averagePositiveH (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_averagePositiveH
set(handles.radiobutton_extractH,'Value',0);
set(handles.radiobutton_averageH,'Value',0);
set(handles.radiobutton_sumH,'Value',0);
set(handles.radiobutton_averagePositiveH,'Value',1);
