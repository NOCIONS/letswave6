function varargout = GLW_conditionAverage(varargin)
% GLW_conditionAverage MATLAB code for GLW_conditionAverage.fig




% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GLW_conditionAverage_OpeningFcn, ...
    'gui_OutputFcn',  @GLW_conditionAverage_OutputFcn, ...
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





% --- Executes just before GLW_conditionAverage is made visible.
function GLW_conditionAverage_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GLW_conditionAverage (see VARARGIN)
% Choose default command line output for GLW_conditionAverage
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
%fill listbox with inputfiles
% set(handles.filebox,'String',varargin{2});
% inputfiles=get(handles.filebox,'String');
inputfiles=varargin{2};
set(handles.uitable, 'UserData', inputfiles);
for i=1:length(inputfiles);
    header=LW_load_header(inputfiles{i});
    [p,n,e]=fileparts(inputfiles{i});
    table{i,1}=n;
    tag = header.tags;
    if iscell(tag)
        tag = tag{1};
    end
    table{i,2}= tag; 
%     table{i,2}= char(header.conditions(strmatch('condition', header.condition_labels, 'exact')));
end;
set(handles.uitable,'Data',table);






% --- Outputs from this function are returned to the command line.
function varargout = GLW_conditionAverage_OutputFcn(hObject, eventdata, handles)
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
oldinputfiles=get(handles.uitable, 'UserData'); 
[p,n,e]=fileparts(oldinputfiles{1});
n2=get(handles.filenametext,'String');
disp('*** Starting.');
%weights
table=get(handles.uitable,'Data');
uniqueConds = unique(table(:,2)');
for condNm = uniqueConds
    condNrs = strmatch(char(condNm), table(:,2)', 'exact');
    inputfiles = oldinputfiles(condNrs);
    %load first header
    header=LW_load(inputfiles{1});
    %prepare outdata
    outdata=zeros(header.datasize);
    weights=zeros(1,length(inputfiles));
    %loop through files
    for filepos=1:length(inputfiles);
        weights(filepos) = 1;
        %load
        [header,data]=LW_load(inputfiles{filepos});
        %process
        disp(['*** Computing grand average : file : ' inputfiles{filepos}]);
        outdata=outdata+(weights(filepos)*data);
    end;
    data=outdata/sum(weights);
    %set tag as new condition
    header.tags = char(condNm);
    header.events=[];
    %save
    LW_save([p,filesep,n2,'_',char(condNm)],[],header,data);
end
disp('*** Finished.');
