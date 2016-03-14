function [out_configuration,out_datasets] = LW_ICA_compute_merged(operation,configuration,datasets,update_pointers)
% LW_ICA_compute_merged
% Compute ICA matrix
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
gui_info.function_name='LW_ICA_compute_merged';
gui_info.name='Compute ICA matrix (merge datasets)';
gui_info.description='Compute one single ICA mixing/unmixing matrix for multiple datasets';
gui_info.parent='spatial_filters_menu';
gui_info.scriptable='no';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';           %process requires data of the dataset?
gui_info.process_filename_string='ica';         %default filename suffix (or filename (if 'unique'))
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
        out_configuration.parameters.num_ICs=0;             %0=square mixing matrix (or PICA); >0: constrained ICA
        out_configuration.parameters.ICA_algorithm='runica' %'runica','jader'
        out_configuration.parameters.ICA_mode='square';     %'square','fixed',or probabilistic: 'LAP','BIC','RRN','AIC','MDL';
        out_configuration.parameters.PICA_percentage=100;   %this is only used if PICA (LAP, BIC, RRN, AIC, MDL)
        out_configuration.parameters.ICA_mm=[];
        out_configuration.parameters.ICA_um=[];
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Compute ICA decomposition.',1,0); end;
        %merge datasets
        merged_data=[];
        for setpos=1:length(datasets);
            %merged_data
            merged_data=cat(1,merged_data,datasets(setpos).data);
        end;
        %merged_header
        merged_header=datasets(1).header;
        merged_header.datasize=size(merged_data);
        %process
        [matrix,message_string]=RLW_ICA_compute(merged_header,merged_data,'num_ICs',configuration.parameters.num_ICs,'ICA_algorithm',configuration.parameters.ICA_algorithm,'ICA_mode',configuration.parameters.ICA_mode,'PICA_percentage',configuration.parameters.PICA_percentage);
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
        %loop through datasets
        for setpos=1:length(datasets);
            out_datasets(setpos).data=datasets(setpos).data;
            out_datasets(setpos).header=datasets(setpos).header;
            %add matrix to configuration
            configuration.parameters.ICA_mm=matrix.ica_mm;
            configuration.parameters.ICA_um=matrix.ica_um;
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
        [a out_configuration]=GLW_ICA_compute_merged('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
