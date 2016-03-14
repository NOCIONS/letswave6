function [out_configuration,out_datasets] = LW_weighted_channel_average_template(operation,configuration,datasets,update_pointers)
% LW_weighted_channel_average_template
% Weighted channel average (create template)
%
% operations : 
% 'gui_info'
% 'default'
% 'process'
% 'configure'
%
% Author : 
% Andre Mouraux
% Institute of Neurosciences (IONS)
% Universite catholique de louvain (UCL)
% Belgium
% 
% Contact : andre.mouraux@uclouvain.be
% This function is part of Letswave 6
% See http://nocions.webnode.com/letswave for additional information
%


%argument parsing
if nargin<1;
    error('operation is a required argument');
end;
if nargin<2;
    configuration=[];
end;
if nargin<3;
    datasets=[];
end;
if nargin<4;
    update_pointers=[];
end;

%gui_info
gui_info.function_name='LW_weighted_channel_average_template';
gui_info.name='Weighted channel average (create template)';
gui_info.description='Weighted channel average (create template).';
gui_info.parent='average_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='chanavg_template';         %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='no';                %process should overwrite the original dataset?


%operation
switch operation
    
    case 'gui_info'
        %configuration
        out_configuration=configuration;
        out_configuration.gui_info=gui_info;
        %datasets
        out_datasets=datasets;
        
    case 'default'
        %configuration
        out_configuration=configuration;
        out_configuration.gui_info=gui_info;
        out_configuration.parameters.selected_channels={};
        out_configuration.parameters.template_labels={};
        out_configuration.parameters.template_weights=[];
        out_configuration.parameters.num_channels=6;
        out_configuration.parameters.x=0;
        out_configuration.parameters.y=0;
        out_configuration.parameters.z=0;
        out_configuration.parameters.epoch=1;
        out_configuration.parameters.index=1;
        out_configuration.parameters.peakdir='max';
        out_configuration.parameters.normalize=1;
        %datasets
        out_datasets=datasets;
     
    
        
    case 'process'
        out_datasets=datasets;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Weighted channel average template.',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [template_weights,template_labels,message_string]=RLW_weighted_channel_average_template(datasets(setpos).header,datasets(setpos).data,'selected_channels',configuration.parameters.selected_channels,'num_channels',configuration.parameters.num_channels,'x',configuration.parameters.x,'y',configuration.parameters.y,'z',configuration.parameters.z,'epoch',configuration.parameters.epoch,'index',configuration.parameters.index,'peakdir',configuration.parameters.peakdir,'normalize',configuration.parameters.normalize);
            %message_string
            if isempty(update_pointers);
            else
                if isempty(message_string);
                else
                    for i=1:length(message_string);
                        update_pointers.function(update_pointers.handles,message_string{i},1,0);
                    end;
                end;
            end;
            %update configuration
            configuration.parameters.template_weights=template_weights;
            configuration.parameters.template_labels=template_labels;
            %configuration
            out_configuration=configuration;
            %add configuration to history
            if isempty(out_datasets(setpos).header.history);
                out_datasets(setpos).header.history(1).configuration=configuration;
            else
                out_datasets(setpos).header.history(end+1).configuration=configuration;
            end;
            %update header.name
            if strcmpi(configuration.gui_info.process_overwrite,'no');
                out_datasets(setpos).header.name=[configuration.gui_info.process_filename_string ' ' out_datasets(setpos).header.name];
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_weighted_channel_average_template('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
