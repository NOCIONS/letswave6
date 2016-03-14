function [out_configuration,out_datasets] = LW_import_MEGA(operation,configuration,datasets,update_pointers)
% LW_import_MEGA
% Import MEGA files
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
gui_info.function_name='LW_import_MEGA';
gui_info.name='Import MEGA files';
gui_info.description='Import MEGA data files.';
gui_info.parent='import_signals_menu';
gui_info.scriptable='no';                              %function can be used in scripts?
gui_info.configuration_mode='direct';                  %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no_header';      %configuration requires data of the dataset? 'yes' 'no' (no data) 'no_header' (no data, no header)
gui_info.save_dataset='yes';                            %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                            %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';            %process requires data of the dataset? 'yes' 'no' (no data) 'no_header' (no data, no header)
gui_info.process_filename_string='';                   %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='yes';                      %process should overwrite the original dataset?

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
        out_configuration.parameters.input_folder=[];
        out_configuration.parameters.session_number=1;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Import MEGA data.',1,0); end;
        %process
        [out_datasets.header out_datasets.data message_string]=RLW_import_MEGA(configuration.parameters.input_folder,configuration.parameters.session_number);
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
        %add history
        out_datasets.header.history(1).configuration=configuration;
        %
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;

        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_import_MEGA('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
