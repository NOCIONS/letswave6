function [out_configuration,out_datasets] = LW_CWT(operation,configuration,datasets,update_pointers)
% LW_CWT
% Continuous Wavelet Transform (CWT) for unsegmented data
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
gui_info.function_name='LW_CWT';
gui_info.name='Continuous Wavelet Transform (CWT)';
gui_info.description='Compute the Continuous Wavelet Transform (CWT) for unsegmented data (avoids border effects).';
gui_info.parent='frequency_transforms_menu';
gui_info.scriptable='yes';                      %function can be used in scripts?
gui_info.configuration_mode='direct';           %configuration GUI run in 'direct' 'script' 'history' mode?
gui_info.configuration_requires_data='no';      %configuration requires data of the dataset?
gui_info.save_dataset='yes';                    %process requires to save dataset? 'yes', 'no', 'unique'
gui_info.process_none='no';                     %for functions which have nothing to process (e.g. visualisation functions)
gui_info.process_requires_data='yes';            %process requires data of the dataset?
gui_info.process_filename_string='cwt';     %default filename suffix (or filename (if 'unique'))
gui_info.process_overwrite='no';               %process should overwrite the original dataset?

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
        %'cmor1-1.5','cmor1-1','cmor1-0.5','cmor1-0.1','fbsp1-1-1.5','fbsp1-1-1','fbsp1-1-0.5','fbsp2-1-1','fbsp2-1-0.5','fbsp2-1-0.1','shan1-1.5','shan1-1','shan1-0.5','shan1-0.1','shan2-3','cgau1','cgau2','cgau3','cgau4','cgau5'
        out_configuration.parameters.wavelet_name='cmor1-1.5';
        out_configuration.parameters.low_frequency=1;
        out_configuration.parameters.high_frequency=30;
        out_configuration.parameters.num_frequency_lines=100;
        out_configuration.parameters.segment_data=0;
        out_configuration.parameters.event_name=[];
        out_configuration.parameters.x_start=-0.5;
        out_configuration.parameters.x_end=1;
        %'amplitude','power','phase','complex'
        out_configuration.parameters.output='amplitude';
        out_configuration.parameters.average_epochs=1;
        %datasets
        out_datasets=datasets;
        
    case 'process'
        out_datasets=[];
        %configuration
        out_configuration=configuration;
        %handles feedback
        if isempty(update_pointers) else update_pointers.function(update_pointers.handles,'*** CWT (fast).',1,0); end;
        %datasets
        for setpos=1:length(datasets);
            %process
            [out_datasets(setpos).header,out_datasets(setpos).data,message_string]=RLW_CWT(datasets(setpos).header,datasets(setpos).data,'wavelet_name',configuration.parameters.wavelet_name,'low_frequency',configuration.parameters.low_frequency,'high_frequency',configuration.parameters.high_frequency,'num_frequency_lines',configuration.parameters.num_frequency_lines,'segment_data',configuration.parameters.segment_data,'event_name',configuration.parameters.event_name,'x_start',configuration.parameters.x_start,'x_end',configuration.parameters.x_end,'output',configuration.parameters.output,'average_epochs',configuration.parameters.average_epochs);
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
        [a out_configuration]=GLW_CWT('dummy',configuration,datasets);
        %datasets
        out_datasets=datasets;
end;
