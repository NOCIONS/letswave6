function [out_configuration,out_datasets] = LW_import_MAT_variable(operation,configuration,datasets,update_pointers)
% LW_import_MAT_variable
% Import MAT variable files
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
gui_info.function_name='LW_import_MAT_variable';
gui_info.name='Import Matlab matrix';
gui_info.description='Import Matlab workspace variable or MAT file.';
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
        out_configuration.parameters.variable_names={};
        out_configuration.parameters.dimension_descriptors={'epochs','channels','Y','X'};
        out_configuration.parameters.unit='amplitude';
        out_configuration.parameters.x_unit='time';
        out_configuration.parameters.y_unit='frequency';
        out_configuration.parameters.xstart=0;
        out_configuration.parameters.ystart=0;
        out_configuration.parameters.xstep=1;
        out_configuration.parameters.ystep=1;
        %datasets
        out_datasets=datasets;
        
        
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** Import MAT variables.',1,0); end;
        %variable_names
        variable_names=configuration.parameters.variable_names;
        %no variable names? return
        if isempty(variable_names);
            return;
        end;
        %loop through variable_names
        for varpos=1:length(variable_names);
            %filename
            varname=variable_names{varpos};
            if isempty(update_pointers) else update_pointers.function(update_pointers.handles,['Loading : ' varname],1,0); end;
            %matdata
            matdata=evalin('base',varname);
            %process
            [out_datasets(varpos).header,out_datasets(varpos).data,message_string]=RLW_import_MAT_variable(matdata,'dimension_descriptors',configuration.parameters.dimension_descriptors,'unit',configuration.parameters.unit,'x_unit',configuration.parameters.x_unit,'y_unit',configuration.parameters.y_unit,'x_start',configuration.parameters.xstart,'y_start',configuration.parameters.ystart,'x_step',configuration.parameters.xstep,'y_step',configuration.parameters.ystep);
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
            out_datasets(varpos).header.history.configuration=configuration;
            %add name
            out_datasets(varpos).header.name=varname;
        end;
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'Finished.',0,1); end;

        
    case 'configure'
        %configuration
        [a out_configuration]=GLW_import_MAT_variable('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
