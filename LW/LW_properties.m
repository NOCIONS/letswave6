function [out_configuration,out_datasets] = LW_properties(operation,configuration,datasets,update_pointers)
% LW_properties
% edit datafile properties
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
gui_info.function_name='LW_properties';
gui_info.name='Edit datafile properties';
gui_info.description='Edit datafile properties.';
gui_info.parent='edit_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='no';            %process requires data of the dataset?
gui_info.process_filename_string='prop';    %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='yes';               %process should overwrite the original dataset?

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
        if isempty(datasets);
            out_configuration.parameters.filetype='time_amplitude';
            out_configuration.parameters.xstart=0;
            out_configuration.parameters.ystart=0;
            out_configuration.parameters.zstart=0;
            out_configuration.parameters.xstep=1;
            out_configuration.parameters.ystep=1;
            out_configuration.parameters.zstep=1;
            out_configuration.parameters.change_filetype=0;
            out_configuration.parameters.change_x=0;
            out_configuration.parameters.change_y=0;
            out_configuration.parameters.change_z=0;
        else
            header=datasets(1).header;
            out_configuration.parameters.filetype=header.filetype;
            out_configuration.parameters.xstart=header.xstart;
            out_configuration.parameters.ystart=header.ystart;
            out_configuration.parameters.zstart=header.zstart;
            out_configuration.parameters.xstep=header.xstep;
            out_configuration.parameters.ystep=header.ystep;
            out_configuration.parameters.zstep=header.zstep;
            out_configuration.parameters.change_filetype=0;
            out_configuration.parameters.change_x=0;
            out_configuration.parameters.change_y=0;
            out_configuration.parameters.change_z=0;
        end;
        %datasets
        out_datasets=datasets;
        
        
        
    case 'process'
        out_datasets=datasets;
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Edit properties.',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [out_datasets(setpos).header,message_string]=RLW_properties(datasets(setpos).header,'filetype',configuration.parameters.filetype,'xstart',configuration.parameters.xstart,'ystart',configuration.parameters.ystart,'zstart',configuration.parameters.zstart,'xstep',configuration.parameters.xstep,'ystep',configuration.parameters.ystep,'zstep',configuration.parameters.zstep,'change_filetype',configuration.parameters.change_filetype,'change_x',configuration.parameters.change_x,'change_y',configuration.parameters.change_y,'change_z',configuration.parameters.change_z);
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
        [a out_configuration]=GLW_properties('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
