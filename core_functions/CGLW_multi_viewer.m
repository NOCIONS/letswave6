function CGLW_multi_viewer(varargin)
% clc;
% figure('Visible','off');
% close all;
% file_path=which('CGLW_multi_viewer');
% [path, n, ~]=fileparts(file_path);
% varargin{2}={[path,'\avg merged_epochs_I.lw6']};
if isempty(varargin{2})
    return;
end
handles=[];
userdata=[];
datasets_header={};
datasets_data={};
CGLW_my_view_OpeningFcn;

%% init_parameter()
    function init_parameter()
        S=load('init_parameter.mat');
        userdata=S.userdata;
        handles=S.handles;
        
        inputfiles=varargin{2};
        for k=1:length(inputfiles);
            [p, n, ~]=fileparts(inputfiles{k});
            userdata.datasets_path=p;
            userdata.datasets_filename{k}=n;
            [datasets_header(k).header, datasets_data(k).data]=CLW_load(inputfiles{k});
            chan_used=find([datasets_header(k).header.chanlocs.topo_enabled]==1, 1);
            if isempty(chan_used)
                datasets_header(k).header=RLW_edit_electrodes(datasets_header(k).header,userdata.chanlocs);
            end
            datasets_header(k).header=CLW_make_spl(datasets_header(k).header);
        end
        set_header_filter();
    end

%% fig1_init
    function fig1_init()
        icon=load('multi_viewer_icon.mat');
        handles.fig1=figure('CloseRequestFcn',@fig1_CloseReq_Callback,...
            'Visible','off','Color',0.94*[1,1,1]);
        set(handles.fig1,'WindowButtonDownFcn',@fig_BtnDown);
        set(handles.fig1,'WindowButtonMotionFcn',@fig_BtnMotion);
        set(handles.fig1,'WindowButtonUpFcn',@fig_BtnUp);
        h = zoom(handles.fig1);h.ActionPostCallback = @fig_axis_Changed;
        h = pan(handles.fig1); h.ActionPostCallback = @fig_axis_Changed;
        set(handles.fig1,'position',userdata.fig1_pos);
        set(handles.fig1,'MenuBar','none');
        set(handles.fig1,'DockControls','off');
        
        %toolbar1
        handles.toolbar1 = uitoolbar(handles.fig1);
        handles.toolbar1_split = uitoggletool(handles.toolbar1);
        set(handles.toolbar1_split,'TooltipString','Split');
        set(handles.toolbar1_split,'CData',icon.icon_split);
        set(handles.toolbar1_split,'ClickedCallback',{@fig_split});
        set(handles.toolbar1_split,'State','off');
        set(handles.toolbar1,'Visible','off');
        
        handles.panel_edit=uipanel(handles.fig1,'BorderType','none');
        set(handles.panel_edit,'Units','pixels');
        set(handles.panel_edit,'Position',[1,1,350,700]);
        handles.dataset_text=uicontrol(handles.panel_edit,'style','text','String','Datasets:');
        set(handles.dataset_text,'Units','pixels');
        set(handles.dataset_text,'HorizontalAlignment','left');
        set(handles.dataset_text,'Position',[5,680,60,20]);
        set(handles.dataset_text,'Units','normalized');
        handles.dataset_listbox=uicontrol(handles.panel_edit,'style','listbox');
        set(handles.dataset_listbox,'Min',1);
        set(handles.dataset_listbox,'Max',3);
        set(handles.dataset_listbox,'Units','pixels');
        set(handles.dataset_listbox,'Position',[5,580,300,100]);
        set(handles.dataset_listbox,'Units','normalized');
        set(handles.dataset_listbox,'Callback',@CGLW_my_view_UpdataFcn)
        
        
        handles.dataset_add=uicontrol(handles.panel_edit,'CData',icon.icon_dataset_add,'style','pushbutton','Units','pixels');
        handles.dataset_del=uicontrol(handles.panel_edit,'CData',icon.icon_dataset_del,'style','pushbutton','Units','pixels');
        handles.dataset_up=uicontrol(handles.panel_edit,'CData',icon.icon_dataset_up,'style','pushbutton','Units','pixels');
        handles.dataset_down=uicontrol(handles.panel_edit,'CData',icon.icon_dataset_down,'style','pushbutton','Units','pixels');
        set(handles.dataset_add,'Position',[310,664,26,26],'TooltipString','add dataset ');
        set(handles.dataset_del,'Position',[310,636,26,26],'TooltipString','delete selected dataset ');
        set(handles.dataset_up,'Position',[310,608,26,26],'TooltipString','dataset up');
        set(handles.dataset_down,'Position',[310,580,26,26],'TooltipString','dataset down');
        set(handles.dataset_add,'Units','normalized','Callback',@edit_dataset_Add);
        set(handles.dataset_del,'Units','normalized','Callback',@edit_dataset_Del);
        set(handles.dataset_up,'Units','normalized','Callback',@edit_dataset_Up);
        set(handles.dataset_down,'Units','normalized','Callback',@edit_dataset_Down);
        
        handles.epoch_text=uicontrol(handles.panel_edit,'style','text','String','Epochs:');
        set(handles.epoch_text,'Units','pixels');
        set(handles.epoch_text,'HorizontalAlignment','left');
        set(handles.epoch_text,'Position',[5,555,60,20]);
        set(handles.epoch_text,'Units','normalized');
        handles.epoch_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@CGLW_my_view_UpdataFcn);
        set(handles.epoch_listbox,'Min',1);
        set(handles.epoch_listbox,'Max',3);
        set(handles.epoch_listbox,'Units','pixels');
        set(handles.epoch_listbox,'Position',[5,183,70,375]);
        set(handles.epoch_listbox,'Units','normalized');
        handles.channel_text=uicontrol(handles.panel_edit,'style','text','String','Channels:');
        set(handles.channel_text,'Units','pixels');
        set(handles.channel_text,'HorizontalAlignment','left');
        set(handles.channel_text,'Position',[80,555,60,20]);
        set(handles.channel_text,'Units','normalized');
        handles.channel_listbox=uicontrol(handles.panel_edit,'style','listbox','Callback',@CGLW_my_view_UpdataFcn);
        set(handles.channel_listbox,'Min',1);
        set(handles.channel_listbox,'Max',3);
        set(handles.channel_listbox,'Units','pixels');
        set(handles.channel_listbox,'Position',[80,183,100,375]);
        set(handles.channel_listbox,'Units','normalized');
        
        handles.graph_row_text=uicontrol(handles.panel_edit,'style','text','String','Separate graphs (rows) :');
        set(handles.graph_row_text,'Units','pixels');
        set(handles.graph_row_text,'HorizontalAlignment','left');
        set(handles.graph_row_text,'Position',[5,152,200,20]);
        set(handles.graph_row_text,'Units','normalized');
        handles.graph_row_popup=uicontrol(handles.panel_edit,'style','popup','String',{'datasets','epochs','channels'},'Callback',{@CGLW_my_view_UpdataFcn,1});
        set(handles.graph_row_popup,'Units','pixels');
        set(handles.graph_row_popup,'Position',[5,130,175,22]);
        set(handles.graph_row_popup,'Units','normalized');
        
        handles.graph_col_text=uicontrol(handles.panel_edit,'style','text','String','Separate graphs (columns) :');
        set(handles.graph_col_text,'Units','pixels');
        set(handles.graph_col_text,'HorizontalAlignment','left');
        set(handles.graph_col_text,'Position',[5,93,200,20]);
        set(handles.graph_col_text,'Units','normalized');
        handles.graph_col_popup=uicontrol(handles.panel_edit,'style','popup','String',{'datasets','epochs','channels'},'Callback',{@CGLW_my_view_UpdataFcn,2});
        set(handles.graph_col_popup,'Units','pixels');
        set(handles.graph_col_popup,'Position',[5,71,175,22]);
        set(handles.graph_col_popup,'Units','normalized');
        
        handles.graph_wave_text=uicontrol(handles.panel_edit,'style','text','String','Superimposed waves :');
        set(handles.graph_wave_text,'Units','pixels');
        set(handles.graph_wave_text,'HorizontalAlignment','left');
        set(handles.graph_wave_text,'Position',[5,35,200,20]);
        set(handles.graph_wave_text,'Units','normalized');
        handles.graph_wave_popup=uicontrol(handles.panel_edit,'style','popup','String',{'datasets','epochs','channels'},'Callback',{@CGLW_my_view_UpdataFcn,3});
        set(handles.graph_wave_popup,'Units','pixels');
        set(handles.graph_wave_popup,'Position',[5,10,175,22]);
        set(handles.graph_wave_popup,'Units','normalized');
        
        handles.index_text=uicontrol(handles.panel_edit,'style','text','String','Index:');
        set(handles.index_text,'Units','pixels');
        set(handles.index_text,'HorizontalAlignment','left');
        set(handles.index_text,'Position',[190,555,50,20]);
        set(handles.index_text,'Units','normalized');
        handles.index_popup=uicontrol(handles.panel_edit,'style','popup','Callback',@CGLW_my_view_UpdataFcn);
        set(handles.index_popup,'String',{'pixels','pixels','pixels','pixels','pixels','pixels','pixels'});
        set(handles.index_popup,'Units','pixels');
        set(handles.index_popup,'Position',[190,535,150,20]);
        set(handles.index_popup,'Units','normalized');
        
        handles.y_text=uicontrol(handles.panel_edit,'style','text','String','Y:');
        set(handles.y_text,'Units','pixels');
        set(handles.y_text,'HorizontalAlignment','left');
        set(handles.y_text,'Position',[190,500,50,20]);
        set(handles.y_text,'Units','normalized');
        handles.y_edit=uicontrol(handles.panel_edit,'style','edit',...
            'String',[],'Callback',@CGLW_my_view_UpdataFcn);
        set(handles.y_edit,'Units','pixels');
        set(handles.y_edit,'Position',[210,502,50,20]);
        set(handles.y_edit,'Units','normalized');
        
        handles.z_text=uicontrol(handles.panel_edit,'style','text','String','Z:');
        set(handles.z_text,'Units','pixels');
        set(handles.z_text,'HorizontalAlignment','left');
        set(handles.z_text,'Position',[270,500,50,20]);
        set(handles.z_text,'Units','normalized');
        handles.z_edit=uicontrol(handles.panel_edit,'style','edit',...
            'String',[],'Callback',@CGLW_my_view_UpdataFcn);
        set(handles.z_edit,'Units','pixels');
        set(handles.z_edit,'Position',[285,502,50,20]);
        set(handles.z_edit,'Units','normalized');
        
        handles.xaxis_panel=uipanel(handles.panel_edit);
        set(handles.xaxis_panel,'Title','X-axis:');
        set(handles.xaxis_panel,'Units','pixels');
        set(handles.xaxis_panel,'Position',[190,420,150,70]);
        set(handles.xaxis_panel,'Units','normalized');
        handles.xaxis1_edit=uicontrol(handles.xaxis_panel,'style','edit','Callback',@edit_xaxis_Changed);
        set(handles.xaxis1_edit,'Units','pixels');
        set(handles.xaxis1_edit,'Position',[5,35,60,20]);
        set(handles.xaxis1_edit,'Units','normalized');
        handles.xaxis2_edit=uicontrol(handles.xaxis_panel,'style','edit','Callback',@edit_xaxis_Changed);
        set(handles.xaxis2_edit,'Units','pixels');
        set(handles.xaxis2_edit,'Position',[80,35,60,20]);
        set(handles.xaxis2_edit,'Units','normalized');
        handles.xaxis_auto_checkbox=uicontrol(handles.xaxis_panel,'style','checkbox');
        set(handles.xaxis_auto_checkbox,'String','auto');
        set(handles.xaxis_auto_checkbox,'Units','pixels');
        set(handles.xaxis_auto_checkbox,'Position',[15,5,60,20]);
        set(handles.xaxis_auto_checkbox,'Units','normalized');
        set(handles.xaxis_auto_checkbox,'Value',userdata.auto_x);
        set(handles.xaxis_auto_checkbox,'Callback',@edit_xaxis_auto_checkbox_Changed);
        
        handles.yaxis_panel=uipanel(handles.panel_edit);
        set(handles.yaxis_panel,'Title','Y-axis:');
        set(handles.yaxis_panel,'Units','pixels');
        set(handles.yaxis_panel,'Position',[190,340,150,70]);
        set(handles.yaxis_panel,'Units','normalized');
        handles.yaxis1_edit=uicontrol(handles.yaxis_panel,'style','edit','Callback',@edit_yaxis_Changed);
        set(handles.yaxis1_edit,'Units','pixels');
        set(handles.yaxis1_edit,'Position',[5,35,60,20]);
        set(handles.yaxis1_edit,'Units','normalized');
        handles.yaxis2_edit=uicontrol(handles.yaxis_panel,'style','edit','Callback',@edit_yaxis_Changed);
        set(handles.yaxis2_edit,'Units','pixels');
        set(handles.yaxis2_edit,'Position',[80,35,60,20]);
        set(handles.yaxis2_edit,'Units','normalized');
        handles.yaxis_auto_checkbox=uicontrol(handles.yaxis_panel,'style','checkbox');
        set(handles.yaxis_auto_checkbox,'String','auto');
        set(handles.yaxis_auto_checkbox,'Units','pixels');
        set(handles.yaxis_auto_checkbox,'Position',[15,5,60,20]);
        set(handles.yaxis_auto_checkbox,'Units','normalized');
        set(handles.yaxis_auto_checkbox,'Value',userdata.auto_y);
        set(handles.yaxis_auto_checkbox,'Callback',@edit_yaxis_auto_checkbox_Changed);
        
        handles.cursor_panel=uipanel(handles.panel_edit);
        set(handles.cursor_panel,'Title','Cursor');
        set(handles.cursor_panel,'Units','pixels');
        set(handles.cursor_panel,'Position',[190,282,150,50]);
        set(handles.cursor_panel,'Units','normalized');
        handles.cursor_edit=uicontrol(handles.cursor_panel,'style','edit','Callback',@edit_cursor_Changed);
        set(handles.cursor_edit,'Units','pixels');
        set(handles.cursor_edit,'Position',[5,10,70,20]);
        set(handles.cursor_edit,'Units','normalized');
        handles.cursor_auto_checkbox=uicontrol(handles.cursor_panel,'style','checkbox');
        set(handles.cursor_auto_checkbox,'String','auto');
        set(handles.cursor_auto_checkbox,'Units','pixels');
        set(handles.cursor_auto_checkbox,'Position',[85,12,60,20]);
        set(handles.cursor_auto_checkbox,'Units','normalized');
        set(handles.cursor_auto_checkbox,'Value',userdata.auto_cursor);
        set(handles.cursor_auto_checkbox,'Callback',@edit_cursor_auto_checkbox_Changed);
        
        handles.interval_panel=uipanel(handles.panel_edit);
        set(handles.interval_panel,'Title','Explore interval');
        set(handles.interval_panel,'Units','pixels');
        set(handles.interval_panel,'Position',[190,183,150,90]);
        set(handles.interval_panel,'Units','normalized');
        handles.interval1_edit=uicontrol(handles.interval_panel,'style','edit','Callback',@edit_interval_Changed);
        set(handles.interval1_edit,'Units','pixels');
        set(handles.interval1_edit,'Position',[5,44,60,20]);
        set(handles.interval1_edit,'Units','normalized');
        handles.interval2_edit=uicontrol(handles.interval_panel,'style','edit','Callback',@edit_interval_Changed);
        set(handles.interval2_edit,'Units','pixels');
        set(handles.interval2_edit,'Position',[80,44,60,20]);
        set(handles.interval2_edit,'Units','normalized');
        handles.interval_button=uicontrol(handles.interval_panel,'style','pushbutton','Callback',@edit_interval_table);
        set(handles.interval_button,'String','Table');
        set(handles.interval_button,'Units','pixels');
        set(handles.interval_button,'Position',[5,7,135,25]);
        set(handles.interval_button,'Units','normalized');
        
        handles.filter_panel=uipanel(handles.panel_edit);
        set(handles.filter_panel,'Title','Online Butterworth Filter');
        set(handles.filter_panel,'Units','pixels');
        set(handles.filter_panel,'Position',[190,5,150,175]);
        set(handles.filter_panel,'Units','normalized');
        
        handles.filter_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_checkbox,'String','Enable');
        set(handles.filter_checkbox,'Units','pixels');
        set(handles.filter_checkbox,'Position',[5,140,105,20]);
        set(handles.filter_checkbox,'Units','normalized');
        set(handles.filter_checkbox,'Value',userdata.is_filter);
        set(handles.filter_checkbox,'Callback',@edit_filter_Changed);
        
        handles.filter_lowpass_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_lowpass_checkbox,'String','Low Pass');
        set(handles.filter_lowpass_checkbox,'Units','pixels');
        set(handles.filter_lowpass_checkbox,'Position',[5,115,80,20]);
        set(handles.filter_lowpass_checkbox,'Units','normalized');
        set(handles.filter_lowpass_checkbox,'Value',userdata.is_filter_low);
        set(handles.filter_lowpass_checkbox,'Callback',@edit_filter_Changed);
        handles.filter_lowpass_edit=uicontrol(handles.filter_panel,'style','edit');
        set(handles.filter_lowpass_edit,'String',num2str(userdata.filter_low));
        set(handles.filter_lowpass_edit,'Units','pixels');
        set(handles.filter_lowpass_edit,'Position',[90,115,50,20]);
        set(handles.filter_lowpass_edit,'Units','normalized');
        set(handles.filter_lowpass_edit,'Callback',@edit_filter_Changed);
        
        handles.filter_highpass_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_highpass_checkbox,'String','High Pass');
        set(handles.filter_highpass_checkbox,'Units','pixels');
        set(handles.filter_highpass_checkbox,'Position',[5,82,80,20]);
        set(handles.filter_highpass_checkbox,'Units','normalized');
        set(handles.filter_highpass_checkbox,'Value',userdata.is_filter_high);
        set(handles.filter_highpass_checkbox,'Callback',@edit_filter_Changed);
        handles.filter_highpass_edit=uicontrol(handles.filter_panel,'style','edit');
        set(handles.filter_highpass_edit,'String',num2str(userdata.filter_high));
        set(handles.filter_highpass_edit,'Units','pixels');
        set(handles.filter_highpass_edit,'Position',[90,82,50,20]);
        set(handles.filter_highpass_edit,'Units','normalized');
        set(handles.filter_highpass_edit,'Callback',@edit_filter_Changed);
        
        handles.filter_notch_checkbox=uicontrol(handles.filter_panel,'style','checkbox');
        set(handles.filter_notch_checkbox,'String','Notch');
        set(handles.filter_notch_checkbox,'Units','pixels');
        set(handles.filter_notch_checkbox,'Position',[5,45,80,20]);
        set(handles.filter_notch_checkbox,'Units','normalized');
        set(handles.filter_notch_checkbox,'Value',userdata.is_filter_notch);
        set(handles.filter_notch_checkbox,'Callback',@edit_filter_Changed);
        handles.filter_notch_popup=uicontrol(handles.filter_panel,'style','popup','String',{'50','60'});
        set(handles.filter_notch_popup,'Value',userdata.filter_notch);
        set(handles.filter_notch_popup,'Units','pixels');
        set(handles.filter_notch_popup,'Position',[90,45,50,25]);
        set(handles.filter_notch_popup,'Units','normalized');
        set(handles.filter_notch_popup,'Callback',@edit_filter_Changed);
        
        handles.filter_order_text=uicontrol(handles.filter_panel,'style','text');
        set(handles.filter_order_text,'String','order:');
        set(handles.filter_order_text,'Units','pixels');
        set(handles.filter_order_text,'Position',[0,10,80,20]);
        set(handles.filter_order_text,'Units','normalized');
        set(handles.filter_order_text,'Callback',@edit_filter_Changed);
        handles.filter_order_popup=uicontrol(handles.filter_panel,...
            'style','popup','String',{'1','2','3','4','5','6','7','8','9','10'});
        set(handles.filter_order_popup,'Units','pixels');
        set(handles.filter_order_popup,'Position',[90,10,50,25]);
        set(handles.filter_order_popup,'Units','normalized');
        set(handles.filter_order_popup,'value',userdata.filter_order);
        set(handles.filter_order_popup,'Callback',@edit_filter_Changed);
        
        set(handles.dataset_listbox,'backgroundcolor',[1,1,1]);
        set(handles.epoch_listbox,'backgroundcolor',[1,1,1]);
        set(handles.channel_listbox,'backgroundcolor',[1,1,1]);
        set(handles.graph_row_popup,'backgroundcolor',[1,1,1]);
        set(handles.graph_col_popup,'backgroundcolor',[1,1,1]);
        set(handles.graph_wave_popup,'backgroundcolor',[1,1,1]);
        set(handles.index_popup,'backgroundcolor',[1,1,1]);
        set(handles.y_edit,'backgroundcolor',[1,1,1]);
        set(handles.z_edit,'backgroundcolor',[1,1,1]);
        set(handles.xaxis1_edit,'backgroundcolor',[1,1,1]);
        set(handles.xaxis2_edit,'backgroundcolor',[1,1,1]);
        set(handles.yaxis1_edit,'backgroundcolor',[1,1,1]);
        set(handles.yaxis2_edit,'backgroundcolor',[1,1,1]);
        set(handles.interval1_edit,'backgroundcolor',[1,1,1]);
        set(handles.interval2_edit,'backgroundcolor',[1,1,1]);
        set(handles.filter_lowpass_edit,'backgroundcolor',[1,1,1]);
        set(handles.filter_highpass_edit,'backgroundcolor',[1,1,1]);
        set(handles.filter_notch_popup,'backgroundcolor',[1,1,1]);
        set(handles.filter_order_popup,'backgroundcolor',[1,1,1]);
        
        set(handles.filter_lowpass_checkbox,'Enable','off');
        set(handles.filter_lowpass_edit,'Enable','off');
        set(handles.filter_highpass_checkbox,'Enable','off');
        set(handles.filter_highpass_edit,'Enable','off');
        set(handles.filter_notch_checkbox,'Enable','off');
        set(handles.filter_notch_popup,'Enable','off');
        set(handles.filter_order_text,'Enable','off');
        set(handles.filter_order_popup,'Enable','off');
    end

