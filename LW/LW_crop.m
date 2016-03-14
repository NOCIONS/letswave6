function [out_configuration,out_datasets] = LW_crop(operation,configuration,datasets,update_pointers)
% LW_crop
% Crop signals
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
gui_info.function_name='LW_crop';
gui_info.name='Crop signals';
gui_info.description='Crop signals';
gui_info.parent='resample_signals_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='crop';        %default filename suffix (or filename (if 'unique'))
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
        out_configuration.parameters.x_crop=1;
        out_configuration.parameters.y_crop=0;
        out_configuration.parameters.z_crop=0;
        if isempty(datasets);
            out_configuration.parameters.x_start=0;
            out_configuration.parameters.x_size=0;
            out_configuration.parameters.y_start=0;
            out_configuration.parameters.y_size=0;
            out_configuration.parameters.z_start=0;
            out_configuration.parameters.z_size=0;
        else
            out_configuration.parameters.x_start=datasets(1).header.xstart;
            out_configuration.parameters.y_start=datasets(1).header.ystart;
            out_configuration.parameters.z_start=datasets(1).header.zstart;
            out_configuration.parameters.x_size=datasets(1).header.datasize(6);
            out_configuration.parameters.y_size=datasets(1).header.datasize(5);
            out_configuration.parameters.z_size=datasets(1).header.datasize(4);
        end;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Crop.',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [out_datasets(setpos).header,out_datasets(setpos).data,message_string]=RLW_crop(datasets(setpos).header,datasets(setpos).data,'x_crop',configuration.parameters.x_crop,'y_crop',configuration.parameters.y_crop,'z_crop',configuration.parameters.z_crop,'x_start',configuration.parameters.x_start,'y_start',configuration.parameters.y_start,'z_start',configuration.parameters.z_start,'x_size',configuration.parameters.x_size,'y_size',configuration.parameters.y_size,'z_size',configuration.parameters.z_size);
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
        [a out_configuration]=GLW_crop('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
