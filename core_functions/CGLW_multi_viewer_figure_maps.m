function varargout = CGLW_multi_viewer_figure_maps(varargin)
% CGLW_MULTI_VIEWER_FIGURE_MAPS MATLAB code for CGLW_multi_viewer_figure_maps.fig
% Edit the above text to modify the response to help CGLW_multi_viewer_figure_maps
%







% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CGLW_multi_viewer_figure_maps_OpeningFcn, ...
                   'gui_OutputFcn',  @CGLW_multi_viewer_figure_maps_OutputFcn, ...
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








% --- Executes just before CGLW_multi_viewer_figure_maps is made visible.
function CGLW_multi_viewer_figure_maps_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CGLW_multi_viewer_figure_maps (see VARARGIN)
% Choose default command line output for CGLW_multi_viewer_figure_maps
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes CGLW_multi_viewer_figure_maps wait for user response (see UIRESUME)
% uiwait(handles.figure1);



% --- Outputs from this function are returned to the command line.
function varargout = CGLW_multi_viewer_figure_maps_OutputFcn(hObject, eventdata, handles) 
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
    userdata=get(mother_handle.graph_col_popup,'UserData');
    if isempty(userdata);
    else
        for i=1:size(userdata.currentaxis,2);
            currentpoint=get(userdata.currentaxis(1,i),'CurrentPoint');
            cp_x(i)=currentpoint(2,1);
            cp_y(i)=currentpoint(2,2);
        end;
        xlim=get(userdata.currentaxis(1,1),'XLim');
        xdist=abs(cp_x(:)-xlim(1))+abs(cp_x(:)-xlim(2));
        [a,b]=min(xdist);
        set(handles.xtext,'String',num2str(cp_x(b)));
        ylim=get(userdata.currentaxis(1,1),'YLim');
        ydist=abs(cp_y(:)-ylim(1))+abs(cp_y(:)-ylim(2));
        [a,b]=min(ydist);
        set(handles.ytext,'String',num2str(cp_y(b)));
    end;
end;







% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mother_handle=get(handles.xtext,'UserData');
userdata=get(mother_handle.graph_col_popup,'UserData');
for i=1:size(userdata.currentaxis,2);
    currentpoint=get(userdata.currentaxis(1,i),'CurrentPoint');
    cp_x(i)=currentpoint(2,1);
    cp_y(i)=currentpoint(2,2);
end;
xlim=get(userdata.currentaxis(1,1),'XLim');
xdist=abs(cp_x(:)-xlim(1))+abs(cp_x(:)-xlim(2));
[a,b]=min(xdist);
cursor1_x=cp_x(b);
ylim=get(userdata.currentaxis(1,1),'YLim');
ydist=abs(cp_y(:)-ylim(1))+abs(cp_y(:)-ylim(2));
[a,b]=min(ydist);
cursor1_y=cp_y(b);
set(handles.xtext1,'String',num2str(cursor1_x));
set(handles.ytext1,'String',num2str(cursor1_y));
CGLW_multi_viewer_maps('update_graph',mother_handle);
%draw cursor
for i=1:size(userdata.currentaxis,1);
    for j=1:size(userdata.currentaxis,2);
        subplot(userdata.currentaxis(i,j));
        hold on;
        ylim=get(userdata.currentaxis(i,j),'YLim');
        plot([cursor1_x cursor1_x],ylim,'w:');
        xlim=get(userdata.currentaxis(i,j),'XLim');
        plot(xlim,[cursor1_y cursor1_y],'w:');
        hold off;
    end;
end;
userdata.cursor1=[cursor1_x cursor1_y];
set(mother_handle.graph_col_popup,'UserData',userdata);
set(mother_handle.interval1_x_edit,'String',num2str(cursor1_x));
set(mother_handle.interval1_y_edit,'String',num2str(cursor1_y));







% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mother_handle=get(handles.xtext,'UserData');
userdata=get(mother_handle.graph_col_popup,'UserData');
for i=1:size(userdata.currentaxis,2);
    currentpoint=get(userdata.currentaxis(1,i),'CurrentPoint');
    cp_x(i)=currentpoint(2,1);
    cp_y(i)=currentpoint(2,2);
end;
xlim=get(userdata.currentaxis(1,1),'XLim');
xdist=abs(cp_x(:)-xlim(1))+abs(cp_x(:)-xlim(2));
[a,b]=min(xdist);
cursor2_x=cp_x(b);
ylim=get(userdata.currentaxis(1,1),'YLim');
ydist=abs(cp_y(:)-ylim(1))+abs(cp_y(:)-ylim(2));
[a,b]=min(ydist);
cursor2_y=cp_y(b);
set(handles.xtext2,'String',num2str(cursor2_x));
set(handles.ytext2,'String',num2str(cursor2_y));
%draw cursor
for i=1:size(userdata.currentaxis,1);
    for j=1:size(userdata.currentaxis,2);
        subplot(userdata.currentaxis(i,j));
        hold on;
        ylim=get(userdata.currentaxis(i,j),'YLim');
        plot([cursor2_x cursor2_x],ylim,'w:');
        xlim=get(userdata.currentaxis(i,j),'XLim');
        plot(xlim,[cursor2_y cursor2_y],'w:');
        hold off;
    end;
end;
userdata.cursor2=[cursor2_x cursor2_y];
set(mother_handle.graph_col_popup,'UserData',userdata);
set(mother_handle.interval2_x_edit,'String',num2str(cursor2_x));
set(mother_handle.interval2_y_edit,'String',num2str(cursor2_y));






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
