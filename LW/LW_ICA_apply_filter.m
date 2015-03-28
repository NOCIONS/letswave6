function [out_configuration,out_datasets] = LW_ICA_apply_filter(operation,configuration,datasets,update_pointers)
% LW_ICA_apply filter
% ICA apply filter
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
gui_info.function_name='LW_ICA_apply_filter';
gui_info.name='ICA apply spatial filter';
gui_info.description='Apply spatial filter using a selection of ICs';
gui_info.parent='spatial_filters_menu';
gui_info.scriptable='no';                       %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='yes';     %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='icfilt';      %default filename suffix (or filename (if 'unique'))
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
        out_configuration.parameters.ICA_mm=[];       %if empty, will search history for an existing mixing matrix (default)
        out_configuration.parameters.ICA_um=[];       %if empty, will search history for an existing unmixing matrix (default)
        out_configuration.parameters.IC_list=[];      %list of ICs to use when remixing
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Baseline correction.',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %mixing and unmixing matrix
            if isempty(configuration.parameters.ICA_um);
                update_pointers.function(update_pointers.handles,'Searching for an ICA matrix.',1,0);
                %search history for an unmixing matrix
                for i=1:length(datasets(setpos).header.history);
                    switch datasets(setpos).header.history(i).configuration.gui_info.function_name
                        case 'LW_ICA_compute';
                            %ICA_um
                            ICA_um=datasets(setpos).header.history(i).configuration.parameters.ICA_um;
                            %ICA_mm
                            ICA_mm=datasets(setpos).header.history(i).configuration.parameters.ICA_mm;
                        case 'LW_ICA_compute_merged';
                            %ICA_um
                            ICA_um=datasets(setpos).header.history(i).configuration.parameters.ICA_um;
                            %ICA_mm
                            ICA_mm=datasets(setpos).header.history(i).configuration.parameters.ICA_mm;
                        case 'LW_ICA_assign';
                            %ICA_um
                            ICA_um=datasets(setpos).header.history(i).configuration.parameters.ICA_um;
                            %ICA_mm
                            ICA_mm=datasets(setpos).header.history(i).configuration.parameters.ICA_mm;
                    end;
                end;
                %store ICA_um and ICA_mm in configuration
                out_configuration.ICA_um=ICA_um;
                out_configuration.ICA_mm=ICA_mm;
            else
                ICA_um=configuration.parameters.ICA_um;
                ICA_mm=configuration.parameters.ICA_mm;
            end;
            %IC_list
            IC_list=configuration.parameters.IC_list;
            %process
            [out_datasets(setpos).header,out_datasets(setpos).data,message_string]=RLW_ICA_apply_filter(datasets(setpos).header,datasets(setpos).data,ICA_mm,ICA_um,IC_list);
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
                out_datasets(setpos).header.history(1).configuration=out_configuration;
            else
                out_datasets(setpos).header.history(end+1).configuration=out_configuration;
            end;
            %update header.name
            if strcmpi(configuration.gui_info.process_overwrite,'no');
                out_datasets(setpos).header.name=[configuration.gui_info.process_filename_string ' ' out_datasets(setpos).header.name];
            end;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;
        
        

        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_ICA_apply_filter('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
