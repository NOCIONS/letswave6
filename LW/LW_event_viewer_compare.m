function [out_configuration,out_datasets] = LW_event_viewer_compare(operation,configuration,datasets,update_pointers)
% LW_event_viewer_compare
% event viewer compare
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
gui_info.function_name='LW_event_viewer_compare';
gui_info.name='Compare signal amplitude at event latencies in two datasets';
gui_info.description='Compare signal at event latencies in two datasets.';
gui_info.parent='stats_menu';
gui_info.scriptable='no';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='yes';      %configuration requires data of the dataset?
gui_info.save_dataset='no';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='yes';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='no';           %process requires data of the dataset?
gui_info.process_filename_string='event_edit';       %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='yes';                %process should overwrite the original dataset?

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
        out_configuration.parameters.events=[];
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=datasets;
        out_configuration=configuration;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Finished!.',0,1); end;

        
    case 'configure'
        %configuration
        GLW_event_viewer_compare('dummy',configuration,datasets);
        %datasets
        out_configuration=configuration;
        out_datasets=datasets;
end;