%% fig2_init
    function fig2_init()
        icon=load('multi_viewer_icon.mat');
        handles.fig2=figure('CloseRequestFcn',@fig2_CloseReq_Callback,'Visible','off');
        set(handles.fig2,'WindowButtonDownFcn',@fig_BtnDown);
        set(handles.fig2,'WindowButtonMotionFcn',@fig_BtnMotion);
        set(handles.fig2,'WindowButtonUpFcn',@fig_BtnUp);
        h = zoom(handles.fig2);h.ActionPostCallback = @fig_axis_Changed;
        h = pan(handles.fig2); h.ActionPostCallback = @fig_axis_Changed;
        set(handles.fig2,'position',userdata.fig2_pos);
        set(handles.fig2,'DockControls','off');
        
        %toolbar2
        handles.toolbar2 = uitoolbar(handles.fig1);
        handles.toolbar2_split = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_split,'TooltipString','Split');
        set(handles.toolbar2_split,'CData',icon.icon_split);
        set(handles.toolbar2_split,'ClickedCallback',{@fig_split});
        set(handles.toolbar2_split,'State','on');
        set(findall(handles.fig2,'ToolTipString','Save Figure'),'Parent',handles.toolbar2);
        set(findall(handles.fig2,'ToolTipString','Zoom In'),'Parent',handles.toolbar2);
        set(findall(handles.fig2,'ToolTipString','Zoom Out'),'Parent',handles.toolbar2);
        set(findall(handles.fig2,'ToolTipString','Pan'),'Parent',handles.toolbar2);
        set(findall(handles.fig2,'ToolTipString','Rotate 3D'),'Parent',handles.toolbar2);
        
        handles.toolbar2_polarity = uitoggletool(handles.toolbar2,'Separator','on');
        set(handles.toolbar2_polarity,'TooltipString','change polarity');
        set(handles.toolbar2_polarity,'CData',icon.icon_polarity);
        if userdata.is_polarity
            set(handles.toolbar2_polarity,'State','on');
        else
            set(handles.toolbar2_polarity,'State','off');
        end
        set(handles.toolbar2_polarity,'ClickedCallback',{@fig_polarity});
        
        handles.toolbar2_shade = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_shade,'TooltipString','enable interval selection');
        set(handles.toolbar2_shade,'CData',icon.icon_shade);
        if userdata.is_shade
            set(handles.toolbar2_shade,'State','on');
        else
            set(handles.toolbar2_shade,'State','off');
        end
        set(handles.toolbar2_shade,'ClickedCallback',{@fig_shade});
        
        handles.toolbar2_cursor = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_cursor,'TooltipString','cursor');
        set(handles.toolbar2_cursor,'CData',icon.icon_cursor);
        if userdata.is_cursor
            set(handles.toolbar2_cursor,'State','on');
        else
            set(handles.toolbar2_cursor,'State','off');
        end
        set(handles.toolbar2_cursor,'ClickedCallback',{@fig_cursor});
        
        handles.toolbar2_legend = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_legend,'TooltipString','lengend');
        set(handles.toolbar2_legend,'CData',icon.icon_legend);
        if userdata.is_legend
            set(handles.toolbar2_legend,'State','on');
        else
            set(handles.toolbar2_legend,'State','off');
        end
        set(handles.toolbar2_legend,'ClickedCallback',{@fig_legend});
        
        handles.toolbar2_title = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_title,'TooltipString','title');
        set(handles.toolbar2_title,'CData',icon.icon_title);
        if userdata.is_title
            set(handles.toolbar2_title,'State','on');
        else
            set(handles.toolbar2_title,'State','off');
        end
        set(handles.toolbar2_title,'ClickedCallback',{@fig_title});
        
        handles.toolbar2_line = uitoggletool(handles.toolbar2,'Separator','on');
        set(handles.toolbar2_line,'TooltipString','display waveform as line');
        set(handles.toolbar2_line,'CData',icon.icon_line);
        set(handles.toolbar2_line,'ClickedCallback',{@fig_linestyle,1});
        
        handles.toolbar2_stem = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_stem,'TooltipString','display waveform as stem');
        set(handles.toolbar2_stem,'CData',icon.icon_stem);
        set(handles.toolbar2_stem,'ClickedCallback',{@fig_linestyle,2});
        
        handles.toolbar2_stairs = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_stairs,'TooltipString','display waveform as stairs');
        set(handles.toolbar2_stairs,'CData',icon.icon_stairs);
        set(handles.toolbar2_stairs,'ClickedCallback',{@fig_linestyle,3});
        switch(userdata.linestyle)
            case 1
                set(handles.toolbar2_line,'State','on');
                set(handles.toolbar2_stem,'State','off');
                set(handles.toolbar2_stairs,'State','off');
            case 2
                set(handles.toolbar2_line,'State','off');
                set(handles.toolbar2_stem,'State','on');
                set(handles.toolbar2_stairs,'State','off');
            case 3
                set(handles.toolbar2_line,'State','off');
                set(handles.toolbar2_stem,'State','off');
                set(handles.toolbar2_stairs,'State','on');
        end
        
        handles.toolbar2_topo = uitoggletool(handles.toolbar2,'Separator','on');
        set(handles.toolbar2_topo,'TooltipString','topograph(4 limited)');
        set(handles.toolbar2_topo,'CData',icon.icon_topo);
        set(handles.toolbar2_topo,'ClickedCallback',{@fig_topo});
        
        handles.toolbar2_headplot = uitoggletool(handles.toolbar2);
        set(handles.toolbar2_headplot,'TooltipString','headplot(4 limited)');
        set(handles.toolbar2_headplot,'CData',icon.icon_head);
        set(handles.toolbar2_headplot,'ClickedCallback',{@fig_headplot});
        
        handles.panel_fig=uipanel(handles.fig1,'BorderType','none');
        set(handles.fig2,'MenuBar','none');
    end

