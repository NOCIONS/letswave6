function varargout = CGLW_multi_viewer_figure(varargin)
% CGLW_MULTI_VIEWER_FIGURE MATLAB code for CGLW_multi_viewer_figure.fig
% Edit the above text to modify the response to help CGLW_multi_viewer_figure
%








% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_multi_viewer_figure_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_multi_viewer_figure_OutputFcn, ...
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








% --- Executes just before CGLW_multi_viewer_figure is made visible.
function CGLW_multi_viewer_figure_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_multi_viewer_figure (see VARARGIN)
% Choose default command line output for CGLW_multi_viewer_figure
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes CGLW_multi_viewer_figure wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = CGLW_multi_viewer_figure_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;
varargout{2} = handles;








% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mother_handle=get(handles.xtext,'UserData');
if isempty(mother_handle);
else
    userdata=get(mother_handle.graph_wave_popup,'UserData');
    if isempty(userdata);
    else
        for i=1:size(userdata.axes_handle,2);
            currentpoint=get(userdata.axes_handle(1,i),'CurrentPoint');
            cp(i)=currentpoint(2,1);
        end;
        xlim=get(userdata.axes_handle(1,1),'XLim');
        xdist=abs(cp(:)-xlim(1))+abs(cp(:)-xlim(2));
        [a,b]=min(xdist);
        set(handles.xtext,'String',num2str(cp(b)));
    end;
end;







% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mother_handle=get(handles.xtext,'UserData');
userdata=get(mother_handle.graph_wave_popup,'UserData');
for i=1:size(userdata.axes_handle,2);
    currentpoint=get(userdata.axes_handle(1,i),'CurrentPoint');
    cp(i)=currentpoint(2,1);
end;
xlim=get(userdata.axes_handle(1,1),'XLim');
xdist=abs(cp(:)-xlim(1))+abs(cp(:)-xlim(2));
[a,b]=min(xdist);
cursor1=cp(b);
set(handles.xtext1,'String',num2str(cursor1));
CGLW_multi_viewer('update_graph',mother_handle);
%draw cursor
for i=1:size(userdata.axes_handle,1);
    for j=1:size(userdata.axes_handle,2);
        subplot(userdata.axes_handle(i,j));
        hold on;
        ylim=get(userdata.axes_handle(i,j),'YLim');
        plot([cursor1 cursor1],ylim,'r:');
        hold off;
    end;
end;
userdata.cursor1=cursor1;
set(mother_handle.graph_wave_popup,'UserData',userdata);
set(mother_handle.interval1_edit,'String',num2str(cursor1));







% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mother_handle=get(handles.xtext,'UserData');
userdata=get(mother_handle.graph_wave_popup,'UserData');
for i=1:size(userdata.axes_handle,2);
    currentpoint=get(userdata.axes_handle(1,i),'CurrentPoint');
    cp(i)=currentpoint(2,1);
end;
xlim=get(userdata.axes_handle(1,1),'XLim');
xdist=abs(cp(:)-xlim(1))+abs(cp(:)-xlim(2));
[a,b]=min(xdist);
set(handles.xtext,'String',num2str(cp(b)));
cursor2=cp(b);
set(handles.xtext2,'String',num2str(cursor2));
%draw cursor
for i=1:size(userdata.axes_handle,1);
    for j=1:size(userdata.axes_handle,2);
        subplot(userdata.axes_handle(i,j));
        hold on;
        ylim=get(userdata.axes_handle(i,j),'YLim');
        plot([cursor2 cursor2],ylim,'b:');
        hold off;
    end;
end;
userdata.cursor2=cursor2;
set(mother_handle.graph_wave_popup,'UserData',userdata);
set(mother_handle.interval2_edit,'String',num2str(cursor2));






% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called







% --- Executes during object creation, after setting all properties.
function xtext_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xtext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called







% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%delete(hObject);





% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
