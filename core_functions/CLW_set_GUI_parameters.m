function CLW_set_GUI_parameters(handles)

%load letswave.mat > letswave_config
load letswave_config.mat

%find objects with property FontSize
h=findobj(handles.figure1,'-property','FontSize');
%set fonts
set(h,'FontUnits',letswave_config.FontUnits);
set(h,'FontSize',letswave_config.FontSize);
set(h,'FontName',letswave_config.FontName);

%if proportional=1
if letswave_config.proportional==1;
    %Units properties of the axes and uicontrols are set to normalized so that these components resize and reposition as the figure window changes size.
    %Units property of the figure is set to characters so the GUI displays at the correct size at run-time, based on any changes in font size.
    %Resize figure property set to on (the default).
    %ResizeFcn figure property is left unset.
    set(handles.figure1,'Units','normalized');
    h=findobj(handles.figure1,'-property','Units');
    set(h,'Units','normalized');
    set(handles.figure1,'Resize','on');
    set(handles.figure1,'ResizeFcn',[]);
    p=get(handles.figure1,'Position');
    p(3)=p(3)*(letswave_config.size/100);
    p(4)=p(4)*(letswave_config.size/100);    
    set(handles.figure1,'Position',p);
else
    %Units properties of the figure, axes, and uicontrols are set to characters (the Layout Editor default) so the GUI displays at the correct size on different computers.
    %Resize figure property is set to off.
    %ResizeFcn figure property is left unset.
    set(handles.figure1,'Units','characters');
    h=findobj(handles.figure1,'-property','Units');
    set(h,'Units','characters');
    set(handles.figure1,'Resize','off');
    set(handles.figure1,'ResizeFcn',[]);
end;





end