%% CGLW_my_view_OpeningFcn
    function CGLW_my_view_OpeningFcn()
        init_parameter();
        fig1_init();
        fig2_init();
        
        set(handles.dataset_listbox,'String',userdata.datasets_filename);
        set(handles.channel_listbox,'String',{datasets_header(1).header.chanlocs.labels});
        set(handles.interval1_edit,'String',num2str(userdata.shade_x(1)));
        set(handles.interval2_edit,'String',num2str(userdata.shade_x(2)));
        set(handles.graph_row_popup,'Value',userdata.graph_style(1));
        set(handles.graph_col_popup,'Value',userdata.graph_style(2));
        set(handles.graph_wave_popup,'Value',userdata.graph_style(3));
        CGLW_my_view_UpdataFcn;
        
        try
            set(handles.fig1,'SizeChangedFcn',@fig1_SizeChangedFcn);
            set(handles.fig2,'SizeChangedFcn',@fig2_SizeChangedFcn);
        catch
            set(handles.fig1,'resizefcn',@fig1_SizeChangedFcn);
            set(handles.fig2,'resizefcn',@fig2_SizeChangedFcn);
        end
        set(handles.fig1,'Visible','on');
    end

%% CGLW_my_view_UpdataFcn
    function CGLW_my_view_UpdataFcn(~, ~,graph_changed_idx)
        selected_datasets=get(handles.dataset_listbox,'Value');
        selected_epochs=get(handles.epoch_listbox,'Value');
        selected_channels=get(handles.channel_listbox,'Value');
        
        graph_style(1)=get(handles.graph_row_popup,'Value');
        graph_style(2)=get(handles.graph_col_popup,'Value');
        graph_style(3)=get(handles.graph_wave_popup,'Value');
        
        if nargin==3
            temp=find(graph_style==graph_style(graph_changed_idx));
            if length(temp)>1
                temp=setdiff(temp,graph_changed_idx);
                graph_style(temp)=setdiff(1:3,graph_style);
                switch temp
                    case 1
                        set(handles.graph_row_popup,'Value',graph_style(temp));
                    case 2
                        set(handles.graph_col_popup,'Value',graph_style(temp));
                    case 3
                        set(handles.graph_wave_popup,'Value',graph_style(temp));
                end
                userdata.graph_style=graph_style;
            end
        end
        if isempty(selected_datasets)
            selected_datasets=userdata.selected_datasets;
            set(handles.dataset_listbox,'Value',selected_datasets);
        end
        if isempty(selected_epochs)
            selected_epochs=userdata.selected_epochs;
            set(handles.epoch_listbox,'Value',selected_epochs);
        end
        if isempty(selected_channels)
            selected_channels=userdata.selected_channels;
            set(handles.channel_listbox,'Value',selected_channels);
        end
        if ~isequal(userdata.selected_datasets,selected_datasets)
            %set datasets
            header=datasets_header(selected_datasets(1)).header;
            channel_cursor= {header.chanlocs.labels};
            for k=selected_datasets(2:end)
                header.datasize=min(header.datasize,datasets_header(k).header.datasize);
                channel_cursor=intersect(channel_cursor,{datasets_header(k).header.chanlocs.labels},'stable');
                if isempty(channel_cursor)
                    CreateStruct.Interpreter = 'none';
                    CreateStruct.WindowStyle = 'modal';
                    msgbox('no common channels!','Error','error',CreateStruct);
                    set(handles.dataset_listbox,'Value',userdata.selected_datasets);
                    return;
                end
            end
            userdata.selected_datasets=selected_datasets;
            
            %set epochs
            st=cell(header.datasize(1),1);
            for k=1:header.datasize(1)
                st{k}=num2str(k);
            end;
            set(handles.epoch_listbox,'String',st);
            userdata.selected_epochs=intersect(selected_epochs,1:header.datasize(1));
            if isempty(userdata.selected_epochs)
                userdata.selected_epochs=1;
            end
            set(handles.epoch_listbox,'Value',userdata.selected_epochs);
            
            %set channels
            header.datasize(2)=length(channel_cursor);
            [~,ia] = intersect(channel_cursor,{header.chanlocs.labels});
            header.chanlocs=header.chanlocs(ia);
            
            userdata.channel_index=zeros(length(userdata.selected_datasets),length(channel_cursor));
            for k=userdata.selected_datasets
                for l=1:length(channel_cursor)
                    userdata.channel_index(k,l)=find(strcmp(channel_cursor(l),{datasets_header(k).header.chanlocs.labels}),1,'first');
                end
            end
            channel_cursor_old=get(handles.channel_listbox,'String');
            [~,userdata.selected_channels,~]=intersect(channel_cursor,channel_cursor_old(selected_channels),'stable');
            userdata.selected_channels=sort(userdata.selected_channels);
            if isempty(userdata.selected_channels)
                userdata.selected_channels=1;
            end
            set(handles.channel_listbox,'String',channel_cursor);
            set(handles.channel_listbox,'Value',userdata.selected_channels);
            
            if header.datasize(3)>1;
                set(handles.index_text,'Visible','on');
                set(handles.index_popup,'Visible','on');
                if isfield(header,'index_labels');
                    set(handles.index_popup,'String',header.index_labels(1:header.datasize(3)));
                    selected_index=get(handles.index_popup,'Value');
                    userdata.selected_index=intersect(selected_index,1:header.datasize(3));
                    if isempty(userdata.selected_index)
                        userdata.selected_index=1;
                        set(handles.index_popup,'Value',userdata.selected_index);
                    end
                else
                    st=cell(header.datasize(3),1);
                    for i=1:header.datasize(3);
                        st{i}=num2str(i);
                    end
                    set(handles.index_popup,'String',st);
                    set(handles.index_popup,'Value',1);
                end
            else
                set(handles.index_text,'Visible','off');
                set(handles.index_popup,'Visible','off');
            end
            %y
            if header.datasize(5)>1;
                set(handles.y_text,'Visible','on');
                set(handles.y_edit,'Visible','on');
                y_value=get(handles.y_edit,'String');
                if isempty(y_value)
                    set(handles.y_edit,'String',num2str(header.ystart));
                end
            else
                set(handles.y_text,'Visible','off');
                set(handles.y_edit,'Visible','off');
            end
            %z
            if header.datasize(4)>1;
                set(handles.z_text,'Visible','on');
                set(handles.z_edit,'Visible','on');
                z_value=get(handles.z_edit,'String');
                if isempty(z_value)
                    set(handles.z_edit,'String',num2str(header.zstart));
                end
            else
                set(handles.z_text,'Visible','off');
                set(handles.z_edit,'Visible','off');
            end
        else
            userdata.selected_epochs=selected_epochs;
            userdata.selected_channels=selected_channels;
        end
        fig_update;
    end

%% create_graph
    function fig_update
        switch(userdata.graph_style(1))
            case 1
                userdata.num_rows=length(userdata.selected_datasets);
            case 2
                userdata.num_rows=length(userdata.selected_epochs);
            case 3
                userdata.num_rows=length(userdata.selected_channels);
        end
        switch(userdata.graph_style(2))
            case 1
                userdata.num_cols=length(userdata.selected_datasets);
            case 2
                userdata.num_cols=length(userdata.selected_epochs);
            case 3
                userdata.num_cols=length(userdata.selected_channels);
        end
        switch(userdata.graph_style(3))
            case 1
                userdata.num_waves=length(userdata.selected_datasets);
            case 2
                userdata.num_waves=length(userdata.selected_epochs);
            case 3
                userdata.num_waves=length(userdata.selected_channels);
        end
        userdata.str_dataset=get(handles.dataset_listbox,'String');
        userdata.str_epoch=get(handles.epoch_listbox,'String');
        userdata.str_channel=get(handles.channel_listbox,'String');
        
        fig_ax;
        fig_line;
        edit_xaxis_auto_checkbox_Changed;
        edit_yaxis_auto_checkbox_Changed;
        fig_title;
        fig_shade;
        fig_polarity;
        fig_cursor;
        if strcmp(get(handles.toolbar2_topo,'State'),'on')
            fig_topo;
        elseif strcmp(get(handles.toolbar2_headplot,'State'),'on')
            fig_headplot;
        else
            fig2_SizeChangedFcn();
        end
        fig_legend;
    end

%% fig_BtnDown
    function fig_BtnDown(obj, ~)
        persistent shade_x_temp;
        temp = get(gca,'CurrentPoint');
        if (temp(1,1)>userdata.last_axis(1) && temp(1,1)<userdata.last_axis(2)...
                && temp(1,2)>userdata.last_axis(3) && temp(1,2)<userdata.last_axis(4))
            switch get(obj,'SelectionType')
                case 'normal'
                    if userdata.is_shade==1
                        userdata.mouse_state=1;
                        shade_x_temp=userdata.shade_x;
                        userdata.shade_x(1)=temp(1,1);
                        userdata.shade_x(2)=temp(1,1);
                        set(handles.interval1_edit,'String',num2str(userdata.shade_x(1)));
                        set(handles.interval2_edit,'String',num2str(userdata.shade_x(2)));
                        fig_shade_Update();
                    end
                case 'open'
                    userdata.auto_cursor=0;
                    set(handles.cursor_auto_checkbox,'Value',userdata.auto_cursor);
                    userdata.cursor_point=temp(1,1);
                    set(handles.cursor_edit,'String',num2str(userdata.cursor_point));
                    fig_cursor_Update();
                    fig_topo_Update();
                    
                    if userdata.is_shade==1
                        userdata.mouse_state=0;
                        userdata.shade_x=shade_x_temp;
                        set(handles.interval1_edit,'String',num2str(userdata.shade_x(1)));
                        set(handles.interval2_edit,'String',num2str(userdata.shade_x(2)));
                        fig_shade_Update();
                    end
                case 'alt'
                    userdata.auto_cursor=1;
                    set(handles.cursor_auto_checkbox,'Value',userdata.auto_cursor);
                    userdata.cursor_point=temp(1,1);
                    set(handles.cursor_edit,'String',num2str(userdata.cursor_point));
                    fig_cursor_Update();
                    fig_topo_Update();
            end
        end
    end

%% fig_BtnUp
    function fig_BtnUp(~, ~)
        if userdata.is_shade==1
            if(userdata.mouse_state==1)
                temp = get(gca,'CurrentPoint');
                point1=temp(1,[1,2]);
                userdata.shade_x(2)=point1(1);
                if userdata.shade_x(2)<userdata.last_axis(1)
                    userdata.shade_x(2)=userdata.last_axis(1);
                end
                if userdata.shade_x(2)>userdata.last_axis(2)
                    userdata.shade_x(2)=userdata.last_axis(2);
                end
            end
            userdata.mouse_state=0;
            if userdata.shade_x(1)>userdata.shade_x(2)
                userdata.shade_x=userdata.shade_x([2,1]);
            end
            fig_shade_Update();
            set(handles.interval1_edit,'String',num2str(userdata.shade_x(1)));
            set(handles.interval2_edit,'String',num2str(userdata.shade_x(2)));
        end
    end

