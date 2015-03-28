function [out_configuration,out_datasets] = LW_segmentation2(operation,configuration,datasets,update_pointers)
% LW_segmentation
% Segmentation relative to events
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
gui_info.function_name='LW_segmentation2';
gui_info.name='Segmentation relative to events (one file per event code)';
gui_info.description='Segment data into epochs relative to events (one file per event code).';
gui_info.parent='segmentation_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='ep';          %default filename suffix (or filename (if 'unique'))
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
        out_configuration.parameters.event_labels={};
        out_configuration.parameters.x_start=0;
        out_configuration.parameters.x_duration=1;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Segmentation (one file per event code).',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [temp_datasets,message_string]=RLW_segmentation2(datasets(setpos).header,datasets(setpos).data,configuration.parameters.event_labels,'x_start',configuration.parameters.x_start,'x_duration',configuration.parameters.x_duration);
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
            %check that temp_datasets is not empty
            if isempty(temp_datasets);
            else
                %loop through temp_datasets
                for i=1:length(temp_datasets);
                    %add configuration to history of temp_datasets
                    if isempty(temp_datasets(i).header.history);
                        temp_datasets(i).header.history(1).configuration=configuration;
                    else
                        temp_datasets(i).header.history(end+1).configuration=configuration;
                    end;
                    %update header.name
                    if strcmpi(configuration.gui_info.process_overwrite,'no');
                        temp_datasets(i).header.name=[configuration.gui_info.process_filename_string ' ' temp_datasets(i).header.name];
                    end;
                end;
                %append temp_datasets to out_datasets
                out_datasets=[out_datasets temp_datasets];
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        
        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_segmentation2('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