%% fig_BtnMotion
    function fig_BtnMotion(~, ~)
        is_inaxis=0;
        for ax_id=1:userdata.num_cols*userdata.num_rows
            col_pos=ceil(ax_id/userdata.num_rows);
            row_pos=mod(ax_id-1,userdata.num_rows)+1;
            temp=get(handles.axes((col_pos-1)*userdata.num_rows+row_pos),'CurrentPoint');
            temp=temp(1,[1,2]);
            if(temp(1)-userdata.last_axis(1))*(temp(1)-userdata.last_axis(2))<0 &&...
                    (temp(2)-userdata.last_axis(3))*(temp(2)-userdata.last_axis(4))<0
                is_inaxis=1;
                userdata.current_point=temp(1);
                userdata.current_ax=col_pos;
                break;
            end
        end
        if(is_inaxis==0)
            return;
        end
        if userdata.is_shade==1
            if(userdata.mouse_state==1)
                userdata.shade_x(2)=userdata.current_point;
                if userdata.shade_x(2)<userdata.last_axis(1)
                    userdata.shade_x(2)=userdata.last_axis(1);
                end
                if userdata.shade_x(2)>userdata.last_axis(2)
                    userdata.shade_x(2)=userdata.last_axis(2);
                end
                fig_shade_Update();
                if userdata.shade_x(1)>userdata.shade_x(2)
                    set(handles.interval1_edit,'String',num2str(userdata.shade_x(2)));
                    set(handles.interval2_edit,'String',num2str(userdata.shade_x(1)));
                else
                    set(handles.interval1_edit,'String',num2str(userdata.shade_x(1)));
                    set(handles.interval2_edit,'String',num2str(userdata.shade_x(2)));
                end
            end
        end
        if(userdata.auto_cursor)
            userdata.cursor_point=userdata.current_point;
            set(handles.cursor_edit,'String',num2str(userdata.cursor_point));
            fig_cursor_Update();
            fig_topo_Update();
            fig_headplot_Update();
        end
    end

%% fig_split
    function fig_split(~, ~)
        userdata.is_split=~userdata.is_split;
        if userdata.is_split==1
            set(handles.toolbar1,'Visible','on');
            set(handles.toolbar2,'parent',handles.fig2);
            userdata.fig1_pos=get(handles.fig1,'Position');
            userdata.fig2_pos=userdata.fig1_pos;
            userdata.fig2_pos(1)=userdata.fig1_pos(1)+365;
            userdata.fig2_pos(3)=userdata.fig2_pos(3)-365;
            set(handles.fig2,'Position',userdata.fig2_pos);
            userdata.fig1_pos(3)=350;
            set(handles.fig1,'Position',userdata.fig1_pos);
            
            set(handles.toolbar1_split,'State','on');
            set(handles.toolbar2_split,'State','on');
            set(handles.fig2,'visible','on');
            set(handles.panel_fig,'parent',handles.fig2);
            set(handles.panel_fig,'Units','normalized');
            set(handles.panel_fig,'Position',[0,0,1,1]);
        else
            set(handles.toolbar1,'Visible','off');
            set(handles.toolbar2,'parent',handles.fig1);
            set(handles.panel_fig,'parent',handles.fig1);
            set(handles.fig2,'visible','off');
            set(handles.toolbar1_split,'State','off');
            set(handles.toolbar2_split,'State','off');
            userdata.fig1_pos=get(handles.fig1,'Position');
            userdata.fig2_pos=get(handles.fig2,'Position');
            userdata.fig1_pos(1)=userdata.fig2_pos(1)-365;
            userdata.fig1_pos(3)=userdata.fig2_pos(3)+365;
            userdata.fig1_pos(4)=userdata.fig2_pos(4);
            set(handles.fig1,'Position',userdata.fig1_pos);
            figure(handles.fig1);
        end
        fig1_SizeChangedFcn;
        fig2_SizeChangedFcn;
    end

%% fig1_SizeChangedFcn
    function fig1_SizeChangedFcn(~, ~)
        userdata.fig1_pos=get(handles.fig1,'Position');
        p_edit=get(handles.panel_edit,'Position');
        if userdata.is_split==1
            p_edit(3)=userdata.fig1_pos(3);
        else
            p_edit(3)=350;
            if userdata.fig1_pos(3)-365>0
                set(handles.panel_fig,'Units','Pixels');
                p_fig=[365,1,userdata.fig1_pos(3)-365,userdata.fig1_pos(4)];
                set(handles.panel_fig,'Position',p_fig);
                fig2_SizeChangedFcn;
                set(handles.panel_fig,'visible','on');
            else
                set(handles.panel_fig,'visible','off');
            end
        end
        p_edit(4)=userdata.fig1_pos(4);
        set(handles.panel_edit,'Position',p_edit);
    end

%% fig2_SizeChangedFcn
    function fig2_SizeChangedFcn(~, ~)
        set(handles.panel_fig,'Units','Pixels');
        userdata.fig_pos=get(handles.panel_fig,'Position');
        set(handles.panel_fig,'Units','normalized');
        fig_width=userdata.fig_pos(3);
        if userdata.is_topo
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            topo_length=min((fig_width-200)/ax_num,100);
            for ax_idx=1:ax_num
                set(handles.axes_topo(ax_idx),'Position',...
                    [(ax_idx-1)*fig_width/ax_num,...
                    userdata.fig_pos(4)-topo_length-30,...
                    (fig_width-20)/ax_num,topo_length]);
            end
            set(handles.colorbar_topo,'Position',...
                [fig_width-35,userdata.fig_pos(4)-topo_length-30,10,topo_length+10]);
            fig_height=userdata.fig_pos(4)-topo_length-30;
        elseif userdata.is_headplot
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            headplot_length=min((fig_width-200)/ax_num,100);
            for ax_idx=1:ax_num
                set(handles.axes_headplot(ax_idx),'Position',...
                    [(ax_idx-1)*fig_width/ax_num,...
                    userdata.fig_pos(4)-headplot_length-30,...
                    (fig_width-20)/ax_num,headplot_length]);
            end
            set(handles.colorbar_headplot,'Position',...
                [fig_width-35,userdata.fig_pos(4)-headplot_length-30,10,headplot_length+10]);
            fig_height=userdata.fig_pos(4)-headplot_length-30;
        else
            fig_height=userdata.fig_pos(4);
        end
        horz_margin=20;
        vert_margin=20;
        width=max((fig_width)/userdata.num_cols,horz_margin*2+10);
        height=max((fig_height)/userdata.num_rows,vert_margin*2+10);
        for col_pos=1:userdata.num_cols
            for row_pos=1:userdata.num_rows
                x_pos=horz_margin+width*(col_pos-1)+horz_margin/2;
                y_pos=fig_height+vert_margin-height*row_pos+vert_margin/2;
                set(handles.axes((col_pos-1)*userdata.num_rows+row_pos),...
                    'position',[x_pos,y_pos,width-horz_margin*2,height-vert_margin*2]);
            end
        end
        fig_cursor_Update();
    end

%% fig_ax
    function fig_ax()
        for col_pos=1:userdata.num_cols
            for row_pos=1:userdata.num_rows
                ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                if length(handles.axes)<ax_idx
                    handles.axes(ax_idx)=axes('Parent',handles.panel_fig,...
                        'Position',[0,0,0.1,0.1]);
                    set(handles.axes(ax_idx),'tag','line');
                end
                hold(handles.axes(ax_idx),'on');
            end
        end
        
        set(handles.axes,'Units','pixels');
        set(handles.axes,'FontName','Arial');
        set(handles.axes,'FontUnits','pixels');
        set(handles.axes,'FontSize',9);
        set(handles.axes,'TickDir','out');
        set(handles.axes,'TickLength',[0.005 0.005]);
        set(handles.axes(1:userdata.num_cols*userdata.num_rows),'Visible','on');
        set(handles.axes(userdata.num_cols*userdata.num_rows+1:end),'Visible','off');
        for k=userdata.num_cols*userdata.num_rows+1:length(handles.axes)
            set(get(handles.axes(k),'Children'),'Visible','off');
        end
    end

%% fig_line
    function fig_line()
        for wave_idx=length(handles.line)+1:userdata.num_cols*userdata.num_rows*userdata.num_waves
            ax_idx=ceil(wave_idx/userdata.num_waves);
            switch userdata.linestyle
                case 1
                    handles.line(wave_idx)=line(1,1,'Parent',handles.axes(ax_idx));
                case 2
                    handles.line(wave_idx)=stem(1,1,'Parent',handles.axes(ax_idx),'Marker','.');
                case 3
                    handles.line(wave_idx)=stairs(1,1,'Parent',handles.axes(ax_idx));
            end
        end
        set(handles.line,'LineWidth',1);
        set(handles.line(1:userdata.num_cols*userdata.num_rows*userdata.num_waves),'Visible','on');
        set(handles.line(userdata.num_cols*userdata.num_rows*userdata.num_waves+1:end),'Visible','off');
        userdata.minmax_axis=[];
        for dataset_index=1:length(userdata.selected_datasets)
            header=datasets_header(userdata.selected_datasets(dataset_index)).header;
            [index_pos,y_pos,z_pos]=get_iyz_pos(header);
            for epoch_index=1:length(userdata.selected_epochs)
                for channel_index=1:length(userdata.selected_channels)
                    switch(userdata.graph_style(1))
                        case 1
                            row_pos=dataset_index;
                        case 2
                            row_pos=epoch_index;
                        case 3
                            row_pos=channel_index;
                    end
                    switch(userdata.graph_style(2))
                        case 1
                            col_pos=dataset_index;
                        case 2
                            col_pos=epoch_index;
                        case 3
                            col_pos=channel_index;
                    end
                    switch(userdata.graph_style(3))
                        case 1
                            wave_pos=dataset_index;
                        case 2
                            wave_pos=epoch_index;
                        case 3
                            wave_pos=channel_index;
                    end
                    ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                    wave_idx=((col_pos-1)*userdata.num_rows+row_pos-1)*userdata.num_waves+wave_pos;
                    dataset_pos=userdata.selected_datasets(dataset_index);
                    epoch_pos=userdata.selected_epochs(epoch_index);
                    channel_pos=userdata.channel_index(dataset_pos,userdata.selected_channels(channel_index));
                    x_start=datasets_header(dataset_pos).header.xstart;
                    x_step=datasets_header(dataset_pos).header.xstep;
                    x=(0:size(datasets_data(dataset_pos).data,6)-1)*x_step+x_start;
                    y=squeeze(datasets_data(dataset_pos).data(epoch_pos,channel_pos,index_pos,z_pos,y_pos,:))';
                    if userdata.is_filter
                        if userdata.is_filter_low
                            y=filtfilt(datasets_header(dataset_pos).header.filter_low_b,datasets_header(dataset_pos).header.filter_low_a,y);
                        end
                        if userdata.is_filter_high
                            y=filtfilt(datasets_header(dataset_pos).header.filter_high_b,datasets_header(dataset_pos).header.filter_high_a,y);
                        end
                        if userdata.is_filter_notch
                            y=filtfilt(datasets_header(dataset_pos).header.filter_notch_b,datasets_header(dataset_pos).header.filter_notch_a,y);
                        end
                    end
                    if isempty(userdata.minmax_axis)
                        userdata.minmax_axis=[min(x),max(x),min(y),max(y)];
                    else
                        userdata.minmax_axis=[min([x,userdata.minmax_axis(1)]),max([x,userdata.minmax_axis(2)]),min([y,userdata.minmax_axis(3)]),max([y,userdata.minmax_axis(4)])];
                    end
                    if userdata.minmax_axis(1)==userdata.minmax_axis(2)
                        userdata.minmax_axis(1)=userdata.minmax_axis(1)-1;
                        userdata.minmax_axis(2)=userdata.minmax_axis(2)+1;
                    end
                    if userdata.minmax_axis(3)==userdata.minmax_axis(4)
                        userdata.minmax_axis(3)=userdata.minmax_axis(3)-1;
                        userdata.minmax_axis(4)=userdata.minmax_axis(4)+1;
                    end
                    set(handles.line(wave_idx),'XData',x);
                    set(handles.line(wave_idx),'YData',y);
                    set(handles.line(wave_idx),'Parent',handles.axes(ax_idx));
                    set(handles.line(wave_idx),'color',userdata.color_order(mod(wave_pos-1,7)+1,:));
                end
            end
        end
    end

%% fig_polarity
    function fig_polarity(~, ~)
        userdata.is_polarity=strcmp(get(handles.toolbar2_polarity,'State'),'on');
        if userdata.is_polarity
            set(handles.axes,'YDir','reverse');
        else
            set(handles.axes,'YDir','normal');
        end
    end

%% fig_shade_Update
    function fig_shade_Update()
        set(handles.shade,'XData',[userdata.shade_x(1),userdata.shade_x(2),userdata.shade_x(2),userdata.shade_x(1)]);
        set(handles.shade,'YData',[userdata.last_axis(3),userdata.last_axis(3),userdata.last_axis(4),userdata.last_axis(4)]);
    end

%% fig_shade
    function fig_shade(~, ~)
        userdata.is_shade=strcmp(get(handles.toolbar2_shade,'State'),'on');
        if userdata.is_shade
            for ax_idx=length(handles.shade)+1:userdata.num_cols*userdata.num_rows
                handles.shade(ax_idx)=fill(userdata.shade_x([1,2,2,1]),...
                    userdata.minmax_axis([3,3,4,4]),[0.8,0.8,0.8],...
                    'EdgeColor','None','FaceAlpha',0.3,...
                    'Parent',handles.axes(ax_idx));
            end
            set(handles.shade(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.shade(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
            fig_shade_Update();
        else
            if ~isempty(handles.shade)
                set(handles.shade,'Visible','off');
            end
        end
    end

%% fig_legend
    function fig_legend(~, ~)
        if ~isempty(handles.legend)
            delete(handles.legend);
        end
        handles.legend=[];
        userdata.is_legend=strcmp(get(handles.toolbar2_legend,'State'),'on');
        if userdata.is_legend
            userdata.title_wave=cell(userdata.num_waves,1);
            switch(userdata.graph_style(3))
                case 1
                    userdata.title_wave=userdata.str_dataset(userdata.selected_datasets);
                case 2
                    userdata.title_wave=userdata.str_epoch(userdata.selected_epochs);
                case 3
                    userdata.title_wave=userdata.str_channel(userdata.selected_channels);
            end
            handles.legend=legend(handles.axes(userdata.num_cols*userdata.num_rows),...
                handles.line((userdata.num_cols*userdata.num_rows-1)*userdata.num_waves+(1:userdata.num_waves)),...
                userdata.title_wave);
            set(handles.legend,'FontSize',10,'Location','SouthEast','Interpreter', 'none');
        end
    end

%% fig_title
    function fig_title(~, ~)
        userdata.is_title=strcmp(get(handles.toolbar2_title,'State'),'on');
        if userdata.is_title
            userdata.title_row=cell(userdata.num_rows,1);
            userdata.title_col=cell(userdata.num_cols,1);
            switch(userdata.graph_style(1))
                case 1
                    userdata.title_row=userdata.str_dataset(userdata.selected_datasets);
                case 2
                    if userdata.num_cols>3
                        userdata.title_row=userdata.str_epoch(userdata.selected_epochs);
                    else
                        userdata.title_row=strcat('epoch:  ',userdata.str_epoch(userdata.selected_epochs));
                    end
                case 3
                    if userdata.num_cols>3
                        userdata.title_row=userdata.str_channel(userdata.selected_channels);
                    else
                        userdata.title_row=strcat('channels:  ',userdata.str_channel(userdata.selected_channels));
                    end
            end
            switch(userdata.graph_style(2))
                case 1
                    userdata.title_col=userdata.str_dataset(userdata.selected_datasets);
                case 2
                    
                    if userdata.num_cols>3
                        userdata.title_col=userdata.str_epoch(userdata.selected_epochs);
                    else
                        userdata.title_col=strcat('epoch:  ',userdata.str_epoch(userdata.selected_epochs));
                    end
                case 3
                    if userdata.num_cols>3
                        userdata.title_col=userdata.str_channel(userdata.selected_channels);
                    else
                        userdata.title_col=strcat('channels:  ',userdata.str_channel(userdata.selected_channels));
                    end
            end
            
            for col_pos=1:userdata.num_cols
                for row_pos=1:userdata.num_rows
                    ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                    if length(handles.title)<ax_idx
                        handles.title(ax_idx)=title(handles.axes(ax_idx),...
                            {[' ',char(userdata.title_row(row_pos))],...
                            [' ',char(userdata.title_col(col_pos))]});
                    end
                    if(userdata.graph_style(1)<userdata.graph_style(2))
                        set(handles.title(ax_idx),'String',...
                            {[' ',char(userdata.title_row(row_pos))],...
                            [' ',char(userdata.title_col(col_pos))]});
                    else
                        set(handles.title(ax_idx),'String',...
                            {[' ',char(userdata.title_col(col_pos))],...
                            [' ',char(userdata.title_row(row_pos))]});
                    end
                end
            end
            set(handles.title,'Units','normalized',...
                'position',[0.01,0.98,0], 'Interpreter', 'none',...
                'HorizontalAlignment','left','VerticalAlignment','top'...
                ,'FontSize',10,'FontWeight','bold');
            set(handles.title(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.title(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
        else
            if ~isempty(handles.title)
                set(handles.title,'Visible','off');
            end
        end
    end

%% fig_cursor_Update
    function fig_cursor_Update()
        if(userdata.is_cursor)
            set(handles.cursor,'XData',[userdata.cursor_point,userdata.cursor_point]);
            set(handles.cursor,'YData',[userdata.last_axis(3),userdata.last_axis(4)]);
            set(handles.text_x,'String',num2str(userdata.cursor_point,'%0.2g'));
            x_extent=get(handles.text_x(1),'extent');
            for col_pos=1:userdata.num_cols
                ax_idx=col_pos*userdata.num_rows;
                fig_pos=get(handles.axes(ax_idx),'Position');
                point_pos(1)=fig_pos(3)+fig_pos(1)-(fig_pos(3)+fig_pos(1)-fig_pos(1))/...
                    (userdata.last_axis(2)-userdata.last_axis(1))*(userdata.last_axis(2)-userdata.cursor_point);
                c3=[point_pos(1)-x_extent(3)/2,fig_pos(2)-x_extent(4),x_extent(3),x_extent(4)-5];
                set(handles.text_x(col_pos),'Position',c3);
                for row_pos=1:userdata.num_rows
                    ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                    fig_pos=get(handles.axes(ax_idx),'Position');
                    for wave_pos=1:userdata.num_waves
                        wave_idx=((col_pos-1)*userdata.num_rows+row_pos-1)*userdata.num_waves+wave_pos;
                        plot_x=get(handles.line(wave_idx),'XData');
                        plot_y=get(handles.line(wave_idx),'YData');
                        if (userdata.cursor_point-plot_x(1))*(plot_x(end)-userdata.cursor_point)<0
                            set(handles.text_y(wave_idx),'visible','off');
                            set(handles.point_y(wave_idx),'visible','off');
                            continue;
                        end
                        a=find(plot_x<userdata.cursor_point,1,'last');
                        b=find(plot_x>userdata.cursor_point,1,'first');
                        plot_x=plot_x([a,b]);
                        plot_y=plot_y([a,b]);
                        cursor_point_y=plot_y(2)-(plot_y(2)-plot_y(1))/(plot_x(2)-plot_x(1))...
                            *(plot_x(2)-userdata.cursor_point);
                        if cursor_point_y<userdata.last_axis(3)||cursor_point_y>userdata.last_axis(4)
                            set(handles.text_y(wave_idx),'visible','off');
                            set(handles.point_y(wave_idx),'visible','off');
                            continue;
                        end
                        if ~userdata.is_polarity
                            point_pos(2)=fig_pos(4)+fig_pos(2)-fig_pos(4)/...
                                (userdata.last_axis(4)-userdata.last_axis(3))*(userdata.last_axis(4)-cursor_point_y);
                        else
                            point_pos(2)=fig_pos(2)+fig_pos(4)/...
                                (userdata.last_axis(4)-userdata.last_axis(3))*(userdata.last_axis(4)-cursor_point_y);
                        end
                        set(handles.text_y(wave_idx),'String',num2str(cursor_point_y,'%0.3g'));
                        c1=get(handles.text_y(wave_idx),'extent');
                        c3=[fig_pos(1)+5,point_pos(2)-c1(4)/2,c1(3),c1(4)-5];
                        set(handles.text_y(wave_idx),'BackgroundColor',get(handles.line(wave_idx),'Color'));
                        set(handles.text_y(wave_idx),'Position',c3);
                        set(handles.text_y(wave_idx),'visible','on');
                        
                        set(handles.point_y(wave_idx),'XData',userdata.cursor_point);
                        set(handles.point_y(wave_idx),'YData',cursor_point_y);
                        set(handles.point_y(wave_idx),'Color',get(handles.line(wave_idx),'Color')/1.5);
                        set(handles.point_y(wave_idx),'parent',handles.axes(ax_idx));
                        set(handles.point_y(wave_idx),'visible','on');
                    end
                end
            end
        end
    end

%% fig_cursor
    function fig_cursor(~, ~)
        userdata.is_cursor=strcmp(get(handles.toolbar2_cursor,'State'),'on');
        if userdata.is_cursor
            for col_pos=1:userdata.num_cols
                if length(handles.text_x)<col_pos
                    handles.text_x(col_pos)=uicontrol('Parent',handles.panel_fig,...
                        'Style','text','String','1','FontSize',10,...
                        'ForegroundColor',[1,1,1],'BackgroundColor',[0,0,0]);
                end
                for row_pos=1:userdata.num_rows
                    ax_idx=(col_pos-1)*userdata.num_rows+row_pos;
                    if length(handles.cursor)<ax_idx
                        handles.cursor(ax_idx)=line(userdata.cursor_point([1,1]),userdata.minmax_axis([3,4]),...
                            'Parent',handles.axes(ax_idx),'Linewidth',0.1);
                    end
                    for wave_pos=1:userdata.num_waves
                        wave_idx=((col_pos-1)*userdata.num_rows+row_pos-1)*userdata.num_waves+wave_pos;
                        if length(handles.text_y)<wave_idx
                            handles.point_y(wave_idx)=plot(userdata.cursor_point,userdata.minmax_axis(3),...
                                'r.','MarkerSize',18,'Parent',handles.axes(ax_idx));
                            handles.text_y(wave_idx)=uicontrol('Parent',handles.panel_fig,'Style','text','String','32',...
                                'FontSize',10,'ForegroundColor',[1,1,1],'BackgroundColor',[0,0,0]);
                        end
                    end
                end
            end
            set(handles.cursor,'color',[0,0,0]);
            set(handles.text_x(1:userdata.num_cols),'Visible','on');
            set(handles.text_x(userdata.num_cols+1:end),'Visible','off');
            
            set(handles.cursor(1:userdata.num_rows*userdata.num_cols),'Visible','on');
            set(handles.cursor(userdata.num_rows*userdata.num_cols+1:end),'Visible','off');
            set(handles.text_y(1:userdata.num_rows*userdata.num_cols*userdata.num_waves),'Visible','on');
            set(handles.text_y(userdata.num_rows*userdata.num_cols*userdata.num_waves+1:end),'Visible','off');
            set(handles.point_y(1:userdata.num_rows*userdata.num_cols*userdata.num_waves),'Visible','on');
            set(handles.point_y(userdata.num_rows*userdata.num_cols*userdata.num_waves+1:end),'Visible','off');
            fig_cursor_Update();
        else
            if ~isempty(handles.cursor)
                set(handles.cursor,'Visible','off');
                set(handles.text_y,'Visible','off');
                set(handles.text_x,'Visible','off');
                set(handles.point_y,'Visible','off');
            end
        end
        set(handles.cursor_edit,'String',num2str(userdata.cursor_point));
    end

%% fig_linestyle
    function fig_linestyle(~, ~,index)
        userdata.linestyle=index;
        switch userdata.linestyle
            case 1
                set(handles.toolbar2_line,'State','on');
                set(handles.toolbar2_stem,'State','off');
                set(handles.toolbar2_stairs,'State','off');
                for col_pos=1:userdata.num_cols
                    for row_pos=1:userdata.num_rows
                        for wave_pos=1:userdata.num_waves
                            wave_idx=((col_pos-1)*userdata.num_rows+row_pos-1)*userdata.num_waves+wave_pos;
                            x=get(handles.line(wave_idx),'XData');
                            y=get(handles.line(wave_idx),'YData');
                            delete(handles.line(wave_idx));
                            handles.line(wave_idx)=line(x,y,'Parent',handles.axes((col_pos-1)*userdata.num_rows+row_pos),'LineWidth',1);
                            set(handles.line(wave_idx),'color',userdata.color_order(mod(wave_pos-1,7)+1,:));
                        end
                    end
                end
            case 2
                set(handles.toolbar2_line,'State','off');
                set(handles.toolbar2_stem,'State','on');
                set(handles.toolbar2_stairs,'State','off');
                for col_pos=1:userdata.num_cols
                    for row_pos=1:userdata.num_rows
                        for wave_pos=1:userdata.num_waves
                            wave_idx=((col_pos-1)*userdata.num_rows+row_pos-1)*userdata.num_waves+wave_pos;
                            x=get(handles.line(wave_idx),'XData');
                            y=get(handles.line(wave_idx),'YData');
                            delete(handles.line(wave_idx));
                            handles.line(wave_idx)=stem(x,y,'Parent',handles.axes((col_pos-1)*userdata.num_rows+row_pos),'Marker','.','LineWidth',1);
                            set(handles.line(wave_idx),'color',userdata.color_order(mod(wave_pos-1,7)+1,:));
                        end
                    end
                end
            case 3
                set(handles.toolbar2_line,'State','off');
                set(handles.toolbar2_stem,'State','off');
                set(handles.toolbar2_stairs,'State','on');
                for col_pos=1:userdata.num_cols
                    for row_pos=1:userdata.num_rows
                        for wave_pos=1:userdata.num_waves
                            wave_idx=((col_pos-1)*userdata.num_rows+row_pos-1)*userdata.num_waves+wave_pos;
                            x=get(handles.line(wave_idx),'XData');
                            y=get(handles.line(wave_idx),'YData');
                            delete(handles.line(wave_idx));
                            handles.line(wave_idx)=stairs(x,y,'Parent',handles.axes((col_pos-1)*userdata.num_rows+row_pos),'LineWidth',1);
                            set(handles.line(wave_idx),'color',userdata.color_order(mod(wave_pos-1,7)+1,:));
                        end
                    end
                end
        end
    end

%% fig_topo_Update
    function fig_topo_Update()
        if userdata.is_topo
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            ax_idx=0;
            [xq,yq] = meshgrid(linspace(-0.5,0.5,67),linspace(-0.5,0.5,67));
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                t=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                chan_used=find([header.chanlocs.topo_enabled]==1);
                if isempty(chan_used)
                    vq=nan(67,67);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        set( handles.surface_topo(ax_idx),'CData',vq);
                    end
                else
                    chanlocs=header.chanlocs(chan_used);
                    [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                    [index_pos,y_pos,z_pos]=get_iyz_pos(header);
                    [~,b]=min(abs(t-userdata.cursor_point));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,chan_used,index_pos,z_pos,y_pos,b));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        vq = griddata(x,y,data(userdata.selected_epochs(epoch_index),:),xq,yq,'cubic');
                        set( handles.surface_topo(ax_idx),'CData',vq);
                    end
                end
            end
        end
    end

%% fig_topo_popup
    function fig_topo_popup(obj,~)
        if strcmp(get(obj,'SelectionType'),'open')
            fig_temp=figure();
            [xq,yq] = meshgrid(linspace(-0.5,0.5,267),linspace(-0.5,0.5,267));
            delta = (xq(2)-xq(1))/2;
            ax_num=length(userdata.selected_datasets)*length(userdata.selected_epochs);
            row_num=length(userdata.selected_datasets);
            col_num=length(userdata.selected_epochs);
            if(col_num>7)
                col_num=7;
                row_num=ceil(ax_num/7);
            end
            for ax_idx=1:ax_num
                axes_topo(ax_idx)=subplot(row_num,col_num,ax_idx);
                set(axes_topo(ax_idx),'Xlim',[-0.55,0.55]);
                set(axes_topo(ax_idx),'Ylim',[-0.5,0.6]);
                caxis(axes_topo(ax_idx),userdata.last_axis(3:4));
                hold(axes_topo(ax_idx),'on');
                axis(axes_topo(ax_idx),'square');
                surface_topo(ax_idx)=surface(xq-delta,yq-delta,zeros(size(xq)),xq,...
                    'EdgeColor','none','FaceColor','flat','parent',axes_topo(ax_idx));
                headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
                    0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
                    -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
                heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
                    0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
                line_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linewidth',2,'parent',axes_topo(ax_idx));
                dot_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8,'parent',axes_topo(ax_idx));
            end
            colormap 'jet';
            colorbar_topo=colorbar;
            p=get(fig_temp,'position');
            set(colorbar_topo,'units','pixels');
            set(colorbar_topo,'position',[p(3)-40,10,10,p(4)-20]);
            set(colorbar_topo,'units','normalized');
            set(axes_topo,'Visible','off');
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                chan_used=find([header.chanlocs.topo_enabled]==1);
                if isempty(chan_used)
                    vq=nan(267,267);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        set( surface_topo(ax_idx),'CData',vq);
                        str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                        title_topo(ax_idx)=title(axes_topo(ax_idx),str,'Interpreter','none');
                    end
                else
                    t=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                    chanlocs=header.chanlocs(chan_used);
                    [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                    [index_pos,y_pos,z_pos]=get_iyz_pos(header);
                    [~,b]=min(abs(t-userdata.cursor_point));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,chan_used,index_pos,y_pos,z_pos,b));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        vq = griddata(x,y,data(userdata.selected_epochs(epoch_index),:),xq,yq,'cubic');
                        set( surface_topo(ax_idx),'CData',vq);
                        set( dot_topo(ax_idx),'XData',x);
                        set( dot_topo(ax_idx),'YData',y);
                        str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                        title_topo(ax_idx)=title(axes_topo(ax_idx),str,'Interpreter','none');
                    end
                end
            end
            set(title_topo,'Visible','on');
        end
    end

%% fig_topo
    function fig_topo(~,~)
        userdata.is_topo=strcmp(get(handles.toolbar2_topo,'State'),'on');
        if userdata.is_topo
            if userdata.is_filter
                userdata.is_filter=0;
                set(handles.filter_checkbox,'value',userdata.is_filter);
                set(handles.filter_lowpass_checkbox,'Enable','off');
                set(handles.filter_lowpass_edit,'Enable','off');
                set(handles.filter_highpass_checkbox,'Enable','off');
                set(handles.filter_highpass_edit,'Enable','off');
                set(handles.filter_notch_checkbox,'Enable','off');
                set(handles.filter_notch_popup,'Enable','off');
                set(handles.filter_order_text,'Enable','off');
                set(handles.filter_order_popup,'Enable','off');
                fig_line;
                edit_yaxis_auto_checkbox_Changed;
                fig_shade_Update;
                fig_cursor_Update;
            end
            if userdata.is_headplot
                set(handles.toolbar2_headplot,'State','off');
                userdata.is_headplot=0;
                if ~isempty(handles.colorbar_headplot)
                    set(handles.colorbar_headplot,'Visible','off');
                    set(handles.axes_headplot,'Visible','off');
                    set(handles.title_headplot,'Visible','off');
                    set(handles.surface_headplot,'Visible','off');
                    set(handles.dot_headplot,'Visible','off');
                end
            end
            
            [xq,yq] = meshgrid(linspace(-0.5,0.5,67),linspace(-0.5,0.5,67));
            delta = (xq(2)-xq(1))/2;
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            for ax_idx=1:ax_num
                if length(handles.axes_topo)<ax_idx
                    handles.axes_topo(ax_idx)=axes('Parent',handles.panel_fig,'units','pixels');
                    caxis(handles.axes_topo(ax_idx),userdata.last_axis(3:4));
                    set(handles.axes_topo(ax_idx),'Xlim',[-0.55,0.55]);
                    set(handles.axes_topo(ax_idx),'Ylim',[-0.5,0.6]);
                    axis(handles.axes_topo(ax_idx),'square');
                    hold(handles.axes_topo(ax_idx),'on')
                    handles.title_topo(ax_idx)=title(handles.axes_topo(ax_idx),'hello','Interpreter','none');
                    handles.surface_topo(ax_idx)=surface(xq-delta,yq-delta,zeros(size(xq)),xq,...
                        'EdgeColor','none','FaceColor','flat','parent',handles.axes_topo(ax_idx));
                    headx = 0.5*[sin(linspace(0,2*pi,100)),NaN,sin(-2*pi*10/360),0,sin(2*pi*10/360),NaN,...
                        0.1*cos(2*pi/360*linspace(80,360-80,100))-1,NaN,...
                        -0.1*cos(2*pi/360*linspace(80,360-80,100))+1];
                    heady = 0.5*[cos(linspace(0,2*pi,100)),NaN,cos(-2*pi*10/360),1.1,cos(2*pi*10/360),NaN,...
                        0.2*sin(2*pi/360*linspace(80,360-80,100)),NaN,0.2*sin(2*pi/360*linspace(80,360-80,100))];
                    handles.line_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linewidth',2,'parent',handles.axes_topo(ax_idx));
                    handles.dot_topo(ax_idx)=line(headx,heady,'Color',[0,0,0],'Linestyle','none','Marker','.','Markersize',8,'parent',handles.axes_topo(ax_idx));
                    set(handles.surface_topo(ax_idx),'ButtonDownFcn',{@fig_topo_popup});
                    set(handles.line_topo(ax_idx),'ButtonDownFcn',{@fig_topo_popup});
                    set(handles.dot_topo(ax_idx),'ButtonDownFcn',{@fig_topo_popup});
                end
                dataset_index=ceil(ax_idx/length(userdata.selected_epochs));
                epoch_index=mod(ax_idx-1,length(userdata.selected_epochs))+1;
                set(handles.title_topo(ax_idx),'String',...
                    [char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']']);
            end
            colormap 'jet';
            if isempty(handles.colorbar_topo)
                handles.colorbar_topo=colorbar;
                set(handles.colorbar_topo,'units','pixels');
                set(handles.colorbar_topo,'FontName','Arial');
                set(handles.colorbar_topo,'FontSize',6);
            else
                set(handles.colorbar_topo,'Visible','on');
            end
            set(handles.axes_topo,'Visible','off');
            set(handles.title_topo(1:ax_num),'Visible','on');
            set(handles.title_topo(ax_num+1:end),'Visible','off');
            set(handles.surface_topo(1:ax_num),'Visible','on');
            set(handles.surface_topo(ax_num+1:end),'Visible','off');
            set(handles.line_topo(1:ax_num),'Visible','on');
            set(handles.line_topo(ax_num+1:end),'Visible','off');
            set(handles.dot_topo(1:ax_num),'Visible','on');
            set(handles.dot_topo(ax_num+1:end),'Visible','off');
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                chan_used=find([header.chanlocs.topo_enabled]==1);
                chanlocs=header.chanlocs(chan_used);
                [y,x]= pol2cart(pi/180.*[chanlocs.theta],[chanlocs.radius]);
                for epoch_index=1:length(userdata.selected_epochs)
                    ax_idx=ax_idx+1;
                    if(ax_idx>ax_num)
                        break;
                    end
                    set( handles.dot_topo(ax_idx),'XData',x);
                    set( handles.dot_topo(ax_idx),'YData',y);
                end
            end
            fig_topo_Update();
        else
            if ~isempty(handles.colorbar_topo)
                set(handles.colorbar_topo,'Visible','off');
                set(handles.axes_topo,'Visible','off');
                set(handles.title_topo,'Visible','off');
                set(handles.surface_topo,'Visible','off');
                set(handles.line_topo,'Visible','off');
                set(handles.dot_topo,'Visible','off');
            end
        end
        fig2_SizeChangedFcn();
    end

%% fig_headplot_Update
    function fig_headplot_Update(~,~)
        if userdata.is_headplot
            ax_num=min(length(userdata.selected_datasets)*length(userdata.selected_epochs),4);
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                t=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                if isempty(header.indices)
                    P=zeros(length(userdata.POS),1);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        set( handles.surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                else
                    [index_pos,y_pos,z_pos]=get_iyz_pos(header);
                    [~,b]=min(abs(t-userdata.cursor_point));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,header.indices,index_pos,z_pos,y_pos,b));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        values=data(userdata.selected_epochs(epoch_index),:);
                        meanval = mean(values);
                        P=header.GG* [values(:)- meanval;0]+meanval;
                        set( handles.surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                end
            end
        end
    end

%% fig_headplot_popup
    function fig_headplot_popup(~,~)
        if strcmp(get(obj,'SelectionType'),'open')
            fig_temp=figure();
            ax_num=length(userdata.selected_datasets)*length(userdata.selected_epochs);
            row_num=length(userdata.selected_datasets);
            col_num=length(userdata.selected_epochs);
            if(col_num>7)
                col_num=7;
                row_num=ceil(ax_num/7);
            end
            for ax_idx=1:ax_num
                axes_headplot(ax_idx)=subplot(row_num,col_num,ax_idx);
                caxis(axes_headplot(ax_idx),userdata.last_axis(3:4));
                axis(axes_headplot(ax_idx),'image');
                title_headplot(ax_idx)=title(axes_headplot(ax_idx),'hello',...
                    'Interpreter','none');
                light('Position',[-125  125  80],'Style','infinite')
                light('Position',[125  125  80],'Style','infinite')
                light('Position',[125 -125 80],'Style','infinite')
                light('Position',[-125 -125 80],'Style','infinite')
                lighting phong;
                
                P=linspace(1,userdata.headplot_colornum,length(userdata.POS))';
                surface_headplot(ax_idx) = ...
                    patch('Vertices',userdata.POS,'Faces',userdata.TRI,...
                    'FaceVertexCdata',P,'FaceColor','interp', ...
                    'EdgeColor','none');
                set(surface_headplot(ax_idx),'DiffuseStrength',.6,...
                    'SpecularStrength',0,'AmbientStrength',.3,...
                    'SpecularExponent',5,'vertexnormals', userdata.NORM);
                axis(axes_headplot(ax_idx),[-125 125 -125 125 -125 125]);
                view([0 90]);
                dot_headplot(ax_idx)=line(1,1,1,'Color',[0,0,0],...
                    'Linestyle','none','Marker','.','Markersize',ceil(10/sqrt(ax_num)),...
                    'parent',axes_headplot(ax_idx));
            end
            colormap(jet(userdata.headplot_colornum));
            colorbar_headplot=colorbar;
            p=get(fig_temp,'position');
            set(colorbar_headplot,'units','pixels');
            set(colorbar_headplot,'position',[p(3)-40,10,10,p(4)-20]);
            set(colorbar_headplot,'units','normalized');
            set(axes_headplot,'Visible','off');
            
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                t=(0:header.datasize(6)-1)*header.xstep+header.xstart;
                if isempty(header.indices)
                    P=zeros(length(userdata.POS),1);
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        if(ax_idx>ax_num)
                            break;
                        end
                        set( surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                else
                    [index_pos,y_pos,z_pos]=get_iyz_pos(header);
                    [~,b]=min(abs(t-userdata.cursor_point));
                    data=squeeze(datasets_data(userdata.selected_datasets(dataset_index)).data...
                        (:,header.indices,index_pos,z_pos,y_pos,b));
                    for epoch_index=1:length(userdata.selected_epochs)
                        ax_idx=ax_idx+1;
                        set( dot_headplot(ax_idx),'XData',header.newElect(:,1));
                        set( dot_headplot(ax_idx),'YData',header.newElect(:,2));
                        set( dot_headplot(ax_idx),'ZData',header.newElect(:,3));
                        str=[char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']'];
                        title_headplot(ax_idx)=title(axes_headplot(ax_idx),str,'Interpreter','none');
                        values=data(userdata.selected_epochs(epoch_index),:);
                        meanval = mean(values); values = values - meanval;
                        P=header.GG * [values(:);0]+meanval;
                        set( surface_headplot(ax_idx),'FaceVertexCdata',P);
                    end
                end
            end
            set(title_headplot,'Visible','on');
        end
    end

%% fig_headplot
    function fig_headplot(~,~)
        userdata.is_headplot=strcmp(get(handles.toolbar2_headplot,'State'),'on');
        if userdata.is_headplot
            if userdata.is_filter
                userdata.is_filter=0;
                set(handles.filter_checkbox,'value',userdata.is_filter);
                set(handles.filter_lowpass_checkbox,'Enable','off');
                set(handles.filter_lowpass_edit,'Enable','off');
                set(handles.filter_highpass_checkbox,'Enable','off');
                set(handles.filter_highpass_edit,'Enable','off');
                set(handles.filter_notch_checkbox,'Enable','off');
                set(handles.filter_notch_popup,'Enable','off');
                set(handles.filter_order_text,'Enable','off');
                set(handles.filter_order_popup,'Enable','off');
                fig_line;
                edit_yaxis_auto_checkbox_Changed;
                fig_shade_Update;
                fig_cursor_Update;
            end
            if userdata.is_topo
                set(handles.toolbar2_topo,'State','off');
                userdata.is_topo=0;
                if ~isempty(handles.colorbar_topo)
                    set(handles.colorbar_topo,'Visible','off');
                    set(handles.axes_topo,'Visible','off');
                    set(handles.title_topo,'Visible','off');
                    set(handles.surface_topo,'Visible','off');
                    set(handles.line_topo,'Visible','off');
                    set(handles.dot_topo,'Visible','off');
                end
            end
            ax_num=min(length(userdata.selected_datasets)...
                *length(userdata.selected_epochs),4);
            for ax_idx=1:ax_num
                if length(handles.axes_headplot)<ax_idx
                    handles.axes_headplot(ax_idx)=axes('Parent',...
                        handles.panel_fig,'units','pixels');
                    caxis(handles.axes_headplot(ax_idx),userdata.last_axis(3:4));
                    axis(handles.axes_headplot(ax_idx),'image');
                    handles.title_headplot(ax_idx)=title(...
                        handles.axes_headplot(ax_idx),'hello',...
                        'Interpreter','none');
                    light('Position',[-125  125  80],'Style','infinite')
                    light('Position',[125  125  80],'Style','infinite')
                    light('Position',[125 -125 80],'Style','infinite')
                    light('Position',[-125 -125 80],'Style','infinite')
                    lighting phong;
                    
                    P=linspace(1,userdata.headplot_colornum,length(userdata.POS))';
                    handles.surface_headplot(ax_idx) = ...
                        patch('Vertices',userdata.POS,'Faces',userdata.TRI,...
                        'FaceVertexCdata',P,'FaceColor','interp', ...
                        'EdgeColor','none');
                    set(handles.surface_headplot(ax_idx),'DiffuseStrength',.6,...
                        'SpecularStrength',0,'AmbientStrength',.3,...
                        'SpecularExponent',5,'vertexnormals', userdata.NORM);
                    axis(handles.axes_headplot(ax_idx),[-125 125 -125 125 -125 125]);
                    view([0 90]);
                    handles.dot_headplot(ax_idx)=line(1,1,1,'Color',[0,0,0],...
                        'Linestyle','none','Marker','.','Markersize',6,...
                        'parent',handles.axes_headplot(ax_idx));
                    set(handles.surface_headplot(ax_idx),'ButtonDownFcn',{@fig_headplot_popup});
                    set(handles.dot_headplot(ax_idx),'ButtonDownFcn',{@fig_headplot_popup});
                end
                dataset_index=ceil(ax_idx/length(userdata.selected_epochs));
                epoch_index=mod(ax_idx-1,length(userdata.selected_epochs))+1;
                set(handles.title_headplot(ax_idx),'String',...
                    [char(userdata.str_dataset(userdata.selected_datasets(dataset_index))),' [',num2str(epoch_index),']']);
            end
            colormap(jet(userdata.headplot_colornum));
            if isempty(handles.colorbar_headplot)
                handles.colorbar_headplot=colorbar;
                set(handles.colorbar_headplot,'units','pixels');
                set(handles.colorbar_headplot,'FontName','Arial');
                set(handles.colorbar_headplot,'FontSize',6);
            else
                set(handles.colorbar_headplot,'Visible','on');
            end
            set(handles.axes_headplot,'Visible','off');
            set(handles.title_headplot(1:ax_num),'Visible','on');
            set(handles.title_headplot(ax_num+1:end),'Visible','off');
            set(handles.surface_headplot(1:ax_num),'Visible','on');
            set(handles.surface_headplot(ax_num+1:end),'Visible','off');
            set(handles.dot_headplot(1:ax_num),'Visible','on');
            set(handles.dot_headplot(ax_num+1:end),'Visible','off');
            ax_idx=0;
            for dataset_index=1:length(userdata.selected_datasets)
                if(ax_idx>ax_num)
                    break;
                end
                header=datasets_header(userdata.selected_datasets(dataset_index)).header;
                for epoch_index=1:length(userdata.selected_epochs)
                    ax_idx=ax_idx+1;
                    if(ax_idx>ax_num)
                        break;
                    end
                    set( handles.dot_headplot(ax_idx),'XData',header.newElect(:,1));
                    set( handles.dot_headplot(ax_idx),'YData',header.newElect(:,2));
                    set( handles.dot_headplot(ax_idx),'ZData',header.newElect(:,3));
                end
            end
            fig_headplot_Update();
        else
            if ~isempty(handles.colorbar_headplot)
                set(handles.colorbar_headplot,'Visible','off');
                set(handles.axes_headplot,'Visible','off');
                set(handles.title_headplot,'Visible','off');
                set(handles.surface_headplot,'Visible','off');
                set(handles.line_headplot,'Visible','off');
                set(handles.dot_headplot,'Visible','off');
            end
        end
        fig2_SizeChangedFcn();
    end

%% get_iyz_pos
    function [index_pos,y_pos,z_pos]=get_iyz_pos(header)
        if strcmp(get(handles.index_popup,'Visible'),'off')
            index_pos=1;
        else
            index_pos=get(handles.index_popup,'Value');
        end
        if strcmp(get(handles.y_edit,'Visible'),'off')
            y_pos=1;
        else
            y=str2double(get(handles.y_edit,'String'));
            y_pos=round(((y-header.ystart)/header.ystep)+1);
            if y_pos<1
                y_pos=1;
            end
            if y_pos>header.datasize(5)
                y_pos=header.datasize(5);
            end
            set(handles.y_edit,'String',num2str((y_pos-1)*header.ystep+header.ystart));
        end
        if strcmp(get(handles.z_edit,'Visible'),'off')
            z_pos=1;
        else
            z=str2num(get(handles.z_edit,'String'));
            z_pos=round((z-header.zstart)/header.zstep)+1;
            if z_pos<1
                z_pos=1;
            end;
            if z_pos>header.datasize(4)
                z_pos=header.datasize(4);
            end
            set(handles.z_edit,'String',num2str((z_pos-1)*header.zstep+header.zstart));
        end
    end

%% edit_dataset_Add
    function edit_dataset_Add(~, ~)
        [FileName,PathName] = uigetfile({'*.lw6','Select the lw6 file'},'MultiSelect','on');
        userdata.datasets_path=PathName;
        FileName=cellstr(FileName);
        if PathName~=0;
            FileName=cellstr(FileName);
            for k=1:length(FileName)
                userdata.datasets_filename{end+1}=FileName{k}(1:end-4);
                [datasets_header(end+1).header, datasets_data(end+1).data]=CLW_load([PathName,FileName{k}]);
                chan_used=find([datasets_header(end).header.chanlocs.topo_enabled]==1, 1);
                if isempty(chan_used)
                    datasets_header(end).header=RLW_edit_electrodes(datasets_header(end).header,userdata.chanlocs);
                end
                datasets_header(end).header=CLW_make_spl(datasets_header(end).header);
            end
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
        end
    end

%% edit_dataset_Del
    function edit_dataset_Del(~, ~)
        index=get(handles.dataset_listbox,'value');
        if length(index)==length(datasets_header)
            CreateStruct.Interpreter = 'none';
            CreateStruct.WindowStyle = 'modal';
            msgbox('Unable to delete all datasets','Error','error',CreateStruct);
            return;
        else
            index_remain=setdiff(1:length(datasets_header),index);
            userdata.datasets_filename={userdata.datasets_filename{index_remain}};
            datasets_header=datasets_header(index_remain);
            datasets_data=datasets_data(index_remain);
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
            set(handles.dataset_listbox,'value',1);
            userdata.selected_datasets=2;
            CGLW_my_view_UpdataFcn();
        end
    end

%% edit_dataset_Up
    function edit_dataset_Up(~, ~)
        index=get(handles.dataset_listbox,'value');
        if index(1)==1
            return;
        else
            index_unselected=setdiff(1:length(datasets_header),index);
            index_order=zeros(1,length(datasets_header));
            index_order(index-1)=index;
            for k=1:length(index_order)
                if index_order(k)==0
                    index_order(k)=index_unselected(1);
                    index_unselected=index_unselected(2:end);
                end
            end
            userdata.datasets_filename={userdata.datasets_filename{index_order}};
            datasets_header=datasets_header(index_order);
            datasets_data=datasets_data(index_order);
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
            set(handles.dataset_listbox,'value',index-1);
            userdata.selected_datasets=index-1;
        end
    end

%% edit_dataset_Down
    function edit_dataset_Down(~, ~)
        index=get(handles.dataset_listbox,'value');
        if index(end)==length(datasets_header)
            return;
        else
            index_unselected=setdiff(1:length(datasets_header),index);
            index_order=zeros(1,length(datasets_header));
            index_order(index+1)=index;
            for k=1:length(index_order)
                if index_order(k)==0
                    index_order(k)=index_unselected(1);
                    index_unselected=index_unselected(2:end);
                end
            end
            userdata.datasets_filename={userdata.datasets_filename{index_order}};
            datasets_header=datasets_header(index_order);
            datasets_data=datasets_data(index_order);
            set(handles.dataset_listbox,'String',userdata.datasets_filename);
            set(handles.dataset_listbox,'value',index+1);
            userdata.selected_datasets=index+1;
        end
    end

%% edit_xaxis_Changed
    function edit_xaxis_Changed(~, ~)
        x(1) = str2double(get(handles.xaxis1_edit, 'String'));
        x(2) = str2double(get(handles.xaxis2_edit, 'String'));
        if x(1)==x(2)
            x(1)=x(1)-1;
            x(2)=x(2)+1;
            set(handles.xaxis1_edit,'String',x(1));
            set(handles.xaxis2_edit,'String',x(2));
        end
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.xaxis1_edit,'String',x(1));
            set(handles.xaxis2_edit,'String',x(2));
        end
        userdata.last_axis([1,2])=x;
        set(handles.axes,'XLim',userdata.last_axis(1:2));
        userdata.auto_x=0;set(handles.xaxis_auto_checkbox,'Value',userdata.auto_x);
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end

%% edit_yaxis_Changed
    function edit_yaxis_Changed(~, ~)
        x(1) = str2double(get(handles.yaxis1_edit, 'String'));
        x(2) = str2double(get(handles.yaxis2_edit, 'String'));
        if x(1)==x(2)
            x(1)=x(1)-1;
            x(2)=x(2)+1;
            set(handles.yaxis1_edit,'String',x(1));
            set(handles.yaxis2_edit,'String',x(2));
        end
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.yaxis1_edit,'String',x(1));
            set(handles.yaxis2_edit,'String',x(2));
        end
        
        userdata.last_axis([3,4])=x;
        set(handles.axes,'YLim',userdata.last_axis(3:4));
        userdata.auto_y=0;set(handles.yaxis_auto_checkbox,'Value',userdata.auto_y);
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
        
        if ~isempty(handles.axes_topo)
            for k=1:length(handles.axes_topo)
                caxis(handles.axes_topo(k),userdata.last_axis(3:4));
            end
        end
        if ~isempty(handles.axes_headplot)
            for k=1:length(handles.axes_headplot)
                caxis(handles.axes_headplot(k),userdata.last_axis(3:4));
            end
        end
    end

%% edit_interval_Changed
    function edit_interval_Changed(~, ~)
        x(1) = str2num(get(handles.interval1_edit,'String'));
        x(2) = str2num(get(handles.interval2_edit,'String'));
        if(x(1)>x(2))
            x=x([2,1]);
            set(handles.interval1_edit,'String',x(1));
            set(handles.interval2_edit,'String',x(2));
        end
        userdata.shade_x=x;
        fig_shade_Update();
    end

%% edit_interval_table
    function edit_interval_table(~,~)
        x1=str2num(get(handles.interval1_edit,'String'));
        x2=str2num(get(handles.interval2_edit,'String'));
        table_idx=1;
        table_data={};
        for dataset_index=1:length(userdata.selected_datasets)
            header=datasets_header(userdata.selected_datasets(dataset_index)).header;
            [index_pos,y_pos,z_pos]=get_iyz_pos(header);
            if userdata.is_filter
                Fs=1/header.xstep;
                if userdata.is_filter_low
                    [filter_low_b,filter_low_a]=butter(userdata.filter_order,userdata.filter_low/(Fs/2),'low');
                end
                if userdata.is_filter_high
                    [filter_high_b,filter_high_a]=butter(userdata.filter_order,userdata.filter_high/(Fs/2),'high');
                end
                if userdata.is_filter_notch
                    if userdata.filter_notch==1 %50Hz
                        [filter_notch_b,filter_notch_a]=butter(userdata.filter_order,[49,51]/(Fs/2),'stop');
                    else %60Hz
                        [filter_notch_b,filter_notch_a]=butter(userdata.filter_order,[59,61]/(Fs/2),'stop');
                    end
                end
            end
            dataset_pos=userdata.selected_datasets(dataset_index);
            x_start=datasets_header(dataset_pos).header.xstart;
            x_step=datasets_header(dataset_pos).header.xstep;
            x=(0:size(datasets_data(dataset_pos).data,6)-1)*x_step+x_start;
            x_pos=find(x>x1 & x<x2);
            for epoch_index=1:length(userdata.selected_epochs)
                epoch_pos=userdata.selected_epochs(epoch_index);
                for channel_index=1:length(userdata.selected_channels)
                    channel_pos=userdata.channel_index(dataset_pos,userdata.selected_channels(channel_index));
                    y=squeeze(datasets_data(dataset_pos).data(epoch_pos,channel_pos,index_pos,z_pos,y_pos,:))';
                    if userdata.is_filter
                        if userdata.is_filter_low
                            y=filtfilt(filter_low_b,filter_low_a,y);
                        end
                        if userdata.is_filter_high
                            y=filtfilt(filter_high_b,filter_high_a,y);
                        end
                        if userdata.is_filter_notch
                            y=filtfilt(filter_notch_b,filter_notch_a,y);
                        end
                    end
                    [ymax,dx]=max(y(x_pos));
                    xmax=x(x_pos(dx));
                    [ymin,dx]=min(y(x_pos));
                    xmin=x(x_pos(dx));
                    ymean=mean(y(x_pos));
                    y1=y(x_pos(1));
                    y2=y(x_pos(end));
                    
                    table_data{table_idx,1}=userdata.str_dataset{dataset_pos};
                    table_data{table_idx,2}=userdata.str_channel{userdata.selected_channels(channel_index)};
                    table_data{table_idx,3}=num2str(epoch_pos);
                    table_data{table_idx,4}=num2str(xmax);
                    table_data{table_idx,5}=num2str(ymax);
                    table_data{table_idx,6}=num2str(xmin);
                    table_data{table_idx,7}=num2str(ymin);
                    table_data{table_idx,8}=num2str(ymean);
                    table_data{table_idx,9}=num2str(x1);
                    table_data{table_idx,10}=num2str(y1);
                    table_data{table_idx,11}=num2str(x2);
                    table_data{table_idx,12}=num2str(y2);
                    table_idx=table_idx+1;
                    
                end
            end
        end
        col_headers{1}='dataset';
        col_headers{2}='channel';
        col_headers{3}='epoch';
        col_headers{4}='xmax';
        col_headers{5}='ymax';
        col_headers{6}='xmin';
        col_headers{7}='ymin';
        col_headers{8}='ymean';
        col_headers{9}='x1';
        col_headers{10}='y1';
        col_headers{11}='x2';
        col_headers{12}='y2';
        h=figure;
        uitable(h,'Data',table_data,'ColumnName',col_headers,'Units','normalized','Position', [0 0 1 1]);
    end

%% fig_axis_Changed
    function fig_axis_Changed(~, event)
        if strcmp(get(event.Axes,'Tag'),'line')
            userdata.last_axis(1:2) = get(event.Axes,'XLim');
            userdata.last_axis(3:4) = get(event.Axes,'YLim');
            set(handles.xaxis1_edit, 'String', num2str(userdata.last_axis(1)));
            set(handles.xaxis2_edit, 'String', num2str(userdata.last_axis(2)));
            set(handles.yaxis1_edit, 'String', num2str(userdata.last_axis(3)));
            set(handles.yaxis2_edit, 'String', num2str(userdata.last_axis(4)));
            set(handles.axes,'XLim',userdata.last_axis(1:2));
            set(handles.axes,'YLim',userdata.last_axis(3:4));
            if userdata.is_shade
                fig_shade_Update();
            end
            if ~isempty(handles.axes_topo)
                for k=1:length(handles.axes_topo)
                    caxis(handles.axes_topo(k),userdata.last_axis(3:4));
                end
            end
            if ~isempty(handles.axes_headplot)
                for k=1:length(handles.axes_headplot)
                    caxis(handles.axes_headplot(k),userdata.last_axis(3:4));
                end
            end
            
            userdata.auto_x=0;set(handles.xaxis_auto_checkbox,'Value',userdata.auto_x);
            userdata.auto_y=0;set(handles.yaxis_auto_checkbox,'Value',userdata.auto_y);
        else
            set(event.Axes,'XLim',[-0.55,0.55]);
            set(event.Axes,'YLim',[-0.5,0.6]);
        end
    end

%% edit_xaxis_auto_checkbox_Changed
    function edit_xaxis_auto_checkbox_Changed(~, ~)
        userdata.auto_x=get(handles.xaxis_auto_checkbox,'Value');
        if  userdata.auto_x==1
            userdata.last_axis(1:2)=userdata.minmax_axis(1:2);
            set(handles.xaxis1_edit,'String',num2str(userdata.last_axis(1)));
            set(handles.xaxis2_edit,'String',num2str(userdata.last_axis(2)));
        end
        set(handles.axes,'XLim',userdata.last_axis(1:2));
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end

%% edit_yaxis_auto_checkbox_Changed
    function edit_yaxis_auto_checkbox_Changed(~, ~)
        userdata.auto_y=get(handles.yaxis_auto_checkbox,'Value');
        if  userdata.auto_y==1
            userdata.last_axis(3:4)=userdata.minmax_axis(3:4);
            set(handles.yaxis1_edit,'String',num2str(userdata.last_axis(3)));
            set(handles.yaxis2_edit,'String',num2str(userdata.last_axis(4)));
            if ~isempty(handles.axes_topo)
                for k=1:length(handles.axes_topo)
                    caxis(handles.axes_topo(k),userdata.last_axis(3:4));
                end
            end
            if ~isempty(handles.axes_headplot)
                for k=1:length(handles.axes_headplot)
                    caxis(handles.axes_headplot(k),userdata.last_axis(3:4));
                end
            end
        end
        set(handles.axes,'YLim',userdata.last_axis(3:4));
        for k=1:userdata.num_cols*userdata.num_rows
            zoom(handles.axes(k),'reset');
        end
    end

%% edit_cursor_Changed
    function edit_cursor_Changed(~,~)
        userdata.auto_cursor=0;
        set(handles.cursor_auto_checkbox,'Value',userdata.auto_cursor);
        userdata.cursor_point=str2num(get(handles.cursor_edit,'String'));
        fig_cursor_Update();
        fig_topo_Update();
        fig_headplot_Update();
    end

%% edit_cursor_auto_checkbox_Changed
    function edit_cursor_auto_checkbox_Changed(~,~)
        userdata.auto_cursor=get(handles.cursor_auto_checkbox,'Value');
    end

%% edit_filter_Changed
    function edit_filter_Changed(~, ~)
        if get(handles.filter_checkbox,'value')
            if userdata.is_filter==0
                if userdata.is_headplot
                    set(handles.toolbar2_headplot,'State','off');
                    userdata.is_headplot=0;
                    if ~isempty(handles.colorbar_headplot)
                        set(handles.colorbar_headplot,'Visible','off');
                        set(handles.axes_headplot,'Visible','off');
                        set(handles.title_headplot,'Visible','off');
                        set(handles.surface_headplot,'Visible','off');
                        set(handles.dot_headplot,'Visible','off');
                    end
                    fig2_SizeChangedFcn();
                end
                if userdata.is_topo
                    set(handles.toolbar2_topo,'State','off');
                    userdata.is_topo=0;
                    if ~isempty(handles.colorbar_topo)
                        set(handles.colorbar_topo,'Visible','off');
                        set(handles.axes_topo,'Visible','off');
                        set(handles.title_topo,'Visible','off');
                        set(handles.surface_topo,'Visible','off');
                        set(handles.line_topo,'Visible','off');
                        set(handles.dot_topo,'Visible','off');
                    end
                    fig2_SizeChangedFcn();
                end
            end
            userdata.is_filter=1;
            if get(handles.filter_lowpass_checkbox,'value')
                userdata.is_filter_low=1;
                userdata.filter_low=str2num(get(handles.filter_lowpass_edit,'String'));
            else
                userdata.is_filter_low=0;
            end
            if get(handles.filter_highpass_checkbox,'value')
                userdata.is_filter_high=1;
                userdata.filter_high=str2num(get(handles.filter_highpass_edit,'String'));
            else
                userdata.is_filter_high=0;
            end
            if get(handles.filter_notch_checkbox,'value')
                userdata.is_filter_notch=1;
                userdata.filter_notch=get(handles.filter_notch_checkbox,'value');
            else
                userdata.is_filter_notch=0;
            end
            userdata.filter_order=get(handles.filter_order_popup,'value');
            set_header_filter();
            set(handles.filter_lowpass_checkbox,'Enable','on');
            set(handles.filter_lowpass_edit,'Enable','on');
            set(handles.filter_highpass_checkbox,'Enable','on');
            set(handles.filter_highpass_edit,'Enable','on');
            set(handles.filter_notch_checkbox,'Enable','on');
            set(handles.filter_notch_popup,'Enable','on');
            set(handles.filter_order_text,'Enable','on');
            set(handles.filter_order_popup,'Enable','on');
        else
            userdata.is_filter=0;
            set(handles.filter_lowpass_checkbox,'Enable','off');
            set(handles.filter_lowpass_edit,'Enable','off');
            set(handles.filter_highpass_checkbox,'Enable','off');
            set(handles.filter_highpass_edit,'Enable','off');
            set(handles.filter_notch_checkbox,'Enable','off');
            set(handles.filter_notch_popup,'Enable','off');
            set(handles.filter_order_text,'Enable','off');
            set(handles.filter_order_popup,'Enable','off');
        end
        fig_line;
        edit_yaxis_auto_checkbox_Changed;
        fig_shade_Update;
        fig_cursor_Update;
    end

%% set_header_filter
    function set_header_filter()
        for k=1:length(datasets_header)
            Fs=1/datasets_header(k).header.xstep;
            if userdata.is_filter_low
                [datasets_header(k).header.filter_low_b,datasets_header(k).header.filter_low_a]=butter(userdata.filter_order,userdata.filter_low/(Fs/2),'low');
            end
            if userdata.is_filter_high
                [datasets_header(k).header.filter_high_b,datasets_header(k).header.filter_high_a]=butter(userdata.filter_order,userdata.filter_high/(Fs/2),'high');
            end
            if userdata.is_filter_notch
                if userdata.filter_notch==1 %50Hz
                    [datasets_header(k).header.filter_notch_b,datasets_header(k).header.filter_notch_a]=butter(userdata.filter_order,[48,52]/(Fs/2),'stop');
                else %60Hz
                    [datasets_header(k).header.filter_notch_b,datasets_header(k).header.filter_notch_a]=butter(userdata.filter_order,[58,62]/(Fs/2),'stop');
                end
            end
        end
    end

%% fig1_CloseReq_Callback
    function fig1_CloseReq_Callback(~, ~)
        closereq;
        if ishandle(handles.fig2)
            close(handles.fig2);
        end
    end

%% fig2_CloseReq_Callback
    function fig2_CloseReq_Callback(~, ~)
        closereq;
        if ishandle(handles.fig1)
            close(handles.fig1);
        end
    end
end